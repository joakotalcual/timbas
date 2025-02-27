import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:timbas/services/database/firebase_services.dart';

class Sales extends StatefulWidget {
  const Sales({super.key});

  @override
  _SalesState createState() => _SalesState();
}

class _SalesState extends State<Sales> {
  late Future<List<Map<String, dynamic>>> salesData;
  String period = 'day'; // 'day' or 'week'

  @override
  void initState() {
    super.initState();
    salesData = fetchSalesData(period: period);
  }

  double calculateTotal(List<Map<String, dynamic>> sales) {
    return sales.fold(0.0, (total, sale) => total + (sale['total'] ?? 0.0));
  }

//   String getPeriod(DateTime currentTime) {
//   final hour = currentTime.hour;
//   final now = DateFormat('dd-MM-yyyy').format(currentTime);

//   if (hour < 14) {
//     // De 2 PM del día anterior hasta 1:59 PM del día actual
//     final yesterday = currentTime.subtract(const Duration(days: 1));
//     final formattedYesterday = DateFormat('dd-MM-yyyy').format(yesterday);
//     return '2PM ($formattedYesterday) - 2PM ($now)';
//   } else {
//     // De 2 PM del día actual hasta 1:59 PM del día siguiente
//     final tomorrow = currentTime.add(const Duration(days: 1));
//     final formattedTomorrow = DateFormat('dd-MM-yyyy').format(tomorrow);
//     return '2PM ($now) - 2PM ($formattedTomorrow)';
//   }
// }

  @override
  Widget build(BuildContext context) {
    DateTime time = DateTime.now();
    final today = DateFormat('dd-MM-yyyy').format(time);
    String periodText =
        'Período: Últimas 24 horas (1:59PM)'; //getPeriod(time); // Obtener el periodo dinámico
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ventas'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                today.toUpperCase(),
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                periodText,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        period = 'day';
                        periodText = 'Período: Últimas 24 horas (1:59PM)';
                        salesData = fetchSalesData(period: period);
                      });
                    },
                    child: const Text(
                      'Día',
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        period = 'week';
                        periodText = 'Período: Últimos 7 días';
                        salesData = fetchSalesData(period: period);
                      });
                    },
                    child: const Text(
                      'Semana',
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: salesData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('No hay ventas registradas en este período.'),
                    );
                  }

                  final sales = snapshot.data!;
                  final totalSales = calculateTotal(sales);

                  return Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Ventas: \$${totalSales.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const Divider(),
                        Expanded(
                          child: ListView.builder(
                            itemCount: sales.length,
                            itemBuilder: (context, index) {
                              final sale = sales[index];
                              final timestamp =
                                  (sale['timestamp'] as Timestamp).toDate();
                              final items = sale['items'] ??
                                  []; // Lista de productos en el recibo
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 5),
                                child: ExpansionTile(
                                    title: Text(
                                        'Recibo: ${sale['id'] ?? 'Sin ID'}'),
                                    subtitle: Text(
                                      'Total: \$${(sale['total'] ?? 0.0).toStringAsFixed(2)}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Hora: ${DateFormat('dd-MM-yyyy HH:mm').format(timestamp)}',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 10),
                                            const Text('Productos:',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            const SizedBox(height: 5),
                                            for (var item in sale['items'])
                                              ListTile(
                                                title: Text(
                                                    '${item['quantity']} x ${item['category']} ${item['product_name']}'),
                                                subtitle: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    if (item['comments']
                                                            ?.isNotEmpty ==
                                                        true)
                                                      Text(
                                                          'Comentarios: ${item['comments']}'),
                                                    if (item.containsKey(
                                                            'extras') &&
                                                        (item['extras'] as List)
                                                            .isNotEmpty) ...[
                                                      const Text('Extras:',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: (item[
                                                                    'extras']
                                                                as List)
                                                            .map((extra) => Text(
                                                                '- ${extra['extra_name']}: \$${(extra['extra_price'] ?? 0.0).toStringAsFixed(2)}'))
                                                            .toList(),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                                trailing: Text(
                                                  '\$${(item['total_price'] ?? 0.0).toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 16),
                                                ),
                                              ),
                                            const SizedBox(height: 10),
                                            Center(
                                              child: SizedBox(
                                                width: 300,
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    foregroundColor:
                                                        Colors.black,
                                                    backgroundColor:
                                                        Colors.white,
                                                  ),
                                                  onPressed: () async {
                                                    // Muestra un cuadro de diálogo para confirmar la eliminación
                                                    bool? confirmed =
                                                        await showDialog<bool>(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          title: const Text(
                                                              '¿Estás seguro?'),
                                                          content: const Text(
                                                              '¿Quieres eliminar este pedido? Esta acción no se puede deshacer.'),
                                                          actions: <Widget>[
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(
                                                                        false); // No eliminar
                                                              },
                                                              child: const Text(
                                                                  'Cancelar'),
                                                            ),
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(
                                                                        true); // Confirmar eliminación
                                                              },
                                                              child: const Text(
                                                                  'Eliminar'),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );

                                                    // Si el usuario confirma, elimina el pedido
                                                    if (confirmed == true) {
                                                      await deleteOrder(sale[
                                                          'id']); // Eliminar el pedido de Firebase usando su ID
                                                      // Recargar los datos de ventas después de la eliminación
                                                      setState(() {
                                                        salesData = fetchSalesData(
                                                            period:
                                                                period); // Recargar las ventas para actualizar la vista
                                                      });
                                                    }
                                                  },
                                                  child: const Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(Icons.cancel),
                                                      SizedBox(width: 8),
                                                      Text('Cancelar producto'),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ]),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
