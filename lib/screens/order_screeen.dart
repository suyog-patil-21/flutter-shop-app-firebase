import 'package:flutter/material.dart';
import 'package:my_shop/models/http_exceptions.dart';
import 'package:provider/provider.dart';
import '../providers/orders.dart';
import '../widgets/app_drawer.dart';
import '../widgets/order_item.dart';

class OrderScreen extends StatelessWidget {
  static const routeName = "/orders";
  const OrderScreen({Key? key}) : super(key: key);

  Future<void> _fetchOrders(BuildContext context) async {
    await Provider.of<Order>(context, listen: false).ordersAndSetList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Orders History'),
        ),
        drawer: AppDrawer(),
        body: FutureBuilder(
            future: _fetchOrders(context),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else {
                if (snapshot.hasError) {
                  return Center(child: Text('${snapshot.error}'));
                }  else {
                  return Consumer<Order>(
                    builder: (_, ordersData, __) {
                      return ListView.builder(
                          itemCount: ordersData.orders.length,
                          itemBuilder: (_, index) {
                            return OrderItemWidget(
                              order: ordersData.orders[index],
                            );
                          });
                    },
                  );
                }
              }
            }));
  }
}
