
import 'package:flutter/material.dart';
import 'package:timbas/views/articles/components/products_screen.dart';
import 'package:timbas/views/categories/categories_screen.dart';

class ArticlesScreen extends StatelessWidget {
  const ArticlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
          onPressed: (){
            // Navegar a la pantalla de productos
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProductsScreen(),
              ),
            );
          },
          child: const Row(
            children: [
              Icon(Icons.list, color: Colors.black,),
              SizedBox(width: 40,),
              Text(
                "Artículos",
                style: TextStyle(
                  color: Colors.black
                ),
              )
            ],
          ),
        ),
        TextButton(
          onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CategoriesScreen(),
              ),
            );
          },
          child: const Row(
            children: [
              Icon(Icons.view_comfy_alt_outlined, color: Colors.black,),
              SizedBox(width: 40,),
              Text(
                "Categorías",
                style: TextStyle(
                  color: Colors.black
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: (){},
          child: const Row(
            children: [
              Icon(Icons.sell, color: Colors.black,),
              SizedBox(width: 40,),
              Text(
                "Descuentos",
                style: TextStyle(
                  color: Colors.black
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}