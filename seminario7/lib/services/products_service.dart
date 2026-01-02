import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductsService extends ChangeNotifier {
  final String _baseUrl = 'flutter-varios-3a077-default-rtdb.firebaseio.com';
  List<Product> products = [];
  late Product selectedProduct;
  bool isLoading = true;
  bool isSaving = false;

  ProductsService() {
    loadProducts();
  }

  Future<String?> uploadImage(File imageFile) async {
    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/dygllwnoj/image/upload',
    );

    final imageUploadRequest = http.MultipartRequest('POST', url);

    imageUploadRequest.fields['upload_preset'] = 'flutter_products';
    imageUploadRequest.files.add(
      await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
      ),
    );

    final streamedResponse = await imageUploadRequest.send();
    final resp = await http.Response.fromStream(streamedResponse);

    if (resp.statusCode != 200 && resp.statusCode != 201) {
      print('Algo salió mal');
      print(resp.body);
      return null;
    }

    final decodedData = json.decode(resp.body);
    return decodedData['secure_url'];
  }

  Future<List<Product>> loadProducts() async {
    isLoading = true;
    notifyListeners();

    final url = Uri.https(_baseUrl, 'products.json');
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

  Future<String> updateProduct(Product product) async {
    final url = Uri.https(_baseUrl, 'products/${product.id}.json');
    final resp = await http.put(url, body: product.toJson());
    print(resp.body);

    // Actualizar listado local
    final index = products.indexWhere((element) => element.id == product.id);
    if (index >= 0) {
      products[index] = product;
      notifyListeners();
    }

    return product.id!;
  }

  Future<String> createProduct(Product product) async {
    final url = Uri.https(_baseUrl, 'products.json');
    final resp = await http.post(
      url,
      body: product.toJson(),
    );

    final decodedData = json.decode(resp.body);

    // Firebase devuelve { "name": "ID_GENERADO" }
    product.id = decodedData['name'];

    // Añadimos el producto a la lista local
    products.add(product);

    notifyListeners();

    return product.id!;
  }

  Future saveOrCreateProduct(Product product) async {
    isSaving = true;
    notifyListeners();

    if (product.picture != null && product.picture!.startsWith('/')) {
      final file = File(product.picture!);
      final imageUrl = await uploadImage(file);
      if (imageUrl != null) {
        product.picture = imageUrl;
      }
    }

    if (product.id == null) {
      await createProduct(product);
    } else {
      await updateProduct(product);
    }

    isSaving = false;
    notifyListeners();
  }
}
