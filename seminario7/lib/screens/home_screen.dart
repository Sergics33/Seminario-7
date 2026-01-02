import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/products_service.dart';
import '../widgets/product_card.dart';
import 'loading_screen.dart';
import 'product_screen.dart';
import 'package:seminario7/models/product.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productsService = Provider.of<ProductsService>(context);

    if (productsService.isLoading) return const LoadingScreen();

    return Scaffold(
      appBar: AppBar(title: const Text('Productos')),
      body: ListView.builder(
        itemCount: productsService.products.length,
        itemBuilder: (context, index) {
          final product = productsService.products[index];
          return GestureDetector(
            onTap: () {
              productsService.selectedProduct = product.copy(); // Creamos copia
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProductScreen()),
              );
            },
            child: ProductCard(product: product),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          // Creamos un producto vacío
          productsService.selectedProduct = Product(
            available: false,
            name: '',
            price: 0,
          );

          Navigator.pushNamed(context, 'product');
        },
      ),
    );
  }
}
