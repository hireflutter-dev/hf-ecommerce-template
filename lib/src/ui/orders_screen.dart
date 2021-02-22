import 'package:ecom/src/common/providers/orders_provider.dart';
import 'package:ecom/src/common/widgets/order_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrdersScreen extends StatelessWidget {
  static const String routeName = '/orderScreen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // drawer: AppDrawer(),
      appBar: AppBar(
        title: const Text('Your Orders'),
      ),
      body: FutureBuilder<dynamic>(
        future: Provider.of<OrdersProvider>(context, listen: false)
            .fetchAndSetOrders(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (dataSnapshot.error != null) {
              // ...
              // Do error handling stuff
              return const Center(
                child: Text('An error occurred!'),
              );
            } else {
              return Consumer<OrdersProvider>(
                builder: (BuildContext context, OrdersProvider orderData, _) =>
                    ListView.builder(
                  itemCount: orderData.orders.length,
                  itemBuilder: (BuildContext context, int i) =>
                      OrderItemWidget(orderData.orders[i]),
                ),
              );
            }
          }
        },
      ),
    );
  }
}
