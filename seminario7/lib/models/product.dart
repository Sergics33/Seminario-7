class Product {
  bool available;
  String name;
  String? picture;
  double price;
  String? id;

  Product({
    required this.available,
    required this.name,
    this.picture,
    required this.price,
    this.id,
  });

  // Crear copia del producto para edición sin afectar la lista original
  Product copy() => Product(
        available: available,
        name: name,
        picture: picture,
        price: price,
        id: id,
      );

  // Método para crear desde Map (Firebase)
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      available: map['available'] ?? true,
      name: map['name'] ?? '',
      picture: map['picture'],
      price: (map['price'] ?? 0).toDouble(),
      id: map['id'],
    );
  }
}
