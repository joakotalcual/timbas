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

  String getPeriod(DateTime currentTime) {
    final hour = currentTime.hour;
    final now = DateFormat('dd-MM-yyyy').format(currentTime);

    // Definir el periodo de tiempo según la hora
    if (hour >= 2 && hour < 12) {
      // De 12 AM a 1:59 PM
      final yesterday = currentTime.subtract(const Duration(days: 1));
      final formattedYesterday = DateFormat('dd-MM-yyyy').format(yesterday);
      return '2PM ($formattedYesterday) - 2PM ($now)';
    } else {
      // De 2 PM a 11:59 PM
      final tomorrow = currentTime.add(const Duration(days: 1));
      final formattedTomorrow = DateFormat('dd-MM-yyyy').format(tomorrow);
      return '2PM ($now) - 2PM ($formattedTomorrow)';
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime time = DateTime.now();
    final today = DateFormat('dd-MM-yyyy').format(time);
    final periodText = getPeriod(time); // Obtener el periodo dinámico

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
                'Período: $periodText',
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
                                                subtitle: item['comments']
                                                            ?.isNotEmpty ==
                                                        true
                                                    ? Text(
                                                        'Adicionales: ${item['comments']}')
                                                    : null,
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
                                                    // Implementa la lógica para cancelar el producto aquí
                                                    print(
                                                        'Cancelar producto implementado');
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
