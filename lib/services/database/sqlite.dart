import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// Función para abrir la base de datos SQLite
Future<Database> getLocalDatabase() async {
  return openDatabase(
    join(await getDatabasesPath(), 'app_database.db'),
    onCreate: (db, version) async {
      // Crear las tablas si no existen
      await db.execute(
        '''
        CREATE TABLE categorias(
          uid TEXT PRIMARY KEY,
          nombre TEXT
        );
        '''
      );
      await db.execute(
        '''
        CREATE TABLE productos(
          uid TEXT PRIMARY KEY,
          nombre TEXT,
          imagen TEXT,
          categorias TEXT,
          precio REAL,
          activo INTEGER
        );
        '''
      );
    },
    version: 1,
  );
}

// Función para obtener categorías locales desde la base de datos
Future<List<Map<String, dynamic>>> getLocalCategories() async {
  final db = await getLocalDatabase();
  return await db.query('categorias');
}

// Función para obtener productos locales desde la base de datos
Future<List<Map<String, dynamic>>> getLocalProducts() async {
  final db = await getLocalDatabase();
  return await db.query('productos');
}

// Función para agregar una categoría local
Future<void> addLocalCategory(String uid, String name) async {
  final db = await getLocalDatabase();
  await db.insert(
    'categorias',
    {'uid': uid, 'nombre': name}, // Incluye el UID en la base de datos local
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

// Función para actualizar una categoría local
Future<void> updateLocalCategory(String uid, String name) async {
  final db = await getLocalDatabase();
  await db.update(
    'categorias',
    {'nombre': name},
    where: 'uid = ?',
    whereArgs: [uid],
  );
}

// Función para agregar una categoría local
Future<void> addLocalProduct(String uid, String name, String image, String category, double price, int active) async {
  final db = await getLocalDatabase();
  await db.insert(
    'productos',
    {
      'nombre' : name,
      'imagen' : image,
      'categorias' : category,
      'precio' : price,
      'activo' : active
    }, // Incluye el UID en la base de datos local
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

// Función para actualizar una categoría local
Future<void> updateLocalProduct(String uid, String name, String image, String category, double price, int active) async {
  final db = await getLocalDatabase();
  await db.update(
    'productos',
    {
      'nombre' : name,
      'imagen' : image,
      'categorias' : category,
      'precio' : price,
      'activo' : active
    },
    where: 'uid = ?',
    whereArgs: [uid],
  );
}

Future<void> deleteLocalCategory(String uid) async {
  final db = await getLocalDatabase();
  await db.delete(
    'categorias',
    where: 'uid = ?',
    whereArgs: [uid],
  );
  print('Categoría "$uid" eliminada correctamente.');
}