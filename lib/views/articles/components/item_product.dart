import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:timbas/controllers/bd_controller.dart';


class ItemProduct extends StatefulWidget {
  final bool isEdit;
  final String? name, image, uid, category;
  final double? price;
  final bool? active;
  final Map<String, String>? categoryNames;

  const ItemProduct({
    super.key,
    required this.isEdit,
    this.name,
    this.image, // Ruta de la imagen, como "assets/images/icons/oreo.png"
    this.category,
    this.price,
    this.active,
    this.uid,
    this.categoryNames,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ItemProductState createState() => _ItemProductState();
}

class _ItemProductState extends State<ItemProduct> {
  bool _isAvailable = true;
  String? _selectedCategory;
  late TextEditingController _priceController;
  late TextEditingController _nameController;
  String? _assetImage; // Variable para manejar la imagen de assets
  String? _imagePath;

  @override
  void initState() {
    _priceController = TextEditingController(
      text: widget.isEdit ? widget.price?.toString() : null,
    );
    _nameController = TextEditingController(
      text: widget.isEdit ? widget.name : null,
    );

    // Inicializar categoría y estado "activo" si es edición
    if (widget.isEdit) {
      //_selectedCategory = _categories[widget.category != null ? (widget.category!) : 0];
      _isAvailable = widget.active ?? true;
      if (widget.category != null) {
        _selectedCategory = widget.category;
      }
      // Cargar imagen desde assets si está disponible
      if (widget.image != null && widget.image!.startsWith('assets/')) {
        _assetImage = widget.image;
      }
      else if(widget.image != null){
        _assetImage = widget.image;
      }
    } else {
      _isAvailable = true;
    }
    super.initState();
  }

  @override
  void dispose() {
    _priceController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imagePath = image.path;
        _assetImage = null; // Limpiar la imagen de assets cuando se selecciona una nueva imagen
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEdit ? 'Editar artículo' : 'Crear artículo',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              String name = _nameController.text;
              //  lógica de guardado aquí
              if (widget.isEdit) {
                await updateProductController(context, widget.uid!, name, _assetImage ?? _imagePath ?? 'n.xrltalcual', _selectedCategory ?? 'n.xrltalcual', _priceController.text, _isAvailable, 0);
              } else {
                //  lógica de inserción aquí
                await updateProductController(context, '', name, _assetImage ?? _imagePath ?? 'n.xrltalcual', _selectedCategory ?? 'n.xrltalcual', _priceController.text, _isAvailable, 1);
              }
            },
            child: const Text(
              "GUARDAR",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
        iconTheme: const IconThemeData(
          color: Colors.white, // Cambia el color de la flecha de retroceso a blanco
        ),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              hint: const Text('Seleccionar categoría'),
              items: widget.categoryNames?.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Categoría',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                _PriceInputFormatter(),
              ],
              decoration: const InputDecoration(
                labelText: 'Precio',
              ),
            ),
            const SizedBox(height: 16),
            const Text("SELECCIONAR FOTO"),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                child: _assetImage != null
                        ? Image.asset(
                            _assetImage!,
                            fit: BoxFit.cover,
                          )
                        : const Center(
                            child: Text(
                              'Toca para seleccionar una imagen(No disponible)',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text("ACTIVO:"),
                Radio<bool>(
                  value: true,
                  groupValue: _isAvailable,
                  onChanged: (bool? value) {
                    setState(() {
                      _isAvailable = value ?? true;
                    });
                  },
                ),
                const Text("Sí"),
                Radio<bool>(
                  value: false,
                  groupValue: _isAvailable,
                  onChanged: (bool? value) {
                    setState(() {
                      _isAvailable = value ?? false;
                    });
                  },
                ),
                const Text("No"),
              ],
            ),
            const SizedBox(height: 16),
            widget.isEdit
                ? TextButton(
                    onPressed: () async {
                      // funcionalidad de eliminación aquí
                      await updateProductController(context, widget.uid!, '', '', _selectedCategory!, _priceController.text, _isAvailable, 2);
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Icon(Icons.delete, color: Colors.black), Text("ELIMINAR ARTICULO", style: TextStyle(color: Colors.black),)],
                    ),
                  )
                : const SizedBox.shrink(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _PriceInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Eliminar todos los caracteres no numéricos, excepto el punto decimal.
    final newText = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Formatear el texto con el punto decimal.
    String formattedText;
    if (newText.isEmpty) {
      formattedText = '';
    } else if (newText.length <= 2) {
      formattedText = newText.padLeft(2);
    } else {
      final integerPart = newText.substring(0, newText.length - 2);
      final decimalPart = newText.substring(newText.length - 2);
      formattedText = '$integerPart.$decimalPart';
    }

    // Mantener el cursor en la posición correcta.
    final newSelection = TextSelection.collapsed(offset: formattedText.length);

    return TextEditingValue(
      text: formattedText,
      selection: newSelection,
    );
  }
}
