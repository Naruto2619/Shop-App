import 'package:flutter/material.dart';
import './Screens/User_products_screen.dart';
import 'package:provider/provider.dart';
import './Screens/products_overview_screen.dart';
import './Screens/product_detail_screen.dart';
import './providers/products.dart';
import './providers/cart.dart';
import './Screens/cart_screen.dart';
import './providers/order.dart';
import './Screens/orders_screen.dart';
import './Screens/User_products_screen.dart';
import './Screens/edit_product_screen.dart';
import './Screens/auth_screen.dart';
import './providers/auth.dart';
import 'Screens/splash_screen.dart';
import './helpers/custom_route.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          create: null,
          update: (ctx, auth, prevprod) => Products(
              auth.userid, auth.token, prevprod == null ? [] : prevprod.items),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: null,
          update: (ctx, auth, prevord) => Orders(
              auth.token, prevord == null ? [] : prevord.orders, auth.userid),
        )
      ],
      child: Consumer<Auth>(
          builder: (ctx, auth, child) => MaterialApp(
                title: 'MyShop',
                theme: ThemeData(
                    fontFamily: 'Lato',
                    primarySwatch: Colors.purple,
                    accentColor: Colors.deepOrange,
                    pageTransitionsTheme: PageTransitionsTheme(builders: {
                      TargetPlatform.android: CustomPageTransitionBuilder(),
                    })),
                home: auth.isAuth
                    ? ProductsOverviewScreen()
                    : FutureBuilder(
                        future: auth.tryAutoLogin(),
                        builder: (ctx, snapshot) =>
                            snapshot.connectionState == ConnectionState.waiting
                                ? SplashScreen()
                                : AuthScreen(),
                      ),
                routes: {
                  CartScreen.routename: (ctx) => CartScreen(),
                  ProductDetailScreen.routename: (ctx) => ProductDetailScreen(),
                  OrdersScreen.routename: (ctx) => OrdersScreen(),
                  UserProductsScreen.routename: (ctx) => UserProductsScreen(),
                  EditProductScreen.routename: (ctx) => EditProductScreen(),
                },
              )),
    );
  }
}
