// ignore_for_file: unused_field, unused_local_variable, deprecated_member_use, prefer_const_constructors, prefer_interpolation_to_compose_strings, avoid_print, avoid_unnecessary_containers, prefer_final_fields, prefer_typing_uninitialized_variables

import 'dart:async';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:hex/hex.dart';
import 'package:intl/intl.dart';
import 'package:usb_serial/usb_serial.dart';

class UsbConsoleScreen extends StatefulWidget {
  const UsbConsoleScreen({Key? key}) : super(key: key);

  @override
  State<UsbConsoleScreen> createState() => _UsbConsoleScreenState();
}

class _UsbConsoleScreenState extends State<UsbConsoleScreen> {
  UsbPort? _port;
  String _status = "Idle";
  List<UsbDevice> _devices = [];
  List<String> _response = [];
  List<String> _serialData = [];

  var hexDecimalValue = '';

  StreamSubscription<Uint8List>? _dataSubscription;
  List<int> _dataBuffer = [];
  List<String> _data = [];

  TextEditingController _textController = TextEditingController();

  Future<bool> _connectTo(UsbDevice? device) async {
    _response.clear();
    _serialData.clear();

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

    // Convert the received data to hexadecimal
    String hexData = hex.encode(_dataBuffer);
    print("Received data in hexadecimal: $hexData");

    _dataBuffer.clear();

    setState(() {
      _response.add(hexData);
      _data.add(completeMessage);
    });
    if (_data.join().contains('INTG')) {
      hexDecimalValue =
          reverseString(reverseString(_response.join()).substring(0, 70));
    } else {
      hexDecimalValue = _response.join();
    }
  }

  Future<void> _getPorts() async {
    final devices = await UsbSerial.listDevices();

    setState(() {
      _devices = devices;
    });
  }

  String reverseString(String input) {
    return input.split('').reversed.join('');
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
                        _response.clear();
                        hexDecimalValue = '';
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
                        Text(_response.join()),
                        Divider(),
                        Text(hexDecimalValue),
                        Text(hexToAscii(hexDecimalValue)),
                        Divider(),
                        Text("Date:- " + getDateTime()),
                        Text("Temprature:-  " + getTemprature().toString()),
                        Text("Batter Voltage:-  " +
                            getBatterVoltage().toString()),
                        Text(
                            "Solar Voltage:-  " + getSOLARVoltage().toString()),
                        Text("Inlet_Pressure_1:-  " +
                            get_Inlet_Pressure_1().toString()),
                        Text("Inlet_Pressure_2:-   " +
                            get_Inlet_Pressure_2().toString()),
                        Text("Firmware Version:-  " +
                            Firmware_Version().toString()),
                        // Text("Alarms:-  " + getAlarms().toString()),
                        Column(
                          children: [
                            Text("DI1:-  " + getAlarms(0)),
                            Text("DI2:-  " + getAlarms(1)),
                            Text("ANY PT FAIL:-  " + getAlarms(2)),
                            Text("ANY POS FAIL:-  " + getAlarms(3)),
                            Text(" HIGH TEMP INSIDE BOX:-  " + getAlarms(4)),
                            Text(" FILTER CHOKED:-  " + getAlarms(5)),
                            Text("LOW BATTERY VOLTAGE:-  " + getAlarms(6)),
                            Text("Low inlet Pressure:-  " + getAlarms(7)),
                            Text("High Outlet Pressure:-  " + getAlarms(8)),
                            Text("All Valve Open:-  " + getAlarms(9)),
                            Text("Any valve Closed:-  " + getAlarms(10)),
                          ],
                        ),
                        Column(
                          children: [
                            Text("Packet Indication  ALARM:-  " +
                                Packet_Indication(0)),
                            Text("Packet Indication  INTG:-  " +
                                Packet_Indication(1)),
                            Text("Packet Indication  IRT:-  " +
                                Packet_Indication(2)),
                          ],
                        ),
                        Column(
                          children: [
                            Text("Emergency Stop:-  " + Emergency_Stop(0)),
                            Text("Stop Irrigation:-  " + Emergency_Stop(1)),
                          ],
                        ),
                        Text("OUTPT2 BAR:-   " + OUTPT2_BAR().toString()),
                        Text("POSITION:-  " + POSITION().toString()),
                        Text("FLOW:-  " + FLOW().toString()),
                        Text("DAILY VOL:-  " + DAILY_VOL().toString()),
                        Text("RUN TIME:-   " + RUN_TIME().toString()),
                        // Text("PFCMD1 Mode Data:-  " +
                        //     PFCMD1_Mode_Data().toString()),
                        Column(
                          children: [
                            Text("Position Control:-  " + PFCMD1_Mode_Data(1)),
                            Text("Flow Control:-  " + PFCMD1_Mode_Data(2)),
                            Text("Open/Close:-  " + PFCMD1_Mode_Data(3)),
                            Text("Test:-  " + PFCMD1_Mode_Data(4)),
                            Text("Auto:-  " + PFCMD1_Mode_Data(5)),
                            Text("Manual:-  " + PFCMD1_Mode_Data(6)),
                          ],
                        ),
                        Text(
                            "Flowmeter Flow:-  " + Flowmeter_Flow().toString()),
                        Text("Flowmeter Volume:-   " +
                            Flowmeter_Volume().toString()),
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

  /*Widget getData() {
    try {
      if (_response.isEmpty) {
        return Container(
          height: 50,
          width: 50,
          color: Colors.red,
        );
      }

      if (_response.join().contains('INTG')) {
        var len = _response.join().indexOf('BO');
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
*/
  getDateTime() {
    String subString3 = hexDecimalValue.substring(0, 8);
    int date = int.parse(subString3, radix: 16);
    var dateTime = DateTime.fromMillisecondsSinceEpoch(date * 1000);
    var formatter = DateFormat('yyyy-MMM-dd HH:mm:ss');
    var formattedDate = formatter.format(dateTime);
    return formattedDate;
  }

  getTemprature() {
    var subString2;
    var Temperature;
    try {
      subString2 = hexDecimalValue.substring(8, 12);
      int decimal = int.parse(subString2, radix: 16);
      Temperature = (decimal / 100).toDouble();
    } catch (_, ex) {
      Temperature = 0.0;
    }
    return Temperature;
  }

  getBatterVoltage() {
    var subString2;
    var BatteryVoltage;
    try {
      subString2 = hexDecimalValue.substring(12, 16);
      int decimal = int.parse(subString2, radix: 16);
      BatteryVoltage = (decimal / 100).toDouble();
    } catch (_, ex) {
      BatteryVoltage = 0.0;
    }
    return BatteryVoltage;
  }

  getSOLARVoltage() {
    var subString3;
    var BatteryVoltage;
    try {
      subString3 = hexDecimalValue.substring(16, 20);
      int decimal = int.parse(subString3, radix: 16);
      BatteryVoltage = (decimal / 100).toDouble();
    } catch (_, ex) {
      BatteryVoltage = 0.0;
    }
    return BatteryVoltage;
  }

  get_Inlet_Pressure_1() {
    var subString3;
    var BatteryVoltage;
    try {
      subString3 = hexDecimalValue.substring(20, 24);
      int decimal = int.parse(subString3, radix: 16);
      BatteryVoltage = (decimal / 100).toDouble();
    } catch (_, ex) {
      BatteryVoltage = 0.0;
    }
    return BatteryVoltage;
  }

  get_Inlet_Pressure_2() {
    var subString3;
    var BatteryVoltage;
    try {
      subString3 = hexDecimalValue.substring(24, 28);
      int decimal = int.parse(subString3, radix: 16);
      BatteryVoltage = (decimal / 100).toDouble();
    } catch (_, ex) {
      BatteryVoltage = 0.0;
    }
    return BatteryVoltage;
  }

  Firmware_Version() {
    var subString3;
    var BatteryVoltage;
    try {
      subString3 = hexDecimalValue.substring(28, 30);
      int decimal = int.parse(subString3, radix: 16);
      BatteryVoltage = (decimal / 10).toDouble();
    } catch (_, ex) {
      BatteryVoltage = 0.0;
    }
    return BatteryVoltage;
  }

  String getAlarms(int index) {
    var subString3;
    var BatteryVoltage;
    String binaryNumber;
    List<String> binaryValues = [];

    try {
      subString3 = hexDecimalValue.substring(30, 34);
      int decimalNumber = int.parse(subString3, radix: 16);
      binaryNumber = decimalNumber.toRadixString(2).padLeft(16, '0');
    } catch (_, ex) {
      binaryNumber = '0.0';
    }

    if (binaryNumber.length >= 16) {
      binaryValues.add(binaryNumber[15]);
      binaryValues.add(binaryNumber[14]);
      binaryValues.add(binaryNumber[13]);
      binaryValues.add(binaryNumber[12]);
      binaryValues.add(binaryNumber[11]);
      binaryValues.add(binaryNumber[10]);
      binaryValues.add(binaryNumber[9]);
      binaryValues.add(binaryNumber[8]);
      binaryValues.add(binaryNumber[7]);
      binaryValues.add(binaryNumber[6]);
      binaryValues.add(binaryNumber[5]);
    }
    print(binaryValues);

    if (index >= 0 && index < binaryValues.length) {
      return binaryValues[index];
    } else {
      return '';
    }
  }

  String Packet_Indication(int index) {
    var subString3;
    var BatteryVoltage;
    String binaryNumber;
    List<String> binaryValues = [];

    try {
      subString3 = hexDecimalValue.substring(34, 36);
      int decimalNumber = int.parse(subString3, radix: 16);
      binaryNumber = decimalNumber.toRadixString(2).padLeft(8, '0');
    } catch (_, ex) {
      binaryNumber = '0.0';
    }

    if (binaryNumber.length >= 7) {
      binaryValues.add(binaryNumber[5]);
      binaryValues.add(binaryNumber[6]);
      binaryValues.add(binaryNumber[7]);
    }

    if (index >= 0 && index < binaryValues.length) {
      return binaryValues[index];
    } else {
      return '';
    }
  }

  String Emergency_Stop(int index) {
    var subString3;
    var BatteryVoltage;
    String binaryNumber;
    List<String> binaryValues = [];

    try {
      subString3 = hexDecimalValue.substring(36, 38);
      int decimalNumber = int.parse(subString3, radix: 16);
      binaryNumber = decimalNumber.toRadixString(2).padLeft(8, '0');
    } catch (_, ex) {
      binaryNumber = '0.0';
    }

    if (binaryNumber.length >= 7) {
      binaryValues.add(binaryNumber[6]);
      binaryValues.add(binaryNumber[7]);
    }

    if (index >= 0 && index < binaryValues.length) {
      return binaryValues[index];
    } else {
      return '';
    }
  }

  // Emergency_Stop() {
  //   var subString3;
  //   var BatteryVoltage;
  //   String binaryNumber;
  //   try {
  //     subString3 = hexDecimalValue.substring(36, 38);
  //     int decimalNumber = int.parse(subString3, radix: 16);
  //     binaryNumber = decimalNumber.toRadixString(2).padLeft(8, '0');
  //     // binary = subString3.toRadixString(2);
  //   } catch (_, ex) {
  //     binaryNumber = '0.0';
  //   }
  //   return binaryNumber;
  // }

  OUTPT2_BAR() {
    var subString3;
    var BatteryVoltage;
    try {
      subString3 = hexDecimalValue.substring(38, 42);
      int decimal = int.parse(subString3, radix: 16);
      BatteryVoltage = (decimal / 100).toDouble();
    } catch (_, ex) {
      BatteryVoltage = 0.0;
    }
    return BatteryVoltage;
  }

  POSITION() {
    var subString3;
    var BatteryVoltage;
    try {
      subString3 = hexDecimalValue.substring(42, 46);
      int decimal = int.parse(subString3, radix: 16);
      BatteryVoltage = (decimal / 100).toDouble();
    } catch (_, ex) {
      BatteryVoltage = 0.0;
    }
    return BatteryVoltage;
  }

  FLOW() {
    var subString3;
    var BatteryVoltage;
    try {
      subString3 = hexDecimalValue.substring(46, 50);
      int decimal = int.parse(subString3, radix: 16);
      BatteryVoltage = (decimal / 100).toDouble();
    } catch (_, ex) {
      BatteryVoltage = 0.0;
    }
    return BatteryVoltage;
  }

  DAILY_VOL() {
    var subString3;
    var BatteryVoltage;
    try {
      subString3 = hexDecimalValue.substring(50, 54);
      int decimal = int.parse(subString3, radix: 16);
      BatteryVoltage = (decimal / 100).toDouble();
    } catch (_, ex) {
      BatteryVoltage = 0.0;
    }
    return BatteryVoltage;
  }

  RUN_TIME() {
    var subString3;
    var BatteryVoltage;
    try {
      subString3 = hexDecimalValue.substring(54, 58);
      int decimal = int.parse(subString3, radix: 16);
      BatteryVoltage = (decimal / 100).toDouble();
    } catch (_, ex) {
      BatteryVoltage = 0.0;
    }
    return BatteryVoltage;
  }

  String PFCMD1_Mode_Data(int index) {
    var subString3;
    var BatteryVoltage;
    String binaryNumber;
    List<String> binaryValues = [];

    try {
      subString3 = hexDecimalValue.substring(58, 60);
      int decimalNumber = int.parse(subString3, radix: 16);
      binaryNumber = decimalNumber.toRadixString(2).padLeft(8, '0');
    } catch (_, ex) {
      binaryNumber = '0.0';
    }

    if (binaryNumber.length >= 7) {
      binaryValues.add(binaryNumber[1]);
      binaryValues.add(binaryNumber[2]);
      binaryValues.add(binaryNumber[3]);
      binaryValues.add(binaryNumber[4]);
      binaryValues.add(binaryNumber[5]);
      binaryValues.add(binaryNumber[6]);

      binaryValues.add(binaryNumber[2]);
    }

    if (index >= 0 && index < binaryValues.length) {
      return binaryValues[index];
    } else {
      return '';
    }
  }

  Flowmeter_Flow() {
    var subString3;
    var BatteryVoltage;
    try {
      subString3 = hexDecimalValue.substring(60, 64);
      int decimal = int.parse(subString3, radix: 16);
      BatteryVoltage = (decimal / 100).toDouble();
    } catch (_, ex) {
      BatteryVoltage = 0.0;
    }
    return BatteryVoltage;
  }

  Flowmeter_Volume() {
    var subString3;
    var BatteryVoltage;
    try {
      subString3 = hexDecimalValue.substring(64, 68);
      int decimal = int.parse(subString3, radix: 16);
      BatteryVoltage = (decimal / 100).toDouble();
    } catch (_, ex) {
      BatteryVoltage = 0.0;
    }
    return BatteryVoltage;
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
