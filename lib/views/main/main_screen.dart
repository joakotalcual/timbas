import 'package:flutter/material.dart';
import 'package:timbas/models/printer.dart';
import 'package:timbas/views/articles/articles_screen.dart';
import 'package:timbas/views/buys/buy_screen.dart';
import 'package:timbas/views/print_ticket/print_ticket_screen.dart';
import 'package:timbas/views/sales/sales_screen.dart';
import 'package:timbas/views/stats/stats_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() async {
    super.initState();
    await Printer().reconnectPrinter(context); // Reconectar impresora al cargar la pantalla principal
  }

  // Mantenemos el índice actual del contenido seleccionado
  int _selectedIndex = 0;

  // Definimos las opciones del Drawer con su respectivo texto y contenido de la pantalla
  final List<Map<String, dynamic>> _drawerOptions = [
    {
      'title': 'Ventas',
      'icon': Icons.shopping_cart,
      'content': const Buys(),
    },
    {
      'title': 'Recibos',
      'icon': Icons.receipt,
      'content': const Sales(),
    },
    {
      'title': 'Estadísticas',
      'icon': Icons.bar_chart,
      'content': const StatsScreen(), // Este será tu nuevo widget
    },
    {
      'title': 'Artículos',
      'icon': Icons.list,
      'content': const ArticlesScreen(),
    },
    {
      'title': 'Configuración',
      'icon': Icons.settings,
      'content': PrintTicketScreen(),
    },
  ];

  void _onSelectItem(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _scaffoldKey.currentState
        ?.closeDrawer(); // Cierra el drawer después de seleccionar una opción
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: IconButton(
          onPressed: () {
            _scaffoldKey.currentState
                ?.openDrawer(); // Usamos la clave para abrir el drawer
          },
          icon: const Icon(
            Icons.menu,
            color: Colors.white,
          ),
        ),
        title: Text(
          _drawerOptions[_selectedIndex]
              ['title'], // Cambia el título según la opción seleccionada
          style: const TextStyle(color: Colors.white),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green,
              ),
              child: Text(
                'Menú\nTimbas y Frappes',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            // Genera las opciones del Drawer dinámicamente
            for (int i = 0; i < _drawerOptions.length; i++)
              ListTile(
                leading: Icon(_drawerOptions[i]['icon'], color: Colors.black87,),
                title: Text(_drawerOptions[i]['title'], style: const TextStyle(color: Colors.black87,),),
                selected: i == _selectedIndex, // Resalta la opción seleccionada
                onTap: () => _onSelectItem(i), // Cambia la pantalla según la opción seleccionada
              ),
          ],
        ),
      ),
      body: _drawerOptions[_selectedIndex]['content'], // Muestra el contenido dinámico
    );
  }
}