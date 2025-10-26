// ignore_for_file: must_be_immutable, file_names

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hex/hex.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';

extension Uint8ListExtension on Uint8List {
  String toAsciiString() {
    return String.fromCharCodes(this);
  }
}

String hexToAscii(String hexString) {
  List<int> bytes = HEX.decode(hexString);
  String asciiString = String.fromCharCodes(bytes);
  return asciiString;
}

class PreviewImageWidget extends StatelessWidget {
  Uint8List? bytearray;
  PreviewImageWidget(this.bytearray, {super.key}) {
    super.key;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Preview Image')),
      body: Container(
        child: PhotoView(imageProvider: MemoryImage(bytearray!)),
      ),
    );
  }
}
// Assuming you're using this to get the Downloads directory.

class FileUtils {
  static Future<Directory?> getDownloadDirectory() async {
    return await getDownloadsDirectory();
  }

  static Future<String> getFormattedDate() async {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('d-MMM-yyyy');
    return formatter.format(now);
  }

  static Future<Directory> createDirectory(
      String projectName, String date, String? deviceType) async {
    Directory? downloadPath = await getDownloadDirectory();
    String dirPath =
        '${downloadPath?.path}/${projectName.trim()}/$date/$deviceType';
    Directory directory = Directory(dirPath);

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  static Future<void> showAlertDialog(
      BuildContext context, String title, String message) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
