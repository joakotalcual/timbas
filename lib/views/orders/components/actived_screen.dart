import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timbas/models/cart.dart';
import 'package:timbas/models/printer.dart';
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
          order.total > 1 ? ElevatedButton(
            style: ButtonStyle(
                foregroundColor: WidgetStateProperty.all<Color>(Colors.black),
                backgroundColor: WidgetStateProperty.all<Color>(Colors.white70),
              ),
            onPressed: () {
              _showConfirmationDialog(context, order.id, null);
              //Navigator.pop(context);
            },
            child: SizedBox(
                    width: 250,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.delete, color: Colors.black54),
                const SizedBox(width: 8),
                Text('ELIMINAR PEDIDO', style: TextStyle(color: Colors.red[600]),),
              ],
            ),
            ),
          ) : const SizedBox.shrink(),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final cartItem = items[index];
                return ListTile(
                  title: Text(
                    '${cartItem.categoria} DE ${cartItem.producto.nombre} \$${cartItem.producto.precio}',
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CANTIDAD: ${cartItem.cantidad}'),
                      if (cartItem.comentario != '' &&
                          cartItem.comentario.isNotEmpty)
                        Text('Comentarios: ${cartItem.comentario}'),
                      if (cartItem.extras.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: cartItem.extras.map((extra) {
                            return Text(
                              'Extra: ${extra.nombre} - \$${extra.precio.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 12),
                            );
                          }).toList(),
                        ),
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
                              _showConfirmationDialog(
                                  context, order.id, cartItem);
                            } else {
                              Provider.of<Cart>(context, listen: false)
                                  .removeItem(order.id, cartItem.producto,
                                      cartItem.categoria, cartItem.comentario, cartItem.extras);
                            }
                          },
                        ),
                        Text('${cartItem.cantidad}'),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            Provider.of<Cart>(context, listen: false).addItem(
                                order.id,
                                cartItem.producto,
                                cartItem.categoria,
                                cartItem.comentario,
                                cartItem.extras);
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
          order.total > 1 ? SizedBox(
            width: 200,
            child: ElevatedButton(
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.all<Color>(Colors.black),
                backgroundColor: WidgetStateProperty.all<Color>(Colors.white70),
              ),
              onPressed: () async {
                try{
                  // Implementa la funcionalidad para imprimir el ticket aquí
                  if(order.total>1){
                    bool? connected = await Printer().ensureConnection(context);
                    if(connected != null && connected){
                      await Printer().printTicket(items);
                      Provider.of<Cart>(context, listen: false)
                        .markOrderAsCompleted(order.id);
                    }else{
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('La impresora no está conectada.', style: TextStyle(color: Colors.red),),
                          duration: Duration(seconds: 2), // Duración del mensaje
                        ),
                      );
                    }
                  }
                } catch (e) {
                  // Maneja el error, mostrando un mensaje al usuario
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Error de impresión', style: TextStyle(color: Colors.red),),
                        content: const Text('No se pudo imprimir el ticket. Verifique la conexión de la impresora o si tiene papel.', style: TextStyle(color: Colors.black),),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Aceptar', style: TextStyle(color: Colors.black),),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.print),
                  SizedBox(width: 8),
                  Text('Imprimir Ticket'),
                ],
              ),
            ),
          ) : const SizedBox.shrink(),
          const SizedBox(
            height: 8,
          ),
        ],
      ),
    );
  }

  Future<bool> _showConfirmationDialog  (
      BuildContext context, String cartId, CartItem? cartItem) async {
    // Determina si estamos eliminando un artículo o el carrito entero
    final isRemovingItem = cartItem != null;
    bool option = false;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmación'),
        content: Text(
          isRemovingItem
              ? '¿Estás seguro de que deseas eliminar "${cartItem.producto.nombre}" del carrito?'
              : '¿Estás seguro de que deseas eliminar todos los productos del carrito? $cartId-1',
        ),
        actions: [
          TextButton(
            onPressed: () {
              final cart = Provider.of<Cart>(context, listen: false);
              Navigator.of(context).pop(); // Cierra el diálogo

              // Realiza la acción dependiendo de si es un ítem o el carrito completo
              if (isRemovingItem) {
                cart.removeItem(
                  cartId,
                  cartItem.producto,
                  cartItem.categoria,
                  cartItem.comentario,
                  cartItem.extras
                );
                option = true;
                if(cart.getTotalAmount(cartId) < 1){
                  Navigator.of(context).pop(); // Solo cierra el diálogo
                  Navigator.of(context).pop(); // Solo cierra el diálogo
                }
              } else {
                cart.clear(cartId);
                option = true;
                Navigator.of(context).pop(); // Solo cierra el diálogo
                Navigator.of(context).pop(); // Solo cierra el diálogo
              }
            },
            child: const Text('Sí', style: TextStyle(color: Colors.redAccent)),
          ),
          TextButton(
            onPressed: () {
                option = false;
                Navigator.of(context).pop(); // Solo cierra el diálogo
            },
            child: const Text('No', style: TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
    return option;
  }
}
