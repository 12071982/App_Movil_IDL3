import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/product_controller.dart';
import '../controllers/cart_controller.dart';
import '../models/product_model.dart';

class ProductListView extends StatelessWidget {
  const ProductListView({super.key});

  @override
  Widget build(BuildContext context) {
    final productController = Provider.of<ProductController>(context);
    final cartController = Provider.of<CartController>(context);

    // Cargar la primera página solo si no hay productos ya cargados
    if (productController.products.isEmpty) {
      productController.fetchProducts(1); // Cargar la primera página al inicio
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bodega Digital',
          style: TextStyle(fontWeight: FontWeight.normal, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Lista de productos',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/cart');
                  },
                  child: Image.asset(
                    'assets/images/cart.png',
                    width: 80,
                    height: 80,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<ProductController>(
              builder: (context, productController, child) {
                if (productController.products.isEmpty) {
                  return Center(
                    child: Text(
                      'No hay productos disponibles',
                      style: TextStyle(color: Colors.grey[600], fontSize: 18),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: productController.products.length,
                  itemBuilder: (context, index) {
                    final product = productController.products[index];
                    final cartQuantity = cartController.items[product.id]?.quantity ?? 0;

                    return ProductCard(
                      product: product,
                      initialQuantity: cartQuantity,
                      onAddToCart: () async {
                        if (cartQuantity < product.stock) {
                          await cartController.addItem(product);
                        } else {
                          _showOutOfStockDialog(context);
                        }
                      },
                      onRemoveFromCart: () => cartController.decreaseItemQuantity(product.id),
                    );
                  },
                );
              },
            ),
          ),
          // Paginación
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.first_page),
                  onPressed: productController.currentPage > 1
                      ? () => productController.goToFirstPage()
                      : null,
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: productController.currentPage > 1
                      ? () => productController.previousPage()
                      : null,
                ),
                ...productController.pageRange().map((page) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: productController.currentPage == page
                              ? Colors.green
                              : Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: productController.currentPage != page
                            ? () => productController.fetchProducts(page)
                            : null,
                        child: Text(
                          '$page',
                          style: TextStyle(
                            color: productController.currentPage == page
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: productController.currentPage < productController.totalPages
                      ? () => productController.nextPage()
                      : null,
                ),
                IconButton(
                  icon: const Icon(Icons.last_page),
                  onPressed: productController.currentPage < productController.totalPages
                      ? () => productController.goToLastPage()
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/cart');
        },
        backgroundColor: const Color.fromARGB(255, 234, 226, 255),
        foregroundColor: Colors.purple,
        child: const Icon(Icons.shopping_cart),
      ),
    );
  }

  void _showOutOfStockDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.red.shade50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red),
              SizedBox(width: 8),
              Text(
                "Sin Stock",
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            "No hay más productos en stock para este artículo.",
            style: TextStyle(color: Colors.black87),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red, // Text color
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Aceptar"),
            ),
          ],
        );
      },
    );
  }
}

class ProductCard extends StatefulWidget {
  final Product product;
  final int initialQuantity;
  final Future<void> Function() onAddToCart;
  final VoidCallback onRemoveFromCart;

  const ProductCard({
    required this.product,
    required this.initialQuantity,
    required this.onAddToCart,
    required this.onRemoveFromCart,
    Key? key,
  }) : super(key: key);

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late int quantity;

  @override
  void initState() {
    super.initState();
    quantity = widget.initialQuantity;
  }

  void _incrementQuantity() async {
    if (quantity < widget.product.stock) {
      await widget.onAddToCart();
      setState(() {
        quantity++;
      });
    } else {
      _showOutOfStockDialog();
    }
  }

  void _decrementQuantity() {
    if (quantity > 0) {
      setState(() {
        quantity--;
      });
      widget.onRemoveFromCart();
    }
  }

  @override
  void didUpdateWidget(covariant ProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final cartController = Provider.of<CartController>(context, listen: false);
    setState(() {
      quantity = cartController.items[widget.product.id]?.quantity ?? 0;
    });
  }

  void _showOutOfStockDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.red.shade50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red),
              SizedBox(width: 8),
              Text(
                "Sin Stock",
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            "No hay más productos en stock para este artículo.",
            style: TextStyle(color: Colors.black87),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red, // Text color
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Aceptar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child: widget.product.imageUrl.isNotEmpty
                  ? Image.network(
                      widget.product.imageUrl,
                      fit: BoxFit.cover,
                    )
                  : const Center(child: Icon(Icons.image, color: Colors.grey)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text('Stock: ${widget.product.stock}', style: TextStyle(color: Colors.grey[700])),
                  Text('Descripción: ${widget.product.description}', style: TextStyle(color: Colors.grey[700])),
                ],
              ),
            ),
            Column(
              children: [
                Text(
                  'S/ ${widget.product.price.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: _decrementQuantity,
                    ),
                    Text('$quantity'),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _incrementQuantity,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
