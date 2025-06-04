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
    bytes += generator.text('Fecha: $formattedDate',
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('--------------------------------');

    // Detalle de los ítems
    for (var item in items) {
      final nombre = sanitizeText(item.producto.nombre);
      String productoLimpio = nombre
    .replaceAll("BASE", "")
    .replaceAll("PAQUETE", "")
    .replaceAll(RegExp(r"\s+"), " ")
    .trim();

      // Reemplazos específicos por nombre
      if (nombre.toLowerCase().contains("super niño")) {
        productoLimpio = "SN SALCHICHA";
      } else if (nombre.toLowerCase().contains("mini fiesta")) {
        productoLimpio = "MF mixta";
      } else if (nombre.toLowerCase().contains("niño consentido")) {
        productoLimpio = "NC SALCHIPULPO";
      }
      final categoria = sanitizeText(item.categoria);
      final categoriaLimpia = categoria.toLowerCase().contains("banderilla") ? "BAND" : categoria;
      final cantidad = item.cantidad;
      final comentario = sanitizeText(item.comentario);

      bytes += generator.text('$cantidad $categoriaLimpia de $productoLimpio',
          styles:
              const PosStyles(align: PosAlign.left, height: PosTextSize.size2));

      if (item.extras.isNotEmpty) {
        bytes += generator.text('Extras:');
        for (var extra in item.extras) {
          bytes += generator.text(' - ${sanitizeText(extra.nombre)}');
        }
      }

      if (comentario != '' && comentario.isNotEmpty) {
        bytes += generator.text('Comentarios: ${sanitizeText(comentario)}',
            styles: const PosStyles(
                height: PosTextSize.size2)); // Ancho aumentado));
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
    final generator = Generator(
      PaperSize.mm58,
      profile,
      spaceBetweenRows: 1,
    );

    List<int> bytes = [];

    bytes += generator.text('--------------------------------');
    bytes += generator.text('Timbas y Frappes de la 50',
        styles: const PosStyles(align: PosAlign.center));
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
      final rowItem = sanitizedCategory(cantidad, categoria, nombre, precio);
      bytes += generator.text(rowItem,
          styles: const PosStyles(align: PosAlign.left));
      if (item.extras.isNotEmpty) {
        bytes += generator.text('Extras:');
        for (var extra in item.extras) {
          String nombreLimpio = sanitizeText(extra.nombre);
          int longitud = nombreLimpio.length;
          String linea = "- $nombreLimpio";

          switch (longitud) {
            case >= 13: // Si es demasiado largo, lo cortamos
              linea =
                  "- $nombreLimpio          \$${extra.precio.toStringAsFixed(2)}";
              break;
            case >= 12: // Se ajusta con un punto si es necesario
              linea =
                  "- $nombreLimpio           \$${extra.precio.toStringAsFixed(2)}";
              break;
            case >= 10: // Mantiene la palabra lo más intacta posible
              linea =
                  "- $nombreLimpio             \$${extra.precio.toStringAsFixed(2)}";
              break;
            case >= 9: // Mantiene la palabra lo más intacta posible
              linea =
                  "- $nombreLimpio              \$${extra.precio.toStringAsFixed(2)}";
              break;
            case >= 8: // Mantiene la palabra lo más intacta posible
              linea =
                  "- $nombreLimpio               \$${extra.precio.toStringAsFixed(2)}";
              break;
            case >= 7: // Mantiene la palabra lo más intacta posible
              linea =
                  "- $nombreLimpio                \$${extra.precio.toStringAsFixed(2)}";
              break;
            case >= 6: // Mantiene la palabra lo más intacta posible
              linea =
                  "- $nombreLimpio                 \$${extra.precio.toStringAsFixed(2)}";
              break;
            case >= 5: // Mantiene la palabra lo más intacta posible
              linea =
                  "- $nombreLimpio................. \$${extra.precio.toStringAsFixed(2)}";
              break;
            case >= 4: // Mantiene la palabra lo más intacta posible
              linea =
                  "- $nombreLimpio.................. \$${extra.precio.toStringAsFixed(2)}";
              break;
            case >= 3: // Mantiene la palabra lo más intacta posible
              linea =
                  "- $nombreLimpio................... \$${extra.precio.toStringAsFixed(2)}";
              break;
            default: // Si cabe bien, lo deja sin modificar
              linea = "- $nombreLimpio";
          }
          bytes += generator.text(linea);
        }
      }
      if (comentario != '' && comentario.isNotEmpty) {
        bytes += generator.text(
            'Comentarios: ${sanitizeText(comentario)}'); // Ancho aumentado));
      }
    }

    // Total
    double total = items.fold(0.0, (sum, item) {
      // Sumar el precio del producto por la cantidad
      double itemTotal = item.producto.precio * item.cantidad;

      // Sumar los extras para este item
      double extrasTotal =
          item.extras.fold(0.0, (extrasSum, extra) => extrasSum + extra.precio);

      // Añadir el precio de los extras al total del item
      return sum + itemTotal + extrasTotal;
    });
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

  String sanitizedCategory(cantidad, String categoria, producto, precio) {
    // Diccionario de categorías abreviadas
    final Map<String, String> categoriasAbreviadas = {
      "smoothies": "SMTH",
      "machakados": "MCHD",
      "frappes de frutas": "FRF",
      "frappes": "FRP",
      "diablitos": "DBL",
      "banderillas": "BAN",
    };
    // Abreviar la categoría si existe en el diccionario
    String catAbrev =
        categoriasAbreviadas[categoria.toLowerCase()] ?? categoria;
    String productoLimpio = producto
        .replaceAll("BASE", "")
        .replaceAll("PAQUETE", "")
        .replaceAll(RegExp(r"\s+"), " ")
        .trim();

    // Reemplazos específicos por nombre
    if (producto.toLowerCase().contains("super niño")) {
      productoLimpio = "SN SALCHICHA";
    } else if (producto.toLowerCase().contains("mini fiesta")) {
      productoLimpio = "MF mixta";
    } else if (producto.toLowerCase().contains("niño consentido")) {
      productoLimpio = "NC SALCHIPULPO";
    }
    if (producto.toString().toLowerCase().contains("salchipulpo") ||
        producto.toString().toLowerCase() == "papas fritas") {
      catAbrev = "";
    }
    // Crear la línea formateada asegurando los 32 caracteres
    String formattedLine =
        "$cantidad x ${catAbrev.padRight(5)} ${productoLimpio.padRight(14)} \$${precio.toStringAsFixed(2)}";
    // Recortar si supera los 32 caracteres
    return formattedLine.length > 32
        ? formattedLine.substring(0, 32)
        : formattedLine;
  }
}
