import 'package:flutter/material.dart';
import 'package:timbas/models/cart.dart';
import 'package:timbas/models/products.dart';

class Cart with ChangeNotifier {
  final Map<String, List<CartItem>> _carts = {};  // Carritos por ID
  final List<Order> _completedOrders = [];  // Pedidos finalizados
  final Map<String, String?> _cartMesa = {};  // Mapa para almacenar la mesa asociada a cada carrito

  // Obtiene el carrito para un ID específico, creando uno nuevo si no existe
  List<CartItem> getCart(String id) {
    return _carts.putIfAbsent(id, () => []);
  }

  // Establece la mesa para un carrito
  void setMesa(String id, String? mesa) {
    _cartMesa[id] = mesa;
  }

  // Obtiene la mesa para un carrito
  String? getMesa(String id) {
    return _cartMesa[id];
  }

  // Obtiene todos los pedidos activos
  List<Order> getActiveOrders() {
    return _carts.entries.map((entry) {
      final cartId = entry.key;
      final cartItems = entry.value;
      final total = cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
      return Order(id: cartId, total: total, mesa: getMesa(cartId)); // Incluye la mesa
    }).toList();
  }

  // Obtiene todos los pedidos finalizados
  List<Order> getCompletedOrders() {
    return _completedOrders;
  }

  // Añade un ítem al carrito
  void addItem(String id, Producto producto, String nombreCategoria) {
    final cart = getCart(id);
    final existingItem = cart.firstWhere(
      (item) => item.producto.id == producto.id,
      orElse: () => CartItem(producto: producto, categoria: nombreCategoria),
    );

    if (cart.contains(existingItem)) {
      existingItem.incrementarCantidad();
    } else {
      cart.add(CartItem(producto: producto, categoria: nombreCategoria));
    }
    notifyListeners();
  }

  // Elimina un ítem del carrito
  void removeItem(String id, Producto producto, String nombreCategoria) {
    final cart = getCart(id);
    final existingItem = cart.firstWhere(
      (item) => item.producto.id == producto.id,
      orElse: () => CartItem(producto: producto, categoria: nombreCategoria),
    );

    if (cart.contains(existingItem)) {
      if (existingItem.cantidad > 1) {
        existingItem.disminuirCantidad();
      } else {
        cart.remove(existingItem);
      }
      notifyListeners();
    }
  }

  // Limpia el carrito para un ID específico
  void clear(String id) {
    _carts.remove(id);
    _cartMesa.remove(id);  // Elimina la mesa asociada también
    notifyListeners();
  }

  // Marca un pedido como completado y lo mueve a la lista de pedidos finalizados
  void markOrderAsCompleted(String orderId) {
    //final cart = getCart(orderId);
    final total = getTotalAmount(orderId);
    final order = Order(id: orderId, total: total, mesa: getMesa(orderId)); // Incluye la mesa
    _completedOrders.add(order);
    clear(orderId);
    notifyListeners();
  }

  // Calcula el monto total del carrito para un ID específico
  double getTotalAmount(String id) {
    return getCart(id).fold(0.0, (total, item) => total + item.totalPrice);
  }
}

// Clase para representar un pedido
class Order {
  final String id;
  final double total;
  final String? mesa;

  Order({
    required this.id,
    required this.total,
    this.mesa,
  });
}