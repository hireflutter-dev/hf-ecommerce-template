import 'dart:convert';
import 'package:http/http.dart' as http;

class RestAPI {
  RestAPI(Map<String, String> header, dynamic payload, String uri) {
    header = header;
    payload = payload;
    uri = server + uri;
  }

  Map<String, String> header;
  dynamic payload;
  String urlSegment;
  String server = 'https://ecom-de420.firebaseio.com/';
  String uri;

  Future<dynamic> postData() async {
    try {
      final http.Response response =
          await http.post(uri, headers: header, body: payload);
      final dynamic body = json.decode(response.body);
      return body;
    } catch (e) {
      return 'Something went wrong';
    }
  }

  Future<dynamic> getData() async {
    final http.Response response = await http.get(uri, headers: header);
    final dynamic body = json.decode(response.body);
    return body;
  }

  Future<void> getFile() async {
    final http.Response response = await http.get(uri, headers: header);
    return response.bodyBytes;
  }

  Future<dynamic> deleteData() async {
    final http.Response response = await http.delete(uri, headers: header);
    return response.bodyBytes;
  }
}
