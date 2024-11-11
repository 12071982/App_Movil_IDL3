import 'package:flutter/material.dart';
import '../models/product_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductController extends ChangeNotifier {
  int _currentPage = 1;
  final int _pageSize = 4;
  bool _hasMoreProducts = true;
  List<Product> _products = [];
  static const int maxPages = 4;
  int _totalPages = maxPages;

  List<Product> get products => _products;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get hasMoreProducts => _hasMoreProducts;

  Future<void> fetchProducts(int page) async {
    // Verificar que la página solicitada esté dentro del límite
    if (page > maxPages) return;

    final url = Uri.parse(
      "https://shop-api-roan.vercel.app/product?page=$page&pageSize=$_pageSize",
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> productList = json.decode(response.body);

        // Manejar la conversión a productos asegurando que los valores sean válidos
        _products = productList.map((json) => Product.fromJson(json)).toList();

        _currentPage = page;
        _hasMoreProducts = _products.length == _pageSize;
        
        // Forzar el total de páginas al máximo definido
        _totalPages = maxPages;

        notifyListeners();
      } else {
        throw Exception('Error al cargar productos');
      }
    } catch (error) {
      print("Error en fetchProducts: $error");
    }
  }

  void nextPage() {
    if (_currentPage < _totalPages) {
      fetchProducts(_currentPage + 1);
    }
  }

  void previousPage() {
    if (_currentPage > 1) {
      fetchProducts(_currentPage - 1);
    }
  }

  void goToFirstPage() {
    fetchProducts(1);
  }

  void goToLastPage() {
    fetchProducts(_totalPages);
  }

  List<int> pageRange() {
    int start = (_currentPage - 1).clamp(1, totalPages - 2);
    int end = (_currentPage + 1).clamp(2, totalPages);
    return [for (int i = start; i <= end; i++) i];
  }
}
