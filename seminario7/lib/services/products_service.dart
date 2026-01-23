import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/product.dart';

class ProductsService extends ChangeNotifier {
  final String _baseUrl = 'flutter-varios-3a077-default-rtdb.firebaseio.com';
  final List<Product> products = [];
  late Product selectedProduct;
  bool isLoading = true;
  bool isSaving = false;
  File? newPictureFile;

  final storage = const FlutterSecureStorage();

  ProductsService() {
    loadProducts();
  }

  Future<String?> uploadImage() async {
    if (newPictureFile == null) return null;

    final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/dygllwnoj/image/upload?upload_preset=flutter_products');

    final imageUploadRequest = http.MultipartRequest('POST', url);
    final file = await http.MultipartFile.fromPath('file', newPictureFile!.path);
    imageUploadRequest.files.add(file);

    final streamResponse = await imageUploadRequest.send();
    final resp = await http.Response.fromStream(streamResponse);

    if (resp.statusCode != 200 && resp.statusCode != 201) {
      print('Error al subir imagen: ${resp.body}');
      return null;
    }

    newPictureFile = null;
    final decodedData = json.decode(resp.body);
    return decodedData['secure_url'];
  }

  void updateSelectedProductImage(String path) {
    selectedProduct.picture = path;
    newPictureFile = File(path);
    notifyListeners();
  }

  Future<List<Product>> loadProducts() async {
    isLoading = true;
    notifyListeners();

    final url = Uri.https(_baseUrl, 'products.json', {
      'auth': await storage.read(key: 'token') ?? ''
    });

    final resp = await http.get(url);
    final Map<String, dynamic>? productsMap = json.decode(resp.body);

    products.clear();

    if (productsMap != null) {
      productsMap.forEach((key, value) {
        final tempProduct = Product.fromMap(value);
        tempProduct.id = key;
        products.add(tempProduct);
      });
    }

    isLoading = false;
    notifyListeners();
    return products;
  }

  Future<String> updateProduct(Product product) async {
    final url = Uri.https(_baseUrl, 'products/${product.id}.json', {
      'auth': await storage.read(key: 'token') ?? ''
    });

    await http.put(url, body: product.toJson());

    final index = products.indexWhere((element) => element.id == product.id);
    if (index >= 0) {
      products[index] = product;
      notifyListeners();
    }

    return product.id!;
  }

  Future<String> createProduct(Product product) async {
    final url = Uri.https(_baseUrl, 'products.json', {
      'auth': await storage.read(key: 'token') ?? ''
    });

    final resp = await http.post(url, body: product.toJson());
    final decodedData = json.decode(resp.body);
    product.id = decodedData['name'];

    products.add(product);
    notifyListeners();
    return product.id!;
  }

  Future saveOrCreateProduct(Product product) async {
    isSaving = true;
    notifyListeners();

    if (product.picture != null && product.picture!.startsWith('/')) {
      final imageUrl = await uploadImage();
      if (imageUrl != null) product.picture = imageUrl;
    }

    product.registrationDate ??= DateTime.now().toIso8601String();

    if (product.id == null) {
      await createProduct(product);
    } else {
      await updateProduct(product);
    }

    isSaving = false;
    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.https(_baseUrl, 'products/$id.json', {
      'auth': await storage.read(key: 'token') ?? ''
    });

    await http.delete(url);

    products.removeWhere((product) => product.id == id);
    notifyListeners();
  }
}