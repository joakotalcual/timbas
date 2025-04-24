import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timbas/services/database/firebase_services.dart';

class SalesStats extends StatefulWidget {
  const SalesStats({super.key});

  @override
  State<SalesStats> createState() => _SalesStatsState();
}

class _SalesStatsState extends State<SalesStats> {
  late Future<List<Map<String, dynamic>>> salesData;
  bool isLoading = false;
  String period = 'week';
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  String periodText = 'Período: Últimos 7 días';

  @override
  void initState() {
    super.initState();
    salesData = fetchSalesData(period: period);
  }

  Map<String, int> contarProductosYExtras(List<Map<String, dynamic>> ventas) {
    Map<String, int> conteo = {};

    for (var venta in ventas) {
      for (var item in venta['items']) {
        String producto = item['product_name'];
        int cantidad = item['quantity'] ?? 1;

        conteo[producto] = (conteo[producto] ?? 0) + cantidad;

        if (item['extras'] != null && item['extras'] is List) {
          for (var extra in item['extras']) {
            String extraNombre = '$producto - Extra: ${extra['extra_name']}';
            conteo[extraNombre] = (conteo[extraNombre] ?? 0) + cantidad;
          }
        }
      }
    }

    return conteo;
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filtros
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(
                periodText,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                        period = 'day';
                        periodText = 'Período: Últimas 24 horas';
                      });
                      final data = await fetchSalesData(period: period);
                      setState(() {
                        salesData = Future.value(data);
                        isLoading = false;
                      });
                    },
                    child: const Text('Día', style: TextStyle(color: Colors.black)),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                        period = 'week';
                        periodText = 'Período: Últimos 7 días';
                      });
                      final data = await fetchSalesData(period: period);
                      setState(() {
                        salesData = Future.value(data);
                        isLoading = false;
                      });
                    },
                    child: const Text('Semana', style: TextStyle(color: Colors.black)),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (_customStartDate != null && _customEndDate != null) {
                        if (_customEndDate!.isBefore(_customStartDate!)) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Fechas inválidas'),
                              content: const Text(
                                  'La fecha de fin debe ser posterior a la de inicio.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                          return;
                        }

                        setState(() {
                          isLoading = true;
                          period = 'custom';
                          periodText =
                              'Período: Del ${DateFormat('dd-MM-yyyy').format(_customStartDate!)} al ${DateFormat('dd-MM-yyyy').format(_customEndDate!)}';
                        });

                        final data = await fetchSalesData(
                          startDate: _customStartDate,
                          endDate: _customEndDate,
                        );

                        setState(() {
                          salesData = Future.value(data);
                          isLoading = false;
                        });
                      }
                    },
                    child:
                        const Text('Aplicar rango', style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _startDateController,
                      readOnly: true,
                      decoration: const InputDecoration(labelText: 'Fecha inicio'),
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
                      decoration: const InputDecoration(labelText: 'Fecha fin'),
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
            ],
          ),
        ),
        const Divider(),
        // Resultados
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.black))
              : FutureBuilder<List<Map<String, dynamic>>>(
                  future: salesData,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                          child: CircularProgressIndicator(color: Colors.black));
                    }

                    final conteo = contarProductosYExtras(snapshot.data!);
                    final productosOrdenados = conteo.entries.toList()
                      ..sort((a, b) => b.value.compareTo(a.value));

                    if (productosOrdenados.isEmpty) {
                      return const Center(
                          child: Text(
                        'No hay ventas registradas en este período.',
                        style: TextStyle(color: Colors.black87),
                      ));
                    }

                    return ListView.builder(
                      itemCount: productosOrdenados.length,
                      itemBuilder: (context, index) {
                        final producto = productosOrdenados[index];
                        return ListTile(
                          title: Text(producto.key,
                              style: const TextStyle(color: Colors.black)),
                          trailing: Text('Vendidos: ${producto.value}',
                              style: const TextStyle(color: Colors.black)),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
