import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrintTicketScreen extends StatefulWidget {
  @override
  _PrintTicketScreenState createState() => _PrintTicketScreenState();
}

class _PrintTicketScreenState extends State<PrintTicketScreen> {
  final BluetoothPrint bluetoothPrint = BluetoothPrint.instance;

  bool _connected = false;
  BluetoothDevice? _device;
  String tips = 'No device connected';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => initBluetooth());
  }

  // Método para inicializar el Bluetooth y reconectar automáticamente
  Future<void> initBluetooth() async {
    bluetoothPrint.startScan(timeout: Duration(seconds: 4));

    // Escucha cambios en el estado de conexión
    bluetoothPrint.state.listen((state) {
      print('******************* Current device status: $state');
      switch (state) {
        case BluetoothPrint.CONNECTED:
          setState(() {
            _connected = true;
            tips = 'Connect success';
          });
          break;
        case BluetoothPrint.DISCONNECTED:
          setState(() {
            _connected = false;
            tips = 'Disconnect success';
          });
          break;
        default:
          break;
      }
    });

    if (!mounted) return;

    // Intentar reconectar automáticamente
    await autoReconnect();
  }

  // Método para reconectar automáticamente a un dispositivo guardado
  Future<void> autoReconnect() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedAddress = prefs.getString('saved_device_address');

    if (savedAddress != null) {
      List<BluetoothDevice> devices = await bluetoothPrint.scanResults.first;
      _device = devices.firstWhere((d) => d.address == savedAddress);
      if (_device != null) {
        await bluetoothPrint.connect(_device!);
      }
    }
  }

  // Método para guardar la dirección MAC del dispositivo conectado
  Future<void> saveDevice(BluetoothDevice device) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('connected_device', device.address!);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('BluetoothPrint example app'),
        ),
        body: RefreshIndicator(
          onRefresh: () =>
              bluetoothPrint.startScan(timeout: Duration(seconds: 4)),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      child: Text(tips),
                    ),
                  ],
                ),
                Divider(),
                StreamBuilder<List<BluetoothDevice>>(
                  stream: bluetoothPrint.scanResults,
                  initialData: [],
                  builder: (c, snapshot) => Column(
                    children: snapshot.data!
                        .map((d) => ListTile(
                              title: Text(d.name ?? ''),
                              subtitle: Text(d.address ?? ''),
                              onTap: () async {
                                setState(() {
                                  _device = d;
                                });
                              },
                              trailing: _device != null &&
                                      _device!.address == d.address
                                  ? Icon(
                                      Icons.check,
                                      color: Colors.green,
                                    )
                                  : null,
                            ))
                        .toList(),
                  ),
                ),
                Divider(),
                Container(
                  padding: EdgeInsets.fromLTRB(20, 5, 20, 10),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          OutlinedButton(
                            child: Text('Connect'),
                            onPressed: _connected
                                ? null
                                : () async {
                                    if (_device != null &&
                                        _device!.address != null) {
                                      setState(() {
                                        tips = 'Connecting...';
                                      });
                                      await bluetoothPrint.connect(_device!);
                                      // Guardar el dispositivo conectado
                                      saveDevice(_device!);
                                    } else {
                                      setState(() {
                                        tips = 'Please select a device';
                                      });
                                      print('Please select a device');
                                    }
                                  },
                          ),
                          SizedBox(width: 10.0),
                          OutlinedButton(
                            child: Text('Disconnect'),
                            onPressed: _connected
                                ? () async {
                                    setState(() {
                                      tips = 'Disconnecting...';
                                    });
                                    await bluetoothPrint.disconnect();
                                  }
                                : null,
                          ),
                        ],
                      ),
                      Divider(),
                      OutlinedButton(
                        child: Text('Print receipt (ESC)'),
                        onPressed: _connected
                            ? () async {
                                Map<String, dynamic> config = Map();

                                List<LineText> list = [];

                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    content:
                                        '**********************************************',
                                    weight: 1,
                                    align: LineText.ALIGN_CENTER,
                                    linefeed: 1));
                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    content: 'Receipt Header',
                                    weight: 1,
                                    align: LineText.ALIGN_CENTER,
                                    fontZoom: 2,
                                    linefeed: 1));
                                list.add(LineText(linefeed: 1));

                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    content:
                                        '----------------------Details---------------------',
                                    weight: 1,
                                    align: LineText.ALIGN_CENTER,
                                    linefeed: 1));
                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    content: 'Item Name Specification',
                                    weight: 1,
                                    align: LineText.ALIGN_LEFT,
                                    x: 0,
                                    relativeX: 0,
                                    linefeed: 0));
                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    content: 'Unit',
                                    weight: 1,
                                    align: LineText.ALIGN_LEFT,
                                    x: 350,
                                    relativeX: 0,
                                    linefeed: 0));
                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    content: 'Quantity',
                                    weight: 1,
                                    align: LineText.ALIGN_LEFT,
                                    x: 500,
                                    relativeX: 0,
                                    linefeed: 1));

                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    content: 'Concrete C30',
                                    align: LineText.ALIGN_LEFT,
                                    x: 0,
                                    relativeX: 0,
                                    linefeed: 0));
                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    content: 'Ton',
                                    align: LineText.ALIGN_LEFT,
                                    x: 350,
                                    relativeX: 0,
                                    linefeed: 0));
                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    content: '12.0',
                                    align: LineText.ALIGN_LEFT,
                                    x: 500,
                                    relativeX: 0,
                                    linefeed: 1));

                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    content:
                                        '**********************************************',
                                    weight: 1,
                                    align: LineText.ALIGN_CENTER,
                                    linefeed: 1));
                                list.add(LineText(linefeed: 1));

                                ByteData data = await rootBundle
                                    .load("assets/images/bluetooth_print.png");
                                List<int> imageBytes = data.buffer
                                    .asUint8List(data.offsetInBytes,
                                        data.lengthInBytes);
                                String base64Image = base64Encode(imageBytes);
                                // list.add(LineText(type: LineText.TYPE_IMAGE, content: base64Image, align: LineText.ALIGN_CENTER, linefeed: 1));

                                await bluetoothPrint.printReceipt(
                                    config, list);
                              }
                            : null,
                      ),
                      OutlinedButton(
                        child: Text('Print label (TSC)'),
                        onPressed: _connected
                            ? () async {
                                Map<String, dynamic> config = Map();
                                config['width'] = 40; // Label width, in mm
                                config['height'] = 70; // Label height, in mm
                                config['gap'] = 2; // Label gap, in mm

                                // x, y coordinates, in dpi (1mm = 8dpi)
                                List<LineText> list = [];
                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    x: 10,
                                    y: 10,
                                    content: 'A Title'));
                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    x: 10,
                                    y: 40,
                                    content: 'this is content'));
                                list.add(LineText(
                                    type: LineText.TYPE_QRCODE,
                                    x: 10,
                                    y: 70,
                                    content: 'qrcode i\n'));
                                list.add(LineText(
                                    type: LineText.TYPE_BARCODE,
                                    x: 10,
                                    y: 190,
                                    content: 'qrcode i\n'));

                                List<LineText> list1 = [];
                                ByteData data = await rootBundle
                                    .load("assets/images/guide3.png");
                                List<int> imageBytes = data.buffer                                    .asUint8List(data.offsetInBytes, data.lengthInBytes);
                                String base64Image = base64Encode(imageBytes);
                                list1.add(LineText(
                                    type: LineText.TYPE_IMAGE,
                                    x: 10,
                                    y: 10,
                                    content: base64Image));

                                await bluetoothPrint.printLabel(config, list);
                              }
                            : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
