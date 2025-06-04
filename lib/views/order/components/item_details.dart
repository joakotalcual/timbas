import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timbas/models/cart.dart';
import 'package:timbas/models/products.dart';
import 'package:timbas/views/cart/components/cart_notifier.dart';

class ItemDetailScreen extends StatefulWidget {
  final Producto producto;
  final String categoria;
  final String? tipoPedido;
  final String? mesa;
  final String cartId; // Añade el cartId
  final List<Producto>? productosRelacionados;

  const ItemDetailScreen({
    super.key,
    required this.producto,
    required this.categoria,
    this.tipoPedido,
    this.mesa,
    required this.cartId, // Pasa el cartId
    this.productosRelacionados,
  });

  @override
  _ItemDetailScreenState createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  int _cantidad = 1;
  double precioTotal = 0.0;
  TextEditingController commentController = TextEditingController();
  List<String> selectedExtras = [];
  List<String> frappesExtras = [];
  List<String> banderillasExtras = ["Clasica","Flamin hot","Papa"];

  void _incrementarCantidad() {
    setState(() {
      _cantidad++;
      actualizarPrecio(); // Asegurar que se actualice el total
    });
  }

  void actualizarPrecio() {
    setState(() {
      double totalExtras = selectedExtras.fold(0.0, (sum, extraFull) {
        String extraNombre = extraFull.split(" - ")[0]; // Extrae solo el nombre
        var extra = widget.productosRelacionados?.firstWhere(
          (e) => e.nombre == extraNombre,
          orElse: () => Producto(id: '', nombre: '', precio: 0.0, extra: 0.0, imagen: '', idCategorias: '', activo: true),
        );
        return sum + (extra?.extra ?? 0.0);
      });

      precioTotal = (widget.producto.precio + totalExtras) * _cantidad; // Multiplica por la cantidad
    });
  }

  void _disminuirCantidad() {
    if (_cantidad > 1) {
      setState(() {
        _cantidad--;
        actualizarPrecio(); // Asegurar que se actualice el total
      });
    }
  }

  void _toggleExtra(String extra) {
    setState(() {
      if (selectedExtras.contains(extra)) {
        selectedExtras.remove(extra);
      } else {
        if (selectedExtras.length < 10 && widget.categoria.toLowerCase() !="banderillas") {
          selectedExtras.add(extra);
        }else if(selectedExtras.isEmpty && widget.categoria.toLowerCase() == "banderillas"){
          selectedExtras.add(extra);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("No puedes agregar más adicionales."),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
      actualizarPrecio();
    });
  }

  void _agregarAlCarrito() {
    String comment = commentController.text;
    final cart = Provider.of<Cart>(context, listen: false);

    // Crear la lista de extras con el nombre y el precio
  List<Extra> extrasSeleccionados = selectedExtras.map((extraFull) {
    String extraNombre = extraFull.split(" - ")[0]; // Extrae solo el nombre
    var productoExtra = widget.productosRelacionados?.firstWhere(
      (e) => e.nombre == extraNombre,
      orElse: () => Producto(id: '', nombre: '', precio: 0.0, extra: 0.0, imagen: '', idCategorias: '', activo: true),
    );
    return Extra(
      nombre: extraNombre,
      precio: productoExtra?.extra ?? 0.0,
    );
  }).toList();


    for (int i = 0; i < _cantidad; i++) {
      cart.addItem(
        widget.cartId, widget.producto, widget.categoria, comment, extrasSeleccionados); // Usa el cartId
      }
    Navigator.pop(context); // Cierra la pantalla de detalles del producto
    Navigator.pop(context); // Cierra la pantalla de detalles del producto
  }

  @override
  void initState() {
    super.initState();
    if (widget.productosRelacionados != null) {
      // Filtra el producto actual
      List<Producto> productosFiltrados = widget.productosRelacionados!
          .where((producto) => producto.id != widget.producto.id && !['supremo base café', 'supremo base fresa'].contains(producto.nombre.toLowerCase()))
          .toList();

      // Ordena por nombre
      productosFiltrados.sort((a, b) => a.nombre.compareTo(b.nombre));

      // Mapea la lista a String después de ordenar
      frappesExtras = productosFiltrados
          .map((producto) => "${producto.nombre} - \$${producto.extra}")
          .toList();
    }
    precioTotal = widget.producto.precio;
  }

  @override
  Widget build(BuildContext context) {
    bool isBanderillas = widget.categoria.toLowerCase() == "banderillas";
    bool notIsExtraBanderillas = (widget.producto.nombre.toLowerCase().contains("paquete") || widget.producto.nombre.toLowerCase().contains("salchipulpo") || widget.producto.nombre.toLowerCase() == "papas fritas");
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
              // Sección de adicionales SOLO si la categoría es Frappes
              if(!notIsExtraBanderillas)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      const Text(
                        "Selecciona adicionales:",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Wrap(
                        spacing: 8.0,
                        children: (isBanderillas ? banderillasExtras : frappesExtras).map((extra) {
                          bool isSelected = selectedExtras.contains(extra);
                          return ChoiceChip(
                            label: Text(extra),
                            selected: isSelected,
                            onSelected: (_) => _toggleExtra(extra),
                            selectedColor: Colors.brown[300],
                            backgroundColor: Colors.grey[200],
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
              const SizedBox(height: 8.0),
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
                label: Text(
                  'Agregar al carrito \$${precioTotal.toStringAsFixed(2)}',
                  style: const TextStyle(color: Color(0xFF424242)),
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