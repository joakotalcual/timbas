import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timbas/views/cart/components/cart_notifier.dart';

class OrderDetailScreen extends StatelessWidget {
  final Order order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    final items = cart.getCart(order.id); // Obtiene los ítems del pedido

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Pedido'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              _showConfirmationDialog(context, order.id);
              Navigator.pop(context);
            },
            child: const Text('ELIMINAR CUENTA'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final cartItem = items[index];
                return ListTile(
                  title: Text('${cartItem.categoria} - ${cartItem.producto.nombre}'),
                  subtitle: Text('Cantidad: ${cartItem.cantidad}'),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Total: \$${cart.getTotalAmount(order.id).toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Implementa la funcionalidad para imprimir el ticket aquí
              Provider.of<Cart>(context, listen: false).markOrderAsCompleted(order.id);
            },
            child: const Text('Imprimir Ticket'),
          ),
          const SizedBox(height: 8,),
        ],
      ),
    );
  }
  void _showConfirmationDialog(
      BuildContext context, String cartId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmación'),
        content: Text(
            '¿Estás seguro de que deseas eliminar el pedido? $cartId'),
        actions: [
          TextButton(
            onPressed: () {
              Provider.of<Cart>(context, listen: false)
                  .clear(cartId);
              Navigator.of(context).pop(); // Solo cierra el diálogo
            },
            child: const Text('Sí'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(), // Solo cierra el diálogo
            child: const Text('No'),
          ),
        ],
      ),
    );
  }
}
