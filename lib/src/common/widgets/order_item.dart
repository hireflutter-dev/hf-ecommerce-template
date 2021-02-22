import 'package:ecom/src/common/providers/cart_provider.dart';
import 'package:ecom/src/common/providers/orders_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderItemWidget extends StatefulWidget {
  const OrderItemWidget(this.order);

  final OrderItem order;

  @override
  _OrderItemWidgetState createState() => _OrderItemWidgetState();
}

class _OrderItemWidgetState extends State<OrderItemWidget> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text('INR ${widget.order.amount}'),
            subtitle: Text(
              DateFormat('dd/MM/yyyy hh:mm').format(widget.order.dateTime),
            ),
            trailing: IconButton(
              icon: Icon(
                _expanded ? Icons.expand_less : Icons.expand_more,
              ),
              onPressed: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
            ),
          ),
          if (_expanded)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
              // height: min(widget.order.products.length * 20.0 + 20, 180),
              child: ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: widget.order.products
                    .map(
                      (CartItem prod) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            prod.title,
                            style: const TextStyle(
                              // fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '${prod.quantity}x INR ${prod.price}',
                                style: const TextStyle(
                                  // fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}
