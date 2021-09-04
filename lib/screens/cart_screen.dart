import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart' show Cart;
import '../widgets/cart_item.dart';
import '../providers/orders.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(15.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontSize: 20.0),
                  ),
                  const Spacer(),
                  Chip(
                      label: Text(
                        '\$ ${cart.totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.surface),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.primary),
                  OrderButton(cart: cart)
                ],
              ),
            ),
          ),
          Expanded(
              child: ListView.builder(
            itemCount: cart.itemCount,
            itemBuilder: (context, index) {
              return CartItem(
                  productId: cart.items.keys.toList()[index],
                  id: cart.items.values.toList()[index].id,
                  quantity: cart.items.values.toList()[index].quantity,
                  price: cart.items.values.toList()[index].price,
                  title: cart.items.values.toList()[index].title);
            },
          ))
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key? key,
    required this.cart,
  }) : super(key: key);

  final Cart cart;

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: widget.cart.totalAmount <= 0.0
            ? null
            : () {
                setState(() {
                  _isLoading = true;
                });
                Provider.of<Order>(context, listen: false)
                    .addOrder(widget.cart.items.values.toList(),
                        widget.cart.totalAmount)
                    .then((value) {
                  setState(() {
                    _isLoading = false;
                  });
                });
                widget.cart.clear();
              },
        child:
            _isLoading ? CircularProgressIndicator() : const Text('ORDER NOW'));
  }
}
