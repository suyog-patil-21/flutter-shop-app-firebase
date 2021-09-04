import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:my_shop/models/http_exceptions.dart';
import '../providers/cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
  });
}

class Order with ChangeNotifier {
  final String authToken;
  final String userId;
  Order(this.authToken, this.userId,this._order);
  List<OrderItem> _order = [];
  List<OrderItem> get orders {
    return [..._order];
  }

  Future<void> ordersAndSetList() async {
    final url =
        'https://my-shop-cc211-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken';
    try {
      http.Response response = await http.get(Uri.parse(url));
      final List<OrderItem> loadedlist = [];
      if(response.body.isEmpty){
return;
      }
      Map<String,dynamic> extracedData = {}; 
      extracedData = json.decode(response.body) ?? {};
      if (extracedData.isEmpty) {
        throw HttpException('You Have No Orders Yet!');
      }
      extracedData.forEach((id, prodData) {
        loadedlist.add(OrderItem(
            id: id,
            amount: prodData['amount'],
            products: (prodData['products'] as List<dynamic>)
                .map((item) => CartItem(
                    id: item['id'],
                    title: item['title'],
                    quantity: item['quantity'],
                    price: item['price']))
                .toList(),
            dateTime: DateTime.parse(prodData['dateTime'])));
      });
      _order = loadedlist.reversed.toList();
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addOrder(List<CartItem> cartProduct, double total) async {
    final url =
        'https://my-shop-cc211-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken';
    final timestamp = DateTime.now();
    final response = await http.post(Uri.parse(url),
        body: json.encode({
          'amount': total,
          'dateTime': timestamp.toIso8601String(),
          'products': cartProduct
              .map((cp) => {
                    'id': cp.id,
                    'title': cp.title,
                    'quantity': cp.quantity,
                    'price': cp.price
                  })
              .toList()
        }));
    _order.insert(
        0,
        OrderItem(
            id: json.decode(response.body)['name'],
            amount: total,
            products: cartProduct,
            dateTime: timestamp));
    notifyListeners();
  }
}
