import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:timbas/helpers/validated.dart';
import 'package:timbas/models/products.dart';
import 'package:timbas/services/database/firebase_services.dart';
import 'package:timbas/services/database/sqlite.dart';
import 'package:timbas/views/dialogCustom/show_confirm_dialog.dart';
import 'package:timbas/views/dialogCustom/show_dialog.dart';

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

Future<List<Categoria>> getLocalCategoriesFuture() async {
  final localDb = await getLocalDatabase();
  final List<Map<String, dynamic>> queryResult = await localDb.query(
    'categorias',
    columns: ['uid', 'nombre'],
    orderBy: 'nombre DESC',
  );

  // Mapea los resultados para crear una lista de objetos `Categoria`
  return queryResult.map((row) {
    return Categoria(
      id: row['uid'],
      nombre: row['nombre'],
    );
  }).toList();
}


Stream<List<Map<String, dynamic>>> getLocalProductsStream() async* {
  await syncProductsFromFirestore();
  final localDb = await getLocalDatabase();
  while (true) {
    yield await localDb.query('productos', orderBy: 'categorias DESC, nombre ASC'); // Ordena los productos por la columna 'categorias' y 'nombre' en orden descendente ;
    await Future.delayed(const Duration(seconds: 5)); // Espera 5 segundos antes de la siguiente consulta
  }
}

Future<List<Producto>> getLocalProductsFuture(String idCategoria) async {
  final localDb = await getLocalDatabase();
  final List<Map<String, dynamic>> queryResult = await localDb.query(
    'productos',
    where: 'categorias = ?',
    whereArgs: [idCategoria],
    orderBy: 'nombre DESC',
  );

  // Mapea los resultados para crear una lista de objetos `Producto`
  return queryResult.map((row) => Producto.fromMap(row)).toList();
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

Future<void> updateCategorieController(BuildContext context, String uid, String name, int isEdit)async{
  //Validar y hacer la actualización
  switch(isEdit){
    case 0:
      if(isValidName(name)){
        await updateCategories(uid, name);
        await updateLocalCategory(uid, name);
        Navigator.pop(context);
      }else{
        showDialogCustom(context, 'NOMBRE INCORRECTO', 'FAVOR DE PONER UN NOMBRE CORRECTO.');
      }
      break;
    case 1:
      if(isValidName(name)){
        String uid =await addCategories(name); // Obtiene el UID de Firestore
        await addLocalCategory(uid, name); // Usa el UID para la base de datos local
        Navigator.pop(context);
      }else{
        showDialogCustom(context, 'NOMBRE INCORRECTO', 'FAVOR DE PONER UN NOMBRE CORRECTO.');
      }
      break;
    default:
      if(await showConfirmationDialog(context, '¿Estás seguro de que deseas eliminar la categoría')){
        // Elimina la categoría de la base de datos en línea y local
        await deleteCategories(uid);
        await deleteLocalCategory(uid);
        Navigator.pop(context);
      }
  }
}

Future<void> updateProductController(BuildContext context, String uid, String name, String assetImage, String selectedCategory, String price, bool isAvailable, int isEdit)async{
  //Validar y hacer la actualización
  switch(isEdit){
    case 0:
      if(isValidName(name)){
        if(isValidCategory(selectedCategory)){
          if(isValidPrice(price)){
            if(isValidImage(assetImage)){
              await updateProducts(uid, name, assetImage, selectedCategory, double.parse(price), isAvailable);
              await updateLocalProduct(uid, name, assetImage, selectedCategory, double.parse(price), isAvailable ? 1 : 0);
              Navigator.pop(context);
            }else{
              showDialogCustom(context, 'SELECCIONAR IMAGEN', 'FAVOR DE ESCOGER UNA IMAGEN.');
            }
          }else{
            showDialogCustom(context, 'PRECIO INCORRECTO', 'FAVOR DE PONER UN PRECIO CORRECTO.');
          }
        }else{
          showDialogCustom(context, 'SELECCIONAR CATEGORIA', 'FAVOR DE ESCOGER UNA CATEGORÍA.');
        }
      }else{
        showDialogCustom(context, 'NOMBRE INCORRECTO', 'FAVOR DE PONER UN NOMBRE CORRECTO.');
      }
      break;
    case 1:
      if(isValidName(name)){
        if(isValidCategory(selectedCategory)){
          if(isValidPrice(price)){
            if(isValidImage(assetImage)){
              String uid = await addProducts(name, assetImage, selectedCategory, double.parse(price), isAvailable);
              await addLocalProduct(uid, name, assetImage, selectedCategory, double.parse(price), isAvailable ? 1 : 0);
              Navigator.pop(context);
            }else{
              showDialogCustom(context, 'SELECCIONAR IMAGEN', 'FAVOR DE ESCOGER UNA IMAGEN.');
            }
          }else{
            showDialogCustom(context, 'PRECIO INCORRECTO', 'FAVOR DE PONER UN PRECIO CORRECTO.');
          }
        }else{
          showDialogCustom(context, 'SELECCIONAR CATEGORIA', 'FAVOR DE ESCOGER UNA CATEGORÍA.');
        }
      }else{
        showDialogCustom(context, 'NOMBRE INCORRECTO', 'FAVOR DE PONER UN NOMBRE CORRECTO.');
      }
      break;
    default:
      if(await showConfirmationDialog(context, '¿Estás seguro de que deseas eliminar la categoría')){
        // Elimina la categoría de la base de datos en línea y local
        await deleteProducts(uid);
        await deleteLocalProducts(uid);
      }
  }
}