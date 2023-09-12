// ignore_for_file: unused_field, unused_local_variable, deprecated_member_use, prefer_const_constructors, prefer_interpolation_to_compose_strings, avoid_print, avoid_unnecessary_containers, prefer_final_fields, prefer_typing_uninitialized_variables

import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hex/hex.dart';
import 'package:usb_serial/usb_serial.dart';

class UsbConsoleScreen_test extends StatefulWidget {
  const UsbConsoleScreen_test({Key? key}) : super(key: key);

  @override
  State<UsbConsoleScreen_test> createState() => _UsbConsoleScreen_testState();
}

class _UsbConsoleScreen_testState extends State<UsbConsoleScreen_test> {
  UsbPort? _port;
  String _status = "Idle";
  List<UsbDevice> _devices = [];

  List<String> _response = [];

  var hexDecimalValue;

  StreamSubscription<Uint8List>? _dataSubscription;
  List<int> _dataBuffer = [];
  List<int> _data = [];

  TextEditingController _textController = TextEditingController();

  Future<bool> _connectTo(UsbDevice? device) async {
    _response.clear();

    if (_port != null) {
      await _port!.close();
      _port = null;
    }

    if (device == null) {
      setState(() {
        _status = "Disconnected";
      });
      return true;
    }

    _port = await device.create();
    if (!await _port!.open()) {
      setState(() {
        _status = "Failed to open port";
      });
      return false;
    }

    await _port!.setDTR(true);
    await _port!.setRTS(true);
    await _port!.setPortParameters(
        115200, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);

    _dataSubscription = _port!.inputStream!.listen((Uint8List data) {
      onDataReceived(data);
    });

    setState(() {
      _status = "Connected";
    });
    return true;
  }

  @override
  void initState() {
    super.initState();
    UsbSerial.usbEventStream?.listen((UsbEvent event) {
      _getPorts();
    });
    _getPorts();
  }

  @override
  void dispose() {
    super.dispose();
    _dataSubscription?.cancel();
    _connectTo(null);
  }

  void onDataReceived(Uint8List data) {
    _dataBuffer.addAll(data);
    print('Data : ' + _dataBuffer.toString());

    String completeMessage = String.fromCharCodes(_dataBuffer);
    print("Received complete message: $completeMessage");

    // Clear the buffer after processing
    _dataBuffer.clear();

    // Now you can parse and handle the complete message as required
    // For example, add it to _response list for display
    setState(() {
      _response.add(completeMessage);
      _data.addAll(data);
    });
  }

  Future<void> _getPorts() async {
    final devices = await UsbSerial.listDevices();

    setState(() {
      _devices = devices;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget data;
    return Scaffold(
      appBar: AppBar(
        title: const Text('USB Console App'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Text(
              _devices.isNotEmpty
                  ? "Available Serial Ports"
                  : "No serial devices available",
              style: Theme.of(context).textTheme.headline6,
            ),
            for (final device in _devices)
              Card(
                elevation: 2,
                color: Color.fromARGB(255, 180, 234, 243),
                child: ListTile(
                  leading: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Container(
                        decoration: BoxDecoration(
                            color: Colors.lightBlue.shade200,
                            borderRadius: BorderRadius.circular(100)),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Icon(Icons.usb),
                        )),
                  ),
                  title: Text(device.productName ?? 'Unknown Device'),
                  subtitle:
                      Text(device.manufacturerName ?? 'Unknown Manufacturer'),
                  onTap: () => _connectTo(device),
                ),
              ),
            ListTile(
              title: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Text To Send',
                ),
              ),
              trailing: ElevatedButton(
                child: Text("Send"),
                onPressed: _port == null
                    ? null
                    : () async {
                        if (_port == null) {
                          return;
                        }
                        String data =
                            _textController.text.toUpperCase() + "\r\n";
                        _dataBuffer.clear();
                        _response.clear();
                        await _port!.write(Uint8List.fromList(data.codeUnits));
                      },
              ),
            ),
            if (_port != null)
              Expanded(
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Center(
                    child: Column(
                      children: [
                        // for (final data in _response) Text(data),
                        Text(_response.join('')),
                        getData()
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget getData() {
    try {
      if (_response.isEmpty) {
        return Container(
          height: 50,
          width: 50,
          color: Colors.red,
        );
      }

      if (_response.join().contains('INTG')) {
        var len = _response.join().indexOf('le');
        hexDecimalValue = _response.join().substring((len + 9));
        
      } else {
        hexDecimalValue = '';
      }

      return Text(hexDecimalValue);
    } catch (ex) {
      return Container(
        child: Text('Something Went Wrong'),
      );
    }
  }
}

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
