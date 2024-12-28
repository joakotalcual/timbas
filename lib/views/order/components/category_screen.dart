import 'package:flutter/material.dart';
import 'package:timbas/controllers/bd_controller.dart';
import 'package:timbas/models/products.dart';
import 'package:timbas/views/order/components/item_details.dart';

class CategoryDetailScreen extends StatelessWidget {
  final Categoria categoria;
  final String? tipoPedido;
  final String? mesa;
  final String cartId; // Añade el cartId

  const CategoryDetailScreen({
    super.key,
    required this.categoria,
    this.tipoPedido,
    this.mesa,
    required this.cartId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(categoria.nombre),
      ),
      body: FutureBuilder(
        future: getLocalProductsFuture(categoria.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final products = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                if (product.activo) {
                  return _buildGridItem(
                      context, product, categoria.nombre, cartId);
                } else {
                  return SizedBox.shrink(); // Retorna un widget vacío.
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, Producto producto,
      String categoriaNombre, String carID) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ItemDetailScreen(
              producto: producto,
              categoria: categoriaNombre,
              cartId: carID,
            ),
          ),
        );
      },
      child: Card(
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.asset(
                producto.imagen,
                fit: BoxFit.cover,
                height: 120,
                width: double.infinity,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                producto.nombre,
                maxLines: 2,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
