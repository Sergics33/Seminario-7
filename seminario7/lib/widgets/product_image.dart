import 'package:flutter/material.dart';
import 'safe_network_image.dart';

class ProductImage extends StatelessWidget {
  final String? url;
  const ProductImage({super.key, this.url});

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
          color: Colors.black, // fondo negro para que el botón de cámara se vea
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
            child: SafeNetworkImage(
              url: url,
              height: 450,
              width: double.infinity,
            ),
          ),
        ),
      ),
    );
  }
}
