import 'package:timbas/models/products.dart';

class CartItem {
  final Producto producto;
  final String categoria;
  int cantidad;

  CartItem({required this.producto, required this.categoria, this.cantidad = 1});

  double get totalPrice {
    return producto.precio * cantidad;
  }

  void incrementarCantidad() {
    cantidad++;
  }

  void disminuirCantidad() {
    if (cantidad > 1) {
      cantidad--;
    }
  }
}

