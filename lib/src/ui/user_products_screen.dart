import 'package:ecom/src/common/providers/products_provider.dart';
import 'package:ecom/src/common/widgets/app_drawer.dart';
import 'package:ecom/src/common/widgets/user_product_item.dart';
import 'package:ecom/src/ui/edit_product_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserProductsScreen extends StatelessWidget {
  static const String routeName = '/userProductsScreen';

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<ProductsProvider>(context, listen: false)
        .fetchAndSetProducts(filterByUser: true);
  }

  @override
  Widget build(BuildContext context) {
    // final _productsData = Provider.of<ProductsProvider>(context);

    return Scaffold(
      // drawer: AppDrawer(),
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
          ),
        ],
      ),
      body: FutureBuilder<void>(
        future: _refreshProducts(context),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => _refreshProducts(context),
                    child: Consumer<ProductsProvider>(
                      builder: (BuildContext context,
                              ProductsProvider productsData, _) =>
                          Padding(
                        padding: const EdgeInsets.all(8),
                        child: ListView.builder(
                          itemCount: productsData.items.length,
                          itemBuilder: (_, int i) => Column(
                            children: <Widget>[
                              UserProductItem(
                                productsData.items[i].id,
                                productsData.items[i].title,
                                productsData.items[i].imageUrl,
                              ),
                              const Divider(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
