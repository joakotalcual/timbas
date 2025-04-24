
// Validador para el nombre del producto
bool isValidName(String name) {
  // Expresión regular actualizada: letras (incluyendo acentos), espacios, &, números y puntos
  String p = r'^[A-Za-zÀ-ÖØ-öø-ÿ0-9\s&.]+$';
  RegExp regExp = RegExp(p);
  return regExp.hasMatch(name);
}

// Validador para el precio del producto
bool isValidPrice(String price) {
  // Comprobamos si el precio es un número válido y positivo
  try {
    double parsedPrice = double.parse(price);
    return parsedPrice >= 0;
  } catch (e) {
    return false;
  }
}

// Validador para la categoría seleccionada
bool isValidCategory(String category) {
  // Validación sencilla, puedes personalizar según tu lógica
  String p = 'n.xrltalcual';
  RegExp regExp = RegExp(p);
  return !regExp.hasMatch(category);
}

bool isValidImage(String image){
  String p = 'n.xrltalcual';
  RegExp regExp = RegExp(p);
  return !regExp.hasMatch(image);
}