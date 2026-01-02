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

  // Convertir de Map recibido desde Firebase a Product
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      available: map['available'] ?? true,
      name: map['name'] ?? 'No name',
      picture: map['picture'],
      price: (map['price'] is int) ? (map['price'] as int).toDouble() : (map['price'] ?? 0.0),
      id: map['id'], // temporal, luego se sobrescribe con key
    );
  }

  // Convertir a Map para subir a Firebase
  Map<String, dynamic> toMap() {
    return {
      'available': available,
      'name': name,
      'picture': picture,
      'price': price,
    };
  }
}
