import 'package:timbas/models/products.dart';

class CartItem {
  final Producto producto;
  final String categoria;
  int cantidad;
  final String comentario;

  CartItem({required this.producto, required this.categoria, this.cantidad = 1, this.comentario=''});

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
  @override
  String toString() {
    return 'CartItem(producto: ${producto.nombre}, categoria: $categoria, comentario: $comentario, cantidad: $cantidad, totalPrice: $totalPrice)';
  }
}

