import 'dart:convert';
import 'package:ecom/src/common/providers/cart_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });

  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;
}

class OrdersProvider extends ChangeNotifier {
  OrdersProvider(this.authToken, this.userId, this._orders);

  final String authToken;
  final String userId;

  List<OrderItem> _orders = <OrderItem>[];

  List<OrderItem> get orders {
    return <OrderItem>[..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final String url =
        'https://ecomproject-daeb7.firebaseio.com/orders/$userId.json?auth=$authToken';

    final http.Response response = await http.get(url);
    final List<OrderItem> loadedOrders = <OrderItem>[];
    final Map<String, dynamic> extractedData =
        json.decode(response.body) as Map<String, dynamic>;
    if (extractedData == null) {
      return;
    }

    extractedData.forEach((String orderId, dynamic ordersData) {
      loadedOrders.add(
        OrderItem(
          id: orderId,
          amount: ordersData['amount'] as double,
          dateTime: DateTime.parse(ordersData['dateTime'] as String),
          products: (ordersData['products'] as List<dynamic>)
              .map(
                (dynamic item) => CartItem(
                  id: item['id'] as String,
                  price: item['price'] as double,
                  quantity: item['quantity'] as int,
                  title: item['title'] as String,
                ),
              )
              .toList(),
        ),
      );
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  //error handling TBD

  Future<String> addOrder(List<CartItem> cartProducts, double total) async {
    final String url =
        'https://ecomproject-daeb7.firebaseio.com/orders/$userId.json?auth=$authToken';

    final DateTime timestamp = DateTime.now();

    try {
      final http.Response response = await http.post(
        url,
        body: json.encode(
          <String, dynamic>{
            'amount': total,
            'dateTime': timestamp.toIso8601String(),
            'products': cartProducts
                .map((CartItem cp) => <String, dynamic>{
                      'id': cp.id,
                      'title': cp.title,
                      'quantity': cp.quantity,
                      'price': cp.price,
                    })
                .toList(),
          },
        ),
      );

      _orders.insert(
        0,
        OrderItem(
          id: json.decode(response.body)['name'] as String,
          amount: total,
          products: cartProducts,
          dateTime: timestamp,
        ),
      );

      notifyListeners();
      return 'success';
    } catch (error) {
      return 'failed';
    }
  }
}
