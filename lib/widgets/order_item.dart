import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_shop/providers/orders.dart';

class OrderItemWidget extends StatefulWidget {
  const OrderItemWidget({Key? key, required this.order}) : super(key: key);
  final OrderItem order;

  @override
  State<OrderItemWidget> createState() => _OrderItemWidgetState();
}

class _OrderItemWidgetState extends State<OrderItemWidget> {
  bool _expanded = false;
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height:
          _expanded ? min(widget.order.products.length * 20.0 + 110, 200) : 100,
      child: Card(
          margin: EdgeInsets.all(10),
          child: Column(
            children: [
              ListTile(
                  title: Text('\$${widget.order.amount}',style: TextStyle(fontSize: 22.0),),
                  subtitle: Text(DateFormat('dd/MM/yyyy hh:mm')
                      .format(widget.order.dateTime)),
                  trailing: IconButton(
                      onPressed: () {
                        setState(() {
                          _expanded = !_expanded;
                        });
                      },
                      icon: _expanded
                          ? Icon(Icons.expand_less)
                          : Icon(Icons.expand_more))),
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                padding: EdgeInsets.all(4.0),
                margin: EdgeInsets.all(8.0),
                height:_expanded? min(widget.order.products.length * 20.0 + 10, 180):0,
                child: ListView(
                  children: widget.order.products
                      .map((prod) => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                prod.title,
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${prod.quantity}x  \$${prod.price}',
                                style:
                                    TextStyle(fontSize: 18, color: Colors.grey),
                              )
                            ],
                          ))
                      .toList(),
                ),
              ),
            ],
          )),
    );
  }
}
