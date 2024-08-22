import 'package:flutter/material.dart';
import 'package:timbas/views/order/order_screen.dart';

class PedidoSelectionScreen extends StatelessWidget {
  const PedidoSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Tipo de Pedido'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SeleccionMesaScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Seleccionar Mesa'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const OrdenParaLlevarScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Para Llevar'),
            ),
          ],
        ),
      ),
    );
  }
}

class SeleccionMesaScreen extends StatelessWidget {
  const SeleccionMesaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Puedes reemplazar esto con una lista real de mesas
    final List<String> mesas = [
      'Mesa 1',
      'Mesa 2',
      'Mesa 3',
      'Mesa 4',
      'Mesa 5',
      'Mesa 6'
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Mesa'),
      ),
      body: ListView.builder(
        itemCount: mesas.length,
        itemBuilder: (context, index) {
          final mesa = mesas[index];
          return ListTile(
            title: Text(mesa),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => OrderScreen(
                    tipoPedido: 'Mesa',
                    mesa: '5', // Cambia esto según corresponda
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class OrdenParaLlevarScreen extends StatefulWidget {
  const OrdenParaLlevarScreen({super.key});

  @override
  _OrdenParaLlevarScreenState createState() => _OrdenParaLlevarScreenState();
}

class _OrdenParaLlevarScreenState extends State<OrdenParaLlevarScreen> {
  int _numeroPedidos = 1;

  void _addNewCart() {
    setState(() {
      _numeroPedidos++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos para Llevar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addNewCart,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Número de Pedidos',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    if (_numeroPedidos > 1) {
                      setState(() {
                        _numeroPedidos--;
                      });
                    }
                  },
                ),
                Text(
                  '$_numeroPedidos',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addNewCart,
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PedidoListScreen(
                      numeroPedidos: _numeroPedidos,
                    ),
                  ),
                );
              },
              child: const Text('Seleccionar Productos'),
            ),
          ],
        ),
      ),
    );
  }
}

class PedidoListScreen extends StatelessWidget {
  final int numeroPedidos;

  const PedidoListScreen({super.key, required this.numeroPedidos});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Pedidos para Llevar'),
      ),
      body: ListView.builder(
        itemCount: numeroPedidos,
        itemBuilder: (context, index) {
          final cartId =
              'Para llevar${index + 1}'; // Generar un ID único para cada carrito
          return ListTile(
            title: Text('Pedido ${index + 1}'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => OrderScreen(
                    tipoPedido: 'Para Llevar',
                    mesa: cartId, // Usa el ID del carrito como mesa
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
