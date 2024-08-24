import 'package:cloud_firestore/cloud_firestore.dart';

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
      'activo' : data['activo']
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

Future<void> updateProducts(String uid, String name, String image, String categories, double price, bool active) async{
  await db.collection('productos').doc(uid).set({
    'nombre' : name,
    'imagen' : image,
    'categorias' : categories,
    'precio' : price,
    'activo' : active
  });
}

Future<void> deleteProducts(String uid) async {
  // Elimina la categoría a Firestore
  await db.collection('productos').doc(uid).delete();
}