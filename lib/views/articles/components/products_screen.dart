import 'package:flutter/material.dart';
import 'package:timbas/views/articles/components/item_product.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ejemplo de lista de productos para mostrar
    final List<String> products = [
      'Producto 1',
      'Producto 2',
      'Producto 3',
      'Producto 4'
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Productos',
          style: TextStyle(
            color: Colors.white
          ),
        ),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(
          color: Colors.white, // Cambia el color de la flecha de retroceso a blanco
        ),
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(products[index]),
              subtitle: const Text('Categoria'),
              trailing: const Text('\$0.00'), // Precio del producto (ejemplo)
              onTap: () {
                // Navegar a la pantalla de productos
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ItemProduct(isEdit: true,),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Acción cuando se presiona el botón de agregar
          Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ItemProduct(isEdit: false,),
                  ),
                );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}
