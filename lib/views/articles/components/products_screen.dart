
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timbas/controllers/bd_controller.dart';
import 'package:timbas/services/database/sqlite.dart';
import 'package:timbas/views/articles/components/item_product.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtén las categorías desde la base de datos local
    Future<List<Map<String, dynamic>>> categoriesFuture = getLocalCategories();

    // Stream de productos
    Stream<List<Map<String, dynamic>>> productsStream =
        getLocalProductsStream();
    Map<String, String> categoryNames = {};

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Productos',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(
          color: Colors
              .white, // Cambia el color de la flecha de retroceso a blanco
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<List<List<Map<String, dynamic>>>>(
          stream: Rx.combineLatest2(
            productsStream,
            Stream.fromFuture(categoriesFuture),
            (List<Map<String, dynamic>> products,
                    List<Map<String, dynamic>> categories) =>
                [products, categories],
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else if (!snapshot.hasData ||
                snapshot.data![0].isEmpty ||
                snapshot.data![1].isEmpty) {
              return const Center(
                child: Text('No se encontraron productos o categorías.'),
              );
            } else {
              List<Map<String, dynamic>> products = snapshot.data![0];
              List<Map<String, dynamic>> categories = snapshot.data![1];

              // Mapa para los nombres de categorías
              categoryNames = {
                for (var category in categories)
                  category['uid'] as String: category['nombre'] as String,
              };
              return ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  bool active = products[index]['activo'] == 1; // Ajuste para convertir 1/0 a bool
                  return Container(
                    color: active ?const Color.fromARGB(132, 226, 255, 191) : Colors.grey.shade200,
                    child: ListTile(
                      leading: Icon(
                        active ? Icons.check : Icons.report,
                        color: active ? Colors.green : Colors.red,
                      ),
                      title: Text(products[index]['nombre']),
                      subtitle: Text(
                          categoryNames[products[index]['categorias']] ??
                              'Categoría desconocida'),
                      trailing: Text(
                        '\$${products[index]['precio']}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {
                        // Navegar a la pantalla de productos
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ItemProduct(
                              isEdit: true,
                              active: active,
                              category: products[index]['categorias'],//Bug corregido
                              image: products[index]['imagen'],
                              name: products[index]['nombre'],
                              price: products[index]['precio'],
                              uid: products[index]['uid'],
                              categoryNames : categoryNames,
                              extra: products[index]['extra'],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Acción cuando se presiona el botón de agregar
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ItemProduct(
                isEdit: false,
                categoryNames : categoryNames
              ),
            ),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
