import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/product_controller.dart';
import 'controllers/cart_controller.dart';
import 'views/product_list_view.dart';
import 'views/cart_view.dart';
import 'views/purchase_form_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductController()),
        ChangeNotifierProvider(create: (_) => CartController()),
      ],
      child: MaterialApp(
        title: 'Bodega Digital',
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        home: const ProductListView(),
        routes: {
          '/cart': (context) => const CartView(),
          '/purchase': (context) => const PurchaseFormView(),
        },
      ),
    );
  }
}
