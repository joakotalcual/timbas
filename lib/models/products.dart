class Producto {
  final String id;
  final String nombre;
  final String imagen;
  final String idCategorias;
  final double precio;
  final bool activo;
  final double extra;

  Producto({
    required this.id,
    required this.nombre,
    required this.imagen,
    required this.idCategorias,
    required this.precio,
    required this.activo,
    required this.extra
});

  factory Producto.fromMap(Map<String, dynamic> map) {
    return Producto(
      id: map['uid'],
      nombre: map['nombre'],
      imagen: map['imagen'],
      idCategorias: map['categorias'],
      precio: map['precio'],
      activo: map['activo'] == 1,
      extra: map['extra'] != null ? (map['extra'] as num).toDouble() : 0.0,
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