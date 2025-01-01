import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:timbas/models/cart.dart';
import 'package:timbas/models/products.dart';
import 'package:timbas/views/cart/components/cart_notifier.dart';

// Función para abrir la base de datos SQLite
Future<Database> getLocalDatabase() async {
  return openDatabase(
    join(await getDatabasesPath(), 'app_database.db'),
    onCreate: (db, version) async {
      // Crear las tablas si no existen
      await db.execute(
        '''
        CREATE TABLE IF NOT EXISTS categorias (
          uid TEXT PRIMARY KEY,
          nombre TEXT
        );
        '''
      );
      await db.execute(
        '''
        CREATE TABLE IF NOT EXISTS productos (
          uid TEXT PRIMARY KEY,
          nombre TEXT,
          imagen TEXT,
          categorias TEXT,
          precio REAL,
          activo INTEGER
        );
        '''
      );
      await db.execute(
        '''
        CREATE TABLE  IF NOT EXISTS orders (
          id TEXT PRIMARY KEY,
          total REAL NOT NULL,
          mesa TEXT NOT NULL,
          timestamp TEXT NOT NULL
        );
        '''
      );
      await db.execute(
        '''
        CREATE TABLE IF NOT EXISTS order_items (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          order_id TEXT NOT NULL,
          product_name TEXT NOT NULL,
          category TEXT NOT NULL,
          comments TEXT,
          quantity INTEGER NOT NULL,
          total_price REAL NOT NULL,
          FOREIGN KEY(order_id) REFERENCES orders(id)
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

Future<void> deleteLocalCategory(String uid) async {
  final db = await getLocalDatabase();
  await db.delete(
    'categorias',
    where: 'uid = ?',
    whereArgs: [uid],
  );
  print('Categoría "$uid" eliminada correctamente.');
}

// Función para agregar una categoría local
Future<void> addLocalProduct(String uid, String name, String image, String category, double price, int active) async {
  final db = await getLocalDatabase();
  await db.insert(
    'productos',
    {
      'uid' : uid,
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

Future<void> deleteLocalProducts(String uid) async {
  final db = await getLocalDatabase();
  await db.delete(
    'productos',
    where: 'uid = ?',
    whereArgs: [uid],
  );
  print('Producto "$uid" eliminada correctamente.');
}

Future<void> addLocalOrder(Order order) async {
  final db = await getLocalDatabase();

  // Insertar el pedido
  await db.insert('orders', {
    'id': order.id,
    'total': order.total,
    'mesa': order.mesa ?? 'mesa-1',
    'timestamp': order.timestamp.toIso8601String(),
  },
    conflictAlgorithm: ConflictAlgorithm.replace, // Si ya existe el ID, reemplázalo
  );

  // Insertar los elementos del pedido
  for (var item in order.items) {
    await db.insert('order_items', {
      'order_id': order.id,
      'product_name': item.producto.nombre,
      'category': item.categoria,
      'comments': item.comentario,
      'quantity': item.cantidad,
      'total_price': item.producto.precio,
    },
      conflictAlgorithm: ConflictAlgorithm.replace, // Si ya existe el ID, reemplázalo
    );
  }
}

// Función para obtener productos locales desde la base de datos
Future<List<Order>> getLocalOrders() async {
  final db = await getLocalDatabase();
  // Obtener pedidos con sus elementos
  final ordersData = await db.rawQuery('''
    SELECT o.id, o.total, o.mesa, o.timestamp, i.product_name, i.category, i.comments, i.quantity, i.total_price
    FROM orders o
    LEFT JOIN order_items i ON o.id = i.order_id
  ''');

  // Agrupar los datos en la estructura de la Order
  Map<String, Order> ordersMap = {};

  for (var orderData in ordersData) {
    final String orderId = orderData['id'].toString();

    // Si el pedido no está en el mapa, agrégalo
    if (!ordersMap.containsKey(orderId)) {
      ordersMap[orderId] = Order(
        id: orderData['id'].toString(),
        total: double.parse(orderData['total'].toString()),
        mesa: orderData['mesa'].toString(),
        items: [],
        timestamp: DateTime.parse(orderData['timestamp'].toString()),
      );
    }

    // Agregar el item a la lista de items del pedido
    ordersMap[orderId]?.items.add(
      CartItem(
        producto: Producto(id: '', nombre: orderData['product_name'].toString(), imagen: '', idCategorias: '', precio: double.parse( orderData['total_price'].toString()), activo: true),
        categoria: orderData['category'].toString(),
        comentario: orderData['comments'].toString(),
        cantidad: int.parse(orderData['quantity'].toString()),
      )
    );
  }

  // Devolver la lista de pedidos con sus elementos
  return ordersMap.values.toList();
}

// Función para actualizar una categoría local
Future<void> updateLocalOrder(String id, String mesa) async {
  final db = await getLocalDatabase();
  await db.update(
  'orders', // Nombre de la tabla
  {
    'mesa': mesa, // Actualiza el valor de 'mesa'
  },
  where: 'id = ?', // Condición para encontrar el pedido a actualizar
  whereArgs: [id], // El valor de 'id' se pasa como argumento
);

}


