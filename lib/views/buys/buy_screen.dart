import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timbas/controllers/bd_controller.dart';
import 'package:timbas/helpers/responsive.dart';
import 'package:timbas/models/products.dart';
import 'package:timbas/views/cart/components/cart_notifier.dart';
import 'package:timbas/views/order/components/category_screen.dart';
import 'package:timbas/views/orders/orders_screen.dart';

class Buys extends StatefulWidget {
  const Buys({super.key});

  @override
  State<Buys> createState() => _BuysState();
}

class _BuysState extends State<Buys> {
  late Future<List<Categoria>> _categoriesFuture;
  bool content = false;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = getLocalCategoriesFuture();
    Provider.of<Cart>(context, listen: false).setMesa('mesa', 'mesa-1');
  }

  Future<void> _syncAndRefreshCategories() async {
    await syncCategoriesFromFirestore();
    await syncProductsFromFirestore();
    setState(() {
      _categoriesFuture = getLocalCategoriesFuture();
    });
  }

  @override
  Widget build(BuildContext context) {
    const cartId = 'preparando'; // Define el ID del carrito
    var responsive = Responsive(context);
    bool isLandscape = responsive.isLandscape;
    bool isSmallScreen = responsive.isSmallScreen;
    bool isMediumScreen = responsive.isMediumScreen;
    double fontTitle = responsive.fontSizeTitle;

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
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const OrdersScreen()));
                  },
                  child: Text(
                    "Tickets\nabiertos",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: fontTitle,
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
                _categoriesFuture, // Asegúrate de que el stream devuelva List<QueryRow>
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final categories = snapshot.data!;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  content = categories.length > 1; // Actualiza content según el resultado
                });
              });
              return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: content
                      ? GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isLandscape && !isSmallScreen ? 3 : isSmallScreen ? 2 : isMediumScreen ? 3 : 4,
                            crossAxisSpacing: 25.0,
                            mainAxisSpacing: 25.0,
                          ),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            return _buildGridItem(context, category, cartId);
                          },
                        )
                      : const SizedBox.shrink());
            },
          ),
        ),
        if(!content)
          SizedBox(
          height: 50,
          width: 200,
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
              foregroundColor: WidgetStateProperty.all<Color>(Colors.black),
            ),
            onPressed: () async {
              await _syncAndRefreshCategories();
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.refresh,
                ),
                SizedBox(
                  width: 16,
                ),
                Text(
                  'Actualizar',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGridItem(
      BuildContext context, Categoria categoria, String carID) {
      var responsive = Responsive(context);
      bool isLandscape = responsive.isLandscape;
      bool isSmallScreen = responsive.isSmallScreen;
      bool isMediumScreen = responsive.isMediumScreen;
      double fontTitle = responsive.fontSizeTitle;
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
              height: isLandscape && !isSmallScreen ? 200 : isSmallScreen ? 100 : isMediumScreen && isLandscape ? 170 : isMediumScreen && !isLandscape ? 100 : 200,
              fit: BoxFit.contain,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                categoria.nombre,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fontTitle,
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
    var responsive = Responsive(context);
      double fontTitle = responsive.fontSizeTitle;
    return Consumer<Cart>(
      builder: (context, cart, child) {
        return Text(
          'Total: \$${cart.getTotalAmount(cartId).toStringAsFixed(2)}',
          textAlign: TextAlign.center,
          maxLines: 2,
          style: TextStyle(
              fontSize: fontTitle, fontWeight: FontWeight.bold, color: Colors.white),
        );
      },
    );
  }
}
