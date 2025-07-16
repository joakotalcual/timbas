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
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  String periodText = "";
  @override
  void initState() {
    super.initState();
    periodText =
        'Período: Últimas 24 horas (1:59PM)'; //getPeriod(time); // Obtener el periodo dinámico
    salesData = fetchSalesData(period: period);
  }

  double calculateTotal(List<Map<String, dynamic>> sales) {
    return sales.fold(0.0, (total, sale) => total + (sale['total'] ?? 0.0));
  }

  double calcularGanancia(List<Map<String, dynamic>> sales, double total) {
    // Mapa con los valores asignados a cada producto
  final productValues = {
    'Queso': 38.0,
    'Salchicha': 39.0,
    'Mixta': 41.0,
    'Paquete Queso': 133.0,
    'Paquete Salchicha': 127.0,
    'Paquete Mixta': 136.0,
    'salchipulpo': 28.0,
    'Paquete 2 Salchicha': 134,
    'Paquete 2 Mixta': 136,
    'Paquete 2 Queso': 139,
    'Helado Frito': 23,
    'Waffle': 42,
  };
  double gananciaTotal = 0.0;

  for (var sale in sales) {
    final items = sale['items'] as List<dynamic>?;

    if (items != null) {
      for (var item in items) {
        final productName = item['product_name'] as String?;
        final quantity = item['quantity'] ?? 1;

        if (productName != null && productValues.containsKey(productName)) {
          gananciaTotal += productValues[productName]! * quantity;
        }
      }
    }
  }

  return gananciaTotal;
  }

  double calcularBanco(double win, double total) {
    return total - win ;
  }


  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DateTime time = DateTime.now();
    final today = DateFormat('dd-MM-yyyy').format(time);
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
                  Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(
                        Icons.filter_alt,
                        color: Colors.black87,
                      ),
                      label: const Text(
                        'Filtrar por fechas',
                        style: TextStyle(color: Colors.black87),
                      ),
                      onPressed: () {
                        if (_customStartDate != null &&
                            _customEndDate != null) {
                          if (_customEndDate!.isBefore(_customStartDate!)) {
                            // Mostrar alerta si las fechas no son válidas
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Rango de fechas no válido'),
                                content: const Text(
                                    'La fecha de fin debe ser igual o posterior a la fecha de inicio.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('OK'),
                                  )
                                ],
                              ),
                            );
                            return; // Salimos y no actualizamos nada
                          }
                          final formattedStart = DateFormat('dd-MM-yyyy')
                              .format(_customStartDate!);
                          final formattedEnd =
                              DateFormat('dd-MM-yyyy').format(_customEndDate!);
                          setState(() {
                            salesData = fetchSalesData(
                              startDate: _customStartDate,
                              endDate: _customEndDate,
                            );
                            periodText =
                                'Período: Del $formattedStart al $formattedEnd';
                          });
                        }
                      },
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filtrar por fechas:',
                    style: TextStyle(color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _startDateController,
                          readOnly: true,
                          style: const TextStyle(color: Colors.black87),
                          decoration: const InputDecoration(
                            labelText: 'Fecha inicio',
                            border: OutlineInputBorder(),
                          ),
                          onTap: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setState(() {
                                _customStartDate = picked;
                                _startDateController.text =
                                    DateFormat('dd-MM-yyyy').format(picked);
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _endDateController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Fecha fin',
                            border: OutlineInputBorder(),
                          ),
                          onTap: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setState(() {
                                _customEndDate = picked;
                                _endDateController.text =
                                    DateFormat('dd-MM-yyyy').format(picked);
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const SizedBox(height: 16),
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
                  final totalWin = calcularGanancia(sales, totalSales);
                  final totalBank = calcularBanco(totalWin, totalSales);

                  return Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Ventas: \$${totalSales.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Total Banco: \$${totalWin.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Total Ganancia: \$${totalBank.toStringAsFixed(2)}',
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
