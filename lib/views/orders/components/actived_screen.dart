import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timbas/models/cart.dart';
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
              _showConfirmationDialog(context, order.id, null);
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
          title: Text(
            '${cartItem.categoria} DE ${cartItem.producto.nombre}',
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('CANTIDAD: ${cartItem.cantidad}'),
              if (cartItem.comentario != null && cartItem.comentario!.isNotEmpty)
                Text('Comentarios: ${cartItem.comentario}'),
            ],
          ),
          trailing: SizedBox(
            width: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    if (cartItem.cantidad == 1) {
                      _showConfirmationDialog(context, order.id, cartItem);
                    } else {
                      Provider.of<Cart>(context, listen: false)
                          .removeItem(order.id, cartItem.producto, cartItem.categoria, cartItem.comentario);
                    }
                  },
                ),
                Text('${cartItem.cantidad}'),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    Provider.of<Cart>(context, listen: false).addItem(
                      order.id, cartItem.producto, cartItem.categoria, cartItem.comentario ?? ''
                    );
                  },
                ),
              ],
            ),
          ),
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
    BuildContext context, String cartId, CartItem? cartItem) {
  // Determina si estamos eliminando un artículo o el carrito entero
  final isRemovingItem = cartItem != null;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Confirmación'),
      content: Text(
        isRemovingItem
            ? '¿Estás seguro de que deseas eliminar "${cartItem.producto.nombre}" del carrito?'
            : '¿Estás seguro de que deseas eliminar todos los productos del carrito? $cartId',
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Cierra el diálogo

            // Realiza la acción dependiendo de si es un ítem o el carrito completo
            if (isRemovingItem) {
              Provider.of<Cart>(context, listen: false).removeItem(
                cartId,
                cartItem.producto,
                cartItem.categoria,
                cartItem.comentario,
              );
            } else {
              Provider.of<Cart>(context, listen: false).clear(cartId);
            }
          },
          child: const Text('Sí'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(), // Solo cierra el diálogo
          child: const Text('No'),
        ),
      ],
    ),
  );
}

}
