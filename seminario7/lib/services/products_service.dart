import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductsService extends ChangeNotifier {
  final String _baseUrl = 'https://flutter-varios-3a077-default-rtdb.firebaseio.com';
  bool isLoading = true;
  List<Product> products = [];

  late Product selectedProduct; // Producto seleccionado para detalle

  ProductsService() {
    loadProducts();
  }

  Future<List<Product>> loadProducts() async {
    isLoading = true;
    notifyListeners();

    final url = Uri.parse('$_baseUrl/products.json');
    final resp = await http.get(url);
    final Map<String, dynamic> productsMap = json.decode(resp.body);
    products.clear();

    productsMap.forEach((key, value) {
      final tempProduct = Product.fromMap(value);
      tempProduct.id = key;
      products.add(tempProduct);
    });

    isLoading = false;
    notifyListeners();

    return products;
  }
}
