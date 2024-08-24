import 'package:flutter/material.dart';

class CustomImage extends StatelessWidget {
  final String imageUrl;
  final String placeholderImage; // Imagen predeterminada

  const CustomImage({
    super.key,
    required this.imageUrl,
    this.placeholderImage = 'assets/images/default.png',
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imageUrl,
      // Si la imagen no puede cargarse, muestra una imagen predeterminada
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          placeholderImage,
          fit: BoxFit.cover,
          height: 150,
          width: double.infinity,
        );
      },
      fit: BoxFit.cover,
      height: 150,
      width: double.infinity,
    );
  }
}
