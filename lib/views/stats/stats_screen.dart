import 'package:flutter/material.dart';
import 'package:timbas/views/stats/investment_screen.dart';
import 'package:timbas/views/stats/sales_screen.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Estadísticas'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Ventas'),
              Tab(text: 'Inversiones'),
            ],
            labelColor: Colors.black,  // Color del texto de las pestañas seleccionadas
        unselectedLabelColor: Colors.grey,  // Color del texto de las pestañas no seleccionadas
        indicatorColor: Colors.black,
          ),
        ),
        body: const TabBarView(
          children: [
            SalesStats(),
            InvestmentScreen(),
          ],
        ),
      ),
    );
  }
}
