import 'dart:convert';
import 'package:ecom/src/common/providers/cart_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class OrdersProvider with ChangeNotifier {
  final String authToken;
  final String userId;

  List<OrderItem> _orders = [];

  OrdersProvider(this.authToken, this.userId, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url = 'https://ecomproject-daeb7.firebaseio.com/' +
        'orders/' +
        userId +
        '.json' +
        '?auth=' +
        authToken;

    final response = await http.get(url);
    final List<OrderItem> loadedOrders = [];
    print(json.decode(response.body));
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData == null) {
      return;
    }

    print('Extracted order data: $extractedData');

    try {
      extractedData.forEach((orderId, ordersData) {
        loadedOrders.add(
          OrderItem(
            id: orderId,
            amount: ordersData['amount'],
            dateTime: DateTime.parse(ordersData['dateTime']),
            products: (ordersData['products'] as List<dynamic>)
                .map(
                  (item) => CartItem(
                    id: item['id'],
                    price: item['price'],
                    quantity: item['quantity'],
                    title: item['title'],
                  ),
                )
                .toList(),
          ),
        );
      });
      _orders = loadedOrders.reversed.toList();
      notifyListeners();
    } catch (error) {
      print(error);
    }
  }

  //error handling TBD

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = 'https://ecomproject-daeb7.firebaseio.com/' +
        'orders/' +
        userId +
        '.json' +
        '?auth=' +
        authToken;

    final timestamp = DateTime.now();

    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'amount': total,
            'dateTime': timestamp.toIso8601String(),
            'products': cartProducts
                .map((cp) => {
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
          id: json.decode(response.body)['name'],
          amount: total,
          products: cartProducts,
          dateTime: timestamp,
        ),
      );
      print('Adding product: ${json.decode(response.body)['name']}');
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }
}
