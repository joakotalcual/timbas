import 'package:flutter/material.dart';
import 'package:timbas/views/articles/articles_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
      'content': const Center(child: Text('Pantalla de Recibos')),
    },
    {
      'title': 'Artículos',
      'icon': Icons.list,
      'content': const ArticlesScreen(),
    },
    {
      'title': 'Configuración',
      'icon': Icons.settings,
      'content': const Center(child: Text('Pantalla de Configuración')),
    },
  ];

  void _onSelectItem(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _scaffoldKey.currentState?.closeDrawer(); // Cierra el drawer después de seleccionar una opción
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: IconButton(
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer(); // Usamos la clave para abrir el drawer
          },
          icon: const Icon(
            Icons.menu,
            color: Colors.white,
          ),
        ),
        title: Text(
          _drawerOptions[_selectedIndex]['title'], // Cambia el título según la opción seleccionada
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
                leading: Icon(_drawerOptions[i]['icon']),
                title: Text(_drawerOptions[i]['title']),
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

class Buys extends StatelessWidget {
  const Buys({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  color: Colors.green,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      "TICKETS\nABIERTOS",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.green,
                  child: TextButton(
                    onPressed: () {},
                    child: const Column(
                      children: [
                        Text(
                          "COBRAR\n\$0.00",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: DropdownButton<String>(
                  value: "Todos los artículos",
                  items: const [
                    DropdownMenuItem(
                      value: "Todos los artículos",
                      child: Text("Todos los artículos"),
                    ),
                  ],
                  onChanged: (value) {},
                ),
              ),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {},
              ),
            ],
          ),
        ),
        ListTile(
          leading: Container(
            width: 20,
            height: 20,
            color: Colors.grey,
          ),
          title: const Text("Combinado"),
          trailing: const Text("\$75.00"),
        ),
        ListTile(
          leading: Container(
            width: 20,
            height: 20,
            color: Colors.red,
          ),
          title: const Text("Oreo"),
          trailing: const Text("\$60.00"),
        ),
      ],
    );
  }
}