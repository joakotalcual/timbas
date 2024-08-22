import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timbas/views/cart/components/cart_notifier.dart';
import 'package:timbas/views/main/main_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => Cart(),
      child: const MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Timbas y frappes de la 50',
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
    );
  }
}