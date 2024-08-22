import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timbas/models/products.dart';
import 'package:timbas/views/cart/components/cart_notifier.dart';

class ItemDetailScreen extends StatefulWidget {
  final Producto producto;
  final String categoria;
  final String tipoPedido;
  final String? mesa;
  final String cartId; // Añade el cartId

  const ItemDetailScreen({
    super.key,
    required this.producto,
    required this.categoria,
    required this.tipoPedido,
    this.mesa,
    required this.cartId, // Pasa el cartId
  });

  @override
  _ItemDetailScreenState createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  int _cantidad = 1;

  void _incrementarCantidad() {
    setState(() {
      _cantidad++;
    });
  }

  void _disminuirCantidad() {
    if (_cantidad > 1) {
      setState(() {
        _cantidad--;
      });
    }
  }

  void _agregarAlCarrito() {
    final cart = Provider.of<Cart>(context, listen: false);
    for (int i = 0; i < _cantidad; i++) {
      cart.addItem(
          widget.cartId, widget.producto, widget.categoria); // Usa el cartId
    }
    Navigator.pop(context); // Cierra la pantalla de detalles del producto
    Navigator.pop(context); // Cierra la pantalla de detalles del producto
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoria),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 206.0),
            Text(
              widget.producto.nombre,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              '\$${widget.producto.precio.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              widget.producto.descripcion,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 156.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _disminuirCantidad,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text(
                  '$_cantidad',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: _incrementarCantidad,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            ElevatedButton.icon(
              onPressed: _agregarAlCarrito,
              icon: const Icon(Icons.shopping_cart),
              label: const Text('Agregar al carrito'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 32.0, vertical: 12.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}