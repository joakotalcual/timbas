
import 'package:flutter/material.dart';
import 'package:timbas/views/articles/components/products_screen.dart';

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
              Icon(Icons.list),
              SizedBox(width: 40,),
              Text("Artículos")
            ],
          ),
        ),
        TextButton(
          onPressed: (){},
          child: const Row(
            children: [
              Icon(Icons.view_comfy_alt_outlined),
              SizedBox(width: 40,),
              Text("Categorías")
            ],
          ),
        ),
        TextButton(
          onPressed: (){},
          child: const Row(
            children: [
              Icon(Icons.sell),
              SizedBox(width: 40,),
              Text("Descuentos")
            ],
          ),
        ),
      ],
    );
  }
}