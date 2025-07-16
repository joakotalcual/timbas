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
  Map<String, List<String>> selectedExtrasByType = {
    'base': [],
    'fruta': [],
    'toppin': [],
    'extras': [],
    'adicionales': [], // para frappes o banderillas
  };

  List<String> frappesExtras = [];
  List<String> waffleExtrasSelected = [];
  List<String> banderillasExtras = [
    "Clasica",
    "Flamin hot",
    "Papa",
    "Ramen",
    "Tradicional (Azucar)",
    "Torciditos"
  ];
  List<String> waffleBase = [
    "Hershey's",
    "Leche Condensada",
    "Maple",
    "Mermelada de Fresa"
  ];
  List<String> waffleFruta = ["Plátano", "Fresa", "Combinado"];
  List<String> waffleToppin = ["Maria", "Oreo"];
  List<String> waffleExtras = ["Crema batida", "Nutella", "Helado"];

  void _incrementarCantidad() {
    setState(() {
      _cantidad++;
      actualizarPrecio(); // Asegurar que se actualice el total
    });
  }

  void actualizarPrecio() {
    setState(() {
      // Combinar todos los extras seleccionados
      double totalExtras = 0.0;

      // 1. Calcular el total de extras personalizados
      selectedExtrasByType.forEach((tipo, extras) {
        for (var extraNombre in extras) {
          double precioExtra = 0.0;

          if (tipo == 'fruta') {
            if (extras.contains("Combinado")) {
              totalExtras += 5.00;
            }
          } else if (tipo == 'extras') {
            // Precios personalizados por nombre
            switch (extraNombre.toLowerCase()) {
              case 'crema batida':
                precioExtra = 5.0;
                break;
              case 'nutella':
                precioExtra = 10.0;
                break;
              case 'helado':
                precioExtra = 5.0;
                break;
              default:
                precioExtra = 0.0;
            }
          } else {
            // Buscar el precio en productosRelacionados si aplica
            var extra = widget.productosRelacionados?.firstWhere(
              (e) => e.nombre == extraNombre,
              orElse: () => Producto(
                id: '',
                nombre: '',
                precio: 0.0,
                extra: 0.0,
                imagen: '',
                idCategorias: '',
                activo: true,
              ),
            );
            precioExtra = extra?.extra ?? 0.0;
          }

          totalExtras += precioExtra;
        }
      });

      // 2. Calcular el precio total
      precioTotal = (widget.producto.precio + totalExtras) * _cantidad;
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

  void _agregarAlCarrito() {
    String comment = commentController.text;
    final cart = Provider.of<Cart>(context, listen: false);

    // Combinar todos los extras seleccionados
    final todosLosExtras =
        selectedExtrasByType.values.expand((e) => e).toList();

    List<Extra> extrasSeleccionados = todosLosExtras.map((extraNombre) {
      double precioExtra;

      switch (extraNombre.toLowerCase()) {
        case 'combinado':
        precioExtra = 5;
        break;
        case 'nutella':
          precioExtra = 10.0;
          break;
        case 'crema batida':
        case 'helado':
          precioExtra = 5.0;
          break;
        case 'plátano':
        case 'fresa':
          // Se maneja como combinación luego, pero aquí es 0
          precioExtra = 0.0;
          break;
        default:
          // Busca en productosRelacionados si existe
          var productoExtra = widget.productosRelacionados?.firstWhere(
            (e) => e.nombre == extraNombre,
            orElse: () => Producto(
                id: '',
                nombre: '',
                precio: 0.0,
                extra: 0.0,
                imagen: '',
                idCategorias: '',
                activo: true),
          );
          precioExtra = productoExtra?.extra ?? 0.0;
      }

      return Extra(
        nombre: extraNombre,
        precio: precioExtra,
      );
    }).toList();

    for (int i = 0; i < _cantidad; i++) {
      cart.addItem(
        widget.cartId,
        widget.producto,
        widget.categoria,
        comment,
        extrasSeleccionados,
      );
    }

    Navigator.pop(context);
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    if (widget.productosRelacionados != null) {
      // Filtra el producto actual
      List<Producto> productosFiltrados = widget.productosRelacionados!
          .where((producto) =>
              producto.id != widget.producto.id &&
              !['supremo base café', 'supremo base fresa']
                  .contains(producto.nombre.toLowerCase()))
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
    bool notIsExtraBanderillas =
        (widget.producto.nombre.toLowerCase().contains("paquete") ||
            widget.producto.nombre.toLowerCase().contains("salchipulpo") ||
            widget.producto.nombre.toLowerCase().contains("papas fritas") ||
            widget.producto.nombre.toLowerCase().contains("helado") ||
            widget.producto.nombre.toLowerCase().contains("waffle"));
    bool isWaffle = widget.producto.nombre.toLowerCase().contains("waffle");
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoria),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: SingleChildScrollView(
          // Envuelve el contenido para hacerlo desplazable
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
                if (!notIsExtraBanderillas)
                  buildChoiceChips(
                      "Selecciona adicionales:",
                      isBanderillas ? banderillasExtras : frappesExtras,
                      'adicionales',
                      isBanderillas ? 1 : 10),
                if (isWaffle)
                  Column(
                    children: [
                      buildChoiceChips(
                          "Selecciona Base:", waffleBase, 'base', 4),
                      buildChoiceChips(
                          "Selecciona Fruta:", waffleFruta, 'fruta', 2),
                      buildChoiceChips(
                          "Selecciona Toppin:", waffleToppin, 'toppin', 2),
                      buildChoiceChips(
                          "Selecciona Extras:", waffleExtras, 'extras', 3),
                    ],
                  ),
                const SizedBox(height: 8.0),
                SizedBox(
                  width: 550,
                  child: TextField(
                    controller: commentController,
                    decoration: InputDecoration(
                      labelText: 'Comentarios',
                      hintText:
                          'Ejemplo: sin fresa, sin mango, sin chocolate, etc',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFF424242),
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
                      side: const BorderSide(
                          color: Color(0xFF424242), width: 2.0),
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

  Widget buildChoiceChips(
      String titulo, List<String> opciones, String tipo, int limite) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 10),
        Text(
          titulo,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8.0,
          children: opciones.map((extra) {
            bool isSelected =
                selectedExtrasByType[tipo]?.contains(extra) ?? false;
            return ChoiceChip(
              label: Text(extra),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  final lista = selectedExtrasByType[tipo]!;
                  if (tipo == 'fruta') {
                    if (extra == 'Combinado') {
                      // Si selecciona Combinado, eliminar Plátano y Fresa
                      lista
                        ..clear()
                        ..add('Combinado');
                    } else {
                      // Si selecciona una fruta individual, quitar Combinado si está
                      lista.remove('Combinado');
                      if (isSelected) {
                        lista.remove(extra);
                      } else if (lista.length < limite) {
                        lista.add(extra);
                      }
                    }
                  } else {
                    // lógica normal para los demás tipos
                    if (isSelected) {
                      lista.remove(extra);
                    } else if (lista.length < limite) {
                      lista.add(extra);
                    }
                  }

                  actualizarPrecio(); // Opcional, si influye en el precio
                });
              },
              selectedColor: Colors.brown[300],
              backgroundColor: Colors.grey[200],
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
