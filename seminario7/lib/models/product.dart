import 'dart:convert';


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

  Product copy() => Product(
        available: available,
        name: name,
        picture: picture,
        price: price,
        id: id,
      );

  Map<String, dynamic> toMap() => {
        'available': available,
        'name': name,
        'picture': picture,
        'price': price,
      };

  String toJson() => json.encode(toMap());

  factory Product.fromMap(Map<String, dynamic> map) => Product(
        available: map['available'] ?? true,
        name: map['name'] ?? '',
        picture: map['picture'],
        price: (map['price'] ?? 0).toDouble(),
      );
}
