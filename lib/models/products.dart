// Modelo de Producto
// class Producto {
//   int? id;
//   String nombre;
//   double precio;
//   String descripcion;
//   String imagen;
//   int categoriaId;

//   Producto({
//     this.id,
//     required this.nombre,
//     required this.precio,
//     required this.descripcion,
//     required this.imagen,
//     required this.categoriaId,
//   });

//   // Convertir un Producto a Map para SQLite
//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'nombre': nombre,
//       'precio': precio,
//       'descripcion': descripcion,
//       'imagen': imagen,
//       'categoria_id': categoriaId,
//     };
//   }

//   @override
//   String toString() {
//     return 'Producto(nombre: $nombre, precio: $precio, descripcion: $descripcion)';
//   }
// }

// // Modelo de Categoria
// class Categoria {
//   int? id;
//   final String nombre;
//   final List<Producto> productos;

//   Categoria({
//     this.id,
//     required this.nombre,
//     this.productos = const [],
//   });

//   // Convertir una Categoria a Map para SQLite
//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'nombre': nombre,
//     };
//   }

//   @override
//   String toString() {
//     return 'Categoria(nombre: $nombre)';
//   }
// }

class Producto {
  int id;
  String nombre;
  double precio;
  String descripcion;
  String imagen;

  Producto({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.descripcion,
    required this.imagen,
  });

  // Método para representar el objeto como una cadena
  @override
  String toString() {
    return 'Producto(nombre: $nombre, precio: $precio, descripcion: $descripcion)';
  }
}

class Categoria {
  final String nombre;
  final List<Producto> productos;

  Categoria({
    required this.nombre,
    required this.productos,
  });
}

final List<Categoria> categorias = [
  Categoria(
    nombre: 'FRAPPES',
    productos: [
      Producto(
        id: 1,
        nombre: 'OREO',
        precio: 60,
        descripcion: 'Un refrescante frappé',
        imagen: 'assets/images/icons/oreo.png'
      ),
      Producto(
        id: 2,
        nombre: 'CHOCOLATINES',
        precio: 60,
        descripcion: 'Un refrescante frappé',
        imagen: 'assets/images/icons/chocolatines.png'
      ),
      Producto(
        id: 3,
        nombre: 'MAMUT',
        precio: 60,
        descripcion: 'Un refrescante frappé',
        imagen: 'assets/images/icons/mamut.png'
      ),
      Producto(
        id: 4,
        nombre: 'GANSITO',
        precio: 60,
        descripcion: 'Un refrescante frappé',
        imagen: 'assets/images/icons/gansito.png'
      ),
      Producto(
        id: 5,
        nombre: 'PINGUINO',
        precio: 60,
        descripcion: 'Un refrescante frappé',
        imagen: 'assets/images/icons/pinguinos.png'
      ),
      Producto(
        id: 6,
        nombre: 'KINDER DELICE',
        precio: 60,
        descripcion: 'Un refrescante frappé',
        imagen: 'assets/images/icons/kinder-delice.png'
      ),
      Producto(
        id: 7,
        nombre: 'KINDER BUENO',
        precio: 65,
        descripcion: 'Un refrescante frappé',
        imagen: 'assets/images/icons/kinder-bueno.png'
      ),
      Producto(
        id: 8,
        nombre: 'BUBULUBU',
        precio: 60,
        descripcion: 'Un refrescante frappé',
        imagen: 'assets/images/icons/bubulubu.png'
      ),
      Producto(
        id: 9,
        nombre: 'M&M',
        precio: 60,
        descripcion: 'Un refrescante frappé',
        imagen: 'assets/images/icons/mym.png'
      ),
      Producto(
        id: 10,
        nombre: 'MILKY WAY',
        precio: 60,
        descripcion: 'Un refrescante frappé',
        imagen: 'assets/images/icons/milky.png'
      ),
      Producto(
        id: 11,
        nombre: 'SNICKERS',
        precio: 60,
        descripcion: 'Un refrescante frappé',
        imagen: 'assets/images/icons/snickers.png'
      ),
      Producto(
        id: 12,
        nombre: 'MAZAPAN',
        precio: 60,
        descripcion: 'Un refrescante frappé',
        imagen: 'assets/images/icons/mazapan.png'
      ),
      Producto(
        id: 13,
        nombre: 'FERRERO',
        precio: 80,
        descripcion: 'Un refrescante frappé',
        imagen: 'assets/images/icons/ferrero.png'
      ),
      Producto(
        id: 14,
        nombre: 'KIT KAT',
        precio: 65,
        descripcion: 'Un refrescante frappé',
        imagen: 'assets/images/icons/kitkat.png'
      ),
      Producto(
        id: 15,
        nombre: 'BAILEYS',
        precio: 80,
        descripcion: 'Un refrescante frappé',
        imagen: 'assets/images/icons/baileys.png'
      ),
      Producto(
        id: 16,
        nombre: 'CHOCOTORRO',
        precio: 60,
        descripcion: 'Un refrescante frappé',
        imagen: 'assets/images/icons/chocotorro.png'
      ),
      Producto(
        id: 17,
        nombre: 'CHOCOROL',
        precio: 60,
        descripcion: 'Un refrescante frappé',
        imagen: 'assets/images/icons/chocorol.png'
      ),
      Producto(
        id: 18,
        nombre: 'CHOCORETAS',
        precio: 60,
        descripcion: 'Un refrescante frappé',
        imagen: 'assets/images/icons/chocoretas.png'
      ),
      Producto(
        id: 19,
        nombre: 'PALETA PAYASO',
        precio: 60,
        descripcion: 'Un refrescante frappé',
        imagen: 'assets/images/icons/ppayaso.png'
      ),
      Producto(
        id: 20,
        nombre: 'CARLOS V',
        precio: 60,
        descripcion: 'Un refrescante frappé',
        imagen: 'assets/images/icons/carlosv.png'
      ),
      Producto(
        id: 21,
        nombre: 'NUTELLA',
        precio: 60,
        descripcion: 'Un refrescante frappé',
        imagen: 'assets/images/icons/nutella.png'
      ),
      Producto(
        id: 22,
        nombre: 'CAJETA',
        precio: 60,
        descripcion: 'Un refrescante frappé',
        imagen: 'assets/images/icons/cajeta.png'
      ),
    ],
  ),
  Categoria(
    nombre: 'FRAPPES DE FRUTAS',
    productos: [
      Producto(
        id: 23,
        nombre: 'FRESADA',
        precio: 80.00,
        descripcion: 'Frappé de frutas frescas mezcladas con hielo.',
        imagen: 'assets/images/icons/fresa.png'
      ),
      Producto(
        id: 24,
        nombre: 'PIÑADA',
        precio: 50.00,
        descripcion: 'Frappé de frutas frescas mezcladas con hielo.',
        imagen: 'assets/images/icons/piña.png'
      ),
      Producto(
        id: 25,
        nombre: 'MANGADA',
        precio: 80.00,
        descripcion: 'Frappé de frutas frescas mezcladas con hielo.',
        imagen: 'assets/images/icons/mango.png'
      ),
      Producto(
        id: 26,
        nombre: 'DURAZNO',
        precio: 60.00,
        descripcion: 'Frappé de frutas frescas mezcladas con hielo.',
        imagen: 'assets/images/icons/durazno.png'
      ),
    ],
  ),
  Categoria(
    nombre: 'DIABLITOS',
    productos: [
      Producto(
        id: 27,
        nombre: 'PIÑA',
        precio: 50,
        descripcion: 'Hielo picado con',
        imagen: 'assets/images/icons/piña.png'
      ),
      Producto(
        id: 28,
        nombre: 'FRESA',
        precio: 55,
        descripcion: 'Hielo picado con',
        imagen: 'assets/images/icons/fresa.png'
      ),
      Producto(
        id: 29,
        nombre: 'MELON',
        precio: 50,
        descripcion: 'Hielo picado con',
        imagen: 'assets/images/icons/melon.png'
      ),
      Producto(
        id: 30,
        nombre: 'KIWI',
        precio: 55,
        descripcion: 'Hielo picado con',
        imagen: 'assets/images/icons/kiwi.png'
      ),
      Producto(
        id: 31,
        nombre: 'COMBINADO',
        precio: 75,
        descripcion: 'Hielo picado con',
        imagen: 'assets/images/icons/combinado.png'
      ),
    ],
  ),
  Categoria(
    nombre: 'SMOOTHIES',
    productos: [
      Producto(
        id: 32,
        nombre: 'FRESA',
        precio: 55,
        descripcion: 'Smoothie cremoso de ',
        imagen: 'assets/images/icons/fresa.png'
      ),
      Producto(
        id: 33,
        nombre: 'PIÑA',
        precio: 50,
        descripcion: 'Smoothie cremoso de ',
        imagen: 'assets/images/icons/piña.png'
      ),
      Producto(
        id: 34,
        nombre: 'MANZANA',
        precio: 50,
        descripcion: 'Smoothie cremoso de ',
        imagen: 'assets/images/icons/manzana.png'
      ),
      Producto(
        id: 35,
        nombre: 'KIWI',
        precio: 55,
        descripcion: 'Smoothie cremoso de ',
        imagen: 'assets/images/icons/kiwi.png'
      ),
      Producto(
        id: 36,
        nombre: 'MANGO',
        precio: 55,
        descripcion: 'Smoothie cremoso de ',
        imagen: 'assets/images/icons/mango.png'
      ),
    ],
  ),
  Categoria(
    nombre: 'MACHAKADOS',
    productos: [
      Producto(
        id: 37,
        nombre: 'FRESA',
        precio: 55,
        descripcion: 'Machakado cremoso de ',
        imagen: 'assets/images/icons/fresa.png'
      ),
      Producto(
        id: 38,
        nombre: 'MANGO',
        precio: 55,
        descripcion: 'Machakado cremoso de ',
        imagen: 'assets/images/icons/mango.png'
      ),
      Producto(
        id: 39,
        nombre: 'PLATANO',
        precio: 45,
        descripcion: 'Machakado cremoso de ',
        imagen: 'assets/images/icons/platano.png'
      ),
      Producto(
        id: 40,
        nombre: 'MANZANA',
        precio: 45,
        descripcion: 'Machakado cremoso de ',
        imagen: 'assets/images/icons/manzana.png'
      ),
      Producto(
        id: 41,
        nombre: 'KIWI',
        precio: 55,
        descripcion: 'Machakado cremoso de ',
        imagen: 'assets/images/icons/kiwi.png'
      ),
      Producto(
        id: 42,
        nombre: 'MELON',
        precio: 45,
        descripcion: 'Machakado cremoso de ',
        imagen: 'assets/images/icons/melon.png'
      ),
      Producto(
        id: 43,
        nombre: 'PIÑA',
        precio: 45,
        descripcion: 'Machakado cremoso de ',
        imagen: 'assets/images/icons/piña.png'
      ),
      Producto(
        id: 44,
        nombre: 'COMBINADO',
        precio: 75,
        descripcion: 'Machakado cremoso de ',
        imagen: 'assets/images/icons/combinado.png'
      ),
      Producto(
        id: 45,
        nombre: 'DURAZNO',
        precio: 55,
        descripcion: 'Machakado cremoso de ',
        imagen: 'assets/images/icons/durazno.png'
      ),
    ],
  ),
];