import 'package:ecom/src/common/providers/auth_provider.dart';
import 'package:ecom/src/common/providers/cart_provider.dart';
import 'package:ecom/src/common/providers/individual_product_provider.dart';

import 'package:flutter/material.dart';
import 'package:ecom/src/ui/product_detail_screen.dart';
import 'package:provider/provider.dart';

class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final IndividualProduct product = Provider.of<IndividualProduct>(context);
    final CartProvider cart = Provider.of<CartProvider>(context);
    final AuthProvider authData = Provider.of<AuthProvider>(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        header: Consumer<IndividualProduct>(
          builder: (BuildContext context, IndividualProduct product, _) =>
              GridTileBar(
            leading: IconButton(
              icon: Icon(
                product.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: Theme.of(context).accentColor,
              ),
              onPressed: () {
                product.toggleFavoriteStatus(authData.token, authData.userId);
              },
            ),
          ),
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.shopping_cart,
              color: Theme.of(context).accentColor,
            ),
            onPressed: () {
              cart.addItem(product.id, product.price, product.title);
              Scaffold.of(context).hideCurrentSnackBar();
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Added item to cart'),
                  duration: const Duration(seconds: 2),
                  action: SnackBarAction(
                    label: 'UNDO',
                    onPressed: () {
                      cart.removeSingleItem(product.id);
                    },
                  ),
                ),
              );
            },
          ),
        ),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              ProductDetailScreen.routeName,
              arguments: product.id,
            );
          },
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
