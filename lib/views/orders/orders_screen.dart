import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timbas/views/cart/components/cart_notifier.dart';
import 'package:timbas/views/orders/components/actived_screen.dart';
import 'package:timbas/views/orders/components/completed_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Órdenes'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pedidos Activos'),
              Tab(text: 'Pedidos Finalizados'),
              //Tab(text: 'Productos'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ActiveOrdersTab(),
            CompletedOrdersTab(),
            //ProductosScreen(),
          ],
        ),
      ),
    );
  }
}

class ActiveOrdersTab extends StatelessWidget {
  const ActiveOrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    final activeOrders = cart.getActiveOrders(); // Método para obtener pedidos activos

    return ListView.builder(
      itemCount: activeOrders.length,
      itemBuilder: (context, index) {
        final order = activeOrders[index];
        return ListTile(
          title: Text('Mesa: ${order.mesa ?? 'Para Llevar'}'),
          subtitle: Text('Total: \$${order.total.toStringAsFixed(2)}'),
          trailing: IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => _imprimirTicket(context, order),
          ),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => OrderDetailScreen(order: order),
            ),
          ),
        );
      },
    );
  }

  void _imprimirTicket(BuildContext context, Order order) {
    // Implementa la funcionalidad para imprimir el ticket aquí
    // Después de imprimir, puedes mover el pedido a la lista de pedidos finalizados
    Provider.of<Cart>(context, listen: false).markOrderAsCompleted(order.id);
  }
}