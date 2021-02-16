import 'package:http/http.dart' as http;
import 'dart:convert';

class RestAPI {
  Map<String, String> header;
  var payload;
  String urlSegment;

  String server = 'https://ecom-de420.firebaseio.com/';

  String uri;
  RestAPI(Map<String, String> header, var payload, String uri) {
    this.header = header;
    this.payload = payload;
    this.uri = server + uri;
  }

  postData() async {
    print("In postData " + this.payload.toString() + " Uri " + uri);
    var response;
    try {
      response = await http
          .post(this.uri, headers: this.header, body: this.payload)
          .then((response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");
        return response;
      });
    } catch (e) {
      print(e.toString());
    }
    //print('Response status:' + response.body);
    var body = json.decode(response.body);
    return body;
  }

  getData() async {
    print("Here in get data");
    var response =
        await http.get(this.uri, headers: this.header).then((response) {
      //print("Response status: ${response.statusCode}");
      //print("Response body: ${response.body}");
      return response;
    });
    //print('Response status:' + response.body);
    var body = json.decode(response.body);
    return body;
  }

  getFile() async {
    var response =
        await http.get(this.uri, headers: this.header).then((response) {
      //print("Response status: ${response.statusCode}");
      //print("Response body: ${response.body}");
      return response;
    });
    //print('Response status:' + response.body);

    return response.bodyBytes;
  }

  deleteData() async {
    var response =
        await http.delete(this.uri, headers: this.header).then((response) {
      //print("Response status: ${response.statusCode}");
      //print("Response body: ${response.body}");
      return response;
    });
    //print('Response status:' + response.body);

    return response.bodyBytes;
  }
}
