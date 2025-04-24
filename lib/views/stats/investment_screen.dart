import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InvestmentScreen extends StatefulWidget {
  const InvestmentScreen({super.key});

  @override
  State<InvestmentScreen> createState() => _InvestmentScreenState();
}

class _InvestmentScreenState extends State<InvestmentScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  void _addInvestment() async {
    final description = _descriptionController.text;
    final amount = double.tryParse(_amountController.text);

    if (description.isNotEmpty && amount != null) {
      try {
        await FirebaseFirestore.instance.collection('investments').add({
          'description': description,
          'amount': amount,
          'timestamp': DateTime.now(),
        });

        _descriptionController.clear();
        _amountController.clear();
      } catch (e) {
        print('Error al guardar la inversión: $e');
      }
    }
  }

  void _deleteInvestment(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('investments')
          .doc(docId)
          .delete();
    } catch (e) {
      print('Error al eliminar la inversión: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nueva Inversión',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Descripción'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Monto (\$)'),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _addInvestment,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              child: const Text('Agregar Inversión',
                  style: TextStyle(color: Colors.black)),
            ),
          ),
          const Divider(),
          const Text('Historial de Inversiones',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('investments')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: Colors.black));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No hay inversiones registradas.',
                        style: TextStyle(color: Colors.black54)),
                  );
                }

                final investments = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: investments.length,
                  itemBuilder: (context, index) {
                    final doc = investments[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final timestamp = (data['timestamp'] as Timestamp).toDate();

                    return Card(
                      child: ListTile(
                        title: Text(data['description'],
                            style: const TextStyle(color: Colors.black)),
                        subtitle: Text(
                            'Monto: \$${(data['amount'] as num).toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.black87)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              DateFormat('dd-MM-yyyy').format(timestamp),
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.black54),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('¿Eliminar inversión?'),
                                    content: const Text(
                                        '¿Estás seguro que deseas eliminar esta inversión? Esta acción no se puede deshacer.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: const Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        child: const Text('Eliminar',
                                            style:
                                                TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  _deleteInvestment(doc.id);
                                }
                              },
                              tooltip: 'Eliminar inversión',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
