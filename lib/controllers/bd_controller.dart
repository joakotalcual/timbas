import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:timbas/services/database/firebase_services.dart';
import 'package:timbas/services/database/sqlite.dart';

Future<void> syncCategoriesFromFirestore() async {
  try {
    final lastSyncDate = await getLastSyncDate();
    final currentDate = DateTime.now();

    // Solo sincroniza si no hay fecha de sincronización o si ha pasado más de una hora desde la última sincronización
    if (lastSyncDate == null || currentDate.difference(lastSyncDate).inDays > 30) {
      List categories = await getCategories(); // Obtener categorías desde Firestore

      final db = await getLocalDatabase();
      Batch batch = db.batch();
      for (var category in categories) {
        batch.insert('categorias', {
          'uid': category['uid'],
          'nombre': category['nombre'],
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit();
      await setLastSyncDate(currentDate); // Actualizar la fecha de sincronización
    }
  } catch (e) {
    print('Error sincronizando categorías: $e');
  }
}

Future<void> syncProductsFromFirestore() async {
  try {
    final lastSyncDate = await getLastSyncDate();
    final currentDate = DateTime.now();

    // Solo sincroniza si no hay fecha de sincronización o si ha pasado más de una hora desde la última sincronización
    if (lastSyncDate == null || currentDate.difference(lastSyncDate).inDays > 30) {
      List products = await getProducts(); // Obtener productos desde Firestore

      final db = await getLocalDatabase();
      Batch batch = db.batch();
      for (var product in products) {
        batch.insert('productos', {
          'uid': product['uid'],
          'nombre': product['nombre'],
          'imagen': product['imagen'],
          'categorias': product['categorias'],
          'precio': product['precio'],
          'activo': product['activo'] ? 1 : 0,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit();
      await setLastSyncDate(currentDate); // Actualizar la fecha de sincronización
    }
  } catch (e) {
    print('Error sincronizando productos: $e');
  }
}

Stream<List<Map<String, dynamic>>> getLocalCategoriesStream() async* {
  await syncCategoriesFromFirestore();
  final localDb = await getLocalDatabase();
  while (true) {
    yield await localDb.query('categorias');
    await Future.delayed(const Duration(seconds: 5)); // Espera 5 segundos antes de la siguiente consulta
  }
}

Stream<List<Map<String, dynamic>>> getLocalProductsStream() async* {
  await syncProductsFromFirestore();
  final localDb = await getLocalDatabase();
  while (true) {
    yield await localDb.query('productos', orderBy: 'categorias DESC, nombre ASC'); // Ordena los productos por la columna 'categorias' y 'nombre' en orden descendente ;
    await Future.delayed(const Duration(seconds: 5)); // Espera 5 segundos antes de la siguiente consulta
  }
}

Future<bool> hasInternetConnection() async {
  try {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  } catch (e) {
    print('Error verificando conexión a Internet: $e');
    return false;
  }
}

Future<List<Map<String, dynamic>>> fetchCategories() async {
  if (await hasInternetConnection()) {
    await syncCategoriesFromFirestore();
  }
  return await getLocalCategories(); // Usa datos locales después de sincronizar si es necesario
}

Future<List<Map<String, dynamic>>> fetchProducts() async {
  if (await hasInternetConnection()) {
    await syncProductsFromFirestore();
  }
  return await getLocalProducts(); // Usa datos locales después de sincronizar si es necesario
}

Future<DateTime?> getLastSyncDate() async {
  final prefs = await SharedPreferences.getInstance();
  final lastSync = prefs.getString('last_sync_date');
  if (lastSync != null) {
    return DateTime.parse(lastSync);
  }
  return null;
}

Future<void> setLastSyncDate(DateTime date) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('last_sync_date', date.toIso8601String());
}
