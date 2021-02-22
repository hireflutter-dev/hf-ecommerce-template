import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class IndividualProduct extends ChangeNotifier {
  IndividualProduct({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
    // this.authToken,
  });

  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;
  // final String authToken;

  void _setFavValue(bool newValue) {
    isFavorite = newValue;
    notifyListeners();
  }

  Future<void> toggleFavoriteStatus(String token, String userId) async {
    final bool oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();

    final String url =
        'https://ecomproject-daeb7.firebaseio.com/userFavorites/$userId/$id.json?auth=$token';

    try {
      final http.Response response = await http.put(
        url,
        body: json.encode(
          isFavorite,
        ),
      );
      if (response.statusCode >= 400) {
        _setFavValue(oldStatus);
      }
    } catch (error) {
      _setFavValue(oldStatus);
      // throw error;
    }
  }
}
