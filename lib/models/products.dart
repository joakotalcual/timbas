class Producto {
  final String id;
  final String nombre;
  final String imagen;
  final String idCategorias;
  final double precio;
  final bool activo;

  Producto({
    required this.id,
    required this.nombre,
    required this.imagen,
    required this.idCategorias,
    required this.precio,
    required this.activo
});

  factory Producto.fromMap(Map<String, dynamic> map) {
    return Producto(
      id: map['uid'],
      nombre: map['nombre'],
      imagen: map['imagen'],
      idCategorias: map['categorias'],
      precio: map['precio'],
      activo: map['activo'] == 1,
    );
  }
}

class Categoria {
  final String id;
  final String nombre;

  Categoria({
    required this.id,
    required this.nombre,
  });
}