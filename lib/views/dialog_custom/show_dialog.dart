import 'package:flutter/material.dart';

// Función para mostrar el diálogo de error
bool showDialogCustom(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    barrierDismissible: false, // Evita que se cierre tocando fuera del diálogo
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title, textAlign: TextAlign.center,),
        content: Text(message, textAlign: TextAlign.center,),
        actionsAlignment: MainAxisAlignment.center,
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cierra el diálogo
            },
            child: const Text('Cerrar', style: TextStyle(color: Colors.black87)),
          ),
        ],
      );
    },
  );
  return true;
}
