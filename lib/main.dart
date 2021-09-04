import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './screens/splash_screen.dart';
import './providers/auth.dart';
import './screens/edit_product_screen.dart';
import './screens/auth_screen.dart';
import './screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';
import './screens/cart_screen.dart';
import './providers/products.dart';
import './providers/cart.dart';
import './providers/orders.dart';
import './screens/order_screeen.dart';
import './screens/user_product_screen.dart';

void main() => runApp(MyApp());

// test@gmail.com
// passsword123
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (BuildContext context) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (context) {
            final authinit = Provider.of<Auth>(context, listen: false);
            return Products(authinit.token.toString(), authinit.userId, []);
          },
          update: (ctx, auth, previousProducts) => Products(
            auth.token.toString(),
            auth.userId,
            previousProducts == null ? [] : previousProducts.items,
          ),
        ),
        ChangeNotifierProvider(
          create: (BuildContext context) => Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Order>(
          create: (context) {
            final authinit = Provider.of<Auth>(context, listen: false);
            return Order(authinit.token.toString(), authinit.userId, []);
          },
          update: (ctx, auth, previuosOrders) => Order(
            auth.token.toString(),
            auth.userId,
            previuosOrders == null ? [] : previuosOrders.orders,
          ),
        ),
      ],
      child: Consumer<Auth>(
        builder: (context, auth, _) {
          return MaterialApp(
              title: 'MyShop',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                fontFamily: 'Lato',
                colorScheme:
                    ColorScheme.fromSwatch(primarySwatch: Colors.purple)
                        .copyWith(secondary: Colors.deepOrange),
              ),
              home: auth.isAuth
                  ? ProductsOverviewScreen()
                  : FutureBuilder(
                      future: auth.tryAutoLogin(),
                      builder: (context, authSnapshot) =>
                          authSnapshot.connectionState == ConnectionState.waiting
                              ? SplashScreen()
                              : AuthScreen()),
              routes: {
                ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
                CartScreen.routeName: (ctx) => CartScreen(),
                OrderScreen.routeName: (context) => OrderScreen(),
                UserProductScreen.routeName: (ctx) => UserProductScreen(),
                EditProductScreen.routeName: (ctx) => EditProductScreen()
              });
        },
      ),
    );
  }
}
