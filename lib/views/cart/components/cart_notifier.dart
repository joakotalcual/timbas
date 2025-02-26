import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:timbas/models/cart.dart';
import 'package:timbas/models/products.dart';
import 'package:timbas/services/database/sqlite.dart';
import 'package:uuid/uuid.dart';

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
      return Order(id: cartId, total: total, mesa: getMesa(cartId), items: cartItems, timestamp: DateTime.now(),); // Incluye la mesa
    }).toList();
  }

  // Obtiene todos los pedidos finalizados
  List<Order> getCompletedOrders() {
    return _completedOrders;
  }

  // Añade un ítem al carrito
  void addItem(String id, Producto producto, String nombreCategoria, String comentario, List<Extra> extras) {
    final cart = getCart(id);
    final existingItem = cart.firstWhere(
      (item) => item.producto.id == producto.id && item.comentario == comentario && _areExtrasEqual(item.extras, extras),
      orElse: () => CartItem(producto: producto, categoria: nombreCategoria, comentario: comentario, extras: extras),
    );

    if (cart.contains(existingItem)) {
      existingItem.incrementarCantidad();
    } else {
      cart.add(CartItem(producto: producto, categoria: nombreCategoria, comentario: comentario, extras: extras));
    }
    notifyListeners();
  }

  // Función que compara dos listas de extras
  bool _areExtrasEqual(List<Extra> extras1, List<Extra> extras2) {
    if (extras1.length != extras2.length) return false;

    for (int i = 0; i < extras1.length; i++) {
      if (extras1[i] != extras2[i]) {
        return false;
      }
    }
    return true;
  }

  // Elimina un ítem del carrito
  void removeItem(String id, Producto producto, String nombreCategoria, String comentario, extras) {
    final cart = getCart(id);
    final existingItem = cart.firstWhere(
      (item) => item.producto.id == producto.id && item.comentario == comentario && _areExtrasEqual(item.extras, extras),
      orElse: () => CartItem(producto: producto, categoria: nombreCategoria, comentario: comentario, extras: extras),
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
  void markOrderAsCompleted(String orderId) async {
    //final cart = getCart(orderId);
    final cartItems = List<CartItem>.from(getCart(orderId)); // Copia de los CartItems
    final total = getTotalAmount(orderId);
    final order = Order(id: generateShortUuid(), total: total, mesa: 'preparando', items: cartItems, timestamp: DateTime.now(),); // Incluye la mesa
    _completedOrders.add(order);
    await addLocalOrder(order);
    clear(orderId);
    notifyListeners();
  }

  // Calcula el monto total del carrito para un ID específico
  double getTotalAmount(String id) {
    return getCart(id).fold(0.0, (total, item) {
      double extrasTotal = item.extras.fold(0.0, (sum, extra) => sum + extra.precio);
      return total + item.producto.precio * item.cantidad + (extrasTotal * item.cantidad);
    });
  }

  String generateShortUuid() {
  var uuid = Uuid().v4(); // Generar un UUID
  var bytes = utf8.encode(uuid); // Convertir a bytes
  var shortUuid = base64UrlEncode(bytes).substring(0, 12); // Codificar en Base64 y truncar a 12 caracteres

  // Insertar guiones después de cada 4 caracteres
  return '${shortUuid.substring(0, 4)}-${shortUuid.substring(4, 8)}-${shortUuid.substring(8, 12)}';
}

}

// Clase para representar un pedido
class Order {
  final String id;
  final double total;
  final String? mesa;
  final List<CartItem> items;
  final DateTime timestamp;

  Order({
    required this.id,
    required this.total,
    this.mesa,
    required this.items,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'Order(id: $id, mesa: $mesa, total: $total, items: $items, fecha: ${timestamp.toLocal()})';
  }
}