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

  File? newPictureFile; // ← aquí almacenamos la foto nueva

  ProductsService() {
    loadProducts();
  }

  // ================== CARGAR PRODUCTOS ==================
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

  // ================== SUBIR IMAGEN A CLOUDINARY ==================
  Future<String?> uploadImage() async {
    if (newPictureFile == null) return null;

    isSaving = true;
    notifyListeners();

    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/dygllwnoj/image/upload?upload_preset=flutter_products',
    );

    final imageUploadRequest = http.MultipartRequest('POST', url);

    final file = await http.MultipartFile.fromPath('file', newPictureFile!.path);
    imageUploadRequest.files.add(file);

    final streamResponse = await imageUploadRequest.send();
    final resp = await http.Response.fromStream(streamResponse);

    if (resp.statusCode != 200 && resp.statusCode != 201) {
      print('Error subiendo imagen a Cloudinary');
      print(resp.body);
      return null;
    }

    newPictureFile = null; // reset
    final decodedData = json.decode(resp.body);
    return decodedData['secure_url'];
  }

  // ================== ACTUALIZAR PRODUCTO ==================
  Future<String> updateProduct(Product product) async {
    final url = Uri.https(_baseUrl, 'products/${product.id}.json');
    final resp = await http.put(url, body: product.toJson());
    print(resp.body);

    final index = products.indexWhere((p) => p.id == product.id);
    if (index >= 0) {
      products[index] = product;
      notifyListeners();
    }

    return product.id!;
  }

  // ================== CREAR PRODUCTO ==================
  Future<String> createProduct(Product product) async {
    final url = Uri.https(_baseUrl, 'products.json');
    final resp = await http.post(url, body: product.toJson());

    final decodedData = json.decode(resp.body);
    product.id = decodedData['name'];

    products.add(product);
    notifyListeners();

    return product.id!;
  }

  // ================== GUARDAR O CREAR PRODUCTO ==================
  Future saveOrCreateProduct(Product product) async {
    isSaving = true;
    notifyListeners();

    // Si hay foto nueva, subirla antes de guardar
    if (newPictureFile != null) {
      final imageUrl = await uploadImage();
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

  // ================== ACTUALIZAR IMAGEN LOCAL ==================
  void updateSelectedProductImage(String path) {
    selectedProduct.picture = path;
    newPictureFile = File(path);
    notifyListeners();
  }
}
