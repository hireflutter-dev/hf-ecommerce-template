import 'package:ecom/src/common/providers/cart_provider.dart';
import 'package:ecom/src/common/providers/individual_product_provider.dart';
import 'package:ecom/src/common/widgets/badge.dart';
import 'package:ecom/src/ui/cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ecom/src/common/providers/products_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  static const String routeName = '/product-detail';

  @override
  Widget build(BuildContext context) {
    final String productId =
        ModalRoute.of(context).settings.arguments as String; // is the id

    final IndividualProduct loadedProduct = Provider.of<ProductsProvider>(
      context,
      listen: false,
    ).findById(productId);

    final CartProvider cart = Provider.of<CartProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(loadedProduct.title),
        actions: <Widget>[
          Consumer<CartProvider>(
            builder: (_, CartProvider cart, Widget ch) => Badge(
              value: cart.itemCount.toString(),
              child: ch,
            ),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 300,
              width: double.infinity,
              child: Image.network(
                loadedProduct.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text(
                  'INR ${loadedProduct.price}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 20,
                  ),
                ),
                FlatButton(
                  color: Colors.black,
                  textColor: Colors.white,
                  onPressed: () {
                    cart.addItem(loadedProduct.id, loadedProduct.price,
                        loadedProduct.title);
                  },
                  child: Row(
                    children: <Widget>[
                      const Text('Add to cart'),
                      Icon(
                        Icons.shopping_cart,
                        color: Theme.of(context).accentColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                loadedProduct.description,
                textAlign: TextAlign.center,
                softWrap: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
