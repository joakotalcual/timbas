import 'package:flutter/material.dart';

class PaymentDialog extends StatefulWidget {
  final double totalAmount;

  const PaymentDialog({super.key, required this.totalAmount});

  @override
  _PaymentDialogState createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  final TextEditingController _controller = TextEditingController();
  double change = 0.0;

  void _calculateChange(String value) {
    final enteredAmount = double.tryParse(value) ?? 0.0;
    setState(() {
      change = enteredAmount - widget.totalAmount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pago'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Total a cobrar: \$${widget.totalAmount.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Cantidad entregada',
              border: OutlineInputBorder(),
            ),
            onChanged: _calculateChange,
          ),
          const SizedBox(height: 20),
          Text(
            'Cambio: \$${change.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(0.00); // Retorna 0 si se cancela
          },
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            final enteredAmount = double.tryParse(_controller.text);

            // Verifica si la cantidad es válida
            if (enteredAmount == null || enteredAmount <= 0) {
              // Muestra un mensaje de error si la cantidad no es válida
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Por favor ingrese una cantidad válida mayor que 0.'),
                  backgroundColor: Colors.red,
                ),
              );
            } else if(widget.totalAmount > enteredAmount){
              // Si la cantidad es válida, cierra el diálogo y pasa la cantidad
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Por favor ingrese una cantidad igual o mayor al total a cobrar.'),
                  backgroundColor: Colors.red,
                ),
              );
            }else{
              Navigator.of(context).pop(enteredAmount);
            }
          },
          child: const Text('Aceptar'),
        ),
      ],
    );
  }
}

Future<double?> showPaymentDialog(BuildContext context, double totalAmount) {
  return showDialog<double>(
    context: context,
    builder: (BuildContext context) {
      return PaymentDialog(totalAmount: totalAmount);
    },
  );
}
