// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import 'package:timbas/models/products.dart';

// // Helper de base de datos
// class DatabaseHelper {
//   static final DatabaseHelper _instance = DatabaseHelper._internal();

//   factory DatabaseHelper() => _instance;

//   static Database? _database;

//   DatabaseHelper._internal();

//   Future<Database> get database async {
//     if (_database != null) return _database!;

//     _database = await _initDB();
//     return _database!;
//   }

//   Future<Database> _initDB() async {
//     String path = join(await getDatabasesPath(), 'productos.db');

//     return await openDatabase(
//       path,
//       version: 1,
//       onCreate: (db, version) async {
//         await db.execute('''
//           CREATE TABLE categorias(
//             id INTEGER PRIMARY KEY AUTOINCREMENT,
//             nombre TEXT
//           )
//         ''');

//         await db.execute('''
//           CREATE TABLE productos(
//             id INTEGER PRIMARY KEY AUTOINCREMENT,
//             nombre TEXT,
//             precio REAL,
//             descripcion TEXT,
//             imagen TEXT,
//             categoria_id INTEGER,
//             FOREIGN KEY (categoria_id) REFERENCES categorias(id)
//           )
//         ''');
//       },
//     );
//   }

//   // Insertar una categoría
//   Future<void> insertCategoria(Categoria categoria) async {
//     final db = await database;
//     await db.insert(
//       'categorias',
//       categoria.toMap(),
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//   }

//   // Insertar un producto
//   Future<void> insertProducto(Producto producto) async {
//     final db = await database;
//     await db.insert(
//       'productos',
//       producto.toMap(),
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//   }

//   // Obtener todos los productos
//   Future<List<Producto>> getProductos() async {
//     final db = await database;
//     final List<Map<String, dynamic>> maps = await db.query('productos');

//     return List.generate(maps.length, (i) {
//       return Producto(
//         id: maps[i]['id'],
//         nombre: maps[i]['nombre'],
//         precio: maps[i]['precio'],
//         descripcion: maps[i]['descripcion'],
//         imagen: maps[i]['imagen'],
//         categoriaId: maps[i]['categoria_id'],
//       );
//     });
//   }

//   // Obtener todas las categorías con sus productos
//   Future<List<Categoria>> getCategorias() async {
//     final db = await database;
//     final List<Map<String, dynamic>> categoriaMaps = await db.query('categorias');

//     List<Categoria> categorias = [];

//     for (var categoriaMap in categoriaMaps) {
//       final List<Map<String, dynamic>> productoMaps = await db.query(
//         'productos',
//         where: 'categoria_id = ?',
//         whereArgs: [categoriaMap['id']],
//       );

//       List<Producto> productos = List.generate(productoMaps.length, (i) {
//         return Producto(
//           id: productoMaps[i]['id'],
//           nombre: productoMaps[i]['nombre'],
//           precio: productoMaps[i]['precio'],
//           descripcion: productoMaps[i]['descripcion'],
//           imagen: productoMaps[i]['imagen'],
//           categoriaId: productoMaps[i]['categoria_id'],
//         );
//       });

//       categorias.add(Categoria(
//         id: categoriaMap['id'],
//         nombre: categoriaMap['nombre'],
//         productos: productos,
//       ));
//     }

//     return categorias;
//   }
// }