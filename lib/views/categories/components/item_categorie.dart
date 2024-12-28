import 'package:flutter/material.dart';
import 'package:timbas/controllers/bd_controller.dart';

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
              String name = _nameController.text.toUpperCase();
              // Implementar lógica de guardado aquí
              if (widget.isEdit) {
                // Actualiza en Firebase y en la base de datos local
                await updateCategorieController(context, widget.uid!, name, 0);
              } else {
                // Añade en Firebase y en la base de datos local
                await updateCategorieController(context, '', name, 1);
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
                      await updateCategorieController(context, widget.uid!, '', 2);
                    },
                    child: const Text(
                      "ELIMINAR CATEGORÍA",
                      style: TextStyle(
                        color: Colors.black
                      ),
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
