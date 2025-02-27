import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timbas/models/printer.dart';
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
          subtitle: Text('Total: \$${cart.getTotalAmount(order.id).toStringAsFixed(2)}'),
          trailing: order.total > 1 ? IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => order.total > 1 ? _imprimirTicket(context, order) : null,
          ) : null,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => OrderDetailScreen(order: order),
            ),
          ),
        );
      },
    );
  }

  // Implementa la funcionalidad para imprimir el ticket
  void _imprimirTicket(BuildContext context, Order order) async {
    try{
      if(order.total>1){
        bool? connected = await Printer().ensureConnection(context);
        if(connected != null && connected){
          final cart = Provider.of<Cart>(context, listen: false);
          final items = cart.getCart(order.id); // Obtiene los ítems del pedido
          await Printer().printTicket(items);
          Provider.of<Cart>(context, listen: false).markOrderAsCompleted(order.id);
        }else{
          ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La impresora no está conectada.', style: TextStyle(color: Colors.red),),
            duration: Duration(seconds: 2), // Duración del mensaje
            ),
          );
        }
      }
    }catch (e) {
      // Maneja el error, mostrando un mensaje al usuario
      print('Error al imprimir: $e'); // Registra el error en la consola

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
  }
}