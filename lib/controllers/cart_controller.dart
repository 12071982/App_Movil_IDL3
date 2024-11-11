import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';
import 'dart:convert';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, required this.quantity});

  double get totalPrice => product.price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
    };
  }

  static CartItem fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(json['product']),
      quantity: json['quantity'],
    );
  }
}

class CartController extends ChangeNotifier {
  Map<String, CartItem> _items = {};

  CartController() {
    loadCartFromPreferences();
  }

  Map<String, CartItem> get items => _items;

  List<CartItem> get cartItems => _items.values.toList();

  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.totalPrice;
    });
    return total;
  }

  Future<void> addItem(Product product) async {
    if (_items.containsKey(product.id)) {
      if (_items[product.id]!.quantity < product.stock) {
        _items[product.id]!.quantity++;
        await saveCartToPreferences();
        notifyListeners();
      } else {
        // Si se alcanza el límite de stock, lanzamos una excepción
        throw Exception("No hay más productos en stock");
      }
    } else {
      _items[product.id] = CartItem(product: product, quantity: 1);
      await saveCartToPreferences();
      notifyListeners();
    }
  }

  Future<void> decreaseItemQuantity(String productId) async {
    if (_items.containsKey(productId) && _items[productId]!.quantity > 1) {
      _items[productId]!.quantity--;
    } else if (_items.containsKey(productId)) {
      _items.remove(productId);
    }
    await saveCartToPreferences();
    notifyListeners();
  }

  Future<void> removeItem(String productId) async {
    _items.remove(productId);
    await saveCartToPreferences();
    notifyListeners();
  }

  Future<void> clearCart() async {
    _items.clear();
    await saveCartToPreferences();
    notifyListeners();
  }

  Future<void> saveCartToPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final cartData = _items.map((key, item) => MapEntry(key, jsonEncode(item.toJson())));
    prefs.setString('cartItems', jsonEncode(cartData));
  }

  Future<void> loadCartFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final cartString = prefs.getString('cartItems');
    if (cartString != null) {
      final Map<String, dynamic> cartData = jsonDecode(cartString);
      _items = cartData.map((key, value) {
        final itemData = jsonDecode(value);
        return MapEntry(key, CartItem.fromJson(itemData));
      }).cast<String, CartItem>();
      notifyListeners();
    }
  }
}
