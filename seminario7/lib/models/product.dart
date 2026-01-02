class Product {
  String id;
  String name;
  double price;
  String imageUrl;
  bool available;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.available = true,
  });
}
