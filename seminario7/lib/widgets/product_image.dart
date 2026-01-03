import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../services/products_service.dart';
import '../providers/product_form_provider.dart';

class ProductImage extends StatelessWidget {
  final String? url;
  const ProductImage({super.key, this.url});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: SizedBox(
          width: double.infinity,
          height: 250,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(color: Colors.grey[300]),
              if (url != null && url!.isNotEmpty)
                Image.network(
                  url!,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.broken_image, size: 100, color: Colors.white70),
                  ),
                )
              else
                const Center(
                  child: Icon(Icons.image, size: 100, color: Colors.white70),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

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

  Future<void> _pickImage(ImageSource source, ProductFormProvider form) async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (pickedFile == null) return;

    productService.updateSelectedProductImage(pickedFile.path);

    final String? imageUrl = await productService.uploadImage();
    if (imageUrl != null) {
      form.product.picture = imageUrl;
      form.notifyListeners();
    }
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Seguro que quieres borrar este producto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              productService.deleteProduct(id);
              Navigator.pop(context); 
              Navigator.pop(context); 
            },
            child: const Text('Borrar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productForm = Provider.of<ProductFormProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Producto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () =>
                _confirmDelete(context, productForm.product.id ?? ''),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: productService.isSaving
            ? null
            : () async {
                if (!productForm.isValidForm()) return;
                await productService.saveOrCreateProduct(productForm.product);
                if (!context.mounted) return;
                Navigator.pop(context);
              },
        child: productService.isSaving
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.save_outlined),
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
                    icon:
                        const Icon(Icons.arrow_back, size: 40, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                Positioned(
                  top: 60,
                  right: 60,
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt_outlined,
                        size: 40, color: Colors.white),
                    onPressed: productService.isSaving
                        ? null
                        : () => _pickImage(ImageSource.camera, productForm),
                  ),
                ),
                Positioned(
                  top: 60,
                  right: 10,
                  child: IconButton(
                    icon: const Icon(Icons.photo_library_outlined,
                        size: 40, color: Colors.white),
                    onPressed: productService.isSaving
                        ? null
                        : () => _pickImage(ImageSource.gallery, productForm),
                  ),
                ),
              ],
            ),
            const _ProductFormWithDate(),
          ],
        ),
      ),
    );
  }
}

class _ProductFormWithDate extends StatefulWidget {
  const _ProductFormWithDate({super.key});

  @override
  State<_ProductFormWithDate> createState() => _ProductFormWithDateState();
}

class _ProductFormWithDateState extends State<_ProductFormWithDate> {
  late TextEditingController _dateController;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final productForm =
          Provider.of<ProductFormProvider>(context, listen: false);
      _dateController = TextEditingController(
        text: productForm.product.registrationDate != null
            ? productForm.product.registrationDate!.split('T')[0]
            : '',
      );
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productForm = Provider.of<ProductFormProvider>(context, listen: false);
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
        child: Column(
          children: [
            const SizedBox(height: 10),
            TextFormField(
              initialValue: product.name,
              onChanged: (value) => product.name = value,
              validator: (value) =>
                  value == null || value.isEmpty ? 'El nombre es obligatorio' : null,
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
              onChanged: (value) => product.price = double.tryParse(value) ?? 0,
              inputFormatters: [
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
            TextFormField(
              readOnly: true,
              controller: _dateController,
              decoration: const InputDecoration(
                hintText: 'Fecha de registro',
                labelText: 'Fecha de registro:',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
              onTap: () async {
                DateTime initialDate = product.registrationDate != null
                    ? DateTime.parse(product.registrationDate!)
                    : DateTime.now();

                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: initialDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );

                if (pickedDate != null) {
                  product.registrationDate = pickedDate.toIso8601String();
                  _dateController.text =
                      pickedDate.toLocal().toString().split(' ')[0];
                  productForm.notifyListeners();
                }
              },
            ),
            const SizedBox(height: 20),
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
    );
  }
}
