import 'package:flutter/widgets.dart';

class Responsive {
  final BuildContext context;

  Responsive(this.context);

  /// Obtiene el ancho total de la pantalla
  double get width => MediaQuery.of(context).size.width;

  /// Obtiene la altura total de la pantalla
  double get height => MediaQuery.of(context).size.height;

  /// Determina si el dispositivo está en orientación vertical
  bool get isPortrait => MediaQuery.of(context).orientation == Orientation.portrait;

  /// Determina si el dispositivo está en orientación horizontal
  bool get isLandscape => MediaQuery.of(context).orientation == Orientation.landscape;

  /// Obtiene la densidad de píxeles de la pantalla
  double get pixelRatio => MediaQuery.of(context).devicePixelRatio;

  /// Calcula un porcentaje del ancho de la pantalla
  double wp(double percentage) => width * (percentage / 100);

  /// Calcula un porcentaje de la altura de la pantalla
  double hp(double percentage) => height * (percentage / 100);

  /// Define si es una pantalla pequeña (teléfono)
  bool get isSmallScreen => width < 600;

  /// Define si es una pantalla mediana (tablet)
  bool get isMediumScreen => width >= 600 && width < 1200;

  /// Define si es una pantalla grande (desktop)
  bool get isLargeScreen => width >= 1200;

  double get fontSizeTitle => isSmallScreen ? 14 : isMediumScreen ? 16 : 18;
  double get fontSizeSubtitle => isSmallScreen ? 10 : isMediumScreen ? 12 : 14;
}
