import 'package:flutter/material.dart';
import 'package:timbas/controllers/bd_controller.dart';
import 'package:timbas/helpers/responsive.dart';
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
    var responsive = Responsive(context);
    bool isLandscape = responsive.isLandscape;
    bool isSmallScreen = responsive.isSmallScreen;
    return Scaffold(
      appBar: AppBar(
        title: Text(categoria.nombre),
      ),
      body: FutureBuilder(
        future: Future.wait([
          getLocalProductsFuture(
              categoria.id), // productos de la categoría actual
          getLocalProductsFuture(
              "LLO2BaBZeqwVHpvbKPkj"), // productos de la categoría frappes
        ]),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final List<Producto> products = snapshot.data![0]; // categoría actual
          final List<Producto> frappesExtras =
              snapshot.data![1]; // siempre disponibles

          final activeProducts =
              products.where((product) => product.activo).toList();
          final activeFrappes =
              frappesExtras.where((product) => product.activo).toList();
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isLandscape && !isSmallScreen ? 5 : 3,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: activeProducts.length,
              itemBuilder: (context, index) {
                final product = activeProducts[index];
                // Si la categoría es "Frappes", pasamos la lista de productos activos
                return _buildGridItem(
                    context, product, categoria.nombre, cartId, activeFrappes);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, Producto producto,
      String categoriaNombre, String carID, List<Producto>? productosFrappes) {
    var responsive = Responsive(context);
    bool isLandscape = responsive.isLandscape;
    bool isSmallScreen = responsive.isSmallScreen;
    bool isMediumScreen = responsive.isMediumScreen;
    double fontTitle = responsive.fontSizeTitle;
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ItemDetailScreen(
              producto: producto,
              categoria: categoriaNombre,
              cartId: carID,
              productosRelacionados: productosFrappes,
            ),
          ),
        );
      },
      child: Card(
        child: Column(
          children: [
            Image.asset(
              producto.imagen,
              fit: BoxFit.contain,
              height: isLandscape && !isSmallScreen
                  ? 120
                  : !isLandscape && isMediumScreen
                      ? 130
                      : 75,
            ),
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Text(
                producto.nombre,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isLandscape && !isSmallScreen
                      ? fontTitle - 1.2
                      : isSmallScreen
                          ? fontTitle - 3
                          : fontTitle,
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
