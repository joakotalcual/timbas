import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timbas/models/printer.dart';
import 'package:timbas/services/database/firebase_services.dart';
import 'package:timbas/services/database/sqlite.dart';
import 'package:timbas/views/cart/components/cart_notifier.dart';
import 'package:timbas/views/payment/payment_screen.dart';

class CompletedOrdersTab extends StatefulWidget {
  const CompletedOrdersTab({super.key});

  @override
  State<CompletedOrdersTab> createState() => _CompletedOrdersTabState();
}

class _CompletedOrdersTabState extends State<CompletedOrdersTab> {
  // Lista de órdenes completadas
  List<Order> completedOrders = [];

  // Cargar órdenes locales
  Future<void> loadOrders() async {
    final orders = await getLocalOrders();
    final today = DateTime.now();
    final startOfDay =
        DateTime(today.year, today.month, today.day, 14); // Hoy a las 2:00 PM
    final endOfDay =
        startOfDay.add(const Duration(hours: 24)); // Mañana a las 2:00 PM

    setState(() {
      completedOrders = orders
          .where((order){
            final orderDate = DateTime.parse(order.timestamp.toString()); // Convertir a DateTime
          return orderDate.isAfter(startOfDay) &&
                orderDate.isBefore(endOfDay);
          }).toList();
      completedOrders.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    });
  }

  @override
  void initState() {
    super.initState();
    loadOrders(); // Cargar las órdenes cuando se inicializa el widget
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Order>>(
      future:
          getLocalOrders(), // Obtener las órdenes locales desde la base de datos
      builder: (context, snapshot) {
        // Si está cargando los datos
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator()); // Indicador de carga mientras se obtiene la data
        }

        // Si ocurrió un error
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}')); // Mostrar el error si ocurre
        }

        // Si no hay datos o está vacío
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No hay órdenes completadas hoy.'));
        }

        final completedOrders = snapshot.data!;
        // Obtener el día de inicio (hoy a las 2 PM)
        final today = DateTime.now();
        final startOfDay = DateTime(
            today.year, today.month, today.day, 14); // Hoy a las 2:00 PM

        // Obtener el día de fin (mañana a las 12 PM)
        final endOfDay =
            startOfDay.add(const Duration(hours: 24)); // Mañana a las 2:00 PM

        // Filtrar órdenes dentro de ese rango
        final filteredOrders = completedOrders.where((order) {
          final orderDate = DateTime.parse(order.timestamp.toString()); // Convertir a DateTime
          return orderDate.isAfter(startOfDay) && orderDate.isBefore(endOfDay);
        }).toList();


        // Ordenar las órdenes por timestamp en orden descendente
        filteredOrders.sort((a, b) => b.timestamp.compareTo(a.timestamp));

        if(filteredOrders.isEmpty){
          return const Center(child: Text('No hay órdenes completadas hoy.'));
        }

        return ListView.builder(
          itemCount: filteredOrders.length,
          itemBuilder: (context, index) {
            final order = filteredOrders[index];

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              color: order.mesa != 'preparando' ? null : Colors.redAccent[200],
              child: ExpansionTile(
                title: Text('ID PEDIDO: ${order.id}'),
                subtitle: Text('Total: \$${order.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                children: [
                  // Detalles del pedido
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hora: ${DateFormat('dd-MM-yyyy -- HH:mm').format(DateTime.parse(order.timestamp.toIso8601String()))}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Text('Productos:'),
                        // Lista de productos en el pedido
                        for (var item in order.items)
                          ListTile(
                            title: Text(
                                '${item.cantidad} x ${item.categoria} ${item.producto.nombre}'),
                            subtitle: item.comentario != ''
                                ? Text('Adicionales: ${item.comentario}')
                                : null,
                            trailing: Text(
                              '\$${item.totalPrice.toStringAsFixed(2)}',
                              style:
                                  const TextStyle(color: Colors.black, fontSize: 16),
                            ),
                          ),
                        Center(
                          child: SizedBox(
                            width: 300,
                            child: ElevatedButton(
                              style: ButtonStyle(
                                foregroundColor: WidgetStateProperty.all<Color>(
                                    Colors.black),
                                backgroundColor: WidgetStateProperty.all<Color>(
                                    Colors.white),
                              ),
                              onPressed: () async {
                                // Implementa la funcionalidad para imprimir el ticket aquí
                                bool? connected = await Printer().ensureConnection(context);
                                if(connected != null && connected){
                                double? amount = await showPaymentDialog(
                                    context, order.total);
                                  if (amount != 0.0) {
                                    await Printer().printTicketClient(order.items, order.id, amount ?? order.total);
                                    if (order.mesa == 'preparando') {
                                      await addOrders(order.id, order);
                                      await updateLocalOrder(
                                          order.id, 'terminado');
                                      loadOrders(); // Vuelve a cargar las órdenes actualizadas
                                    }
                                  } else {
                                    print('No realizar nada porque cancelo');
                                  }
                                }
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(order.mesa == 'preparando'
                                      ? Icons.payments
                                      : Icons.print),
                                  const SizedBox(width: 8),
                                  Text(order.mesa == 'preparando'
                                      ? 'Cobrar al cliente'
                                      : 'Reimprimir ticket cliente'),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
