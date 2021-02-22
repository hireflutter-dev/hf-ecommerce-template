import 'package:ecom/src/common/providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartItemWidget extends StatelessWidget {
  const CartItemWidget(
      this.cartItemId, this.productId, this.price, this.quantity, this.title);

  final String cartItemId;
  final String productId;
  final double price;
  final int quantity;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey<String>(cartItemId),
      background: Container(
        color: Theme.of(context).errorColor,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (DismissDirection direction) {
        // return Future.value(true);
        return showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Are you sure?'),
            content:
                const Text('Do you want to delete this item from the cart'),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text('No'),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text('Yes'),
              ),
            ],
          ),
        );
      },
      onDismissed: (DismissDirection direction) {
        Provider.of<CartProvider>(context, listen: false).removeItem(productId);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
        child: ListTile(
          leading: CircleAvatar(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: FittedBox(child: Text('INR$price')),
            ),
          ),
          title: Text(title),
          subtitle: Text('Total: INR ${quantity * price}'),
          trailing: Text('$quantity x'),
        ),
      ),
    );
  }
}
