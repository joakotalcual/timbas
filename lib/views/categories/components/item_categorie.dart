import 'package:flutter/material.dart';
import 'package:timbas/services/database/firebase_services.dart';
import 'package:timbas/services/database/sqlite.dart';

class ItemCategorie extends StatefulWidget {
  final bool isEdit;
  final String? name, uid;
  const ItemCategorie({super.key, required this.isEdit, this.name, this.uid});

  @override
  State<ItemCategorie> createState() => _ItemCategorieState();
}

class _ItemCategorieState extends State<ItemCategorie> {
  late TextEditingController _nameController;

  @override
  void initState() {
    _nameController = TextEditingController(
      text: widget.isEdit ? widget.name : null,
    );

    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEdit ? 'Editar categoría' : 'Crear categoría',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(
          color: Colors
              .white, // Cambia el color de la flecha de retroceso a blanco
        ),
        actions: [
          TextButton(
            onPressed: () async {
              String name = _nameController.text;
              // Implementar lógica de guardado aquí
              if (widget.isEdit) {
                // Actualiza en Firebase y en la base de datos local
                await updateCategories(widget.uid!, name);
                await updateLocalCategory(widget.uid!, name);
                Navigator.pop(context);
              } else {
                // Añade en Firebase y en la base de datos local
                String uid =
                    await addCategories(name); // Obtiene el UID de Firestore
                await addLocalCategory(
                    uid, name); // Usa el UID para la base de datos local
                Navigator.pop(context);
              }
            },
            child: const Text(
              "GUARDAR",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            const SizedBox(
              height: 250,
            ),
            widget.isEdit
                ? TextButton(
                    onPressed: () async {
                      // Llama al diálogo de confirmación y espera el resultado
                      bool confirmation = await _showConfirmationDialog(
                          context, 'la categoría');
                      if (confirmation) {
                        // Elimina la categoría de la base de datos en línea y local
                        await deleteCategories(widget.uid!);
                        await deleteLocalCategory(widget.uid!);
                      }
                    },
                    child: const Text(
                      "ELIMINAR CATEGORÍA",
                    ),
                  )
                : const SizedBox.shrink(),

            // const Text("SELECCIONAR FOTO"),
            // const SizedBox(height: 16),
            // GestureDetector(
            //   onTap: _pickImage,
            //   child: Container(
            //     height: 200,
            //     width: double.infinity,
            //     decoration: BoxDecoration(
            //       border: Border.all(color: Colors.grey),
            //     ),
            //     child: _selectedImage != null
            //         ? Image.file(
            //             _selectedImage!,
            //             fit: BoxFit.cover,
            //           )
            //         : _assetImage != null
            //             ? Image.asset(
            //                 _assetImage!,
            //                 fit: BoxFit.cover,
            //               )
            //             : const Center(
            //                 child: Text(
            //                   'Toca para seleccionar una imagen',
            //                   style: TextStyle(color: Colors.grey),
            //                 ),
            //               ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

Future<bool> _showConfirmationDialog(
    BuildContext context, String categoria) async {
  // Muestra el diálogo y espera la respuesta del usuario
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Confirmación'),
      content: Text(
        '¿Estás seguro de que deseas eliminar la categoría $categoria',
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
