import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timbas/models/products.dart';
import 'package:timbas/views/cart/components/cart_notifier.dart';

class ItemDetailScreen extends StatefulWidget {
  final Producto producto;
  final String categoria;
  final String? tipoPedido;
  final String? mesa;
  final String cartId; // Añade el cartId

  const ItemDetailScreen({
    super.key,
    required this.producto,
    required this.categoria,
    this.tipoPedido,
    this.mesa,
    required this.cartId, // Pasa el cartId
  });

  @override
  _ItemDetailScreenState createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  int _cantidad = 1;
  TextEditingController commentController = TextEditingController();

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
    String comment = commentController.text;
    final cart = Provider.of<Cart>(context, listen: false);
    for (int i = 0; i < _cantidad; i++) {
      cart.addItem(
          widget.cartId, widget.producto, widget.categoria, comment); // Usa el cartId
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
    body: GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: SingleChildScrollView( // Envuelve el contenido para hacerlo desplazable
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "${widget.categoria} \n ${widget.producto.nombre}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '\$${widget.producto.precio.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
              ),
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
              SizedBox(
                width: 550,
                child: TextField(
                  controller: commentController,
                  decoration: InputDecoration(
                    labelText: 'Comentarios',
                    hintText: 'Ejemplo: sin fresa, sin mango, sin chocolate, etc',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color:
                            Color(0xFF424242),
                        width: 2.0,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 16.0,
                    ),
                  ),
                  maxLines: 4,
                  keyboardType: TextInputType.text,
                ),
              ),
              const SizedBox(height: 8.0),
              ElevatedButton.icon(
                onPressed: _agregarAlCarrito,
                icon: const Icon(Icons.shopping_cart),
                label: const Text(
                  'Agregar al carrito',
                  style: TextStyle(color: Color(0xFF424242)),
                ),
                style: ElevatedButton.styleFrom(
                  iconColor: const Color(0xFF424242),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40.0, vertical: 16.0),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: const BorderSide(color: Color(0xFF424242), width: 2.0),
                  ),
                  elevation: 3.0,
                  shadowColor: Colors.black.withOpacity(0.2),
                ),
              ),
              const SizedBox(height: 32.0),
            ],
          ),
        ),
      ),
    ),
  );
}
}