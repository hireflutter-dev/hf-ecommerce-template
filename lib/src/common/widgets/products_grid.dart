import 'package:ecom/src/common/providers/individual_product_provider.dart';
import 'package:ecom/src/common/providers/products_provider.dart';
import 'package:ecom/src/common/widgets/product_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductsGrid extends StatelessWidget {
  const ProductsGrid({this.showFavs});

  final bool showFavs;

  @override
  Widget build(BuildContext context) {
    final ProductsProvider productsData =
        Provider.of<ProductsProvider>(context);
    final List<IndividualProduct> products =
        showFavs ? productsData.favoriteItems : productsData.items;

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: products.length,
      itemBuilder: (BuildContext context, int i) =>
          ChangeNotifierProvider<IndividualProduct>.value(
        // create: (c) => products[i],
        value: products[i],
        child: ProductItem(
            // products[i].id,
            // products[i].title,
            // products[i].imageUrl,
            ),
      ),
    );
  }
}
