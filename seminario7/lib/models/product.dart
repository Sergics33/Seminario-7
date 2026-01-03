import 'dart:convert';

class Product {
  String? id;
  String name;
  double price;
  bool available;
  String? picture;
  String? registrationDate;

  Product({
    this.id,
    this.name = '',
    this.price = 0,
    this.available = true,
    this.picture,
    this.registrationDate,
  });

  // ================== CONVERTIR A MAP ==================
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'available': available,
      'picture': picture,
      'registrationDate': registrationDate,
    };
  }

  // ================== CREAR DESDE MAP ==================
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      name: map['name'] ?? '',
      price: map['price']?.toDouble() ?? 0,
      available: map['available'] ?? true,
      picture: map['picture'],
      registrationDate: map['registrationDate'],
    );
  }

  // ================== CONVERTIR A JSON ==================
  String toJson() => json.encode(toMap());

  // ================== CREAR DESDE JSON ==================
  factory Product.fromJson(String source) => Product.fromMap(json.decode(source));

  // ================== MÉTODO COPY ==================
  Product copy() {
    return Product(
      id: id,
      name: name,
      price: price,
      available: available,
      picture: picture,
      registrationDate: registrationDate,
    );
  }
}
