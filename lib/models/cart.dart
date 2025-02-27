import 'package:timbas/models/products.dart';

class CartItem {
  final Producto producto;
  final String categoria;
  int cantidad;
  final String comentario;
  final List<Extra> extras;

  CartItem({
    required this.producto,
    required this.categoria,
    this.cantidad = 1,
    this.comentario='',
    this.extras = const [],
  });

  double get totalPrice {
    double extrasTotal = extras.fold(0.0, (sum, extra) => sum + extra.precio);
    return (producto.precio + extrasTotal) * cantidad;
  }


  void incrementarCantidad() {
    cantidad++;
  }

  void disminuirCantidad() {
    if (cantidad > 1) {
      cantidad--;
    }
  }

  @override
  String toString() {
    return 'CartItem(producto: ${producto.nombre}, categoria: $categoria, comentario: $comentario, cantidad: $cantidad, totalPrice: $totalPrice , extras: $extras)';
  }
}

class Extra {
  final String nombre;
  final double precio;

  Extra({required this.nombre, required this.precio});

  // Método para comparar si dos Extras son iguales
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Extra && other.nombre == nombre && other.precio == precio;
  }

  // Método para crear un hashCode único para cada Extra
  @override
  int get hashCode => nombre.hashCode ^ precio.hashCode;
}