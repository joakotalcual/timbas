import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timbas/views/cart/components/cart_notifier.dart';
import 'package:timbas/views/orders/components/actived_screen.dart';

class CompletedOrdersTab extends StatelessWidget {
  const CompletedOrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    final completedOrders = cart.getCompletedOrders(); // Método para obtener pedidos finalizados

    return ListView.builder(
      itemCount: completedOrders.length,
      itemBuilder: (context, index) {
        final order = completedOrders[index];
        return ListTile(
          title: Text('Mesa: ${order.mesa ?? 'Para Llevar'}'),
          subtitle: Text('Total: \$${order.total.toStringAsFixed(2)}'),
          trailing: IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => OrderDetailScreen(order: order),
              ),
            ),
          ),
        );
      },
    );
  }
}