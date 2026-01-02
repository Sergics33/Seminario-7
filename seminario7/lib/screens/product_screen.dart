import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/products_service.dart';
import '../providers/product_form_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/product_image.dart';
import 'package:flutter/services.dart';


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

  @override
  Widget build(BuildContext context) {
    final productForm = Provider.of<ProductFormProvider>(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (!productForm.isValidForm()) return;
          // Guardar cambios en Firebase aquí
        },
        child: const Icon(Icons.save_outlined),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                ProductImage(url: productForm.product.picture),
                Positioned(
                  top: 60,
                  left: 20,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, size: 40, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                Positioned(
                  top: 60,
                  right: 20,
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt_outlined, size: 40, color: Colors.white),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
            _ProductForm(),
          ],
        ),
      ),
    );
  }
}

// --------------------- Formulario ---------------------
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
          child: Column(
            children: [
              const SizedBox(height: 10),
              TextFormField(
                initialValue: product.name,
                onChanged: (value) => product.name = value,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'El nombre es obligatorio';
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
              TextFormField(
                initialValue: product.price.toString(),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final parsed = double.tryParse(value);
                  product.price = parsed ?? 0;
                },
                inputFormatters: [
                  // Solo permite hasta 2 decimales
                  FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?\.?\d{0,2}')),
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
