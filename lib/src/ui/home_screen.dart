import 'package:ecom/src/common/providers/cart_provider.dart';
import 'package:ecom/src/common/providers/products_provider.dart';
import 'package:ecom/src/common/widgets/app_drawer.dart';
// import 'package:ecom/src/common/providers/products_provider.dart';
import 'package:ecom/src/common/widgets/badge.dart';
import 'package:ecom/src/common/widgets/products_grid.dart';
import 'package:ecom/src/ui/cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

enum FilterOptions {
  favorites,
  all,
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showFavoritesOnly = false;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    getDate();
  }

  Future<void> getDate() async {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductsProvider>(context, listen: false)
          .fetchAndSetProducts()
          .then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    });
  }

  // @override
  // void didChangeDependencies() {
  //   if (_isInit) {
  //     setState(() {
  //       _isLoading = true;
  //     });
  //   }
  //   _isInit = false;

  //   super.didChangeDependencies();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: const Text('Store'),
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
          PopupMenuButton<FilterOptions>(
            onSelected: (FilterOptions selectedValue) {
              setState(() {
                if (selectedValue == FilterOptions.favorites) {
                  _showFavoritesOnly = true;
                } else {
                  _showFavoritesOnly = false;
                }
              });
            },
            icon: const Icon(Icons.filter_list),
            itemBuilder: (_) => <PopupMenuItem<FilterOptions>>[
              const PopupMenuItem<FilterOptions>(
                value: FilterOptions.favorites,
                child: Text('Only favorites'),
              ),
              const PopupMenuItem<FilterOptions>(
                value: FilterOptions.all,
                child: Text('Show all'),
              ),
            ],
          ),
        ],
      ),
      body: ProductsGrid(showFavs: _showFavoritesOnly),
    );
  }
}
