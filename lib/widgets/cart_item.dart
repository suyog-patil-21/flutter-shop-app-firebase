import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart';

class CartItem extends StatelessWidget {
  CartItem(
      {Key? key,
      required this.id,
      required this.quantity,
      required this.price,
      required this.productId,
      required this.title})
      : super(key: key);
  final String id;
  final double price;
  final String productId;
  int quantity;
  final String title;
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        Provider.of<Cart>(context, listen: false).removeItem(productId);
      },
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Are You Sure?'),
            content: Text('Do You Want to Remove the Item from the Cart'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text('Yes'),
              )
            ],
          ),
        );
      },
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        color: Theme.of(context).errorColor,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, size: 40),
        alignment: Alignment.centerRight,
      ),
      key: ValueKey(id),
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(
              radius: 30,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: FittedBox(
                child: Text('\$$price '),
              ),
            ),
            title: Text(title),
            subtitle: Text('Total: \$${(price * quantity)}'),
            trailing: Text('$quantity x'),
          ),
        ),
      ),
    );
  }
}
