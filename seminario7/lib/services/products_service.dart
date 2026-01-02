import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductsService extends ChangeNotifier {
  List<Product> products = [];
  bool isLoading = true;

  ProductsService() {
    loadProducts();
  }

  Future<void> loadProducts() async {
    await Future.delayed(const Duration(seconds: 2)); // simula carga
    products = [
      Product(
        id: '1',
        name: 'Disco duro G',
        price: 103.99,
        imageUrl: 'https://via.placeholder.com/400x300/f6f6f6',
        available: true,
      ),
      Product(
        id: '2',
        name: 'Memoria RAM 16GB',
        price: 75.50,
        imageUrl: 'https://via.placeholder.com/400x300/00ff00',
        available: false,
      ),
      Product(
        id: '3',
        name: 'Teclado mecánico',
        price: 49.99,
        imageUrl: 'https://via.placeholder.com/400x300/0000ff',
        available: true,
      ),
    ];
    isLoading = false;
    notifyListeners();
  }

  void addProduct(Product product) {
    products.add(product);
    notifyListeners();
  }
}
