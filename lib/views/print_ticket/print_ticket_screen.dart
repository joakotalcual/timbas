import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:timbas/models/printer.dart';

class PrintTicketScreen extends StatefulWidget {
  @override
  _PrintTicketScreenState createState() => _PrintTicketScreenState();
}

class _PrintTicketScreenState extends State<PrintTicketScreen> {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  List<BluetoothDevice> devices = [];
  BluetoothDevice? selectedDevice;
  String statusMessage = "Selecciona una impresora";
  String? connectedPrinter;

  @override
  void initState() {
    super.initState();
    _getBondedDevices();
    _checkConnectedPrinter();
  }

  Future<void> _getBondedDevices() async {
    try {
      List<BluetoothDevice> bondedDevices = await bluetooth.getBondedDevices();
      setState(() {
        devices = bondedDevices;
      });
    } catch (e) {
      setState(() {
        statusMessage = "Error al obtener dispositivos.";
        print('Error al obtener dispositivos: $e');
      });
    }
  }

  Future<void> _checkConnectedPrinter() async {
    try {
      bool? isConnected = await bluetooth.isConnected;
      if (isConnected ?? false) {
        String? address = await Printer().getPrinterAddress();
        if (address != null) {
          List<BluetoothDevice> bondedDevices = await bluetooth.getBondedDevices();
          // Proporcionar un valor predeterminado en caso de que no se encuentre el dispositivo
          BluetoothDevice? connectedDevice = bondedDevices.firstWhere(
            (device) => device.address == address,
            orElse: () => BluetoothDevice("Desconocido", address),
          );

          setState(() {
            connectedPrinter = connectedDevice.name ?? "Sin nombre";
          });
        }
      }
    } catch (e) {
      setState(() {
        connectedPrinter = "Error al verificar conexión";
      });
    }
  }

  Future<void> _connectToPrinter() async {
    if (selectedDevice == null) {
      setState(() {
        statusMessage = "Por favor selecciona una impresora.";
      });
      return;
    }

    try {
      setState(() {
        statusMessage = "Conectando a ${selectedDevice!.name}...";
      });

      // Desconectar antes de conectar
      if (await bluetooth.isConnected ?? false) {
        await bluetooth.disconnect();
      }

      await bluetooth.connect(selectedDevice!);
      setState(() {
        statusMessage = "Conexión exitosa con ${selectedDevice!.name}.";
        connectedPrinter = selectedDevice!.name;
      });

      // Guardar la dirección de la impresora para reconexión automática
      await Printer().savePrinterAddress(selectedDevice!.address!);
    } catch (e) {
      setState(() {
        statusMessage = "Error al conectar: ${selectedDevice!.name}";
        print('Error al conectar: $e');
      });
    }
  }

  Future<void> _disconnectPrinter() async {
    try {
      await bluetooth.disconnect();
      setState(() {
        connectedPrinter = null;
        statusMessage = "Desconectado exitosamente.";
      });

      // Eliminar la dirección guardada
      await Printer().savePrinterAddress("");
    } catch (e) {
      setState(() {
        statusMessage = "Error al desconectar";
        print("Error al desconectar: $e");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (connectedPrinter != null && connectedPrinter != 'Error al verificar conexión')
                  Column(
                    children: [
                      Text("Impresora conectada: $connectedPrinter"),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _disconnectPrinter,
                        child: const Text("Desconectar / Olvidar", style: TextStyle(color: Colors.black),),
                      ),
                    ],
                  )
                else
                  const Text("No hay ninguna impresora conectada."),
                  const SizedBox(height: 20),
                if (devices.isEmpty)
                  const Text("No se encontraron dispositivos emparejados.")
                else
                  DropdownButton<BluetoothDevice>(
                    hint: const Text("Selecciona una impresora"),
                    value: selectedDevice,
                    items: devices
                        .map((device) => DropdownMenuItem(
                              value: device,
                              child: Text(device.name ?? "Sin nombre"),
                            ))
                        .toList(),
                    onChanged: (device) {
                      setState(() {
                        selectedDevice = device;
                      });
                    },
                  ),
                const SizedBox(height: 20),
                if (devices.isNotEmpty)
                  ElevatedButton(
                    onPressed: _connectToPrinter,
                    child: const Text("Conectar", style: TextStyle(color: Colors.black),),
                  ),
                const SizedBox(height: 20),
                Text(statusMessage),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
