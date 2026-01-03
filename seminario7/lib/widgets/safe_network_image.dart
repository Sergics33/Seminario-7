import 'package:flutter/material.dart';

class SafeNetworkImage extends StatelessWidget {
  final String? url;
  final double? height;
  final double? width;

  const SafeNetworkImage({super.key, this.url, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return Image.asset(
        'assets/no-image.png',
        height: height,
        width: width,
        fit: BoxFit.cover,
      );
    }

    return FadeInImage(
      placeholder: const AssetImage('assets/jar-loading.gif'),
      image: NetworkImage(url!),
      height: height,
      width: width,
      fit: BoxFit.cover,
      imageErrorBuilder: (context, error, stackTrace) {
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
