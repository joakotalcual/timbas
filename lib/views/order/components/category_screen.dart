import 'package:flutter/material.dart';
import 'package:timbas/models/products.dart';
import 'package:timbas/views/order/components/item_details.dart';

class CategoryDetailScreen extends StatelessWidget {
  final Categoria categoria;
  final String tipoPedido;
  final String? mesa;
  final String cartId; // Añade el cartId

  const CategoryDetailScreen({
    super.key,
    required this.categoria,
    required this.tipoPedido,
    this.mesa,
    required this.cartId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(categoria.nombre),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: categoria.productos.length,
        itemBuilder: (context, index) {
          final producto = categoria.productos[index];
          return _buildGridItem(context, producto, categoria.nombre, cartId);
        },
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, Producto producto,
      String categoriaNombre, String cartId) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ItemDetailScreen(
              producto: producto,
              categoria: categoriaNombre,
              tipoPedido: tipoPedido,
              mesa: mesa,
              cartId: cartId, // Pasa el cartId
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
                style: const TextStyle(
                  fontSize: 16,
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