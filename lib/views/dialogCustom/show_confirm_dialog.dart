
import 'package:flutter/material.dart';

Future<bool> showConfirmationDialog(
    BuildContext context, String title) async {
  // Muestra el diálogo y espera la respuesta del usuario
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Confirmación'),
      content: const Text(
        '¿Estás seguro de que deseas eliminar la categoría',
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(true); // Confirma la acción
          },
          child: const Text('Sí'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false); // Cancela la acción
          },
          child: const Text('No'),
        ),
      ],
    ),
  );

  // Retorna el resultado (true si el usuario confirma, false si cancela)
  return result ?? false;
}