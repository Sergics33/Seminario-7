import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../services/products_service.dart';
import '../providers/product_form_provider.dart';

// ------------------ PANTALLA PRODUCTO ------------------

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productsService = Provider.of<ProductsService>(context);

    return ChangeNotifierProvider(
      create: (_) => ProductFormProvider(productsService.selectedProduct),
      child: _ProductScreenBody(productService: productsService),
    );
  }
}

class _ProductScreenBody extends StatelessWidget {
  final ProductsService productService;
  const _ProductScreenBody({super.key, required this.productService});

  // --------------------------------------------------------
  // MÉTODO PRIVADO PARA TOMAR FOTO
  Future<void> _processImage(ProductFormProvider productForm) async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (pickedFile == null) {
        print('No se seleccionó ninguna imagen');
        return;
      }

      print('Imagen tomada: ${pickedFile.path}');
      productForm.product.picture = pickedFile.path;
      productForm.notifyListeners();
    } catch (e) {
      print('Error al tomar la foto: $e');
    }
  }

  // --------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final productForm = Provider.of<ProductFormProvider>(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (!productForm.isValidForm()) return;

          await productService.saveOrCreateProduct(
            productForm.product,
          );

          if (!context.mounted) return;
          Navigator.pop(context);
        },
        child: const Icon(Icons.save_outlined),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                // Imagen del producto
                ProductImage(url: productForm.product.picture),

                // Botón volver
                Positioned(
                  top: 60,
                  left: 20,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      size: 40,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),

                // Botón Cámara
                Positioned(
                  top: 60,
                  right: 20,
                  child: IconButton(
                    icon: const Icon(
                      Icons.camera_alt_outlined,
                      size: 40,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      await _processImage(productForm);
                    },
                  ),
                ),
              ],
            ),
            const _ProductForm(),
          ],
        ),
      ),
    );
  }
}

// --------------------- FORMULARIO ---------------------

class _ProductForm extends StatelessWidget {
  const _ProductForm({super.key});

  @override
  Widget build(BuildContext context) {
    final productForm = Provider.of<ProductFormProvider>(context);
    final product = productForm.product;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Form(
          key: productForm.formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              const SizedBox(height: 10),

              // Nombre
              TextFormField(
                initialValue: product.name,
                onChanged: (value) => product.name = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  hintText: 'Nombre del producto',
                  labelText: 'Nombre:',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Precio
              TextFormField(
                initialValue: product.price.toString(),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final parsed = double.tryParse(value);
                  product.price = parsed ?? 0;
                },
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^(\d+)?\.?\d{0,2}'),
                  ),
                ],
                decoration: const InputDecoration(
                  hintText: '150€',
                  labelText: 'Precio:',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Disponible
              SwitchListTile.adaptive(
                value: product.available,
                title: const Text('Disponible'),
                activeColor: Colors.indigo,
                onChanged: productForm.updateAvailability,
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// --------------------- WIDGET PRODUCT IMAGE ---------------------

class ProductImage extends StatelessWidget {
  final String? url;
  const ProductImage({super.key, this.url});

  Widget _getImage(String? picture) {
    if (picture == null || picture.isEmpty) {
      return const Image(
        image: AssetImage('assets/no-image.png'),
        fit: BoxFit.cover,
      );
    }

    if (picture.startsWith('http')) {
      return FadeInImage(
        placeholder: const AssetImage('assets/jar-loading.gif'),
        image: NetworkImage(picture),
        fit: BoxFit.cover,
      );
    }

    return Image.file(
      File(picture),
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    const borderRadius = BorderRadius.only(
      bottomLeft: Radius.circular(45),
      bottomRight: Radius.circular(45),
    );

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        width: double.infinity,
        height: 450,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Opacity(
          opacity: 0.9,
          child: ClipRRect(
            borderRadius: borderRadius,
            child: _getImage(url),
          ),
        ),
      ),
    );
  }
}
