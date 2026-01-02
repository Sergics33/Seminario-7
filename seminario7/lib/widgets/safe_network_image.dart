import 'package:flutter/material.dart';

/// Widget seguro para mostrar imagen de red con gif de carga
class SafeNetworkImage extends StatelessWidget {
  final String? url;
  final double? height;
  final double? width;

  const SafeNetworkImage({super.key, this.url, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      // Si no hay URL, muestra la imagen local de "no-image"
      return Image.asset(
        'assets/no-image.png',
        height: height,
        width: width,
        fit: BoxFit.cover,
      );
    }

    return FadeInImage(
      placeholder: const AssetImage('assets/jar-loading.gif'), // Gif de carga
      image: NetworkImage(url!),
      height: height,
      width: width,
      fit: BoxFit.cover,
      imageErrorBuilder: (context, error, stackTrace) {
        // Si falla la carga de la red, mostrar imagen local
        return Image.asset(
          'assets/no-image.png',
          height: height,
          width: width,
          fit: BoxFit.cover,
        );
      },
    );
  }
}
