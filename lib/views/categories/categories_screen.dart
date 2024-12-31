import 'package:flutter/material.dart';
import 'package:timbas/controllers/bd_controller.dart';
import 'package:timbas/helpers/custom_image.dart';
import 'package:timbas/helpers/responsive.dart';
import 'package:timbas/views/categories/components/item_categorie.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var responsive = Responsive(context);
    bool isLandscape = responsive.isLandscape;
    bool isSmallScreen = responsive.isSmallScreen;
    bool isMediumScreen = responsive.isMediumScreen;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Categorías',
          style: TextStyle(
            color: Colors.white
          )
        ),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: getLocalCategoriesStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No se encontraron categorías.'));
            } else {
              return Column(
                children: [
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isLandscape && !isSmallScreen ? 3 : isSmallScreen ? 2 : isMediumScreen ? 3 : 4,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                      ),
                      itemCount: snapshot.data?.length,
                      itemBuilder: (context, index) {
                        return _buildGridItem(context, snapshot.data?[index]['nombre'], snapshot.data?[index]['uid']);
                      },
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ItemCategorie(
                isEdit: false,
              ),
            ),
          ).then((_) {
            // Volver a cargar las categorías después de volver de la pantalla de edición
            // Esto ya se maneja automáticamente con el StreamBuilder
          });
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white,),
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, String nombre, String id) {
    var responsive = Responsive(context);
    double fontTitle = responsive.fontSizeTitle;

    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ItemCategorie(
                isEdit: true,
                name: nombre,
                uid: id,
              ),
            ),
        );
      },
      child: Card(
        child: Column(
          children: [
            CustomImage(
              imageUrl: 'assets/images/${nombre.toLowerCase().replaceAll(' ', '_')}.png',
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                nombre,
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
}
