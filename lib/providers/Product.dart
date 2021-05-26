import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;

  bool isFavorite;

  Product(
      {@required this.id,
      @required this.title,
      @required this.description,
      @required this.price,
      @required this.imageUrl,
      this.isFavorite = false});
  Future<void> toggleFav(String token, String userid) async {
    final url = Uri.parse(
        'https://shop-app-573a6-default-rtdb.firebaseio.com/userFavorites/$userid/$id.json?auth=$token');
    final oldstat = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    try {
      final response = await http.put(url, body: json.encode(isFavorite));
      if (response.statusCode >= 400) {
        isFavorite = oldstat;
        notifyListeners();
      }
    } catch (error) {
      isFavorite = oldstat;
      notifyListeners();
    }
  }
}
