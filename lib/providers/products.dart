import 'package:flutter/material.dart';
import '../Models/http_exception.dart';
import 'dart:convert';
import './Product.dart';
import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];
  final String token;
  final String userid;
  Products(this.userid, this.token, this._items);
  var showfav = false;
  List<Product> get items {
    return [..._items];
  }

  List<Product> get favitems {
    return _items.where((prod) => prod.isFavorite).toList();
  }

  Product findbyid(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchprod([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorid"&equalTo="$userid"' : '';
    var url = Uri.parse(
        'https://shop-app-573a6-default-rtdb.firebaseio.com/products.json?auth=$token&$filterString');
    try {
      final response = await http.get(url);
      final extracted = json.decode(response.body) as Map<String, dynamic>;
      if (extracted == null) {
        return;
      }
      url = Uri.parse(
          'https://shop-app-573a6-default-rtdb.firebaseio.com/userFavorites/$userid.json?auth=$token');
      final favoriteresponse = await http.get(url);
      final favdata = json.decode(favoriteresponse.body);
      final List<Product> loadedprod = [];
      extracted.forEach((pid, pdata) {
        loadedprod.add(Product(
            id: pid,
            description: pdata['description'],
            title: pdata['title'],
            price: pdata['price'],
            isFavorite: favdata == null ? false : favdata[pid] ?? false,
            imageUrl: pdata['imageUrl']));
      });
      _items = loadedprod;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addProduct(Product p) async {
    var url = Uri.parse(
        'https://shop-app-573a6-default-rtdb.firebaseio.com/products.json?auth=$token');
    try {
      final response = await http.post(url,
          body: json.encode({
            'title': p.title,
            'description': p.description,
            'imageUrl': p.imageUrl,
            'price': p.price,
            'creatorid': userid
          }));
      final newProduct = Product(
          title: p.title,
          imageUrl: p.imageUrl,
          description: p.description,
          price: p.price,
          id: json.decode(response.body)['name']);
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateprod(String id, Product newProd) async {
    final pindex = _items.indexWhere((p) => p.id == id);
    final url = Uri.parse(
        'https://shop-app-573a6-default-rtdb.firebaseio.com/products/$id.json?auth=$token');
    http.patch(url,
        body: json.encode({
          'title': newProd.title,
          'description': newProd.description,
          'imageUrl': newProd.imageUrl,
          'price': newProd.price,
        }));
    _items[pindex] = newProd;
    notifyListeners();
  }

  Future<void> deleteprod(String id) async {
    final url = Uri.parse(
        'https://shop-app-573a6-default-rtdb.firebaseio.com/products/$id.json?auth=$token');
    final existingprodindex = _items.indexWhere((p) => p.id == id);
    var existingprod = _items[existingprodindex];
    _items.removeAt(existingprodindex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingprodindex, existingprod);
      notifyListeners();
      throw HttpException('Could not Delete Product');
    }
    existingprod = null;
  }
}
