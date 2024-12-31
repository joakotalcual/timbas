import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timbas/models/products.dart';
import 'package:timbas/views/cart/cart_screen.dart';
import 'package:timbas/views/cart/components/cart_notifier.dart';
import 'package:timbas/views/order/components/category_screen.dart';

class OrderScreen extends StatelessWidget {
  final String tipoPedido;
  final String? mesa;

  const OrderScreen({super.key, required this.tipoPedido, this.mesa});

  @override
  Widget build(BuildContext context) {
    final cartId = mesa ?? 'takeaway'; // Define el ID del carrito
    // Establece la mesa para el carrito cuando se construye la pantalla
    Provider.of<Cart>(context, listen: false).setMesa(cartId, mesa);
    return Scaffold(
      appBar: AppBar(
        title: Text(tipoPedido == 'Mesa' ? 'MESA $mesa' : 'Para Llevar'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: 2,
              itemBuilder: (context, index) {
                const categoria = '';
                return _buildGridItem(context, categoria as Categoria?, cartId);
              },
            ),
          ),
          const SizedBox(height: 16.0),
          _buildCartSummary(context, cartId),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, Categoria? categoria, String cartId) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CategoryDetailScreen(
              categoria: categoria,
              tipoPedido: tipoPedido,
              mesa: mesa,
              cartId: cartId,
            ),
          ),
        );
      },
      child: Card(
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.asset(
                'assets/images/${categoria?.nombre.toLowerCase().replaceAll(' ', '_')}.png',
                fit: BoxFit.cover,
                height: 120,
                width: double.infinity,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                categoria!.nombre,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartSummary(BuildContext context, String cartId) {
    return Consumer<Cart>(
      builder: (context, cart, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total: \$${cart.getTotalAmount(cartId).toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CartScreen(cartId: cartId),
                  ),
                );
              },
              child: const Text('Ver Carrito'),
            ),
          ],
        );
      },
    );
  }

  void _finalizarPedido(BuildContext context, String cartId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmación'),
        content: Text(
            '¿Deseas finalizar el pedido? Tipo de pedido: $tipoPedido${mesa != null ? ', ID: $mesa' : ''}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Provider.of<Cart>(context, listen: false)
                  .clear(cartId); // Limpia el carrito específico
            },
            child: const Text('Sí'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
        ],
      ),
    );
  }
}