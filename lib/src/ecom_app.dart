import 'package:ecom/src/common/providers/auth_provider.dart';
import 'package:ecom/src/common/providers/cart_provider.dart';
import 'package:ecom/src/common/providers/individual_product_provider.dart';
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
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'ui/product_detail_screen.dart';

class EcomApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: <SingleChildWidget>[
        ChangeNotifierProvider<AuthProvider>(
          create: (BuildContext context) => AuthProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ProductsProvider>(
          update: (BuildContext context, AuthProvider auth,
                  ProductsProvider previousProducts) =>
              ProductsProvider(
            auth.token,
            auth.userId,
            previousProducts == null
                ? <IndividualProduct>[]
                : previousProducts.items,
          ),
          create: (_) => ProductsProvider('', '', <IndividualProduct>[]),
        ),
        ChangeNotifierProvider<CartProvider>(
          create: (BuildContext context) => CartProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, OrdersProvider>(
          update: (BuildContext context, AuthProvider auth,
                  OrdersProvider previousOrders) =>
              OrdersProvider(
            auth.token,
            auth.userId,
            previousOrders == null ? <OrderItem>[] : previousOrders.orders,
          ),
          create: (_) => OrdersProvider('', '', <OrderItem>[]),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (BuildContext context, AuthProvider auth, _) => MaterialApp(
          title: 'eCom',
          theme: ThemeData(
            primarySwatch: Colors.purple,
            accentColor: Colors.deepOrange,
            fontFamily: 'Lato',
          ),
          home: auth.isAuth
              ? HomeScreen()
              : FutureBuilder<bool>(
                  future: auth.tryAutoLogin(),
                  builder: (BuildContext context,
                          AsyncSnapshot<bool> authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                ),
          routes: <String, WidgetBuilder>{
            ProductDetailScreen.routeName: (BuildContext context) =>
                ProductDetailScreen(),
            CartScreen.routeName: (BuildContext context) => CartScreen(),
            OrdersScreen.routeName: (BuildContext context) => OrdersScreen(),
            UserProductsScreen.routeName: (BuildContext context) =>
                UserProductsScreen(),
            EditProductScreen.routeName: (BuildContext context) =>
                EditProductScreen(),
          },
        ),
      ),
    );
  }
}
