import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/http_exception.dart';

class AuthProvider extends ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String get userId {
    return _userId;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final String url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=' +
            'AIzaSyBTzzbcgD6hB2fji1AQxe8h1LP7WVAAHWU';
    try {
      final http.Response response = await http.post(
        url,
        body: json.encode(
          <String, dynamic>{
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      final dynamic responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message'] as String);
      }
      _token = responseData['idToken'] as String;
      _userId = responseData['localId'] as String;
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData['expiresIn'] as String,
          ),
        ),
      );
      _autoLogout();
      notifyListeners();
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String userData = json.encode(
        <String, String>{
          'token': _token,
          'userId': _userId,
          'expiryDate': _expiryDate.toIso8601String(),
        },
      );
      prefs.setString('userData', userData);
    } catch (error) {
      return error;
    }
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  Future<bool> tryAutoLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final Map<String, dynamic> extractedUserData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    final DateTime expiryDate =
        DateTime.parse(extractedUserData['expiryDate'] as String);

    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedUserData['token'] as String;
    _userId = extractedUserData['userId'] as String;
    _expiryDate = expiryDate;
    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.remove('userData');
    prefs.clear();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final int timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
