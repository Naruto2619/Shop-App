import 'package:flutter/cupertino.dart';

import 'package:flutter/foundation.dart';

class CartItem {
  final String id;
  final String title;
  int quantity;
  final double price;
  CartItem(
      {@required this.id,
      @required this.title,
      @required this.quantity,
      @required this.price});
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};
  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemCount {
    return _items.length;
  }

  double get totalamt {
    var total = 0.0;
    _items.forEach((key, cartitem) {
      total += cartitem.price * cartitem.quantity;
    });
    return total;
  }

  void addItem(String pid, double price, String title) {
    if (_items.containsKey(pid)) {
      _items.update(
          pid,
          (existingCartItem) => CartItem(
              id: existingCartItem.id,
              title: existingCartItem.title,
              quantity: existingCartItem.quantity + 1,
              price: existingCartItem.price));
    } else {
      _items.putIfAbsent(
          pid,
          () => CartItem(
              id: DateTime.now().toString(),
              price: price,
              title: title,
              quantity: 1));
    }
    notifyListeners();
  }

  void removeItem(String id) {
    _items.remove(id);
    notifyListeners();
  }

  void removesingleItem(String prodid) {
    if (!_items.containsKey(prodid)) {
      return;
    }
    if (_items[prodid].quantity > 1) {
      _items.update(
          prodid,
          (existing) => CartItem(
              id: existing.id,
              title: existing.title,
              price: existing.price,
              quantity: existing.quantity - 1));
    } else {
      _items.remove(prodid);
    }
    notifyListeners();
  }

  void add(String d) {
    _items[d].quantity += 1;
    notifyListeners();
  }

  void sub(String d) {
    _items[d].quantity -= 1;
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }
}
