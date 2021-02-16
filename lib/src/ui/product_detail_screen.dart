import 'package:ecom/src/common/providers/cart_provider.dart';
import 'package:ecom/src/common/widgets/badge.dart';
import 'package:ecom/src/ui/cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ecom/src/common/providers/products_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  // final String title;
  // final double price;

  // const ProductDetailScreen(this.title, this.price);

  static const routeName = '/product-detail';

  @override
  Widget build(BuildContext context) {
    final productId =
        ModalRoute.of(context).settings.arguments as String; // is the id

    final loadedProduct = Provider.of<ProductsProvider>(
      context,
      listen: false,
    ).findById(productId);

    final cart = Provider.of<CartProvider>(context, listen: false);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(loadedProduct.title),
          actions: <Widget>[
            Consumer<CartProvider>(
              builder: (_, cart, ch) => Badge(
                child: ch,
                value: cart.itemCount.toString(),
              ),
              child: IconButton(
                icon: Icon(Icons.shopping_cart),
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
              Container(
                height: 300,
                width: double.infinity,
                child: Image.network(
                  loadedProduct.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(
                    '\INR ${loadedProduct.price}',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 20,
                    ),
                  ),
                  FlatButton(
                    color: Colors.black,
                    textColor: Colors.white,
                    child: Row(
                      children: <Widget>[
                        Text('Add to cart'),
                        Icon(
                          Icons.shopping_cart,
                          color: Theme.of(context).accentColor,
                        ),
                      ],
                    ),
                    onPressed: () {
                      cart.addItem(loadedProduct.id, loadedProduct.price,
                          loadedProduct.title);
                    },
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  loadedProduct.description,
                  textAlign: TextAlign.center,
                  softWrap: true,
                  // style: TextStyle(
                  //   color: Colors.grey,
                  //   fontSize: 20,
                  // ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
