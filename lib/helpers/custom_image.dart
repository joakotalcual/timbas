import 'package:flutter/material.dart';
import 'package:timbas/helpers/responsive.dart';

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
    var responsive = Responsive(context);
    bool isLandscape = responsive.isLandscape;
    bool isSmallScreen = responsive.isSmallScreen;
    bool isMediumScreen = responsive.isMediumScreen;

    return Image.asset(
      imageUrl,
      // Si la imagen no puede cargarse, muestra una imagen predeterminada
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          placeholderImage,
          fit: BoxFit.contain,
          height: isLandscape && !isSmallScreen ? 200 : isSmallScreen ? 100 : isMediumScreen && isLandscape ? 170 : isMediumScreen && !isLandscape ? 130 : 200,
        );
      },
      fit: BoxFit.contain,
      height:isLandscape && !isSmallScreen ? 200 : isSmallScreen ? 100 : isMediumScreen && isLandscape ? 170 : isMediumScreen && !isLandscape ? 130 : 200,
    );
  }
}
