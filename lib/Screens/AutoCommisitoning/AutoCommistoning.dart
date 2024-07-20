// ignore_for_file: prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, prefer_const_constructors, unused_field, non_constant_identifier_names, unused_local_variable, unused_catch_stack, file_names, prefer_final_fields, use_build_context_synchronously, prefer_typing_uninitialized_variables, avoid_print, sort_child_properties_last, depend_on_referenced_packages, unused_import, import_of_legacy_library_into_null_safe, void_checks, unnecessary_new, library_prefixes, unnecessary_string_interpolations, await_only_futures

import 'dart:async';
import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_usb2/Provider/data_provider.dart';
import 'package:flutter_application_usb2/core/app_export.dart';
import 'package:flutter_application_usb2/models/loginmodel.dart';

import 'package:get/get.dart';
import 'package:hex/hex.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usb_serial/transaction.dart';
import 'package:usb_serial/usb_serial.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pdfWidgets;
import 'package:pdf/widgets.dart' as pdf;

class AutoCommistioningScreen extends StatefulWidget {
  const AutoCommistioningScreen({super.key});

  @override
  State<AutoCommistioningScreen> createState() =>
      _AutoCommistioningScreenState();
}

class _AutoCommistioningScreenState extends State<AutoCommistioningScreen>
    with SingleTickerProviderStateMixin {
  UsbPort? _port;
  String _status = "Idle";
  String lora_comm = "";
  String dtbefore = '';
  String dtafter = '';
  List<UsbDevice> _devices = [];
  List<String> _response = [];
  String btntxt = 'Connect';
  String hexDecimalValue = '';
  String? hexIntgValue = '';
  String macId = '';
  bool? isloracheck = false;
  bool? isSaved = false;
  String? filePath = '';

  String InletButton = '';
  String OutletButton = '';

  String PFCMD1 = '';
  String PFCMD2 = '';
  String PFCMD3 = '';
  String PFCMD4 = '';
  String PFCMD5 = '';
  String PFCMD6 = '';

  String? sov1;
  String? sov2;
  String? sov3;
  String? sov4;
  String? sov5;
  String? sov6;

  String? pos1;
  String? pos2;
  String? pos3;
  String? pos4;
  String? pos5;
  String? pos6;

  double? posval1;
  double? posval2;
  double? posval3;
  double? posval4;
  double? posval5;
  double? posval6;

  int? index;
  String? controllerType;
  int? pfcmcdType = 1;
  List<String> _serialData = [];
  double? ptSetpoint = 2.5;
  double lowerLimit = 2.5 * 0.9;
  double upperLimit = 2.5 * 1.1;

  String? deviceType;
  final _formKey = GlobalKey<FormState>();
  List<int> _dataBuffer = [];
  StreamSubscription<Uint8List>? _dataSubscription;

  String? Door1;
  String? Door2;
  double? batteryVoltage;
  double? firmwareversion;
  double? solarVoltage;

  var postionvalue;

  var openvalpos1;
  var closevalpos1;
  var openvalpos2;
  var closevalpos2;
  var openvalpos3;
  var closevalpos3;
  var openvalpos4;
  var closevalpos4;
  var openvalpos5;
  var closevalpos5;
  var openvalpos6;
  var closevalpos6;

  double? filterInlet;
  double? filterOutlet;
  AnimationController? _animationController;

  bool PFCMD1_blink = false;
  bool PFCMD2_blink = false;
  bool PFCMD3_blink = false;
  bool PFCMD4_blink = false;
  bool PFCMD5_blink = false;
  bool PFCMD6_blink = false;

  String btnstate = '';
  String siteName = '';
  String nodeNo = '';

  // outlet pt
  double? outlet_1_actual_count_controller;

// outlet pt 2
  double? outlet_2_actual_count_after_controller;

  // outlet pt 3
  double? outlet_3_actual_count_controller;

  // outlet pt 4
  double? outlet_4_actual_count_controller;

  // outlet pt 6
  double? outlet_6_actual_count_controller;

  // outlet pt 5
  double? outlet_5_actual_count_controller;

  Future<bool> _connectTo(UsbDevice? device) async {
    _response.clear();
    if (_port != null) {
      await _port!.close();
      _port = null;
    }
    if (device == null) {
      setState(() {
        _status = "Disconnected";
        btntxt = 'Disconnected';
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
      btntxt = 'Connected';
    });
    return true;
  }

  void onDataReceived(Uint8List data) {
    _dataBuffer.addAll(data);
    String completeMessage = String.fromCharCodes(_dataBuffer);
    String hexData = hex.encode(_dataBuffer);
    _dataBuffer.clear();
    setState(() {
      _response.add(hexData);
      _serialData.add(completeMessage);
    });

    if (_serialData.join().contains('INTG')) {
      if (_serialData.join().contains('BOCOM1')) {
        hexDecimalValue =
            reverseString(reverseString(_response.join()).substring(0, 70));
      } else if (_serialData.join().contains('BOCOM6')) {
        hexIntgValue =
            reverseString(reverseString(_response.join()).substring(0, 172));
      }
    } else {
      hexDecimalValue = _response.join();
    }
  }

  @override
  void initState() {
    super.initState();
    UsbSerial.usbEventStream?.listen((UsbEvent event) {
      _getPorts();
    });
    _getPorts();
    _animationController =
        new AnimationController(vsync: this, duration: Duration(seconds: 1));
    _animationController!.repeat(reverse: true);
  }

  @override
  void dispose() {
    super.dispose();
    _connectTo(null);
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
    return Scaffold(
      appBar: AppBar(
        title: Text('OMS Auto Commission'),
      ),
      body: getBodyWidget(),
    );
  }

  Widget getBodyWidget() {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        tooltip: 'Clear Console',
        child: Icon(Icons.clear_all_rounded),
        onPressed: () {
          clearSerialData();
        },
      ),
      body: Container(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final device in _devices)
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.blueAccent.shade100),
                child: ListTile(
                  leading: Container(
                      decoration: BoxDecoration(
                          color: Colors.lightBlue.shade200,
                          borderRadius: BorderRadius.circular(100)),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Icon(Icons.usb),
                      )),
                  title: Text(device.productName ?? 'Unknown Device'),
                  trailing: ElevatedButton(
                    child: Text(btntxt),
                    onPressed: () {
                      if (_status == 'Disconnected') {
                        _connectTo(device);
                      } else if (_status == 'Connected') {
                        _connectTo(null);
                      } else {
                        _connectTo(device);
                      }
                    },
                  ),
                ),
              ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      child: Text("Get SINM"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      onPressed: _port == null
                          ? null
                          : () async {
                              if (_port == null) {
                                return;
                              }
                              String data = "${'SINM'.toUpperCase()}\r\n";
                              _response.clear();
                              _serialData.clear();
                              hexDecimalValue = '';
                              await _port!
                                  .write(Uint8List.fromList(data.codeUnits));
                              await getSiteName();
                            },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "${controllerType ?? 'Site-Name'}",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
                if (controllerType != null &&
                    controllerType!.contains('BOCOM6'))
                  Row(
                    children: [
                      Text("Controller Type:"),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Radio<int>(
                            value: 1,
                            groupValue: pfcmcdType,
                            onChanged: (value) {
                              setState(() {
                                pfcmcdType = value;
                              });
                            },
                          ),
                          Text('BOC Controller With 6 PT'),
                          Radio<int>(
                            value: 2,
                            groupValue: pfcmcdType,
                            onChanged: (value) {
                              setState(() {
                                pfcmcdType = value;
                              });
                            },
                          ),
                          Text('BOC Controller With 2 PT'),
                        ],
                      )
                    ],
                  )
              ],
            ),
            // if (hexDecimalValue.isNotEmpty)
            infoCardWidget(),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 200,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF232323),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: _serialData
                            .map(
                              (message) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5.0),
                                child: Text(
                                  message,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors
                                        .green, // Set the desired text color here
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            )

            /*Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 200,
                    child: SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: _serialData
                            .map(
                              (widget) => Center(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5.0),
                                  child: DefaultTextStyle.merge(
                                    style: TextStyle(
                                      color: Colors
                                          .green, // Set the desired text color here
                                    ),
                                    textAlign: TextAlign.center,
                                    child: Text(widget),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF232323),
                      borderRadius: BorderRadius.circular(8),

                      // padding : NEVER FOLD
                    ),
                  ),
                ],
              ),
            ),*/
          ],
        ),
      ),
    );
  }

  clearSerialData() {
    setState(() {
      _serialData.clear();
      _response.clear();
    });
  }

  Widget infoCardWidget() {
    try {
      if (controllerType!.contains('BOCOM6')) {
        return Expanded(
          child: SingleChildScrollView(
            child: Center(
              child: Container(
                child: Column(
                  children: [
                    //Lora Communication Check
                    Container(
                      margin: EdgeInsets.all(5.5),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 1.5,
                            spreadRadius: 2.2,
                            offset: Offset(1.5, 2),
                          )
                        ],
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.white,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  child: Text(
                                    'Lora Communication Check',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  child: Text("Check"),
                                  onPressed: _port == null
                                      ? null
                                      : () async {
                                          if (_port == null) {
                                            return;
                                          }
                                          await setDatetime();
                                        },
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Divider(),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  child: Text(
                                    'Lora Communication :',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.3,
                                  child: isloracheck!
                                      ? SizedBox(
                                          child: Center(
                                            child: SpinKitFadingCircle(
                                              size: 30,
                                              color: Colors.blue,
                                            ),
                                          ),
                                          height: 30,
                                          width: 20,
                                        )
                                      : Text(
                                          lora_comm,
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: lora_comm == 'Ok'
                                                  ? Colors.green
                                                  : Colors.red),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    //General Checks
                    Container(
                      margin: EdgeInsets.all(5.5),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 1.5,
                            spreadRadius: 2.2,
                            offset: Offset(1.5, 2),
                          )
                        ],
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.white,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  child: Text(
                                    'General Checks',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  child: Text("Check"),
                                  onPressed: (_port == null)
                                      ? null
                                      : () async {
                                          if (_port == null) {
                                            return;
                                          }
                                          String data =
                                              "${'INTG'.toUpperCase()}\r\n";
                                          _response.clear();
                                          _serialData.clear();
                                          hexIntgValue = '';
                                          await _port!.write(Uint8List.fromList(
                                              data.codeUnits));
                                          Future.delayed(Duration(seconds: 6))
                                              .whenComplete(() async {
                                            await getAllINTGPacket();
                                            await getAllPTValues();
                                            // await getAllPositionSensorValue();
                                          });
                                        },
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Divider(),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  child: Text(
                                    'Firmware Version :',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.3,
                                  child: /* getFirmwareVersion() == 0.0
                                      ? SizedBox(
                                          child: Center(
                                            child: SpinKitFadingCircle(
                                              size: 30,
                                              color: Colors.blue,
                                            ),
                                          ),
                                          height: 30,
                                          width: 20,
                                        )
                                      :*/
                                      Text(
                                    "${firmwareversion ?? '-'}",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  child: Text(
                                    'MAC ID :',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.3,
                                  child: macId == ''
                                      ? SizedBox(
                                          child: Center(
                                            child: SpinKitFadingCircle(
                                              size: 30,
                                              color: Colors.blue,
                                            ),
                                          ),
                                          height: 30,
                                          width: 20,
                                        )
                                      : Text(
                                          macId,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  child: Text(
                                    'Battery Voltage :',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.3,
                                  child: /*getBatterVoltage() == 0.0
                                      ? SizedBox(
                                          child: Center(
                                            child: SpinKitFadingCircle(
                                              size: 30,
                                              color: Colors.blue,
                                            ),
                                          ),
                                          height: 30,
                                          width: 20,
                                        )
                                      :*/
                                      Text(
                                    ("${batteryVoltage ?? '-'}").toString(),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  child: Text(
                                    'Solar Voltage :',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.3,
                                  child: /*getBatterVoltage() == 0.0
                                      ? SizedBox(
                                          child: Center(
                                            child: SpinKitFadingCircle(
                                              size: 30,
                                              color: Colors.blue,
                                            ),
                                          ),
                                          height: 30,
                                          width: 20,
                                        )
                                      :*/
                                      Text(
                                    "${solarVoltage ?? '-'}".toString(),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  // color: Colors.blue,
                                  child: Text(
                                    'Door 1 :',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.3,
                                  child: /*getBatterVoltage() == 0.0
                                      ? SizedBox(
                                          child: Center(
                                            child: SpinKitFadingCircle(
                                              size: 30,
                                              color: Colors.blue,
                                            ),
                                          ),
                                          height: 30,
                                          width: 20,
                                        )
                                      : */
                                      Text(
                                    Door1 ?? '-',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Door1 == 'CLOSE'
                                            ? Colors.green
                                            : Colors.red),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  // color: Colors.blue,
                                  child: Text(
                                    'Door 2 :',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.3,
                                  child: /* getBatterVoltage() == 0.0
                                      ? SizedBox(
                                          child: Center(
                                            child: SpinKitFadingCircle(
                                              size: 30,
                                              color: Colors.blue,
                                            ),
                                          ),
                                          height: 30,
                                          width: 20,
                                        )
                                      :*/
                                      Text(
                                    Door2 ?? '-',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Door2 == 'CLOSE'
                                            ? Colors.green
                                            : Colors.red),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    //PT Valve Check
                    Container(
                      margin: EdgeInsets.all(5.5),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 1.5,
                            spreadRadius: 2.2,
                            offset: Offset(1.5, 2),
                          )
                        ],
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.white,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'PT Valve Check',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 2.5),
                                      child: Text(
                                        'Pressure Set Point : ',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                        width: 50,
                                        child: TextFormField(
                                          // enabled: isEdit(),
                                          initialValue: ptSetpoint.toString(),
                                          decoration: InputDecoration(
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  width: 1, color: Colors.blue),
                                            ),
                                            suffixText: 'bar',
                                          ),
                                          onChanged: (value) {
                                            setState(() {
                                              ptSetpoint =
                                                  double.tryParse(value);
                                              lowerLimit =
                                                  (ptSetpoint ?? 0.0) * 0.9;
                                              upperLimit =
                                                  (ptSetpoint ?? 0.0) * 1.1;
                                            });
                                          },
                                        )),
                                  ],
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                                "Connect external pressure kit, Set pressure set point and When pressure generated in pipe line press Check PT values" /*"Connect external pressure kit with pressure 2.5 bar and When pressure generated in pipe line press Check PT values"*/),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: ElevatedButton(
                              child: Text("Check PT Value"),
                              onPressed: _port == null
                                  ? null
                                  : () async {
                                      if (_port == null) {
                                        return;
                                      }
                                      String data =
                                          "${'INTG'.toUpperCase()}\r\n";
                                      _response.clear();
                                      _serialData.clear();
                                      hexIntgValue = '';
                                      await _port!.write(
                                          Uint8List.fromList(data.codeUnits));
                                      Future.delayed(Duration(seconds: 5))
                                          .whenComplete(() async {
                                        getAllPTValues();
                                      });
                                    },
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Divider(),
                          ),
                          //Inlet valve Check
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Container(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Center(
                                            child: Text(
                                                '${pfcmcdType == 1 ? "Filter Inlet PT" : "Inlet PT"}',
                                                style:
                                                    TextStyle(fontSize: 10))),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.3,
                                          child: Center(
                                            child: Text(
                                              '${filterInlet ?? ''} Bar',
                                            ),
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Radio<String>(
                                            value: 'OK',
                                            groupValue: InletButton,
                                            onChanged: (value) {},
                                          ),
                                          Text('OK'),
                                          Radio<String>(
                                            value: 'Faulty',
                                            groupValue: InletButton,
                                            onChanged: (value) {},
                                          ),
                                          Text('Faulty'),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: SizedBox(
                                            height: 50,
                                            child: Center(
                                                child: Text(
                                                    '${pfcmcdType == 1 ? "Filter Outlet PT" : "Outlet PT"}',
                                                    style: TextStyle(
                                                        fontSize: 10)))),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.3,
                                          child: Center(
                                            child: Text(
                                              '${filterOutlet ?? ''} Bar',
                                            ),
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Radio<String>(
                                            value: 'OK',
                                            groupValue: OutletButton,
                                            onChanged: (value) {},
                                          ),
                                          Text('OK'),
                                          Radio<String>(
                                            value: 'Faulty',
                                            groupValue: OutletButton,
                                            onChanged: (value) {},
                                          ),
                                          Text('Faulty'),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (pfcmcdType == 1)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Divider(),
                            ),
                          //Outlet valve Check
                          if (pfcmcdType == 1)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: SizedBox(
                                              height: 50,
                                              child: Center(
                                                  child: Text('Outlet PT 1',
                                                      style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight: FontWeight
                                                              .bold)))),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.3,
                                            child: PFCMD1_blink
                                                ? SizedBox(
                                                    child: Center(
                                                      child:
                                                          SpinKitFadingCircle(
                                                        size: 30,
                                                        color: Colors.blue,
                                                      ),
                                                    ),
                                                    height: 30,
                                                    width: 20,
                                                  )
                                                : Center(
                                                    child: Text(
                                                      '${outlet_1_actual_count_controller ?? ''} bar',
                                                    ),
                                                  ),
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Radio<String>(
                                              value: 'OK',
                                              groupValue: PFCMD1,
                                              onChanged: (value) {},
                                            ),
                                            Text('OK'),
                                            Radio<String>(
                                              value: 'Faulty',
                                              groupValue: PFCMD1,
                                              onChanged: (value) {},
                                            ),
                                            Text('Faulty'),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: SizedBox(
                                              height: 50,
                                              child: Center(
                                                  child: Text('Outlet PT 2',
                                                      style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight: FontWeight
                                                              .bold)))),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.3,
                                            child: PFCMD2_blink
                                                ? SizedBox(
                                                    child: Center(
                                                      child:
                                                          SpinKitFadingCircle(
                                                        size: 30,
                                                        color: Colors.blue,
                                                      ),
                                                    ),
                                                    height: 30,
                                                    width: 20,
                                                  )
                                                : Center(
                                                    child: Text(
                                                      '${outlet_2_actual_count_after_controller ?? ''} Bar',
                                                    ),
                                                  ),
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Radio<String>(
                                              value: 'OK',
                                              groupValue: PFCMD2,
                                              onChanged: (value) {},
                                            ),
                                            Text('OK'),
                                            Radio<String>(
                                              value: 'Faulty',
                                              groupValue: PFCMD2,
                                              onChanged: (value) {},
                                            ),
                                            Text('Faulty'),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: SizedBox(
                                              height: 50,
                                              child: Center(
                                                  child: Text('Outlet PT 3',
                                                      style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight: FontWeight
                                                              .bold)))),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.3,
                                            child: PFCMD3_blink
                                                ? SizedBox(
                                                    child: Center(
                                                      child:
                                                          SpinKitFadingCircle(
                                                        size: 30,
                                                        color: Colors.blue,
                                                      ),
                                                    ),
                                                    height: 30,
                                                    width: 20,
                                                  )
                                                : Center(
                                                    child: Text(
                                                      '${outlet_3_actual_count_controller ?? ''} Bar',
                                                    ),
                                                  ),
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Radio<String>(
                                              value: 'OK',
                                              groupValue: PFCMD3,
                                              onChanged: (value) {},
                                            ),
                                            Text('OK'),
                                            Radio<String>(
                                              value: 'Faulty',
                                              groupValue: PFCMD3,
                                              onChanged: (value) {},
                                            ),
                                            Text('Faulty'),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: SizedBox(
                                              height: 50,
                                              child: Center(
                                                  child: Text('Outlet PT 4',
                                                      style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight: FontWeight
                                                              .bold)))),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.3,
                                            child: PFCMD4_blink
                                                ? SizedBox(
                                                    child: Center(
                                                      child:
                                                          SpinKitFadingCircle(
                                                        size: 30,
                                                        color: Colors.blue,
                                                      ),
                                                    ),
                                                    height: 30,
                                                    width: 20,
                                                  )
                                                : Center(
                                                    child: Text(
                                                      '${outlet_4_actual_count_controller ?? ''} Bar',
                                                    ),
                                                  ),
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Radio<String>(
                                              value: 'OK',
                                              groupValue: PFCMD4,
                                              onChanged: (value) {},
                                            ),
                                            Text('OK'),
                                            Radio<String>(
                                              value: 'Faulty',
                                              groupValue: PFCMD4,
                                              onChanged: (value) {},
                                            ),
                                            Text('Faulty'),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: SizedBox(
                                              height: 50,
                                              child: Center(
                                                  child: Text('Outlet PT 5',
                                                      style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight: FontWeight
                                                              .bold)))),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.3,
                                            child: PFCMD5_blink
                                                ? SizedBox(
                                                    child: Center(
                                                      child:
                                                          SpinKitFadingCircle(
                                                        size: 30,
                                                        color: Colors.blue,
                                                      ),
                                                    ),
                                                    height: 30,
                                                    width: 20,
                                                  )
                                                : Center(
                                                    child: Text(
                                                      '${outlet_5_actual_count_controller ?? ''} Bar',
                                                    ),
                                                  ),
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Radio<String>(
                                              value: 'OK',
                                              groupValue: PFCMD5,
                                              onChanged: (value) {},
                                            ),
                                            Text('OK'),
                                            Radio<String>(
                                              value: 'Faulty',
                                              groupValue: PFCMD5,
                                              onChanged: (value) {},
                                            ),
                                            Text('Faulty'),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: SizedBox(
                                              height: 50,
                                              child: Center(
                                                  child: Text('Outlet PT 6',
                                                      style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight: FontWeight
                                                              .bold)))),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.3,
                                            child: PFCMD6_blink
                                                ? SizedBox(
                                                    child: Center(
                                                      child:
                                                          SpinKitFadingCircle(
                                                        size: 30,
                                                        color: Colors.blue,
                                                      ),
                                                    ),
                                                    height: 30,
                                                    width: 20,
                                                  )
                                                : Center(
                                                    child: Text(
                                                      '${outlet_6_actual_count_controller ?? ''} Bar',
                                                    ),
                                                  ),
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Radio<String>(
                                              value: 'OK',
                                              groupValue: PFCMD6,
                                              onChanged: (value) {},
                                            ),
                                            Text('OK'),
                                            Radio<String>(
                                              value: 'Faulty',
                                              groupValue: PFCMD6,
                                              onChanged: (value) {},
                                            ),
                                            Text('Faulty'),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    //Position Sensor
                    Container(
                      margin: EdgeInsets.all(5.5),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 1.5,
                            spreadRadius: 2.2,
                            offset: Offset(1.5, 2),
                          )
                        ],
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.white,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Position Sensor Check',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                                "Click on Check Position Valve to get position sensor values (if you didn't get any response please click on the Position titel to get the value for the perticular position valve ) " /*"Connect external pressure kit with pressure 2.5 bar and When pressure generated in pipe line press Check PT values"*/),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: ElevatedButton(
                              child: Text("Check Position Valve"),
                              onPressed: _port == null
                                  ? null
                                  : () async {
                                      if (_port == null) {
                                        return;
                                      }

                                      getAllPositionSensorValue();
                                      // String data =
                                      //     "${'INTG'.toUpperCase()}\r\n";
                                      // _response.clear();
                                      // _serialData.clear();
                                      // hexIntgValue = '';
                                      // await _port!.write(
                                      //     Uint8List.fromList(data.codeUnits));
                                      // Future.delayed(Duration(seconds: 5))
                                      //     .whenComplete(() async {
                                      //   getAllPositionSensorValue();
                                      // });
                                    },
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Divider(),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                //pos 1
                                Container(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      InkWell(
                                        onTap: () => getPostion1Value(),
                                        child: SizedBox(
                                            height: 50,
                                            child: Center(
                                                child: Text(
                                                    'Position Sensor 1 :',
                                                    style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.bold)))),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.3,
                                          child: Center(
                                            child: Text(
                                              '${posval1 ?? ''} mA',
                                            ),
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Radio<String>(
                                            value: 'OK',
                                            groupValue: pos1,
                                            onChanged: (value) {},
                                          ),
                                          Text('OK'),
                                          Radio<String>(
                                            value: 'Faulty',
                                            groupValue: pos1,
                                            onChanged: (value) {},
                                          ),
                                          Text('Faulty'),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                //pos 2
                                Container(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      InkWell(
                                        onTap: () => getPostion2Value(),
                                        child: SizedBox(
                                            height: 50,
                                            child: Center(
                                                child: Text(
                                                    'Position Sensor 2 :',
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold)))),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.3,
                                          child: Center(
                                            child: Text(
                                              '${posval2 ?? ''} mA',
                                            ),
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Radio<String>(
                                            value: 'OK',
                                            groupValue: pos2,
                                            onChanged: (value) {},
                                          ),
                                          Text('OK'),
                                          Radio<String>(
                                            value: 'Faulty',
                                            groupValue: pos2,
                                            onChanged: (value) {},
                                          ),
                                          Text('Faulty'),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                //pos 3
                                Container(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      InkWell(
                                        onTap: () => getPostion3Value(),
                                        child: SizedBox(
                                            height: 50,
                                            child: Center(
                                                child: Text(
                                                    'Position Sensor 3 :',
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold)))),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.3,
                                          child: Center(
                                            child: Text(
                                              '${posval3 ?? ''} mA',
                                            ),
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Radio<String>(
                                            value: 'OK',
                                            groupValue: pos3,
                                            onChanged: (value) {},
                                          ),
                                          Text('OK'),
                                          Radio<String>(
                                            value: 'Faulty',
                                            groupValue: pos3,
                                            onChanged: (value) {},
                                          ),
                                          Text('Faulty'),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                //pos 4
                                Container(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      InkWell(
                                        onTap: () => getPostion4Value(),
                                        child: SizedBox(
                                            height: 50,
                                            child: Center(
                                                child: Text(
                                                    'Position Sensor 4 :',
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold)))),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.3,
                                          child: Center(
                                            child: Text(
                                              '${posval4 ?? ''} mA',
                                            ),
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Radio<String>(
                                            value: 'OK',
                                            groupValue: pos4,
                                            onChanged: (value) {},
                                          ),
                                          Text('OK'),
                                          Radio<String>(
                                            value: 'Faulty',
                                            groupValue: pos4,
                                            onChanged: (value) {},
                                          ),
                                          Text('Faulty'),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                //pos 5
                                Container(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      InkWell(
                                        onTap: () => getPostion5Value(),
                                        child: SizedBox(
                                            height: 50,
                                            child: Center(
                                                child: Text(
                                                    'Position Sensor 5 :',
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold)))),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.3,
                                          child: Center(
                                            child: Text(
                                              '${posval5 ?? ''} mA',
                                            ),
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Radio<String>(
                                            value: 'OK',
                                            groupValue: pos5,
                                            onChanged: (value) {},
                                          ),
                                          Text('OK'),
                                          Radio<String>(
                                            value: 'Faulty',
                                            groupValue: pos5,
                                            onChanged: (value) {},
                                          ),
                                          Text('Faulty'),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                //pos 6
                                Container(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      InkWell(
                                        onTap: () => getPostion6Value(),
                                        child: SizedBox(
                                            height: 50,
                                            child: Center(
                                                child: Text(
                                                    'Position Sensor 6 :',
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold)))),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.3,
                                          child: Center(
                                            child: Text(
                                              '${posval6 ?? ''} mA',
                                            ),
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Radio<String>(
                                            value: 'OK',
                                            groupValue: pos6,
                                            onChanged: (value) {},
                                          ),
                                          Text('OK'),
                                          Radio<String>(
                                            value: 'Faulty',
                                            groupValue: pos6,
                                            onChanged: (value) {},
                                          ),
                                          Text('Faulty'),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    //Solonoid
                    Container(
                      margin: EdgeInsets.all(5.5),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 1.5,
                            spreadRadius: 2.2,
                            offset: Offset(1.5, 2),
                          )
                        ],
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.white,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Solenoid Check',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                                "Observe opening & closing of solenoid valve and click on Ok / Faluty"),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Divider(),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                //SOV 1
                                Container(
                                  padding: EdgeInsets.all(10),
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      double buttonHeight =
                                          constraints.maxWidth *
                                              0.08; // Adjust as needed
                                      double buttonWidth =
                                          constraints.maxWidth *
                                              0.15; // Adjust as needed
                                      double fontSize = constraints.maxWidth *
                                          0.03; // Adjust as needed
                                      double smallFontSize =
                                          constraints.maxWidth *
                                              0.02; // Adjust as needed

                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            height: 50,
                                            child: Center(
                                              child: Text(
                                                'SOV 1',
                                                style: TextStyle(
                                                  fontSize: fontSize,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Column(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.blueAccent,
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black26,
                                                      spreadRadius: 1,
                                                      blurRadius: 1.5,
                                                      offset: Offset(1, 1.5),
                                                    ),
                                                  ],
                                                ),
                                                height: buttonHeight,
                                                width: buttonWidth,
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor: Colors
                                                        .blueAccent.shade200,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                    ),
                                                  ),
                                                  onPressed: () async {
                                                    await setSov1Opneclose();
                                                  },
                                                  child: Text(
                                                    'Mode',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: smallFontSize,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.blueAccent,
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black26,
                                                      spreadRadius: 1,
                                                      blurRadius: 1.5,
                                                      offset: Offset(1, 1.5),
                                                    ),
                                                  ],
                                                ),
                                                height: buttonHeight,
                                                width: buttonWidth,
                                                child: TextButton(
                                                  onPressed: () async {
                                                    await setSov1SMode();
                                                  },
                                                  child: Text(
                                                    'S-Mode',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: smallFontSize,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              SizedBox(
                                                height: buttonHeight,
                                                width: buttonWidth,
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor: Colors
                                                        .blueAccent.shade200,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                    ),
                                                  ),
                                                  onPressed: () async {
                                                    await setValveOpenPFCMD6(1);
                                                  },
                                                  child: FittedBox(
                                                    child: Text(
                                                      'Open',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: smallFontSize,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              SizedBox(
                                                height: buttonHeight,
                                                width: buttonWidth,
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor: Colors
                                                        .blueAccent.shade200,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                    ),
                                                  ),
                                                  onPressed: () async {
                                                    await setValveClosePFCMD6(
                                                        1);
                                                  },
                                                  child: FittedBox(
                                                    child: Text(
                                                      'Close',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: smallFontSize,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Radio<String>(
                                                    value: 'OK',
                                                    groupValue: sov1,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        sov1 = value ?? "";
                                                      });
                                                    },
                                                  ),
                                                  Text(
                                                    'OK',
                                                    style: TextStyle(
                                                        fontSize:
                                                            smallFontSize),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio<String>(
                                                    value: 'Faulty',
                                                    groupValue: sov1,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        sov1 = value ?? "";
                                                      });
                                                    },
                                                  ),
                                                  Text(
                                                    'Faulty',
                                                    style: TextStyle(
                                                        fontSize:
                                                            smallFontSize),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(10),
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      double buttonHeight =
                                          constraints.maxWidth *
                                              0.08; // Adjust as needed
                                      double buttonWidth =
                                          constraints.maxWidth *
                                              0.15; // Adjust as needed
                                      double fontSize = constraints.maxWidth *
                                          0.03; // Adjust as needed
                                      double smallFontSize =
                                          constraints.maxWidth *
                                              0.02; // Adjust as needed

                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            height: 50,
                                            child: Center(
                                              child: Text(
                                                'SOV 2',
                                                style: TextStyle(
                                                  fontSize: fontSize,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Column(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.blueAccent,
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black26,
                                                      spreadRadius: 1,
                                                      blurRadius: 1.5,
                                                      offset: Offset(1, 1.5),
                                                    ),
                                                  ],
                                                ),
                                                height: buttonHeight,
                                                width: buttonWidth,
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor: Colors
                                                        .blueAccent.shade200,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                    ),
                                                  ),
                                                  onPressed: () async {
                                                    await setSov2Opneclose();
                                                  },
                                                  child: Text(
                                                    'Mode',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: smallFontSize,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.blueAccent,
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black26,
                                                      spreadRadius: 1,
                                                      blurRadius: 1.5,
                                                      offset: Offset(1, 1.5),
                                                    ),
                                                  ],
                                                ),
                                                height: buttonHeight,
                                                width: buttonWidth,
                                                child: TextButton(
                                                  onPressed: () async {
                                                    await setSov2SMode();
                                                  },
                                                  child: Text(
                                                    'S-Mode',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: smallFontSize,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              SizedBox(
                                                height: buttonHeight,
                                                width: buttonWidth,
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor: Colors
                                                        .blueAccent.shade200,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                    ),
                                                  ),
                                                  onPressed: () async {
                                                    await setValveOpenPFCMD6(2);
                                                  },
                                                  child: FittedBox(
                                                    child: Text(
                                                      'Open',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: smallFontSize,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              SizedBox(
                                                height: buttonHeight,
                                                width: buttonWidth,
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor: Colors
                                                        .blueAccent.shade200,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                    ),
                                                  ),
                                                  onPressed: () async {
                                                    await setValveClosePFCMD6(
                                                        2);
                                                  },
                                                  child: FittedBox(
                                                    child: Text(
                                                      'Close',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: smallFontSize,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Radio<String>(
                                                    value: 'OK',
                                                    groupValue: sov2,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        sov2 = value ?? "";
                                                      });
                                                    },
                                                  ),
                                                  Text(
                                                    'OK',
                                                    style: TextStyle(
                                                        fontSize:
                                                            smallFontSize),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio<String>(
                                                    value: 'Faulty',
                                                    groupValue: sov2,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        sov2 = value ?? "";
                                                      });
                                                    },
                                                  ),
                                                  Text(
                                                    'Faulty',
                                                    style: TextStyle(
                                                        fontSize:
                                                            smallFontSize),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(10),
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      double buttonHeight =
                                          constraints.maxWidth *
                                              0.08; // Adjust as needed
                                      double buttonWidth =
                                          constraints.maxWidth *
                                              0.15; // Adjust as needed
                                      double fontSize = constraints.maxWidth *
                                          0.03; // Adjust as needed
                                      double smallFontSize =
                                          constraints.maxWidth *
                                              0.02; // Adjust as needed

                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            height: 50,
                                            child: Center(
                                              child: Text(
                                                'SOV 3',
                                                style: TextStyle(
                                                  fontSize: fontSize,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Column(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.blueAccent,
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black26,
                                                      spreadRadius: 1,
                                                      blurRadius: 1.5,
                                                      offset: Offset(1, 1.5),
                                                    ),
                                                  ],
                                                ),
                                                height: buttonHeight,
                                                width: buttonWidth,
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor: Colors
                                                        .blueAccent.shade200,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                    ),
                                                  ),
                                                  onPressed: () async {
                                                    await setSov3Opneclose();
                                                  },
                                                  child: Text(
                                                    'Mode',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: smallFontSize,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.blueAccent,
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black26,
                                                      spreadRadius: 1,
                                                      blurRadius: 1.5,
                                                      offset: Offset(1, 1.5),
                                                    ),
                                                  ],
                                                ),
                                                height: buttonHeight,
                                                width: buttonWidth,
                                                child: TextButton(
                                                  onPressed: () async {
                                                    await setSov3SMode();
                                                  },
                                                  child: Text(
                                                    'S-Mode',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: smallFontSize,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              SizedBox(
                                                height: buttonHeight,
                                                width: buttonWidth,
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor: Colors
                                                        .blueAccent.shade200,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                    ),
                                                  ),
                                                  onPressed: () async {
                                                    await setValveOpenPFCMD6(3);
                                                  },
                                                  child: FittedBox(
                                                    child: Text(
                                                      'Open',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: smallFontSize,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              SizedBox(
                                                height: buttonHeight,
                                                width: buttonWidth,
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor: Colors
                                                        .blueAccent.shade200,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                    ),
                                                  ),
                                                  onPressed: () async {
                                                    await setValveClosePFCMD6(
                                                        3);
                                                  },
                                                  child: FittedBox(
                                                    child: Text(
                                                      'Close',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: smallFontSize,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Radio<String>(
                                                    value: 'OK',
                                                    groupValue: sov3,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        sov3 = value ?? "";
                                                      });
                                                    },
                                                  ),
                                                  Text(
                                                    'OK',
                                                    style: TextStyle(
                                                        fontSize:
                                                            smallFontSize),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio<String>(
                                                    value: 'Faulty',
                                                    groupValue: sov3,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        sov3 = value ?? "";
                                                      });
                                                    },
                                                  ),
                                                  Text(
                                                    'Faulty',
                                                    style: TextStyle(
                                                        fontSize:
                                                            smallFontSize),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(10),
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      double buttonHeight =
                                          constraints.maxWidth *
                                              0.08; // Adjust as needed
                                      double buttonWidth =
                                          constraints.maxWidth *
                                              0.15; // Adjust as needed
                                      double fontSize = constraints.maxWidth *
                                          0.03; // Adjust as needed
                                      double smallFontSize =
                                          constraints.maxWidth *
                                              0.02; // Adjust as needed

                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            height: 50,
                                            child: Center(
                                              child: Text(
                                                'SOV 4',
                                                style: TextStyle(
                                                  fontSize: fontSize,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Column(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.blueAccent,
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black26,
                                                      spreadRadius: 1,
                                                      blurRadius: 1.5,
                                                      offset: Offset(1, 1.5),
                                                    ),
                                                  ],
                                                ),
                                                height: buttonHeight,
                                                width: buttonWidth,
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor: Colors
                                                        .blueAccent.shade200,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                    ),
                                                  ),
                                                  onPressed: () async {
                                                    await setSov4Opneclose();
                                                  },
                                                  child: Text(
                                                    'Mode',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: smallFontSize,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.blueAccent,
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black26,
                                                      spreadRadius: 1,
                                                      blurRadius: 1.5,
                                                      offset: Offset(1, 1.5),
                                                    ),
                                                  ],
                                                ),
                                                height: buttonHeight,
                                                width: buttonWidth,
                                                child: TextButton(
                                                  onPressed: () async {
                                                    await setSov4SMode();
                                                  },
                                                  child: Text(
                                                    'S-Mode',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: smallFontSize,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              SizedBox(
                                                height: buttonHeight,
                                                width: buttonWidth,
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor: Colors
                                                        .blueAccent.shade200,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                    ),
                                                  ),
                                                  onPressed: () async {
                                                    await setValveOpenPFCMD6(4);
                                                  },
                                                  child: FittedBox(
                                                    child: Text(
                                                      'Open',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: smallFontSize,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              SizedBox(
                                                height: buttonHeight,
                                                width: buttonWidth,
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor: Colors
                                                        .blueAccent.shade200,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                    ),
                                                  ),
                                                  onPressed: () async {
                                                    await setValveClosePFCMD6(
                                                        4);
                                                  },
                                                  child: FittedBox(
                                                    child: Text(
                                                      'Close',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: smallFontSize,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Radio<String>(
                                                    value: 'OK',
                                                    groupValue: sov4,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        sov4 = value ?? "";
                                                      });
                                                    },
                                                  ),
                                                  Text(
                                                    'OK',
                                                    style: TextStyle(
                                                        fontSize:
                                                            smallFontSize),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio<String>(
                                                    value: 'Faulty',
                                                    groupValue: sov4,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        sov4 = value ?? "";
                                                      });
                                                    },
                                                  ),
                                                  Text(
                                                    'Faulty',
                                                    style: TextStyle(
                                                        fontSize:
                                                            smallFontSize),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(10),
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      double buttonHeight =
                                          constraints.maxWidth *
                                              0.08; // Adjust as needed
                                      double buttonWidth =
                                          constraints.maxWidth *
                                              0.15; // Adjust as needed
                                      double fontSize = constraints.maxWidth *
                                          0.03; // Adjust as needed
                                      double smallFontSize =
                                          constraints.maxWidth *
                                              0.02; // Adjust as needed

                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            height: 50,
                                            child: Center(
                                              child: Text(
                                                'SOV 5',
                                                style: TextStyle(
                                                  fontSize: fontSize,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Column(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.blueAccent,
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black26,
                                                      spreadRadius: 1,
                                                      blurRadius: 1.5,
                                                      offset: Offset(1, 1.5),
                                                    ),
                                                  ],
                                                ),
                                                height: buttonHeight,
                                                width: buttonWidth,
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor: Colors
                                                        .blueAccent.shade200,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                    ),
                                                  ),
                                                  onPressed: () async {
                                                    await setSov5Opneclose();
                                                  },
                                                  child: Text(
                                                    'Mode',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: smallFontSize,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.blueAccent,
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black26,
                                                      spreadRadius: 1,
                                                      blurRadius: 1.5,
                                                      offset: Offset(1, 1.5),
                                                    ),
                                                  ],
                                                ),
                                                height: buttonHeight,
                                                width: buttonWidth,
                                                child: TextButton(
                                                  onPressed: () async {
                                                    await setSov5SMode();
                                                  },
                                                  child: Text(
                                                    'S-Mode',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: smallFontSize,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              SizedBox(
                                                height: buttonHeight,
                                                width: buttonWidth,
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor: Colors
                                                        .blueAccent.shade200,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                    ),
                                                  ),
                                                  onPressed: () async {
                                                    await setValveOpenPFCMD6(5);
                                                  },
                                                  child: FittedBox(
                                                    child: Text(
                                                      'Open',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: smallFontSize,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              SizedBox(
                                                height: buttonHeight,
                                                width: buttonWidth,
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor: Colors
                                                        .blueAccent.shade200,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                    ),
                                                  ),
                                                  onPressed: () async {
                                                    await setValveClosePFCMD6(
                                                        5);
                                                  },
                                                  child: FittedBox(
                                                    child: Text(
                                                      'Close',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: smallFontSize,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Radio<String>(
                                                    value: 'OK',
                                                    groupValue: sov5,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        sov5 = value ?? "";
                                                      });
                                                    },
                                                  ),
                                                  Text(
                                                    'OK',
                                                    style: TextStyle(
                                                        fontSize:
                                                            smallFontSize),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio<String>(
                                                    value: 'Faulty',
                                                    groupValue: sov5,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        sov5 = value ?? "";
                                                      });
                                                    },
                                                  ),
                                                  Text(
                                                    'Faulty',
                                                    style: TextStyle(
                                                        fontSize:
                                                            smallFontSize),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(10),
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      double buttonHeight =
                                          constraints.maxWidth *
                                              0.08; // Adjust as needed
                                      double buttonWidth =
                                          constraints.maxWidth *
                                              0.15; // Adjust as needed
                                      double fontSize = constraints.maxWidth *
                                          0.03; // Adjust as needed
                                      double smallFontSize =
                                          constraints.maxWidth *
                                              0.02; // Adjust as needed

                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            height: 50,
                                            child: Center(
                                              child: Text(
                                                'SOV 6',
                                                style: TextStyle(
                                                  fontSize: fontSize,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Column(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.blueAccent,
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black26,
                                                      spreadRadius: 1,
                                                      blurRadius: 1.5,
                                                      offset: Offset(1, 1.5),
                                                    ),
                                                  ],
                                                ),
                                                height: buttonHeight,
                                                width: buttonWidth,
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor: Colors
                                                        .blueAccent.shade200,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                    ),
                                                  ),
                                                  onPressed: () async {
                                                    await setSov6Opneclose();
                                                  },
                                                  child: Text(
                                                    'Mode',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: smallFontSize,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.blueAccent,
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black26,
                                                      spreadRadius: 1,
                                                      blurRadius: 1.5,
                                                      offset: Offset(1, 1.5),
                                                    ),
                                                  ],
                                                ),
                                                height: buttonHeight,
                                                width: buttonWidth,
                                                child: TextButton(
                                                  onPressed: () async {
                                                    await setSov6SMode();
                                                  },
                                                  child: Text(
                                                    'S-Mode',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: smallFontSize,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              SizedBox(
                                                height: buttonHeight,
                                                width: buttonWidth,
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor: Colors
                                                        .blueAccent.shade200,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                    ),
                                                  ),
                                                  onPressed: () async {
                                                    await setValveOpenPFCMD6(6);
                                                  },
                                                  child: FittedBox(
                                                    child: Text(
                                                      'Open',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: smallFontSize,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              SizedBox(
                                                height: buttonHeight,
                                                width: buttonWidth,
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor: Colors
                                                        .blueAccent.shade200,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                    ),
                                                  ),
                                                  onPressed: () async {
                                                    await setValveClosePFCMD6(
                                                        6);
                                                  },
                                                  child: FittedBox(
                                                    child: Text(
                                                      'Close',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: smallFontSize,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Radio<String>(
                                                    value: 'OK',
                                                    groupValue: sov6,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        sov6 = value ?? "";
                                                      });
                                                    },
                                                  ),
                                                  Text(
                                                    'OK',
                                                    style: TextStyle(
                                                        fontSize:
                                                            smallFontSize),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio<String>(
                                                    value: 'Faulty',
                                                    groupValue: sov6,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        sov6 = value ?? "";
                                                      });
                                                    },
                                                  ),
                                                  Text(
                                                    'Faulty',
                                                    style: TextStyle(
                                                        fontSize:
                                                            smallFontSize),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    //Save
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                                'Make sure all the test came out successfully and then click the button bellow'),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 25),
                                child: ElevatedButton(
                                    child: Text('Submit',
                                        style: TextStyle(color: Colors.white)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            5), // Set border radius to 0 for square shape
                                      ),
                                    ),
                                    onPressed: () {
                                      getusername();
                                      getcurrentdate();
                                      showSaveDialog(context);
                                    }),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // set Solenoid to Flow Control mode.
                    if (isSaved!)
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                  'Your PDF was saved successfully ${filePath} now please set all the solenoid to Flow Control mode.'),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                    child: Text('sov 1',
                                        style: TextStyle(color: Colors.white)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            5), // Set border radius to 0 for square shape
                                      ),
                                    ),
                                    onPressed: () async {
                                      await setSov1FlowControl();
                                    }),
                                ElevatedButton(
                                    child: Text('sov 2',
                                        style: TextStyle(color: Colors.white)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            5), // Set border radius to 0 for square shape
                                      ),
                                    ),
                                    onPressed: () async {
                                      await setSov2FlowControl();
                                    }),
                                ElevatedButton(
                                    child: Text('sov 3',
                                        style: TextStyle(color: Colors.white)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            5), // Set border radius to 0 for square shape
                                      ),
                                    ),
                                    onPressed: () async {
                                      await setSov3FlowControl();
                                    }),
                                ElevatedButton(
                                    child: Text('sov 4',
                                        style: TextStyle(color: Colors.white)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            5), // Set border radius to 0 for square shape
                                      ),
                                    ),
                                    onPressed: () async {
                                      await setSov4FlowControl();
                                    }),
                                ElevatedButton(
                                    child: Text('sov 5',
                                        style: TextStyle(color: Colors.white)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            5), // Set border radius to 0 for square shape
                                      ),
                                    ),
                                    onPressed: () async {
                                      await setSov5FlowControl();
                                    }),
                                ElevatedButton(
                                    child: Text('sov 6',
                                        style: TextStyle(color: Colors.white)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            5), // Set border radius to 0 for square shape
                                      ),
                                    ),
                                    onPressed: () async {
                                      await setSov6FlowControl();
                                    }),
                              ],
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
      } else {
        return Center(
          child: SizedBox(
            height: 260, //MediaQuery.of(context).size.height * 0.35,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(
                  image: AssetImage('assets/images/wrong.gif'),
                  height: 120,
                  width: 120,
                ),
                Text(
                  'Site Name Data Not Found',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                ),
                Text(
                  'You have connected to unknown device${controllerType ?? ""}',
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 25.0),
                  child: TextButton(
                    onPressed: () async {
                      // _progress = 0.0;
                      _response.clear();
                      _serialData.clear();
                      hexDecimalValue = '';
                      getSiteName();
                    },
                    child: Text(
                      'Retry',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (ex, _) {
      return Container(
        child: Center(
          child: Text('Click On Get SINM to Find Device Type'),
        ),
      );
    }
  }

  setDatetime() async {
    try {
      _serialData.clear();

      isloracheck = true;
      lora_comm = '';
      String data = "${('dts 0000 00 00 00 00 00').toUpperCase()}\r\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 5)).whenComplete(() async {
        String res = _serialData.join('');
        int i = res.indexOf("DT");
        dtbefore = res.substring(i + 4, i + 18);
        _response = [];
        String rebootData = "${'RBT'.toUpperCase()}\r\n";
        await _port!.write(Uint8List.fromList(rebootData.codeUnits));

        await Future.delayed(Duration(seconds: 30)).whenComplete(() async {
          getDatetime();
        });
      });
    } catch (_, ex) {
      _serialData.add('Please Try Again...');
    }
  }

  Future<void> getDatetime() async {
    try {
      _response.clear();
      _serialData.clear();
      String data = "${'dts'.toUpperCase()}\r\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 5)).whenComplete(() {
        print(_serialData);
        String res = _serialData.join('');
        int i = res.indexOf("DT");
        String dateTime = res.substring(i + 4, i + 21).replaceAll('>', '');
        List<int> dateParts =
            dateTime.split(' ').map((part) => int.parse(part)).toList();

        int year = dateParts[0];
        int month = dateParts[1];
        int day = dateParts[2];
        int hour = dateParts[3];
        int minute = dateParts[4];
        int second = dateParts[5];

        final DateFormat formatter = DateFormat('yyyy/MM/dd HH:mm:ss');

        DateTime deviceDateTime =
            DateTime(year, month, day, hour, minute, second);
        DateTime currentDateTime = DateTime.now();

        // Calculate the difference
        Duration difference = currentDateTime.difference(deviceDateTime).abs();

        // Check if the difference is within 10 minutes
        setState(() {
          if (difference.inMinutes <= 10) {
            lora_comm = 'Ok';
          } else {
            lora_comm = 'Not Ok';
          }
        });

        String deviceTime = formatter.format(deviceDateTime);
        String currTime = formatter.format(currentDateTime);

        print("DeviceTime: $deviceTime Curr Time: $currTime");
        setState(() {
          isloracheck = false;
        });
        // if (_datetimecontroller.text.isEmpty) {
        //   // getDatetime();
        // }
      });
      _response = [];
    } catch (ex) {
      print("Error: $ex");
      throw Exception("Failed to get datetime");
    }
  }

  getMID() async {
    try {
      _serialData.clear();
      String data = "${'mid'.toUpperCase()}\r\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 5)).whenComplete(
        () {
          String res = _serialData.join('');
          print(res);
          int i = res.indexOf("MI");
          String substring = res.substring(i + 4, i + 20);
          RegExp pattern = RegExp(r'^[0-9A-F]{16}$');
          bool matchesPattern = pattern.hasMatch(substring);
          if (matchesPattern) {
            setState(() {
              macId = res.substring(i + 4, i + 20);
            });
            /* showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: SizedBox(
                    height: 260, //MediaQuery.of(context).size.height * 0.35,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image(
                          image: AssetImage('assets/images/success.gif'),
                          height: 120,
                          width: 120,
                        ),
                        Text(
                          'Connected',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey),
                        ),
                        Text(
                          'Your device is connected to ' +
                              controllerType?? "".toString(),
                          textAlign: TextAlign.center,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 25.0),
                          child: TextButton(
                            onPressed: () {
                              _progress = 0.0;
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'OK',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
         */
          } else {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: SizedBox(
                    height: 260, //MediaQuery.of(context).size.height * 0.35,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image(
                          image: AssetImage('assets/images/wrong.gif'),
                          height: 120,
                          width: 120,
                        ),
                        Text(
                          'Mac Id Not Found',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey),
                        ),
                        Text(
                          'This Device is unable to get mac id from controller',
                          textAlign: TextAlign.center,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 25.0),
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              getMID();
                              // _startTask(15);
                              // getpop_loader(context);
                              // Future.delayed(Duration(milliseconds: 15), () {
                              //   Navigator.pop(context); //pop dialog
                              // });
                              // Navigator.of(context).pop();
                            },
                            child: Text(
                              'Retry',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      );

      _response = [];
    } catch (_, ex) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SizedBox(
              height: 260, //MediaQuery.of(context).size.height * 0.35,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    image: AssetImage('assets/images/wrong.gif'),
                    height: 120,
                    width: 120,
                  ),
                  Text(
                    'Mac Id Not Found',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                  Text(
                    'This Device is unable to get mac id from controller',
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 25.0),
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        getMID();
                        // _progress = 0.0;
                        // _startTask(15);
                        // getpop_loader(context);
                        // Future.delayed(Duration(seconds: 16), () {
                        //   Navigator.pop(context); //pop dialog
                        // });
                      },
                      child: Text(
                        'Retry',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
      macId = 'NOT FOUND';
      _serialData.add('Please Try Again...');
    }
  }

  setValveOpenPFCMD6(int index) {
    _serialData.clear();
    String data = "${('PFCMD6ONOFF $index 1').toUpperCase()}\r\n";
    _port!.write(Uint8List.fromList(data.codeUnits));
    new Future.delayed(Duration(seconds: 10)).whenComplete(() {
      String res = _serialData.join('');
      print(res);
      if (res.toLowerCase().contains('pfcmd$index on')) {
        Future.delayed(Duration(seconds: 5)).whenComplete(() async {
          print("PFCMD $index is OPEN now");

          switch (index) {
            case 1:
              openvalpos1 = true;
              break;
            case 2:
              openvalpos2 = true;
              break;
            case 3:
              openvalpos3 = true;
              break;
            case 4:
              openvalpos4 = true;
              break;
            case 5:
              openvalpos5 = true;
              break;
            case 6:
              openvalpos6 = true;
              break;
            default:
              print('open');
          }
        });
      } else {
        /*showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: SizedBox(
                height: 260, //MediaQuery.of(context).size.height * 0.35,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image(
                      image: AssetImage('assets/images/wrong.gif'),
                      height: 120,
                      width: 120,
                    ),
                    Text(
                      'Command Revived Ended.',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
                    Text(
                      'Devices is not able to Open valve $index',
                      textAlign: TextAlign.center,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 25.0),
                      child: TextButton(
                        onPressed: () {
                          setValveOpenPFCMD6(index);
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Retry',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      */
      }
    });
  }

  setValveClosePFCMD6(int index) {
    _serialData.clear();
    String data = "${('PFCMD6ONOFF $index 0').toUpperCase()}\r\n";
    _port!.write(Uint8List.fromList(data.codeUnits));
    new Future.delayed(Duration(seconds: 10)).whenComplete(() {
      String res = _serialData.join('');
      if (res.toLowerCase().contains('pfcmd$index off')) {
        Future.delayed(Duration(seconds: 5)).whenComplete(() async {
          print("PFCMD $index is CLOSE now");
          switch (index) {
            case 1:
              closevalpos1 = true;
              if (openvalpos1 && closevalpos1) {
                setState(() {
                  sov1 = 'OK';
                });
              } else {
                setState(() {
                  sov1 = 'Faulty';
                });
              }
              break;
            case 2:
              closevalpos2 = true;
              if (openvalpos2 && closevalpos2) {
                setState(() {
                  sov2 = 'OK';
                });
              } else {
                setState(() {
                  sov2 = 'Faulty';
                });
              }
              break;
            case 3:
              closevalpos3 = true;
              if (openvalpos3 && closevalpos3) {
                setState(() {
                  sov3 = 'OK';
                });
              } else {
                setState(() {
                  sov3 = 'Faulty';
                });
              }
              break;
            case 4:
              closevalpos4 = true;
              if (openvalpos4 && closevalpos4) {
                setState(() {
                  sov4 = 'OK';
                });
              } else {
                setState(() {
                  sov4 = 'Faulty';
                });
              }
              break;
            case 5:
              closevalpos5 = true;
              if (openvalpos5 && closevalpos5) {
                setState(() {
                  sov5 = 'OK';
                });
              } else {
                setState(() {
                  sov5 = 'Faulty';
                });
              }
              break;
            case 6:
              closevalpos6 = true;
              if (openvalpos6 && closevalpos6) {
                setState(() {
                  sov6 = 'OK';
                });
              } else {
                setState(() {
                  sov6 = 'Faulty';
                });
              }
              break;
            default:
              print('');
          } // await getINTG2(index);
        });
      } else {
        /*showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: SizedBox(
                height: 260, //MediaQuery.of(context).size.height * 0.35,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image(
                      image: AssetImage('assets/images/wrong.gif'),
                      height: 120,
                      width: 120,
                    ),
                    Text(
                      'Command Revived Ended.',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
                    Text(
                      'Devices is not able to Close Valve $index',
                      textAlign: TextAlign.center,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 25.0),
                      child: TextButton(
                        onPressed: () {
                          setValveClosePFCMD6(index);
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Retry',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      */
      }
    });
  }

  double getBatterVoltage() {
    var subString2;
    try {
      subString2 = hexIntgValue?.substring(12, 16);
      int decimal = int.parse(subString2, radix: 16);
      batteryVoltage = (decimal / 100);
      getAlarms();
    } catch (_, ex) {
      batteryVoltage = 0.0;
    }
    return batteryVoltage!;
  }

  double getFirmwareVersion() {
    var subString3;
    firmwareversion;
    try {
      subString3 = hexIntgValue?.substring(28, 30);
      int decimal = int.parse(subString3, radix: 16);
      firmwareversion = (decimal / 10);
    } catch (_, ex) {
      firmwareversion = 0.0;
    }
    return firmwareversion!;
  }

  getSOLARVoltage() {
    var subString3;
    try {
      subString3 = hexIntgValue?.substring(16, 20);
      int decimal = int.parse(subString3, radix: 16);
      solarVoltage = (decimal / 100).toDouble();
    } catch (_, ex) {
      solarVoltage = 0.0;
    }
    return solarVoltage;
  }

  getAlarms() {
    var hexvalue;
    String binaryNumber;
    List<String> binaryValues = [];

    try {
      hexvalue = hexIntgValue?.substring(30, 34);
      int decimalNumber = int.parse(hexvalue, radix: 16);
      binaryNumber = decimalNumber.toRadixString(2).padLeft(16, '0');
    } catch (_, ex) {
      binaryNumber = '0.0';
    }

    if (binaryNumber.length >= 16) {
      binaryValues.add(binaryNumber[15]);
      binaryValues.add(binaryNumber[14]);
    }
    setState(() {
      Door1 = binaryNumber[15] == '0' ? 'OPEN' : 'CLOSE';
      Door2 = binaryNumber[14] == '0' ? 'OPEN' : 'CLOSE';
    });
  }

  getAllPTValues() async {
    await getFilterInlet();
    await getFilterOutlet();
    await getPT1value();
    await getPT2value();
    await getPT3value();
    await getPT4value();
    await getPT5value();
    await getPT6value();
  }

  getFilterInlet() {
    try {
      var filterinlethex = hexIntgValue?.substring(20, 24);
      int decimal = int.parse(filterinlethex ?? "", radix: 16);
      double ai1 = (decimal / 100);
      bool isWithinRange = ai1 >= lowerLimit && ai1 <= upperLimit;
      print(
          'Filter Inlet: ${ai1.toStringAsFixed(3)}'); // Format to 3 decimal places
      print('Is filterInlet between 2.25 and 2.75? $isWithinRange');

      setState(() {
        filterInlet = ai1;
        if (isWithinRange) {
          InletButton = 'OK';
        } else {
          InletButton = 'Faulty';
        }
      });
    } catch (_, ex) {
      print(ex);
    }
  }

  getFilterOutlet() {
    try {
      var filteroutlethex = hexIntgValue?.substring(24, 28);
      int decimal = int.parse(filteroutlethex ?? "", radix: 16);
      double ai2 = (decimal / 100);
      print('Filter Outlet PT $ai2');
      bool isWithinRange = ai2 >= lowerLimit && ai2 <= upperLimit;
      print('Is filterOutlet between 2.25 and 2.75? $isWithinRange');

      setState(() {
        filterOutlet = ai2;
        if (isWithinRange) {
          OutletButton = 'OK';
        } else {
          OutletButton = 'Faulty';
        }
      });
    } catch (_, ex) {
      print(ex);
    }
  }

  getPT1value() {
    try {
      var outletPt1hex = hexIntgValue?.substring(38, 42);
      int decimal = int.parse(outletPt1hex ?? "", radix: 16);
      var outletpt1 = (decimal / 100);
      bool isWithinRange = outletpt1 >= lowerLimit && outletpt1 <= upperLimit;
      print('Is OutletPT-1 between 2.25 and 2.75? $isWithinRange');
      setState(() {
        outlet_1_actual_count_controller = outletpt1;
        if (isWithinRange) {
          PFCMD1 = 'OK';
        } else {
          PFCMD1 = 'Faulty';
        }
      });
    } catch (_, ex) {
      print(ex);
    }
  }

  getPT2value() {
    try {
      var outletPt2hex = hexIntgValue?.substring(58, 62);
      int decimal = int.parse(outletPt2hex ?? "", radix: 16);
      var outletpt2 = (decimal / 100);
      print(outletpt2.toString());
      bool isWithinRange = outletpt2 >= lowerLimit && outletpt2 <= upperLimit;
      print(
          'Is OutletPt-2 between $lowerLimit and $upperLimit? $isWithinRange');
      setState(() {
        outlet_2_actual_count_after_controller = outletpt2;
        if (isWithinRange) {
          PFCMD2 = 'OK';
        } else {
          PFCMD2 = 'Faulty';
        }
      });
    } catch (_, ex) {
      print(ex);
    }
  }

  getPT3value() {
    try {
      var outletPt3hex = hexIntgValue?.substring(78, 82);
      int decimal = int.parse(outletPt3hex ?? "", radix: 16);
      double outletpt3 = (decimal / 100);
      print(outletpt3.toString());
      bool isWithinRange = outletpt3 >= lowerLimit && outletpt3 <= upperLimit;
      print(
          'Is OutletPt-3 between $lowerLimit and $upperLimit? $isWithinRange');
      setState(() {
        outlet_3_actual_count_controller = outletpt3;
        if (isWithinRange) {
          PFCMD3 = 'OK';
        } else {
          PFCMD3 = 'Faulty';
        }
      });
    } catch (_, ex) {
      print(ex);
    }
  }

  getPT4value() {
    try {
      var outletPt4hex = hexIntgValue?.substring(98, 102);
      int decimal = int.parse(outletPt4hex ?? "", radix: 16);
      double outletpt4 = (decimal / 100);
      setState(() {
        outlet_4_actual_count_controller = outletpt4;
        bool isWithinRange = outletpt4 >= lowerLimit && outletpt4 <= upperLimit;
        print(
            'Is OutletPt-4 between $lowerLimit and $upperLimit? $isWithinRange');
        if (isWithinRange) {
          PFCMD4 = 'OK';
        } else {
          PFCMD4 = 'Faulty';
        }
      });
    } catch (_, ex) {}
  }

  getPT5value() {
    try {
      var outletPt5hex = hexIntgValue?.substring(118, 122);
      int decimal = int.parse(outletPt5hex ?? "", radix: 16);
      double outletpt5 = (decimal / 100);
      setState(() {
        outlet_5_actual_count_controller = outletpt5;
        bool isWithinRange = outletpt5 >= lowerLimit && outletpt5 <= upperLimit;
        print(
            'Is OutletPt-5 between $lowerLimit and $upperLimit? $isWithinRange');
        if (isWithinRange) {
          PFCMD5 = 'OK';
        } else {
          PFCMD5 = 'Faulty';
        }
      });
    } catch (_, ex) {}
  }

  getPT6value() {
    try {
      var outletPt6hex = hexIntgValue?.substring(138, 142);
      int decimal = int.parse(outletPt6hex ?? "", radix: 16);
      double outletpt6 = (decimal / 100);
      setState(() {
        outlet_6_actual_count_controller = outletpt6;
        bool isWithinRange = outletpt6 >= lowerLimit && outletpt6 <= upperLimit;
        print(
            'Is OutletPt-6 between $lowerLimit and $upperLimit? $isWithinRange');
        if (isWithinRange) {
          PFCMD6 = 'OK';
        } else {
          PFCMD6 = 'Faulty';
        }
      });
    } catch (_, ex) {}
  }

  getAllPositionSensorValue() async {
    await getPostion1Value();
    await Future.delayed(Duration(seconds: 2));
    await getPostion2Value();
    await Future.delayed(Duration(seconds: 2));
    await getPostion3Value();
    await Future.delayed(Duration(seconds: 2));
    await getPostion4Value();
    await Future.delayed(Duration(seconds: 2));
    await getPostion5Value();
    await Future.delayed(Duration(seconds: 2));
    await getPostion6Value();
  }

/*
getPostion_pfcmd_1() async {
    try {
      String data = "${'AI 9'.toUpperCase()}\r\n";
      _serialData.clear();
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 14)).whenComplete(
        () {
          String res = _serialData.join('');
          int i = res.indexOf("AI");
          var aisData = res.substring(i + 5);
          List<String> position_range = aisData.split(' ');
          posval1 = double.parse(position_range[0]);
          print(posval1.toString());
          bool isWithinRange = posval1! >= 4000 && posval1! <= 20000;
          print('Is filterOutlet between 4000 and 20000? $isWithinRange');
          if (isWithinRange) {
            pos1 = 'OK';
          } else {
            pos1 = 'Faulty';
          }
        },
      );
      _response = [];
    } catch (_, ex) {
      
      print(ex);
    }
  }
  */
  getPostion1Value() async {
    try {
      _response.clear();
      _serialData.clear();
      String data = "${'AI 9'.toUpperCase()}\r\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 5)).whenComplete(
        () {
          String res = _serialData.join('');
          if (_serialData.join(' ').toUpperCase().contains('AI 9')) {
            String res = _serialData.join('');
            int i = res.indexOf("AI");
            var aisData = res.substring(i + 5);
            List<String> position_range = aisData.split(' ');
            setState(() {
              posval1 = double.parse(position_range[1]);
              print(posval1.toString());
              bool isWithinRange = posval1! >= 3800 && posval1! <= 20000;
              print(
                  'Is Position Sensor 1 between 3800 and 20000? $isWithinRange');
              if (isWithinRange) {
                pos1 = 'OK';
              } else {
                pos1 = 'Faulty';
              }
            });
          }
        },
      );
      // _response = [];
      // var pos1hex = hexIntgValue?.substring(42, 46);
      // int decimal = int.parse(pos1hex ?? "", radix: 16);
      // double position1value = (decimal / 100);
      // bool isWithinRange = position1value >= 0 && position1value <= 100;
      // print('Is pos1  between 0 and 100? $isWithinRange');
      // setState(() {
      //   posval1 = position1value;
      //   if (isWithinRange) {
      //     pos1 = 'OK';
      //   } else {
      //     pos1 = 'Faulty';
      // }
      // });
    } catch (_, ex) {
      print(ex);
    }
  }

  getPostion2Value() async {
    try {
      _response.clear();
      _serialData.clear();
      String data = "${'AI 10'.toUpperCase()}\r\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 5)).whenComplete(
        () {
          String res = _serialData.join('');
          if (_serialData.join(' ').toUpperCase().contains('AI 10')) {
            String res = _serialData.join('');
            int i = res.indexOf("AI");
            var aisData = res.substring(i + 7);
            List<String> position_range = aisData.split(' ');
            setState(() {
              posval2 = double.parse(position_range[1]);
              print(posval2.toString());
              bool isWithinRange = posval2! >= 3800 && posval2! <= 20000;
              print(
                  'Is Position Sensor 2 between 3800 and 20000? $isWithinRange');
              if (isWithinRange) {
                pos2 = 'OK';
              } else {
                pos2 = 'Faulty';
              }
            });
          }
        },
      );
    } catch (_, ex) {
      print(ex);
    }
  }

  getPostion3Value() async {
    try {
      _response.clear();
      _serialData.clear();
      String data = "${'AI 11'.toUpperCase()}\r\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 5)).whenComplete(
        () {
          String res = _serialData.join('');
          if (_serialData.join(' ').toUpperCase().contains('AI 11')) {
            String res = _serialData.join('');
            int i = res.indexOf("AI");
            int lastindex = res.indexOf(">");
            var aisData = res.substring(i + 7, lastindex);
            List<String> position_range = aisData.split(' ');
            setState(() {
              posval3 = double.parse(position_range[1]);
              print(posval3.toString());
              bool isWithinRange = posval3! >= 3800 && posval3! <= 20000;
              print(
                  'Is Position Sensor 3 between 3800 and 20000? $isWithinRange');
              if (isWithinRange) {
                pos3 = 'OK';
              } else {
                pos3 = 'Faulty';
              }
            });
          }
        },
      );
    } catch (_, ex) {
      print(ex);
    }
  }

  getPostion4Value() async {
    try {
      _response.clear();
      _serialData.clear();
      String data = "${'AI 12'.toUpperCase()}\r\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 5)).whenComplete(
        () {
          String res = _serialData.join('');
          if (_serialData.join(' ').toUpperCase().contains('AI 12')) {
            String res = _serialData.join('');
            int i = res.indexOf("AI");
            int lastindex = res.indexOf(">");
            var aisData = res.substring(i + 7, lastindex);
            List<String> position_range = aisData.split(' ');
            setState(() {
              posval4 = double.parse(position_range[1]);
              print(posval4.toString());
              bool isWithinRange = posval4! >= 3800 && posval4! <= 20000;
              print(
                  'Is Position Sensor 4 between 3800 and 20000? $isWithinRange');
              if (isWithinRange) {
                pos4 = 'OK';
              } else {
                pos4 = 'Faulty';
              }
            });
          }
        },
      );
    } catch (_, ex) {
      print(ex);
    }
  }

  getPostion5Value() async {
    try {
      _response.clear();
      _serialData.clear();
      String data = "${'AI 13'.toUpperCase()}\r\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 5)).whenComplete(
        () {
          String res = _serialData.join('');
          if (_serialData.join(' ').toUpperCase().contains('AI 13')) {
            String res = _serialData.join('');
            int i = res.indexOf("AI");
            int lastindex = res.indexOf(">");
            var aisData = res.substring(i + 7, lastindex);
            List<String> position_range = aisData.split(' ');
            setState(() {
              posval5 = double.parse(position_range[1]);
              print(posval5.toString());
              bool isWithinRange = posval5! >= 3800 && posval5! <= 20000;
              print(
                  'Is Position Sensor 5 between 3800 and 20000? $isWithinRange');
              if (isWithinRange) {
                pos5 = 'OK';
              } else {
                pos5 = 'Faulty';
              }
            });
          }
        },
      );
    } catch (_, ex) {
      print(ex);
    }
  }

  getPostion6Value() async {
    try {
      _response.clear();
      _serialData.clear();
      String data = "${'AI 14'.toUpperCase()}\r\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 5)).whenComplete(
        () {
          String res = _serialData.join('');
          if (_serialData.join(' ').toUpperCase().contains('AI 14')) {
            String res = _serialData.join('');
            int i = res.indexOf("AI");
            int lastindex = res.indexOf(">");
            var aisData = res.substring(i + 7, lastindex);
            List<String> position_range = aisData.split(' ');
            setState(() {
              posval6 = double.parse(position_range[1]);
              print(posval6.toString());
              bool isWithinRange = posval6! >= 3800 && posval6! <= 20000;
              print(
                  'Is Position Sensor 6 between 3800 and 20000? $isWithinRange');
              if (isWithinRange) {
                pos6 = 'OK';
              } else {
                pos6 = 'Faulty';
              }
            });
          }
        },
      );
    } catch (_, ex) {
      print(ex);
    }
  }

  /*getPostion2Value() {
    try {
      var pos2hex = hexIntgValue?.substring(62, 66);
      int decimal = int.parse(pos2hex ?? "", radix: 16);
      double position2value = (decimal / 100);
      bool isWithinRange = position2value >= 0 && position2value <= 100;
      print('Is pos2  between 0 and 100? $isWithinRange');
      setState(() {
        posval2 = position2value;
        if (isWithinRange) {
          pos2 = 'OK';
        } else {
          pos2 = 'Faulty';
        }
      });
    } catch (_, ex) {
      print(ex);
    }
  }

  getPostion3Value() {
    try {
      var pos3hex = hexIntgValue?.substring(82, 86);
      int decimal = int.parse(pos3hex ?? "", radix: 16);
      double position3value = (decimal / 100);
      bool isWithinRange = position3value >= 0 && position3value <= 100;
      print('Is pos3  between 0 and 100? $isWithinRange');
      setState(() {
        posval3 = position3value;
        if (isWithinRange) {
          pos3 = 'OK';
        } else {
          pos3 = 'Faulty';
        }
      });
    } catch (_, ex) {
      print(ex);
    }
  }

  getPostion4Value() {
    try {
      var pos4hex = hexIntgValue?.substring(102, 106);
      int decimal = int.parse(pos4hex ?? "", radix: 16);
      double position4value = (decimal / 100);
      bool isWithinRange = position4value >= 0 && position4value <= 100;
      print('Is pos4  between 0 and 100? $isWithinRange');
      setState(() {
        posval4 = position4value;
        if (isWithinRange) {
          pos4 = 'OK';
        } else {
          pos4 = 'Faulty';
        }
      });
    } catch (_, ex) {
      print(ex);
    }
  }

  getPostion5Value() {
    try {
      var pos5hex = hexIntgValue?.substring(122, 126);

      int decimal = int.parse(pos5hex ?? "", radix: 16);
      double position5value = (decimal / 100);
      bool isWithinRange = position5value >= 0 && position5value <= 100;
      print('Is pos5  between 0 and 100? $isWithinRange');
      setState(() {
        posval5 = position5value;
        if (isWithinRange) {
          pos5 = 'OK';
        } else {
          pos5 = 'Faulty';
        }
      });
    } catch (_, ex) {
      print(ex);
    }
  }

  getPostion6Value() {
    try {
      var pos6hex = hexIntgValue?.substring(142, 146);
      int decimal = int.parse(pos6hex ?? "", radix: 16);
      double position6value = (decimal / 100);
      bool isWithinRange = position6value >= 0 && position6value <= 100;
      print('Is pos6  between 0 and 100? $isWithinRange');
      setState(() {
        posval6 = position6value;
        if (isWithinRange) {
          pos6 = 'OK';
        } else {
          pos6 = 'Faulty';
        }
      });
    } catch (_, ex) {
      print(ex);
    }
  }
*/

  getAllINTGPacket() async {
    await getFirmwareVersion();
    await getBatterVoltage();
    await getSOLARVoltage();
    await getAlarms();
  }

  setSov1FlowControl() async {
    try {
      _response.clear();
      _serialData.clear();
      String data = "${'PFCMD6TYPE 1 2'.toUpperCase()}\r\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 5)).whenComplete(
        () {
          String res = _serialData.join('');
          // print(res);
          if (_serialData.join(' ').toUpperCase().contains('PFCMD6TYPE 1 2')) {
            print("SOV 1 set to Flow Control mode");
          }
        },
      );
      _response = [];
    } catch (_, ex) {
      print(ex);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SizedBox(
              height: 260, //MediaQuery.of(context).size.height * 0.35,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    image: AssetImage('assets/images/wrong.gif'),
                    height: 120,
                    width: 120,
                  ),
                  Text(
                    'Command Revived Ended.',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                  Text(
                    'Devices is not able to Set Mode In Flow Control',
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 25.0),
                    child: TextButton(
                      onPressed: () {
                        setSov1FlowControl();
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Retry',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
      _serialData.add('Please Try Again...');
    }
  }

  setSov2FlowControl() async {
    try {
      _response.clear();
      _serialData.clear();
      String data = "${'PFCMD6TYPE 2 2'.toUpperCase()}\r\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 5)).whenComplete(
        () {
          String res = _serialData.join('');
          // print(res);
          if (_serialData.join(' ').toUpperCase().contains('PFCMD6TYPE 2 2')) {
            print("SOV 2 set to Flow Control mode");
          }
        },
      );
      _response = [];
    } catch (_, ex) {
      print(ex);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SizedBox(
              height: 260, //MediaQuery.of(context).size.height * 0.35,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    image: AssetImage('assets/images/wrong.gif'),
                    height: 120,
                    width: 120,
                  ),
                  Text(
                    'Command Revived Ended.',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                  Text(
                    'Devices is not able to Set Mode In Flow Control',
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 25.0),
                    child: TextButton(
                      onPressed: () {
                        setSov2FlowControl();
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Retry',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
      _serialData.add('Please Try Again...');
    }
  }

  setSov3FlowControl() async {
    try {
      _response.clear();
      _serialData.clear();
      String data = "${'PFCMD6TYPE 3 2'.toUpperCase()}\r\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 5)).whenComplete(
        () {
          String res = _serialData.join('');
          // print(res);
          if (_serialData.join(' ').toUpperCase().contains('PFCMD6TYPE 3 2')) {
            print("SOV 3 set to Flow Control mode");
          }
        },
      );
      _response = [];
    } catch (_, ex) {
      print(ex);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SizedBox(
              height: 260, //MediaQuery.of(context).size.height * 0.35,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    image: AssetImage('assets/images/wrong.gif'),
                    height: 120,
                    width: 120,
                  ),
                  Text(
                    'Command Revived Ended.',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                  Text(
                    'Devices is not able to Set Mode In Flow Control',
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 25.0),
                    child: TextButton(
                      onPressed: () {
                        setSov3FlowControl();
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Retry',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
      _serialData.add('Please Try Again...');
    }
  }

  setSov4FlowControl() async {
    try {
      _response.clear();
      _serialData.clear();
      String data = "${'PFCMD6TYPE 4 2'.toUpperCase()}\r\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 5)).whenComplete(
        () {
          String res = _serialData.join('');
          // print(res);
          if (_serialData.join(' ').toUpperCase().contains('PFCMD6TYPE 4 2')) {
            print("SOV 4 set to Flow Control mode");
          }
        },
      );
      _response = [];
    } catch (_, ex) {
      print(ex);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SizedBox(
              height: 260, //MediaQuery.of(context).size.height * 0.35,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    image: AssetImage('assets/images/wrong.gif'),
                    height: 120,
                    width: 120,
                  ),
                  Text(
                    'Command Revived Ended.',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                  Text(
                    'Devices is not able to Set Mode In Flow Control',
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 25.0),
                    child: TextButton(
                      onPressed: () {
                        setSov4FlowControl();
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Retry',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
      _serialData.add('Please Try Again...');
    }
  }

  setSov5FlowControl() async {
    try {
      _response.clear();
      _serialData.clear();
      String data = "${'PFCMD6TYPE 5 2'.toUpperCase()}\r\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 5)).whenComplete(
        () {
          String res = _serialData.join('');
          // print(res);
          if (_serialData.join(' ').toUpperCase().contains('PFCMD6TYPE 5 2')) {
            print("SOV 5 set to Flow Control mode");
          }
        },
      );
      _response = [];
    } catch (_, ex) {
      print(ex);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SizedBox(
              height: 260, //MediaQuery.of(context).size.height * 0.35,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    image: AssetImage('assets/images/wrong.gif'),
                    height: 120,
                    width: 120,
                  ),
                  Text(
                    'Command Revived Ended.',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                  Text(
                    'Devices is not able to Set Mode In Flow Control',
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 25.0),
                    child: TextButton(
                      onPressed: () {
                        setSov5FlowControl();
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Retry',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
      _serialData.add('Please Try Again...');
    }
  }

  setSov6FlowControl() async {
    try {
      _response.clear();
      _serialData.clear();
      String data = "${'PFCMD6TYPE 6 2'.toUpperCase()}\r\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 5)).whenComplete(
        () {
          String res = _serialData.join('');
          // print(res);
          if (_serialData.join(' ').toUpperCase().contains('PFCMD6TYPE 6 2')) {
            print("SOV 6 set to Flow Control mode");
          }
        },
      );
      _response = [];
    } catch (_, ex) {
      print(ex);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SizedBox(
              height: 260, //MediaQuery.of(context).size.height * 0.35,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    image: AssetImage('assets/images/wrong.gif'),
                    height: 120,
                    width: 120,
                  ),
                  Text(
                    'Command Revived Ended.',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                  Text(
                    'Devices is not able to Set Mode In Flow Control',
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 25.0),
                    child: TextButton(
                      onPressed: () {
                        setSov6FlowControl();
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Retry',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
      _serialData.add('Please Try Again...');
    }
  }

  setSov1Opneclose() async {
    try {
      _response.clear();
      _serialData.clear();
      String data = "${'PFCMD6TYPE 1 1'.toUpperCase()}\r\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 5)).whenComplete(
        () {
          String res = _serialData.join('');
          // print(res);
          if (_serialData.join(' ').toUpperCase().contains('PFCMD6TYPE 1 1')) {
            print("SOV 1 set to Open/Close mode");
          }
        },
      );
      _response = [];
    } catch (_, ex) {
      print(ex);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SizedBox(
              height: 260, //MediaQuery.of(context).size.height * 0.35,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    image: AssetImage('assets/images/wrong.gif'),
                    height: 120,
                    width: 120,
                  ),
                  Text(
                    'Command Revived Ended.',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                  Text(
                    'Devices is not able to Set Mode In Open/Close',
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 25.0),
                    child: TextButton(
                      onPressed: () {
                        setSov1Opneclose();
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Retry',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
      _serialData.add('Please Try Again...');
    }
  }

  setSov2Opneclose() async {
    try {
      _response.clear();
      _serialData.clear();
      String data = "${'PFCMD6TYPE 2 1'.toUpperCase()}\r\n";
      _port!.write(Uint8List.fromList(data.codeUnits));
      new Future.delayed(Duration(seconds: 5)).whenComplete(() {
        // String res = _data.join('');
        if (_serialData.join(' ').toUpperCase().contains('PFCMD6TYPE 2 1')) {
          print("SOV 2 set to Open/Close mode");
        }
        _response = [];
      });
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SizedBox(
              height: 260, //MediaQuery.of(context).size.height * 0.35,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    image: AssetImage('assets/images/wrong.gif'),
                    height: 120,
                    width: 120,
                  ),
                  Text(
                    'Command Revived Ended.',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                  Text(
                    'Devices is not able to Set Mode In Open/Close',
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 25.0),
                    child: TextButton(
                      onPressed: () {
                        setSov2Opneclose();
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Retry',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  setSov3Opneclose() async {
    try {
      _response.clear();
      _serialData.clear();
      String data = "${'PFCMD6TYPE 3 1'.toUpperCase()}\r\n";
      _port!.write(Uint8List.fromList(data.codeUnits));
      new Future.delayed(Duration(seconds: 10)).whenComplete(() {
        if (_serialData.join(' ').toUpperCase().contains('PFCMD6TYPE 3 1')) {
          print(_response);
          print("SOV 3 set to Open/Close mode");
        }
      });
      _response = [];
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SizedBox(
              height: 260, //MediaQuery.of(context).size.height * 0.35,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    image: AssetImage('assets/images/wrong.gif'),
                    height: 120,
                    width: 120,
                  ),
                  Text(
                    'Command Revived Ended.',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                  Text(
                    'Devices is not able to Set Mode In Open/Close',
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 25.0),
                    child: TextButton(
                      onPressed: () {
                        setSov3Opneclose();
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Retry',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  setSov4Opneclose() {
    try {
      _response.clear();
      _serialData.clear();
      String data = "${'PFCMD6TYPE 4 1'.toUpperCase()}\r\n";
      _port!.write(Uint8List.fromList(data.codeUnits));
      new Future.delayed(Duration(seconds: 10)).whenComplete(() {
        if (_serialData.join(' ').toUpperCase().contains('PFCMD6TYPE 4 1')) {
          // print(_response);
          print("SOV 4 set to Open/Close mode");
        }
      });
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SizedBox(
              height: 260, //MediaQuery.of(context).size.height * 0.35,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    image: AssetImage('assets/images/wrong.gif'),
                    height: 120,
                    width: 120,
                  ),
                  Text(
                    'Command Revived Ended.',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                  Text(
                    'Devices is not able to Set Mode In Open/Close',
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 25.0),
                    child: TextButton(
                      onPressed: () {
                        setSov4Opneclose();
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Retry',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  setSov5Opneclose() {
    try {
      _response.clear();
      String data = "${'PFCMD6TYPE 5 1'.toUpperCase()}\r\n";
      _port!.write(Uint8List.fromList(data.codeUnits));
      new Future.delayed(Duration(seconds: 10)).whenComplete(() {
        if (_serialData.join(' ').toUpperCase().contains('PFCMD6TYPE 5 1')) {
          // print(_response);
          print("SOV 5 set to Open/Close mode");
        }
      });
      _response = [];
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SizedBox(
              height: 260, //MediaQuery.of(context).size.height * 0.35,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    image: AssetImage('assets/images/wrong.gif'),
                    height: 120,
                    width: 120,
                  ),
                  Text(
                    'Command Revived Ended.',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                  Text(
                    'Devices is not able to Set Mode In Open/Close',
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 25.0),
                    child: TextButton(
                      onPressed: () {
                        setSov5Opneclose();
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Retry',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  setSov6Opneclose() {
    try {
      _response.clear();
      String data = "${'PFCMD6TYPE 6 1'.toUpperCase()}\r\n";
      _port!.write(Uint8List.fromList(data.codeUnits));
      new Future.delayed(Duration(seconds: 10)).whenComplete(() {
        if (_serialData.join(' ').toUpperCase().contains('PFCMD6TYPE 6 1')) {
          // print(_response);
          print("SOV 6 set to Open/Close mode");
        }
      });
      _response = [];
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SizedBox(
              height: 260, //MediaQuery.of(context).size.height * 0.35,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    image: AssetImage('assets/images/wrong.gif'),
                    height: 120,
                    width: 120,
                  ),
                  Text(
                    'Command Revived Ended.',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                  Text(
                    'Devices is not able to Set Mode In Open/Close',
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 25.0),
                    child: TextButton(
                      onPressed: () {
                        setSov6Opneclose();
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Retry',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  setSov1SMode() async {
    try {
      _response.clear();
      _serialData.clear();
      String data = "${'SMODE 1 2 1 1'.toUpperCase()}\r\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 5)).whenComplete(
        () {
          String res = _serialData.join('');
          // print(res);
          if (_serialData.join(' ').toUpperCase().contains('SMODE 1 2 1 1')) {
            print("SOV 1 set to Open/Close mode");
          }
        },
      );
      _response = [];
    } catch (_, ex) {
      /*print(ex);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SizedBox(
              height: 260, //MediaQuery.of(context).size.height * 0.35,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    image: AssetImage('assets/images/wrong.gif'),
                    height: 120,
                    width: 120,
                  ),
                  Text(
                    'Command Revived Ended.',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                  Text(
                    'Devices is not able to Set Mode In Open/Close',
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 25.0),
                    child: TextButton(
                      onPressed: () {
                        setSov1Opneclose();
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Retry',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
     */
      _serialData.add('Please Try Again...');
    }
  }

  setSov2SMode() async {
    try {
      _response.clear();
      _serialData.clear();
      String data = "${'SMODE 2 2 1 1'.toUpperCase()}\r\n";
      _port!.write(Uint8List.fromList(data.codeUnits));
      new Future.delayed(Duration(seconds: 5)).whenComplete(() {
        // String res = _data.join('');
        if (_serialData.join(' ').toUpperCase().contains('SMODE 2 2 1 1')) {
          print("SOV 2 set to Open/Close mode");
        }
        _response = [];
      });
    } catch (e) {
      _serialData.add('Try Again ....');
      /*showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SizedBox(
              height: 260, //MediaQuery.of(context).size.height * 0.35,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    image: AssetImage('assets/images/wrong.gif'),
                    height: 120,
                    width: 120,
                  ),
                  Text(
                    'Command Revived Ended.',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                  Text(
                    'Devices is not able to Set Mode In Open/Close',
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 25.0),
                    child: TextButton(
                      onPressed: () {
                        setSov2Opneclose();
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Retry',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    */
    }
  }

  setSov3SMode() async {
    try {
      _response.clear();
      _serialData.clear();
      String data = "${'SMODE 3 2 1 1'.toUpperCase()}\r\n";
      _port!.write(Uint8List.fromList(data.codeUnits));
      new Future.delayed(Duration(seconds: 10)).whenComplete(() {
        if (_serialData.join(' ').toUpperCase().contains('SMODE 3 2 1 1')) {
          print(_response);
          print("SOV 3 set to Open/Close mode");
        }
      });
      _response = [];
    } catch (e) {
      _serialData.add('Try Again ....');
      /*showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SizedBox(
              height: 260, //MediaQuery.of(context).size.height * 0.35,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    image: AssetImage('assets/images/wrong.gif'),
                    height: 120,
                    width: 120,
                  ),
                  Text(
                    'Command Revived Ended.',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                  Text(
                    'Devices is not able to Set Mode In Open/Close',
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 25.0),
                    child: TextButton(
                      onPressed: () {
                        setSov3Opneclose();
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Retry',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    */
    }
  }

  setSov4SMode() {
    try {
      _response.clear();
      _serialData.clear();
      String data = "${'SMODE 4 2 1 1'.toUpperCase()}\r\n";
      _port!.write(Uint8List.fromList(data.codeUnits));
      new Future.delayed(Duration(seconds: 10)).whenComplete(() {
        if (_serialData.join(' ').toUpperCase().contains('SMODE 4 2 1 1')) {
          // print(_response);
          print("SOV 4 set to Open/Close mode");
        }
      });
    } catch (e) {
      _serialData.add('Try Again ....');
      /*showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SizedBox(
              height: 260, //MediaQuery.of(context).size.height * 0.35,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    image: AssetImage('assets/images/wrong.gif'),
                    height: 120,
                    width: 120,
                  ),
                  Text(
                    'Command Revived Ended.',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                  Text(
                    'Devices is not able to Set Mode In Open/Close',
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 25.0),
                    child: TextButton(
                      onPressed: () {
                        setSov4Opneclose();
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Retry',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    */
    }
  }

  setSov5SMode() {
    try {
      _response.clear();
      String data = "${'SMODE 5 2 1 1'.toUpperCase()}\r\n";
      _port!.write(Uint8List.fromList(data.codeUnits));
      new Future.delayed(Duration(seconds: 10)).whenComplete(() {
        if (_serialData.join(' ').toUpperCase().contains('SMODE 5 2 1 1')) {
          // print(_response);
          print("SOV 5 set to Open/Close mode");
        }
      });
      _response = [];
    } catch (e) {
      _serialData.add('Try Again ....');
      /*showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SizedBox(
              height: 260, //MediaQuery.of(context).size.height * 0.35,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    image: AssetImage('assets/images/wrong.gif'),
                    height: 120,
                    width: 120,
                  ),
                  Text(
                    'Command Revived Ended.',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                  Text(
                    'Devices is not able to Set Mode In Open/Close',
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 25.0),
                    child: TextButton(
                      onPressed: () {
                        setSov5Opneclose();
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Retry',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    */
    }
  }

  setSov6SMode() {
    try {
      _response.clear();
      String data = "${'SMODE 6 2 1 1'.toUpperCase()}\r\n";
      _port!.write(Uint8List.fromList(data.codeUnits));
      new Future.delayed(Duration(seconds: 10)).whenComplete(() {
        if (_serialData.join(' ').toUpperCase().contains('SMODE 6 2 1 1')) {
          // print(_response);
          print("SOV 6 set to Open/Close mode");
        }
      });
      _response = [];
    } catch (e) {
      _serialData.add('Try Again ....');
      /*showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SizedBox(
              height: 260, //MediaQuery.of(context).size.height * 0.35,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    image: AssetImage('assets/images/wrong.gif'),
                    height: 120,
                    width: 120,
                  ),
                  Text(
                    'Command Revived Ended.',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                  Text(
                    'Devices is not able to Set Mode In Open/Close',
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 25.0),
                    child: TextButton(
                      onPressed: () {
                        setSov6Opneclose();
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Retry',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    */
    }
  }

  void showSaveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Project Name',
                ),
                onChanged: (value) {
                  siteName = value;
                },
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Node No',
                ),
                onChanged: (value) {
                  nodeNo = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Submit'),
              onPressed: () {
                if (siteName.isEmpty || nodeNo.isEmpty) {
                  // Display an error message if any field is empty
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Error'),
                        content: Text('Please fill in all fields.'),
                        actions: [
                          TextButton(
                            child: Text('OK'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  _submitForm();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _submitForm() {
    final pdfWidgets.Document pdf = pdfWidgets.Document();
    pdf.addPage(pdfWidgets.Page(build: (context) {
      return pdfWidgets.Container(
        child: pdfWidgets.Column(
            mainAxisAlignment: pdfWidgets.MainAxisAlignment.start,
            crossAxisAlignment: pdfWidgets.CrossAxisAlignment.start,
            children: [
              pdfWidgets.Center(
                child: pdfWidgets.Text(
                  'Auto Dry Commissinning Report',
                  style: pdfWidgets.TextStyle(
                      fontSize: 24, fontWeight: pdfWidgets.FontWeight.bold),
                ),
              ),
              pdfWidgets.Divider(),
              pdfWidgets.Container(
                child: pdfWidgets.Column(
                  children: [
                    pdfWidgets.SizedBox(height: 10),
                    pdfWidgets.Row(
                      children: [
                        pdfWidgets.Text('Site Name :',
                            style: pdfWidgets.TextStyle(
                                fontWeight: pdfWidgets.FontWeight.bold)),
                        pdfWidgets.SizedBox(width: 20),
                        pdfWidgets.Text(siteName)
                      ],
                    ),
                    pdfWidgets.SizedBox(height: 10),
                    pdfWidgets.Row(
                      children: [
                        pdfWidgets.Text('Node No :',
                            style: pdfWidgets.TextStyle(
                                fontWeight: pdfWidgets.FontWeight.bold)),
                        pdfWidgets.SizedBox(width: 20),
                        pdfWidgets.Text(nodeNo)
                      ],
                    ),
                    pdfWidgets.SizedBox(height: 5),
                  ],
                ),
              ),
              pdfWidgets.Divider(),
              pdfWidgets.Container(
                width: 200,
                child: pdfWidgets.Column(
                  mainAxisAlignment: pdfWidgets.MainAxisAlignment.start,
                  crossAxisAlignment: pdfWidgets.CrossAxisAlignment.start,
                  children: [
                    pdfWidgets.Padding(
                      padding: const pdfWidgets.EdgeInsets.all(8.0),
                      child: pdfWidgets.Row(
                        mainAxisAlignment:
                            pdfWidgets.MainAxisAlignment.spaceBetween,
                        children: [
                          pdfWidgets.SizedBox(
                            child: pdfWidgets.Text(
                              'General Checks ',
                              style: pdfWidgets.TextStyle(
                                fontSize: 22,
                                fontWeight: pdfWidgets.FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    pdfWidgets.Padding(
                      padding: const pdfWidgets.EdgeInsets.all(8.0),
                      child: pdfWidgets.Row(
                        mainAxisAlignment:
                            pdfWidgets.MainAxisAlignment.spaceBetween,
                        children: [
                          pdfWidgets.SizedBox(
                            child: pdfWidgets.Text(
                              'Firmware Version :',
                              style: pdfWidgets.TextStyle(
                                fontWeight: pdfWidgets.FontWeight.bold,
                              ),
                            ),
                          ),
                          // Replace with your actual battery percentage

                          pdfWidgets.SizedBox(
                            child: pdfWidgets.Text(
                              '$firmwareversion',
                              style: pdfWidgets.TextStyle(
                                fontWeight: pdfWidgets.FontWeight.normal,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    pdfWidgets.Padding(
                      padding: const pdfWidgets.EdgeInsets.all(8.0),
                      child: pdfWidgets.Row(
                        mainAxisAlignment:
                            pdfWidgets.MainAxisAlignment.spaceBetween,
                        children: [
                          pdfWidgets.SizedBox(
                            child: pdfWidgets.Text(
                              'Mac ID :',
                              style: pdfWidgets.TextStyle(
                                fontWeight: pdfWidgets.FontWeight.bold,
                              ),
                            ),
                          ),
                          // Replace with your actual battery percentage

                          pdfWidgets.SizedBox(
                            child: pdfWidgets.Text(
                              macId,
                              style: pdfWidgets.TextStyle(
                                fontWeight: pdfWidgets.FontWeight.normal,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    pdfWidgets.Padding(
                      padding: const pdfWidgets.EdgeInsets.all(8.0),
                      child: pdfWidgets.Row(
                        mainAxisAlignment:
                            pdfWidgets.MainAxisAlignment.spaceBetween,
                        children: [
                          pdfWidgets.SizedBox(
                            child: pdfWidgets.Text(
                              'Battery Voltage :',
                              style: pdfWidgets.TextStyle(
                                fontWeight: pdfWidgets.FontWeight.bold,
                              ),
                            ),
                          ),
                          // Replace with your actual battery percentage

                          pdfWidgets.SizedBox(
                            child: pdfWidgets.Text(
                              '$batteryVoltage V',
                              style: pdfWidgets.TextStyle(
                                fontWeight: pdfWidgets.FontWeight.normal,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    pdfWidgets.Padding(
                      padding: const pdfWidgets.EdgeInsets.all(8.0),
                      child: pdfWidgets.Row(
                        mainAxisAlignment:
                            pdfWidgets.MainAxisAlignment.spaceBetween,
                        children: [
                          pdfWidgets.SizedBox(
                            child: pdfWidgets.Text(
                              'Solar Voltage :',
                              style: pdfWidgets.TextStyle(
                                fontWeight: pdfWidgets.FontWeight.bold,
                              ),
                            ),
                          ),
                          // Replace with your actual battery percentage

                          pdfWidgets.SizedBox(
                            child: pdfWidgets.Text(
                              '$solarVoltage V',
                              style: pdfWidgets.TextStyle(
                                fontWeight: pdfWidgets.FontWeight.normal,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    pdfWidgets.Padding(
                      padding: const pdfWidgets.EdgeInsets.all(8.0),
                      child: pdfWidgets.Row(
                        mainAxisAlignment:
                            pdfWidgets.MainAxisAlignment.spaceBetween,
                        children: [
                          pdfWidgets.SizedBox(
                            // color: Colors.blue,
                            child: pdfWidgets.Text(
                              'Door 1 :',
                              style: pdfWidgets.TextStyle(
                                fontWeight: pdfWidgets.FontWeight.bold,
                              ),
                            ),
                          ),
                          pdfWidgets.SizedBox(
                            child: pdfWidgets.Text(
                              Door1 ?? '',
                              style: pdfWidgets.TextStyle(
                                fontWeight: pdfWidgets.FontWeight.normal,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    pdfWidgets.Padding(
                      padding: const pdfWidgets.EdgeInsets.all(8.0),
                      child: pdfWidgets.Row(
                        mainAxisAlignment:
                            pdfWidgets.MainAxisAlignment.spaceBetween,
                        children: [
                          pdfWidgets.SizedBox(
                            // color: Colors.blue,
                            child: pdfWidgets.Text(
                              'Door 2 :',
                              style: pdfWidgets.TextStyle(
                                fontWeight: pdfWidgets.FontWeight.bold,
                              ),
                            ),
                          ),
                          pdfWidgets.SizedBox(
                            child: pdfWidgets.Text(
                              Door2 ?? '',
                              style: pdfWidgets.TextStyle(
                                fontWeight: pdfWidgets.FontWeight.normal,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              pdfWidgets.Container(
                width: 200,
                child: pdfWidgets.Column(
                  mainAxisAlignment: pdfWidgets.MainAxisAlignment.start,
                  crossAxisAlignment: pdfWidgets.CrossAxisAlignment.start,
                  children: [
                    pdfWidgets.Padding(
                      padding: const pdfWidgets.EdgeInsets.all(8.0),
                      child: pdfWidgets.Row(
                        mainAxisAlignment:
                            pdfWidgets.MainAxisAlignment.spaceBetween,
                        children: [
                          pdfWidgets.SizedBox(
                            child: pdfWidgets.Text(
                              'Lora Communication Check',
                              style: pdfWidgets.TextStyle(
                                fontSize: 22,
                                fontWeight: pdfWidgets.FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    pdfWidgets.Padding(
                      padding: const pdfWidgets.EdgeInsets.all(8.0),
                      child: pdfWidgets.Row(
                        mainAxisAlignment:
                            pdfWidgets.MainAxisAlignment.spaceBetween,
                        children: [
                          pdfWidgets.SizedBox(
                            child: pdfWidgets.Text(
                              'Lora Communication :',
                              style: pdfWidgets.TextStyle(
                                fontWeight: pdfWidgets.FontWeight.bold,
                              ),
                            ),
                          ),
                          pdfWidgets.SizedBox(
                            child: pdfWidgets.Text(
                              lora_comm,
                              style: pdfWidgets.TextStyle(
                                fontWeight: pdfWidgets.FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              pdfWidgets.Padding(
                padding: const pdfWidgets.EdgeInsets.all(8.0),
                child: pdfWidgets.Container(
                  decoration: pdfWidgets.BoxDecoration(
                      borderRadius: pdfWidgets.BorderRadius.circular(5)),
                  width: double.infinity,
                  child: pdfWidgets.Padding(
                    padding: const pdfWidgets.EdgeInsets.all(8.0),
                    child: pdfWidgets.Text(
                      'Inlet PT Valve Test',
                      style: pdfWidgets.TextStyle(
                        fontSize: 22,
                        fontWeight: pdfWidgets.FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              pdfWidgets.Padding(
                padding: const pdfWidgets.EdgeInsets.all(8),
                child: pdfWidgets.Table(
                  border: pdfWidgets.TableBorder.all(
                      width: 1, color: PdfColors.black),
                  children: [
                    pdfWidgets.TableRow(
                      children: [
                        pdfWidgets.Expanded(
                          flex: 1,
                          child: pdfWidgets.Container(
                            height: 20,
                            alignment: pdfWidgets.Alignment.center,
                            child: pdfWidgets.Text('PT Name',
                                style: pdfWidgets.TextStyle(
                                    fontWeight: pdfWidgets.FontWeight.bold)),
                          ),
                        ),
                        pdfWidgets.Expanded(
                          flex: 1,
                          child: pdfWidgets.Container(
                            height: 20,
                            alignment: pdfWidgets.Alignment.center,
                            child: pdfWidgets.Text('Pressure',
                                style: pdfWidgets.TextStyle(
                                    fontWeight: pdfWidgets.FontWeight.bold)),
                          ),
                        ),
                        pdfWidgets.Expanded(
                          flex: 1,
                          child: pdfWidgets.Container(
                            height: 20,
                            alignment: pdfWidgets.Alignment.center,
                            child: pdfWidgets.Text('Technician Remark',
                                style: pdfWidgets.TextStyle(
                                    fontWeight: pdfWidgets.FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                    pdfWidgets.TableRow(
                      children: [
                        pdfWidgets.Expanded(
                          flex: 1,
                          child: pdfWidgets.Container(
                            height: 20,
                            alignment: pdfWidgets.Alignment.center,
                            child: pdfWidgets.Text(
                                '${pfcmcdType == 1 ? "Filter Inlet PT" : "Inlet PT"}'),
                          ),
                        ),
                        pdfWidgets.Expanded(
                          flex: 1,
                          child: pdfWidgets.Container(
                            height: 20,
                            alignment: pdfWidgets.Alignment.center,
                            child: pdfWidgets.Text(
                              '${filterInlet.toString()} bar',
                            ),
                          ),
                        ),
                        /*pdfWidgets.Expanded(
                          flex: 1,
                          child: pdfWidgets.Container(
                            height: 20,
                            alignment: pdfWidgets.Alignment.center,
                            child: pdfWidgets.Text(
                              '${aibarvalue.toString()} bar',
                            ),
                          ),
                        ),*/
                        pdfWidgets.Expanded(
                          flex: 1,
                          child: pdfWidgets.Container(
                            height: 20,
                            alignment: pdfWidgets.Alignment.center,
                            child: pdfWidgets.Text(InletButton),
                          ),
                        ),
                      ],
                    ),
                    pdfWidgets.TableRow(
                      children: [
                        pdfWidgets.Expanded(
                          flex: 1,
                          child: pdfWidgets.Container(
                            height: 20,
                            alignment: pdfWidgets.Alignment.center,
                            child: pdfWidgets.Text(
                                "${pfcmcdType == 1 ? 'Flter Outlet PT' : 'Outlet PT'}"),
                          ),
                        ),
                        pdfWidgets.Expanded(
                          flex: 1,
                          child: pdfWidgets.Container(
                            height: 20,
                            alignment: pdfWidgets.Alignment.center,
                            child: pdfWidgets.Text(
                              '${filterOutlet.toString()} bar',
                            ),
                          ),
                        ),
                        pdfWidgets.Expanded(
                          flex: 1,
                          child: pdfWidgets.Container(
                            height: 20,
                            alignment: pdfWidgets.Alignment.center,
                            child: pdfWidgets.Text(OutletButton),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              /* pdfWidgets.Padding(
                  padding: const pdfWidgets.EdgeInsets.all(8.0),
                  child: pdfWidgets.Container(
                    width: double.infinity,
                    child: pdfWidgets.Padding(
                      padding: const pdfWidgets.EdgeInsets.all(8.0),
                      child: pdfWidgets.Text(
                        'Solenoid Testing',
                        style: pdfWidgets.TextStyle(
                          fontSize: 22,
                          fontWeight: pdfWidgets.FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                pdfWidgets.Padding(
                  padding: const pdfWidgets.EdgeInsets.all(8),
                  child: pdfWidgets.Table(
                    border: pdfWidgets.TableBorder.all(
                      color: PdfColors.black,
                      width: 1,
                      style: pdfWidgets.BorderStyle.solid,
                    ),
                    children: [
                      pdfWidgets.TableRow(
                        children: [
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text('Command',
                                  style: pdfWidgets.TextStyle(
                                      fontWeight: pdfWidgets.FontWeight.bold)),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text('Output',
                                  style: pdfWidgets.TextStyle(
                                      fontWeight: pdfWidgets.FontWeight.bold)),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text('Technician Remark',
                                  style: pdfWidgets.TextStyle(
                                      fontWeight: pdfWidgets.FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                      //PFCMD 1
                      pdfWidgets.TableRow(
                        children: [
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              width: 50,
                              child: pdfWidgets.Center(
                                child: pdfWidgets.Text(
                                  'OPEN',
                                ),
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              width: 50,
                              child: pdfWidgets.Center(
                                child: pdfWidgets.Text(
                                  '${openvalpos1.toString()} %',
                                ),
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Row(
                              mainAxisAlignment:
                                  pdfWidgets.MainAxisAlignment.center,
                              children: [
                                pdfWidgets.Container(
                                  height: 20,
                                  width: 50,
                                  child: pdfWidgets.Center(
                                      child: pdfWidgets.Text(OpenBtn)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      pdfWidgets.TableRow(
                        children: [
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              width: 50,
                              child: pdfWidgets.Center(
                                child: pdfWidgets.Text(
                                  'CLOSE',
                                ),
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              width: 50,
                              child: pdfWidgets.Center(
                                child: pdfWidgets.Text(
                                  '${closevalpos1.toString()} %',
                                ),
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Row(
                              mainAxisAlignment:
                                  pdfWidgets.MainAxisAlignment.center,
                              children: [
                                pdfWidgets.Container(
                                  height: 20,
                                  width: 50,
                                  child: pdfWidgets.Center(
                                      child: pdfWidgets.Text(CloseBtn)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      //PFCMD 2
                      pdfWidgets.TableRow(
                        children: [
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              width: 50,
                              child: pdfWidgets.Center(
                                child: pdfWidgets.Text(
                                  'OPEN',
                                ),
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              width: 50,
                              child: pdfWidgets.Center(
                                child: pdfWidgets.Text(
                                  '${openvalpos2.toString()} %',
                                ),
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Row(
                              mainAxisAlignment:
                                  pdfWidgets.MainAxisAlignment.center,
                              children: [
                                pdfWidgets.Container(
                                  height: 20,
                                  width: 50,
                                  child: pdfWidgets.Center(
                                      child: pdfWidgets.Text(OpenBtn)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      pdfWidgets.TableRow(
                        children: [
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              width: 50,
                              child: pdfWidgets.Center(
                                child: pdfWidgets.Text(
                                  'CLOSE',
                                ),
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              width: 50,
                              child: pdfWidgets.Center(
                                child: pdfWidgets.Text(
                                  '${closevalpos2.toString()} %',
                                ),
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Row(
                              mainAxisAlignment:
                                  pdfWidgets.MainAxisAlignment.center,
                              children: [
                                pdfWidgets.Container(
                                  height: 20,
                                  width: 50,
                                  child: pdfWidgets.Center(
                                      child: pdfWidgets.Text(CloseBtn)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // PFCMD 3
                      pdfWidgets.TableRow(
                        children: [
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              width: 50,
                              child: pdfWidgets.Center(
                                child: pdfWidgets.Text(
                                  'OPEN',
                                ),
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              width: 50,
                              child: pdfWidgets.Center(
                                child: pdfWidgets.Text(
                                  '${openvalpos3.toString()} %',
                                ),
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Row(
                              mainAxisAlignment:
                                  pdfWidgets.MainAxisAlignment.center,
                              children: [
                                pdfWidgets.Container(
                                  height: 20,
                                  width: 50,
                                  child: pdfWidgets.Center(
                                      child: pdfWidgets.Text(OpenBtn)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      pdfWidgets.TableRow(
                        children: [
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              width: 50,
                              child: pdfWidgets.Center(
                                child: pdfWidgets.Text(
                                  'CLOSE',
                                ),
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              width: 50,
                              child: pdfWidgets.Center(
                                child: pdfWidgets.Text(
                                  '${closevalpos3.toString()} %',
                                ),
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Row(
                              mainAxisAlignment:
                                  pdfWidgets.MainAxisAlignment.center,
                              children: [
                                pdfWidgets.Container(
                                  height: 20,
                                  width: 50,
                                  child: pdfWidgets.Center(
                                      child: pdfWidgets.Text(CloseBtn)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      //PFCMD 4
                      pdfWidgets.TableRow(
                        children: [
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              width: 50,
                              child: pdfWidgets.Center(
                                child: pdfWidgets.Text(
                                  'OPEN',
                                ),
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              width: 50,
                              child: pdfWidgets.Center(
                                child: pdfWidgets.Text(
                                  '${openvalpos4.toString()} %',
                                ),
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Row(
                              mainAxisAlignment:
                                  pdfWidgets.MainAxisAlignment.center,
                              children: [
                                pdfWidgets.Container(
                                  height: 20,
                                  width: 50,
                                  child: pdfWidgets.Center(
                                      child: pdfWidgets.Text(OpenBtn)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      pdfWidgets.TableRow(
                        children: [
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              width: 50,
                              child: pdfWidgets.Center(
                                child: pdfWidgets.Text(
                                  'CLOSE',
                                ),
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              width: 50,
                              child: pdfWidgets.Center(
                                child: pdfWidgets.Text(
                                  '${closevalpos4.toString()} %',
                                ),
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Row(
                              mainAxisAlignment:
                                  pdfWidgets.MainAxisAlignment.center,
                              children: [
                                pdfWidgets.Container(
                                  height: 20,
                                  width: 50,
                                  child: pdfWidgets.Center(
                                      child: pdfWidgets.Text(CloseBtn)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      //PFCMD 5
                      pdfWidgets.TableRow(
                        children: [
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              width: 50,
                              child: pdfWidgets.Center(
                                child: pdfWidgets.Text(
                                  'OPEN',
                                ),
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              width: 50,
                              child: pdfWidgets.Center(
                                child: pdfWidgets.Text(
                                  '${openvalpos5.toString()} %',
                                ),
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Row(
                              mainAxisAlignment:
                                  pdfWidgets.MainAxisAlignment.center,
                              children: [
                                pdfWidgets.Container(
                                  height: 20,
                                  width: 50,
                                  child: pdfWidgets.Center(
                                      child: pdfWidgets.Text(OpenBtn)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      pdfWidgets.TableRow(
                        children: [
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              width: 50,
                              child: pdfWidgets.Center(
                                child: pdfWidgets.Text(
                                  'CLOSE',
                                ),
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              width: 50,
                              child: pdfWidgets.Center(
                                child: pdfWidgets.Text(
                                  '${closevalpos5.toString()} %',
                                ),
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Row(
                              mainAxisAlignment:
                                  pdfWidgets.MainAxisAlignment.center,
                              children: [
                                pdfWidgets.Container(
                                  height: 20,
                                  width: 50,
                                  child: pdfWidgets.Center(
                                      child: pdfWidgets.Text(CloseBtn)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // PFCMD 6
                      pdfWidgets.TableRow(
                        children: [
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              width: 50,
                              child: pdfWidgets.Center(
                                child: pdfWidgets.Text(
                                  'OPEN',
                                ),
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              width: 50,
                              child: pdfWidgets.Center(
                                child: pdfWidgets.Text(
                                  '${openvalpos6.toString()} %',
                                ),
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Row(
                              mainAxisAlignment:
                                  pdfWidgets.MainAxisAlignment.center,
                              children: [
                                pdfWidgets.Container(
                                  height: 20,
                                  width: 50,
                                  child: pdfWidgets.Center(
                                      child: pdfWidgets.Text(OpenBtn)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      pdfWidgets.TableRow(
                        children: [
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              width: 50,
                              child: pdfWidgets.Center(
                                child: pdfWidgets.Text(
                                  'CLOSE',
                                ),
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              width: 50,
                              child: pdfWidgets.Center(
                                child: pdfWidgets.Text(
                                  '${closevalpos6.toString()} %',
                                ),
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Row(
                              mainAxisAlignment:
                                  pdfWidgets.MainAxisAlignment.center,
                              children: [
                                pdfWidgets.Container(
                                  height: 20,
                                  width: 50,
                                  child: pdfWidgets.Center(
                                      child: pdfWidgets.Text(CloseBtn)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                pdfWidgets.Divider(),
                pdfWidgets.Row(
                  children: [
                    pdfWidgets.Text('Done By:  ',
                        style: pdfWidgets.TextStyle(
                            fontWeight: pdfWidgets.FontWeight.bold)),
                    pdfWidgets.Text(username?? "")
                  ],
                ),
                pdfWidgets.SizedBox(height: 10),
                pdfWidgets.Row(
                  children: [
                    pdfWidgets.Text('Date: ',
                        style: pdfWidgets.TextStyle(
                            fontWeight: pdfWidgets.FontWeight.bold)),
                    pdfWidgets.Text(Cdate?? "")
                  ],
                ),
             */
            ]),
      );
    }));
    pdf.addPage(pdfWidgets.Page(build: (context) {
      return pdfWidgets.Container(
        child: pdfWidgets.Column(
            mainAxisAlignment: pdfWidgets.MainAxisAlignment.start,
            crossAxisAlignment: pdfWidgets.CrossAxisAlignment.start,
            children: [
              if (pfcmcdType == 1)
                pdfWidgets.Padding(
                  padding: const pdfWidgets.EdgeInsets.all(8.0),
                  child: pdfWidgets.Container(
                    decoration: pdfWidgets.BoxDecoration(
                        borderRadius: pdfWidgets.BorderRadius.circular(5)),
                    width: double.infinity,
                    child: pdfWidgets.Padding(
                      padding: const pdfWidgets.EdgeInsets.all(8.0),
                      child: pdfWidgets.Text(
                        'Outlet PT Valve Test',
                        style: pdfWidgets.TextStyle(
                          fontSize: 22,
                          fontWeight: pdfWidgets.FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              if (pfcmcdType == 1)
                pdfWidgets.Padding(
                  padding: const pdfWidgets.EdgeInsets.all(8),
                  child: pdfWidgets.Table(
                    border: pdfWidgets.TableBorder.all(
                        width: 1, color: PdfColors.black),
                    children: [
                      pdfWidgets.TableRow(
                        children: [
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text('PT Name',
                                  style: pdfWidgets.TextStyle(
                                      fontWeight: pdfWidgets.FontWeight.bold)),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text('Pressure',
                                  style: pdfWidgets.TextStyle(
                                      fontWeight: pdfWidgets.FontWeight.bold)),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text('Technician Remark',
                                  style: pdfWidgets.TextStyle(
                                      fontWeight: pdfWidgets.FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                      pdfWidgets.TableRow(
                        children: [
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text('Outlet PT 1'),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                '${outlet_1_actual_count_controller.toString()} bar',
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(PFCMD1),
                            ),
                          ),
                        ],
                      ),
                      pdfWidgets.TableRow(
                        children: [
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text('Outlet PT 2'),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                '${outlet_2_actual_count_after_controller?.toString() ?? ''} bar',
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(PFCMD2.toString()),
                            ),
                          ),
                        ],
                      ),
                      pdfWidgets.TableRow(
                        children: [
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text('Outlet PT 3'),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                '${outlet_3_actual_count_controller?.toString() ?? ''} bar',
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(PFCMD3.toString()),
                            ),
                          ),
                        ],
                      ),
                      pdfWidgets.TableRow(
                        children: [
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text('Outlet PT 4'),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                '${outlet_4_actual_count_controller?.toString() ?? ''} bar',
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(PFCMD4.toString()),
                            ),
                          ),
                        ],
                      ),
                      pdfWidgets.TableRow(
                        children: [
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text('Outlet PT 5'),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                '${outlet_5_actual_count_controller?.toString() ?? ''} bar',
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(PFCMD5.toString()),
                            ),
                          ),
                        ],
                      ),
                      pdfWidgets.TableRow(
                        children: [
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text('Outlet PT 6'),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                '${outlet_6_actual_count_controller?.toString() ?? ''} bar',
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(PFCMD6.toString()),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              pdfWidgets.Padding(
                padding: const pdfWidgets.EdgeInsets.all(8.0),
                child: pdfWidgets.Container(
                  decoration: pdfWidgets.BoxDecoration(
                      borderRadius: pdfWidgets.BorderRadius.circular(5)),
                  width: double.infinity,
                  child: pdfWidgets.Padding(
                    padding: const pdfWidgets.EdgeInsets.all(8.0),
                    child: pdfWidgets.Text(
                      'Position Sensor Test',
                      style: pdfWidgets.TextStyle(
                        fontSize: 22,
                        fontWeight: pdfWidgets.FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              pdfWidgets.Padding(
                padding: const pdfWidgets.EdgeInsets.all(8),
                child: pdfWidgets.Table(
                  border: pdfWidgets.TableBorder.all(
                      width: 1, color: PdfColors.black),
                  children: [
                    pdfWidgets.TableRow(
                      children: [
                        pdfWidgets.Expanded(
                          flex: 1,
                          child: pdfWidgets.Container(
                            height: 20,
                            alignment: pdfWidgets.Alignment.center,
                            child: pdfWidgets.Text('Position Sensor',
                                style: pdfWidgets.TextStyle(
                                    fontWeight: pdfWidgets.FontWeight.bold)),
                          ),
                        ),
                        pdfWidgets.Expanded(
                          flex: 1,
                          child: pdfWidgets.Container(
                            height: 20,
                            alignment: pdfWidgets.Alignment.center,
                            child: pdfWidgets.Text('Value',
                                style: pdfWidgets.TextStyle(
                                    fontWeight: pdfWidgets.FontWeight.bold)),
                          ),
                        ),
                        pdfWidgets.Expanded(
                          flex: 1,
                          child: pdfWidgets.Container(
                            height: 20,
                            alignment: pdfWidgets.Alignment.center,
                            child: pdfWidgets.Text('Remark',
                                style: pdfWidgets.TextStyle(
                                    fontWeight: pdfWidgets.FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                    pdfWidgets.TableRow(
                      children: [
                        pdfWidgets.Expanded(
                          flex: 1,
                          child: pdfWidgets.Container(
                            height: 20,
                            alignment: pdfWidgets.Alignment.center,
                            child: pdfWidgets.Text('Position Sensor 1'),
                          ),
                        ),
                        pdfWidgets.Expanded(
                          flex: 1,
                          child: pdfWidgets.Container(
                            height: 20,
                            alignment: pdfWidgets.Alignment.center,
                            child: pdfWidgets.Text(
                              '${posval1.toString()} %',
                            ),
                          ),
                        ),
                        pdfWidgets.Expanded(
                          flex: 1,
                          child: pdfWidgets.Container(
                            height: 20,
                            alignment: pdfWidgets.Alignment.center,
                            child: pdfWidgets.Text(pos1 ?? ''),
                          ),
                        ),
                      ],
                    ),
                    pdfWidgets.TableRow(
                      children: [
                        pdfWidgets.Expanded(
                          flex: 1,
                          child: pdfWidgets.Container(
                            height: 20,
                            alignment: pdfWidgets.Alignment.center,
                            child: pdfWidgets.Text('Position Sensor 2'),
                          ),
                        ),
                        pdfWidgets.Expanded(
                          flex: 1,
                          child: pdfWidgets.Container(
                            height: 20,
                            alignment: pdfWidgets.Alignment.center,
                            child: pdfWidgets.Text(
                              '${posval2?.toString() ?? ''} %',
                            ),
                          ),
                        ),
                        pdfWidgets.Expanded(
                          flex: 1,
                          child: pdfWidgets.Container(
                            height: 20,
                            alignment: pdfWidgets.Alignment.center,
                            child: pdfWidgets.Text(pos2 ?? ''),
                          ),
                        ),
                      ],
                    ),
                    pdfWidgets.TableRow(
                      children: [
                        pdfWidgets.Expanded(
                          flex: 1,
                          child: pdfWidgets.Container(
                            height: 20,
                            alignment: pdfWidgets.Alignment.center,
                            child: pdfWidgets.Text('Position Sensor 3'),
                          ),
                        ),
                        pdfWidgets.Expanded(
                          flex: 1,
                          child: pdfWidgets.Container(
                            height: 20,
                            alignment: pdfWidgets.Alignment.center,
                            child: pdfWidgets.Text(
                              '${posval3?.toString() ?? ''} %',
                            ),
                          ),
                        ),
                        pdfWidgets.Expanded(
                          flex: 1,
                          child: pdfWidgets.Container(
                            height: 20,
                            alignment: pdfWidgets.Alignment.center,
                            child: pdfWidgets.Text(pos3 ?? ''),
                          ),
                        ),
                      ],
                    ),
                    pdfWidgets.TableRow(
                      children: [
                        pdfWidgets.Expanded(
                          flex: 1,
                          child: pdfWidgets.Container(
                            height: 20,
                            alignment: pdfWidgets.Alignment.center,
                            child: pdfWidgets.Text('Position Sensor 4'),
                          ),
                        ),
                        pdfWidgets.Expanded(
                          flex: 1,
                          child: pdfWidgets.Container(
                            height: 20,
                            alignment: pdfWidgets.Alignment.center,
                            child: pdfWidgets.Text(
                              '${posval4?.toString() ?? ''} %',
                            ),
                          ),
                        ),
                        pdfWidgets.Expanded(
                          flex: 1,
                          child: pdfWidgets.Container(
                            height: 20,
                            alignment: pdfWidgets.Alignment.center,
                            child: pdfWidgets.Text(pos4 ?? ''),
                          ),
                        ),
                      ],
                    ),
                    pdfWidgets.TableRow(
                      children: [
                        pdfWidgets.Expanded(
                          flex: 1,
                          child: pdfWidgets.Container(
                            height: 20,
                            alignment: pdfWidgets.Alignment.center,
                            child: pdfWidgets.Text('Position Sensor 5'),
                          ),
                        ),
                        pdfWidgets.Expanded(
                          flex: 1,
                          child: pdfWidgets.Container(
                            height: 20,
                            alignment: pdfWidgets.Alignment.center,
                            child: pdfWidgets.Text(
                              '${posval5?.toString() ?? ''} %',
                            ),
                          ),
                        ),
                        pdfWidgets.Expanded(
                          flex: 1,
                          child: pdfWidgets.Container(
                            height: 20,
                            alignment: pdfWidgets.Alignment.center,
                            child: pdfWidgets.Text(pos5 ?? ''),
                          ),
                        ),
                      ],
                    ),
                    pdfWidgets.TableRow(
                      children: [
                        pdfWidgets.Expanded(
                          flex: 1,
                          child: pdfWidgets.Container(
                            height: 20,
                            alignment: pdfWidgets.Alignment.center,
                            child: pdfWidgets.Text('Position Sensor 6'),
                          ),
                        ),
                        pdfWidgets.Expanded(
                          flex: 1,
                          child: pdfWidgets.Container(
                            height: 20,
                            alignment: pdfWidgets.Alignment.center,
                            child: pdfWidgets.Text(
                              '${posval6?.toString() ?? ''} %',
                            ),
                          ),
                        ),
                        pdfWidgets.Expanded(
                          flex: 1,
                          child: pdfWidgets.Container(
                            height: 20,
                            alignment: pdfWidgets.Alignment.center,
                            child: pdfWidgets.Text(pos6 ?? ''),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pdfWidgets.Padding(
                padding: const pdfWidgets.EdgeInsets.all(8.0),
                child: pdfWidgets.Container(
                  width: double.infinity,
                  child: pdfWidgets.Padding(
                    padding: const pdfWidgets.EdgeInsets.all(8.0),
                    child: pdfWidgets.Text(
                      'Solenoid Testing',
                      style: pdfWidgets.TextStyle(
                        fontSize: 22,
                        fontWeight: pdfWidgets.FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              pdfWidgets.Padding(
                padding: const pdfWidgets.EdgeInsets.all(8),
                child: pdfWidgets.Table(
                  border: pdfWidgets.TableBorder.all(
                    color: PdfColors.black,
                    width: 1,
                    style: pdfWidgets.BorderStyle.solid,
                  ),
                  children: [
                    pdfWidgets.TableRow(
                      children: [
                        pdfWidgets.Expanded(
                          flex: 1,
                          child: pdfWidgets.Container(
                            height: 20,
                            alignment: pdfWidgets.Alignment.center,
                            child: pdfWidgets.Text('Solenoid',
                                style: pdfWidgets.TextStyle(
                                    fontWeight: pdfWidgets.FontWeight.bold)),
                          ),
                        ),
                        pdfWidgets.Expanded(
                          flex: 1,
                          child: pdfWidgets.Container(
                            height: 20,
                            alignment: pdfWidgets.Alignment.center,
                            child: pdfWidgets.Text('Technician Remark',
                                style: pdfWidgets.TextStyle(
                                    fontWeight: pdfWidgets.FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                    //PFCMD 1
                    pdfWidgets.TableRow(
                      children: [
                        pdfWidgets.Expanded(
                          flex: 1,
                          child: pdfWidgets.Container(
                            height: 20,
                            width: 50,
                            child: pdfWidgets.Center(
                              child: pdfWidgets.Text(
                                'SOV 1',
                              ),
                            ),
                          ),
                        ),
                        pdfWidgets.Expanded(
                          flex: 1,
                          child: pdfWidgets.Row(
                            mainAxisAlignment:
                                pdfWidgets.MainAxisAlignment.center,
                            children: [
                              pdfWidgets.Container(
                                height: 20,
                                width: 50,
                                child: pdfWidgets.Center(
                                    child: pdfWidgets.Text(sov1 ?? '')),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    pdfWidgets.TableRow(
                      children: [
                        pdfWidgets.Expanded(
                          flex: 1,
                          child: pdfWidgets.Container(
                            height: 20,
                            width: 50,
                            child: pdfWidgets.Center(
                              child: pdfWidgets.Text(
                                'SOV 2',
                              ),
                            ),
                          ),
                        ),
                        pdfWidgets.Expanded(
                          flex: 1,
                          child: pdfWidgets.Row(
                            mainAxisAlignment:
                                pdfWidgets.MainAxisAlignment.center,
                            children: [
                              pdfWidgets.Container(
                                height: 20,
                                width: 50,
                                child: pdfWidgets.Center(
                                    child: pdfWidgets.Text(sov2 ?? '')),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // PFCMD 3
                    pdfWidgets.TableRow(
                      children: [
                        pdfWidgets.Expanded(
                          flex: 1,
                          child: pdfWidgets.Container(
                            height: 20,
                            width: 50,
                            child: pdfWidgets.Center(
                              child: pdfWidgets.Text(
                                'SOV 3',
                              ),
                            ),
                          ),
                        ),
                        pdfWidgets.Expanded(
                          flex: 1,
                          child: pdfWidgets.Row(
                            mainAxisAlignment:
                                pdfWidgets.MainAxisAlignment.center,
                            children: [
                              pdfWidgets.Container(
                                height: 20,
                                width: 50,
                                child: pdfWidgets.Center(
                                    child: pdfWidgets.Text(sov3 ?? '')),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    pdfWidgets.TableRow(
                      children: [
                        pdfWidgets.Expanded(
                          flex: 1,
                          child: pdfWidgets.Container(
                            height: 20,
                            width: 50,
                            child: pdfWidgets.Center(
                              child: pdfWidgets.Text(
                                'SOV 4',
                              ),
                            ),
                          ),
                        ),
                        pdfWidgets.Expanded(
                          flex: 1,
                          child: pdfWidgets.Row(
                            mainAxisAlignment:
                                pdfWidgets.MainAxisAlignment.center,
                            children: [
                              pdfWidgets.Container(
                                height: 20,
                                width: 50,
                                child: pdfWidgets.Center(
                                    child: pdfWidgets.Text(sov4 ?? '')),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    pdfWidgets.TableRow(
                      children: [
                        pdfWidgets.Expanded(
                          flex: 1,
                          child: pdfWidgets.Container(
                            height: 20,
                            width: 50,
                            child: pdfWidgets.Center(
                              child: pdfWidgets.Text(
                                'SOV 5',
                              ),
                            ),
                          ),
                        ),
                        pdfWidgets.Expanded(
                          flex: 1,
                          child: pdfWidgets.Row(
                            mainAxisAlignment:
                                pdfWidgets.MainAxisAlignment.center,
                            children: [
                              pdfWidgets.Container(
                                height: 20,
                                width: 50,
                                child: pdfWidgets.Center(
                                    child: pdfWidgets.Text(sov5 ?? '')),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    pdfWidgets.TableRow(
                      children: [
                        pdfWidgets.Expanded(
                          flex: 1,
                          child: pdfWidgets.Container(
                            height: 20,
                            width: 50,
                            child: pdfWidgets.Center(
                              child: pdfWidgets.Text(
                                'SOV 6',
                              ),
                            ),
                          ),
                        ),
                        pdfWidgets.Expanded(
                          flex: 1,
                          child: pdfWidgets.Row(
                            mainAxisAlignment:
                                pdfWidgets.MainAxisAlignment.center,
                            children: [
                              pdfWidgets.Container(
                                height: 20,
                                width: 50,
                                child: pdfWidgets.Center(
                                    child: pdfWidgets.Text(sov6 ?? '')),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pdfWidgets.Divider(),
              pdfWidgets.Row(
                children: [
                  pdfWidgets.Text('Done By:  ',
                      style: pdfWidgets.TextStyle(
                          fontWeight: pdfWidgets.FontWeight.bold)),
                  pdfWidgets.Text(username ?? "")
                ],
              ),
              pdfWidgets.SizedBox(height: 10),
              pdfWidgets.Row(
                children: [
                  pdfWidgets.Text('Date: ',
                      style: pdfWidgets.TextStyle(
                          fontWeight: pdfWidgets.FontWeight.bold)),
                  pdfWidgets.Text(Cdate ?? "")
                ],
              ),
            ]),
      );
    }));
    savePDF(pdf, context);

    // Save PDF to file
  }

  String? username;
  getusername() async {
    final sharePref = await SharedPreferences.getInstance();
    var user = sharePref.getString(Keys.user.name);
    if (user != null) {
      final userJson = json.decode(user);
      var newUser = LoginMasterModel.fromJson(userJson);
      // return newUser;
      username = newUser.fName;
    }
  }

  String? Cdate;
  getcurrentdate() async {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('d-MMM-y H:m:s');
    final String formatted = formatter.format(now);
    Cdate = formatted;
  }

  void savePDF(pdfWidgets.Document pdf, BuildContext context) async {
    // String downloadPath = '/storage/emulated/0/Download';
    final Directory? downloadPath = await getDownloadsDirectory();
    String pdfName = 'AutoDry ${nodeNo.trim()}-${siteName.trim()}.pdf';
    File file = File('${downloadPath?.path}/$pdfName');
    try {
      await file.writeAsBytes(await pdf.save());
      setState(() {
        filePath = file.path.replaceAll('/storage/emulated/0/', '');
      });
      print('PDF saved successfully');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('PDF Saved'),
            content: Text('The PDF was saved successfully.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  setState(() {
                    isSaved = true;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Error saving PDF: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('An error occurred while saving the PDF.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
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

  getSiteName() async {
    try {
      await Future.delayed(Duration(seconds: 5)).whenComplete(
        () async {
          String res = _serialData.join('');
          int i = res.indexOf("SI");
          controllerType = res.substring(i + 5, i + 13);
          if (controllerType!.toLowerCase().contains('boc')) {
            setState(() {
              controllerType = res.substring(i + 5, i + 13);
            });
            deviceType = _serialData.join();
            print('Controller Type :${controllerType ?? ""}');
            getMID();
          } else {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: SizedBox(
                    height: 260, //MediaQuery.of(context).size.height * 0.35,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image(
                          image: AssetImage('assets/images/wrong.gif'),
                          height: 120,
                          width: 120,
                        ),
                        Text(
                          'Invalid Site Name',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey),
                        ),
                        Text(
                          'You have connected to unknown device',
                          textAlign: TextAlign.center,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 25.0),
                          child: TextButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              String data = "${'SINM'.toUpperCase()}\r\n";
                              _response.clear();
                              _serialData.clear();
                              hexDecimalValue = '';
                              await _port!
                                  .write(Uint8List.fromList(data.codeUnits));

                              await getSiteName();
                            },
                            child: Text(
                              'Retry',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      );
      _response = [];
    } catch (_, ex) {
      _serialData.add('Please Try Again...');
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
