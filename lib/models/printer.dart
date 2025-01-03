import 'dart:typed_data';

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timbas/views/dialog_custom/show_dialog.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';

class Printer {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  // Almacenar la dirección de la impresora
  Future<void> savePrinterAddress(String address) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('printer_address', address);
  }

  // Recuperar la dirección de la impresora
  Future<String?> getPrinterAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('printer_address');
  }

  // Reconectar automáticamente
  Future<bool?> reconnectPrinter(BuildContext context) async {
    final address = await getPrinterAddress();
    if (address != null) {
      try {
        List<BluetoothDevice> devices = await bluetooth.getBondedDevices();
        BluetoothDevice? device;

        try {
          device = devices.firstWhere((d) => d.address == address);
        } catch (_) {
          showDialogCustom(context, 'La impresora no está emparejada', '');
          return null;
        }

        await bluetooth.connect(device);
        return true;
      } catch (e) {
        showDialogCustom(context, 'Error al reconectar la impresora',
            'Verifique que este encendida o con carga.');
        print('Error al reconectar la impresora: $e');
        return null;
      }
    } else {
      showDialogCustom(
          context, 'Error', 'No se ha conectado ninguna impresora.');
      return null;
    }
  }

  // Verificar la conexión antes de imprimir
  Future<bool?> ensureConnection(BuildContext context) async {
    bool? connected = await bluetooth.isConnected;
    if (connected == null || !connected) {
      return await reconnectPrinter(context);
    } else {
      print('Ya está conectado');
      return true;
    }
  }

  Future<void> printTicket(List items) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);

    List<int> bytes = [];

    // Obtener fecha y hora actuales
    final now = DateTime.now();
    final formatter = DateFormat('dd-MM-yyyy HH:mm');
    final formattedDate = formatter.format(now);

    bytes += generator.feed(2);
    bytes += generator.text('Fecha: $formattedDate', styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('--------------------------------');

    // Detalle de los ítems
    for (var item in items) {
      final nombre = sanitizeText(item.producto.nombre);
      final categoria = sanitizeText(item.categoria);
      final cantidad = item.cantidad;
      final comentario = sanitizeText(item.comentario);

      bytes += generator.text(
        '$cantidad $categoria de $nombre',
        styles: const PosStyles(align: PosAlign.left, height: PosTextSize.size2)
      );

      if (comentario != '' && comentario.isNotEmpty) {
        bytes += generator.text('Adicionales: $comentario', styles: const PosStyles(height: PosTextSize.size2));  // Ancho aumentado));
      }
      bytes += generator.text('--------------------------------');
    }

    // Espacios y corte del ticket
    bytes += generator.feed(4);
    //bytes += generator.cut();

    // Convertir List<int> a Uint8List
    Uint8List byteData = Uint8List.fromList(bytes);

    // Enviar los datos a la impresora
    bluetooth.writeBytes(byteData);
  }

  Future<void> printTicketClient(List items, String uid, double amount) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile, spaceBetweenRows: 1, );

    List<int> bytes = [];

    bytes += generator.text('--------------------------------');
    bytes += generator.text('Timbas y Frappes de la 50', styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('--------------------------------');
    // Obtener fecha y hora actuales
    final now = DateTime.now();
    final formatter = DateFormat('dd-MM-yyyy HH:mm');
    final formattedDate = formatter.format(now);

    // Encabezado del ticket
    bytes += generator.feed(1);

    bytes += generator.text('Horario: Lunes-Domingo 5pm-12am');
    bytes += generator.text('Fecha: $formattedDate');
    bytes += generator.text('Folio: $uid');
    bytes += generator.text('--------------------------------');

    bytes += generator.feed(1);

    bytes += generator.text('Can| Cat |  Producto   | Precio');
    bytes += generator.text('--------------------------------');
    // Detalle de los ítems
    for (var item in items) {
      final nombre = sanitizeText(item.producto.nombre);
      final categoria = sanitizeText(item.categoria);
      final cantidad = item.cantidad;
      final comentario = sanitizeText(item.comentario);
      final precio = item.producto.precio;
      final rowItem = sanitizedCategory('$cantidad $categoria de $nombre $precio',cantidad, categoria, nombre, precio);
      bytes += generator.text(
        rowItem,
        styles: const PosStyles(align: PosAlign.left)
      );
      if (comentario != '' && comentario.isNotEmpty) {
        bytes += generator.text('Adicionales: $comentario');  // Ancho aumentado));
      }
    }

    // Total
    double total = items.fold(
        0, (sum, item) => sum + item.producto.precio * item.cantidad);
    bytes += generator.text('--------------------------------');
    bytes += generator.text(
      'Total: \$${total.toStringAsFixed(2)}',
      styles: const PosStyles(align: PosAlign.right, bold: true),
    );
    bytes += generator.text(
      'Pago: \$${amount.toStringAsFixed(2)}',
      styles: const PosStyles(align: PosAlign.right, bold: true),
    );
    double change = amount - total;
    bytes += generator.text(
      'Cambio: \$${change.toStringAsFixed(2)}',
      styles: const PosStyles(align: PosAlign.right, bold: true),
    );

    bytes += generator.feed(2);
    bytes += generator.text(
      '!Gracias por tu compra!',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    // Espacios y corte del ticket
    bytes += generator.feed(4);
    //bytes += generator.cut();

    // Convertir List<int> a Uint8List
    Uint8List byteData = Uint8List.fromList(bytes);

    // Enviar los datos a la impresora
    bluetooth.writeBytes(byteData);
  }

  //Convertir el string por no aceptar utf-8
  String sanitizeText(String input) {
    final Map<String, String> replacements = {
      'ñ': 'n',
      'Ñ': 'N',
      'á': 'a',
      'Á': 'A',
      'é': 'e',
      'É': 'E',
      'í': 'i',
      'Í': 'I',
      'ó': 'o',
      'Ó': 'O',
      'ú': 'u',
      'Ú': 'U',
    };

    String sanitized = input;
    replacements.forEach((key, value) {
      sanitized = sanitized.replaceAll(key, value);
    });

    return sanitized;
  }

  String sanitizedCategory(String input, cantidad, String categoria, producto, precio){
      // Diccionario de categorías abreviadas
      final Map<String, String> categoriasAbreviadas = {
        "smoothies": "SMTH",
        "machakados": "MCHD",
        "frappes de frutas": "FRF",
        "frappes": "FRP",
        "diablitos": "DBL",
      };
      // Abreviar la categoría si existe en el diccionario
      String catAbrev = categoriasAbreviadas[categoria.toLowerCase()] ?? categoria;
      // Crear la línea formateada asegurando los 32 caracteres
      String formattedLine = "$cantidad x ${catAbrev.padRight(5)} ${producto.padRight(14)} \$${precio.toStringAsFixed(2)}";
      // Recortar si supera los 32 caracteres
      return formattedLine.length > 32 ? formattedLine.substring(0, 32) : formattedLine;
  }
}
