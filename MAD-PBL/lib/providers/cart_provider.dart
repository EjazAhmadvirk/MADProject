import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _cartItems = [];

  List<Map<String, dynamic>> get cartItems => _cartItems;

  int get itemCount => _cartItems.length;

  double get totalPrice {
    double total = 0;
    for (var item in _cartItems) {
      total += (item['price'] as num).toDouble();
    }
    return total;
  }

  void addToCart(Map<String, dynamic> book) {
    // Check if already in cart
    bool exists = _cartItems.any((item) => item['title'] == book['title']);
    if (!exists) {
      _cartItems.add(book);
      notifyListeners();
    }
  }

  void removeFromCart(Map<String, dynamic> book) {
    _cartItems.removeWhere((item) => item['title'] == book['title']);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  bool isInCart(Map<String, dynamic> book) {
    return _cartItems.any((item) => item['title'] == book['title']);
  }
}