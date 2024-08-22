import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timbas/models/cart.dart';
import 'package:timbas/views/cart/components/cart_notifier.dart';

class CartScreen extends StatelessWidget {
  final String cartId;

  const CartScreen({super.key, required this.cartId});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    final items = cart.getCart(cartId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito de Compras'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final cartItem = items[index];
                return ListTile(
                  title: Text(
                      '${cartItem.categoria} DE ${cartItem.producto.nombre}'),
                  subtitle: Text('CANTIDAD: ${cartItem.cantidad}'),
                  trailing: SizedBox(
                    width: 150,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            if (cartItem.cantidad == 1) {
                              _showConfirmationDialog(
                                  context, cartId, cartItem);
                            } else {
                              Provider.of<Cart>(context, listen: false)
                                  .removeItem(cartId, cartItem.producto,
                                      cartItem.categoria);
                            }
                          },
                        ),
                        Text('${cartItem.cantidad}'),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            Provider.of<Cart>(context, listen: false).addItem(
                                cartId, cartItem.producto, cartItem.categoria);
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
              'Total: \$${cart.getTotalAmount(cartId).toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Imprimir ticket'),
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog(
      BuildContext context, String cartId, CartItem cartItem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmación'),
        content: Text(
            '¿Estás seguro de que deseas eliminar "${cartItem.producto.nombre}" del carrito?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cierra el diálogo
              Provider.of<Cart>(context, listen: false)
                  .removeItem(cartId, cartItem.producto, cartItem.categoria);
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