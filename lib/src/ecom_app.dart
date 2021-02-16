import 'package:ecom/src/common/providers/auth_provider.dart';
import 'package:ecom/src/common/providers/cart_provider.dart';
import 'package:ecom/src/common/providers/orders_provider.dart';
import 'package:ecom/src/common/providers/products_provider.dart';
import 'package:ecom/src/ui/auth_screen.dart';
import 'package:ecom/src/ui/cart_screen.dart';
import 'package:ecom/src/ui/edit_product_screen.dart';
import 'package:ecom/src/ui/home_screen.dart';
import 'package:ecom/src/ui/orders_screen.dart';
import 'package:ecom/src/ui/splash_screen.dart';
import 'package:ecom/src/ui/user_products_screen.dart';
import 'package:flutter/material.dart';
import 'ui/product_detail_screen.dart';

import 'package:provider/provider.dart';

class EcomApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => AuthProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ProductsProvider>(
          update: (ctx, auth, previousProducts) => ProductsProvider(
            auth.token,
            auth.userId,
            previousProducts == null ? [] : previousProducts.items,
          ),
          create: (_) => ProductsProvider('', '', []),
        ),
        ChangeNotifierProvider(
          create: (ctx) => CartProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, OrdersProvider>(
          update: (ctx, auth, previousOrders) => OrdersProvider(
            auth.token,
            auth.userId,
            previousOrders == null ? [] : previousOrders.orders,
          ),
          create: (_) => OrdersProvider('', '', []),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'eCom',
          theme: ThemeData(
            primarySwatch: Colors.purple,
            accentColor: Colors.deepOrange,
            fontFamily: 'Lato',
          ),
          home: auth.isAuth
              ? HomeScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                ),
          routes: {
            ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
            CartScreen.routeName: (ctx) => CartScreen(),
            OrdersScreen.routeName: (ctx) => OrdersScreen(),
            UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
            EditProductScreen.routeName: (ctx) => EditProductScreen(),
          },
        ),
      ),
    );
  }
}
