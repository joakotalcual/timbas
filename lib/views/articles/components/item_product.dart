import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ItemProduct extends StatefulWidget {
  final bool isEdit;
  const ItemProduct({super.key, required this.isEdit});

  @override
  _ItemProductState createState() => _ItemProductState();
}

class _ItemProductState extends State<ItemProduct> {
  bool _isAvailable = true;
  String? _selectedCategory;
  final List<String> _categories = ['Diablitos', 'Frappes', 'Frappes de frutas', 'Machakados', 'Smoothies'];
  final TextEditingController _priceController = TextEditingController();

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
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
            onPressed: () {
              // Implement save functionality here
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
            const TextField(
              decoration: InputDecoration(
                labelText: 'Nombre',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              hint: const Text('Seleccionar categoría'),
              items: _categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
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
              keyboardType: TextInputType.numberWithOptions(decimal: true),
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
            widget.isEdit ? TextButton(
              onPressed: () {
                // Implement delete functionality here
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Icon(Icons.delete), Text("ELIMINAR ARTICULOS")],
              ),
            ) : const SizedBox.shrink(),
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
