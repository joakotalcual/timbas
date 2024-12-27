import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timbas/controllers/bd_controller.dart';
import 'package:timbas/models/products.dart';
import 'package:timbas/views/articles/articles_screen.dart';
import 'package:timbas/views/cart/components/cart_notifier.dart';
import 'package:timbas/views/order/components/category_screen.dart';
import 'package:timbas/views/orders/orders_screen.dart';
import 'package:timbas/views/print_ticket/print_ticket_screen.dart';

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
                leading: Icon(_drawerOptions[i]['icon']),
                title: Text(_drawerOptions[i]['title']),
                selected: i == _selectedIndex, // Resalta la opción seleccionada
                onTap: () => _onSelectItem(
                    i), // Cambia la pantalla según la opción seleccionada
              ),
          ],
        ),
      ),
      body: _drawerOptions[_selectedIndex]
          ['content'], // Muestra el contenido dinámico
    );
  }
}

class Buys extends StatelessWidget {
  const Buys({super.key});

  @override
  Widget build(BuildContext context) {
    const cartId = 'mesa'; // Define el ID del carrito
    // Establece la mesa para el carrito cuando se construye la pantalla
    Provider.of<Cart>(context, listen: false).setMesa(cartId, 'mesa-1');
    return Column(
      children: [
        Container(
          color: Colors.green,
          child: Row(
            children: [
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0), // Espaciado vertical
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.zero,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const OrdersScreen()));
                  },
                  child: const Text(
                    "Tickets\nabiertos",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _buildCartSummary(context, cartId),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
        Expanded(
          child: FutureBuilder(
            future:
                getLocalCategoriesFuture(), // Asegúrate de que el stream devuelva List<QueryRow>
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final categories = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 25.0,
                    mainAxisSpacing: 25.0,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return _buildGridItem(context, category, cartId);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGridItem(
      BuildContext context, Categoria categoria, String carID) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CategoryDetailScreen(
              categoria: categoria,
              cartId: carID,
            ),
          ),
        );
      },
      child: Card(
        child: Column(
          children: [
            Image.asset(
              'assets/images/${categoria.nombre.toLowerCase().replaceAll(' ', '_')}.png',
              height: 200,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                categoria.nombre,
                maxLines: 2,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartSummary(BuildContext context, String cartId) {
    return Consumer<Cart>(
      builder: (context, cart, child) {
        return Expanded(
          child: Text(
            'Total: \$${cart.getTotalAmount(cartId).toStringAsFixed(2)}',
            textAlign: TextAlign.center,
            maxLines: 2,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        );
      },
    );
  }
}
