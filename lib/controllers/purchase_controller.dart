import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PurchaseController extends ChangeNotifier {
  Future<void> createOrder({
    required List<Map<String, dynamic>> products,
    required String paymentMethod,
    required String userName,
    required String userPhone,
    required String userAddress,
    required double userLat,
    required double userLng,
    required String userPhoto,
  }) async {
    final url = Uri.parse("https://shop-api-roan.vercel.app/order");

    final body = json.encode({
      "products": products,
      "paymentMethod": paymentMethod,
      "userName": userName,
      "userPhone": userPhone,
      "userAddress": userAddress,
      "userLat": userLat,
      "userLng": userLng,
      "userPhoto": userPhoto,
    });

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        print("Orden creada exitosamente");
      } else {
        print("Error al crear la orden: ${response.body}");
      }
    } catch (error) {
      print("Error de red al crear la orden: $error");
    }
  }
}
