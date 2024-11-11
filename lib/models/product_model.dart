class Product {
  final String id;
  final String name;
  final double price;
  final int stock;
  final String imageUrl;
  final String description;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.imageUrl,
    required this.description,
  });

  // Convierte el producto a un mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'stock': stock,
      'imageUrl': imageUrl,
      'description': description,
    };
  }

  // Crea un producto desde un JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '', // Asigna cadena vacía si es null
      name: json['name'] ?? 'Producto sin nombre',
      price: (json['price'] ?? 0).toDouble(),
      stock: json['stock'] ?? 0,
      imageUrl: json['imageUrl'] ?? '', // Asigna cadena vacía si es null
      description: json['description'] ?? 'Sin descripción',
    );
  }
}
