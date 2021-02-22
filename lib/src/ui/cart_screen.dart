import 'package:ecom/src/common/providers/cart_provider.dart';
import 'package:ecom/src/common/providers/orders_provider.dart';
import 'package:ecom/src/common/widgets/cart_item.dart';
import 'package:ecom/src/ui/orders_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  static const String routeName = '/cartScreen';
  @override
  Widget build(BuildContext context) {
    final CartProvider cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
      ),
      body: Column(
        children: <Widget>[
          Card(
            margin: const EdgeInsets.all(10),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text(
                    'Total',
                    style: TextStyle(fontSize: 20),
                  ),
                  const Spacer(),
                  Chip(
                    label: Text('INR ${cart.totalAmount.toStringAsFixed(2)}'),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  OrderNowButton(cart: cart),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemBuilder: (BuildContext context, int i) => CartItemWidget(
                cart.items.values.toList()[i].id,
                cart.items.keys.toList()[i],
                cart.items.values.toList()[i].price,
                cart.items.values.toList()[i].quantity,
                cart.items.values.toList()[i].title,
              ),
              itemCount: cart.itemCount,
            ),
          ),
        ],
      ),
    );
  }
}

class OrderNowButton extends StatefulWidget {
  const OrderNowButton({
    Key key,
    @required this.cart,
  }) : super(key: key);

  final CartProvider cart;

  @override
  _OrderNowButtonState createState() => _OrderNowButtonState();
}

class _OrderNowButtonState extends State<OrderNowButton> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: (widget.cart.totalAmount <= 0 || _isLoading)
          ? null
          : () async {
              setState(() {
                _isLoading = true;
              });

              await Provider.of<OrdersProvider>(context, listen: false)
                  .addOrder(
                widget.cart.items.values.toList(),
                widget.cart.totalAmount,
              )
                  .then((String value) {
                if (value == 'success') {
                  widget.cart.clearCart();

                  Navigator.of(context).pushNamed(OrdersScreen.routeName);
                }
              });

              setState(() {
                _isLoading = false;
              });
            },
      textColor: Theme.of(context).primaryColor,
      child: _isLoading
          ? const CircularProgressIndicator()
          : const Text(
              'Order Now',
            ),
    );
  }
}
