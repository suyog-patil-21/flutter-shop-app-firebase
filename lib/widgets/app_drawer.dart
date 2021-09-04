import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/order_screeen.dart';
import '../screens/user_product_screen.dart';
import '../providers/auth.dart';
class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
          child: Column(children: [
        AppBar(
          title: Text('Hello Friend!'),
          automaticallyImplyLeading: false,
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.shop),
          title: const Text('Shop'),
          onTap: () {
            Navigator.of(context).pushReplacementNamed('/');
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.payment),
          title: const Text('Orders History'),
          onTap: () {
            Navigator.of(context).pushReplacementNamed(OrderScreen.routeName);
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.edit),
          title: const Text('Manage Product'),
          onTap: () {
            Navigator.of(context).pushReplacementNamed(UserProductScreen.routeName);
          },
        ),
         const Divider(),
        ListTile(
          leading: const Icon(Icons.exit_to_app),
          title: const Text('Logout'),
          onTap: () {
            // Navigator to pop the App Drawer of the Screen
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacementNamed('/');
            Provider.of<Auth>(context,listen: false).logout();
          },
        ),
      ])),
    );
  }
}
