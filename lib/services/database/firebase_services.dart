import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timbas/views/cart/components/cart_notifier.dart' as cart;

FirebaseFirestore db= FirebaseFirestore.instance;

Future<List> getCategories() async{
  List categories = [];

  CollectionReference collectionReferenceCategories = db.collection('categorias');

  QuerySnapshot queryCategories = await collectionReferenceCategories.get();
  for (var document in queryCategories.docs) {
    final Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    final caterogie = {
      'nombre' : data['nombre'],
      'uid' : document.id
    };
    categories.add(caterogie);
  }
  return categories;
}

Future<String> addCategories(String name) async {
  // Añade la categoría a Firestore y devuelve el UID del documento creado
  DocumentReference docRef = await db.collection('categorias').add({
    'nombre': name,
  });
  return docRef.id; // Devuelve el UID
}

Future<void> deleteCategories(String uid) async {
  // Elimina la categoría a Firestore
  await db.collection('categorias').doc(uid).delete();
}

Future<void> updateCategories(String uid, String name) async{
  await db.collection('categorias').doc(uid).set({'nombre' : name});
}

//////////////////////////////////////////////////////////////////////////

Future<List> getProducts() async{
  List products = [];

  CollectionReference collectionReferenceProducts = db.collection('productos');

  QuerySnapshot queryProducts = await collectionReferenceProducts.get();
  for (var document in queryProducts.docs) {
    final Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    final product = {
      'nombre' : data['nombre'],
      'uid' : document.id,
      'precio' : data['precio'],
      'imagen' : data['imagen'],
      'categorias' : data['categorias'],
      'activo' : data['activo'],
      'extra' : data['extra'],
    };
    products.add(product);
  }
  return products;
}

Future<String> addProducts(String name, String image, String categories, double price, bool active) async{
  DocumentReference docRef = await db.collection('productos').add(
    {
      'activo' : active,
      'categorias' : categories,
      'imagen' : image,
      'nombre' : name,
      'precio' : price
    }
  );
  return docRef.id; // Devuelve el UID
}

Future<void> updateProducts(String uid, String name, String image, String categories, double price, bool active, double extra) async{
  await db.collection('productos').doc(uid).set({
    'nombre' : name,
    'imagen' : image,
    'categorias' : categories,
    'precio' : price,
    'activo' : active,
    'extra' : extra,
  });
}

Future<void> deleteProducts(String uid) async {
  // Elimina la categoría a Firestore
  await db.collection('productos').doc(uid).delete();
}

Future<void> addOrders(String uid, cart.Order order) async {
  // Guardar el pedido en la colección "orders"
  final orderDoc = db.collection('orders').doc(uid);
  await orderDoc.set({
    'id': order.id,
    'total': order.total,
    'mesa': order.mesa,
    'timestamp': order.timestamp,
  });

  // Guardar los elementos del pedido en la subcolección "items"
  for (var item in order.items) {
    final itemDoc = await orderDoc.collection('items').add({
      'product_name': item.producto.nombre,
      'category': item.categoria,
      'comments': item.comentario,
      'quantity': item.cantidad,
      'total_price': item.totalPrice,
    });

    // Guardar los extras asociados a este item en la subcolección "extras"
  for (var extra in item.extras) {
    await itemDoc.collection('extras').add({
      'extra_name': extra.nombre,
      'extra_price': extra.precio,
    });
  }
  }
}

Future<void> deleteOrder(String orderId) async {
  try {
    // Obtén la referencia al documento de la orden
    final orderDoc = FirebaseFirestore.instance.collection('orders').doc(orderId);

    // Eliminar el documento de la colección
    await orderDoc.delete();
    print('Orden eliminada con éxito.');
  } catch (e) {
    print('Error al eliminar la orden: $e');
  }
}

Future<List<Map<String, dynamic>>> fetchSalesData({String? period, // ahora opcional
  DateTime? startDate,
  DateTime? endDate,}) async {
    final now = DateTime.now();
    DateTime startOfPeriod;
    DateTime endOfPeriod = endDate ?? now;

    if (startDate != null && endDate != null) {
    // Si se pasan fechas específicas, usamos esas
      startOfPeriod = startDate;
      endOfPeriod = endDate;
    }else if (period == 'day') {
      // Si la hora actual es antes de las 2 PM, el periodo comienza desde AYER a las 2 PM
      bool isBefore2PM = now.hour < 14;
      startOfPeriod = isBefore2PM
          ? DateTime(now.year, now.month, now.day - 1, 14) // Ayer a las 2 PM
          : DateTime(now.year, now.month, now.day, 14); // Hoy a las 2 PM
    } else {
      startOfPeriod = DateTime(now.year, now.month, now.day - 6, 14).subtract(const Duration(days: 1)); // Hace una semana a las 2PM
    }

    // Consultar a Firebase
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('timestamp', isGreaterThanOrEqualTo: startOfPeriod)
        .where('timestamp', isLessThanOrEqualTo: endOfPeriod)
        .orderBy('timestamp', descending: true)
        .get();

  List<Map<String, dynamic>> results = [];

  // Iterar sobre los documentos principales
  for (var doc in snapshot.docs) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id; // Añadir el ID del documento

    // Consultar subcolección 'details' si existe
    QuerySnapshot subCollectionSnapshot = await FirebaseFirestore.instance
        .collection('orders')
        .doc(doc.id)
        .collection('items')
        .get();

    List<Map<String, dynamic>> items = [];

    // Iterar sobre los 'items'
    for (var itemDoc in subCollectionSnapshot.docs) {
      Map<String, dynamic> itemData = itemDoc.data() as Map<String, dynamic>;

      // Consultar los 'extras' de cada item
      QuerySnapshot extrasSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .doc(doc.id)
          .collection('items')
          .doc(itemDoc.id)
          .collection('extras')
          .get();

      itemData['extras'] = extrasSnapshot.docs
          .map((extraDoc) => extraDoc.data() as Map<String, dynamic>)
          .toList();

      items.add(itemData);
    }

    data['items'] = items;
    results.add(data);
  }

  return results;

  }

Future<List<Map<String, dynamic>>> getPromotions() async {
  final snapshot = await db.collection('promociones').where('activo', isEqualTo: true).get();
  return snapshot.docs.map((doc) {
    return {
      'uid': doc.id,
      'nombre': doc['nombre'],
      'productos': List<String>.from(doc['productos']),
      'precio_combo': doc['precio_combo'],
    };
  }).toList();
}
