import 'package:flutter/foundation.dart';
import './cart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime datetime;
  OrderItem({this.id, this.amount, this.products, this.datetime});
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String token;
  final String userid;
  Orders(this.token, this._orders, this.userid);
  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchOrders() async {
    var url = Uri.parse(
        'https://shop-app-573a6-default-rtdb.firebaseio.com/orders/$userid.json?auth=$token');
    final response = await http.get(url);
    final List<OrderItem> loadedorder = [];
    final extracted = json.decode(response.body) as Map<String, dynamic>;
    if (extracted == null) {
      return;
    }
    extracted.forEach((orderid, odata) {
      loadedorder.add(OrderItem(
          id: orderid,
          amount: odata['amount'],
          datetime: DateTime.parse(odata['datetime']),
          products: (odata['products'] as List<dynamic>)
              .map(
                (item) => CartItem(
                    id: item['id'],
                    price: item['price'],
                    quantity: item['quantity'],
                    title: item['title']),
              )
              .toList()));
    });
    _orders = loadedorder;
    notifyListeners();
  }

  Future<void> addorder(List<CartItem> cartprod, double total) async {
    var url = Uri.parse(
        'https://shop-app-573a6-default-rtdb.firebaseio.com/orders/$userid.json?auth=$token');
    final timestamp = DateTime.now();
    try {
      final response = await http.post(url,
          body: json.encode({
            'id': DateTime.now().toString(),
            'amount': total,
            'datetime': timestamp.toIso8601String(),
            'products': cartprod
                .map((cp) => {
                      'id': cp.id,
                      'title': cp.title,
                      'quantity': cp.quantity,
                      'price': cp.price
                    })
                .toList(),
          }));
      _orders.insert(
          0,
          OrderItem(
              id: json.decode(response.body)['name'],
              amount: total,
              datetime: timestamp,
              products: cartprod));
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }
}
