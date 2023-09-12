// ignore_for_file: prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, prefer_const_constructors, unused_field, non_constant_identifier_names, unused_local_variable, unused_catch_stack, file_names, prefer_final_fields, use_build_context_synchronously, prefer_typing_uninitialized_variables, avoid_print, sort_child_properties_last, depend_on_referenced_packages, unused_import, import_of_legacy_library_into_null_safe, void_checks, unnecessary_new

import 'dart:async';
import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_usb2/Screens/AutoCommisitoning/Timer.dart';
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
  List<String> _serialdata = [];
  List<String> _response = [];
  String btntxt = 'Connect';

  String valveOpen = '';
  String valveClose = '';

  String valveOpen2 = '';
  String valveClose2 = '';

  String valveOpen3 = '';
  String valveClose3 = '';

  String valveOpen4 = '';
  String valveClose4 = '';

  String valveOpen5 = '';
  String valveClose5 = '';

  String valveOpen6 = '';
  String valveClose6 = '';

  String InletButton = '';
  String OutletButton = '';

  String PFCMD1 = '';
  String PFCMD2 = '';
  String PFCMD3 = '';
  String PFCMD4 = '';
  String PFCMD5 = '';
  String PFCMD6 = '';
  int? index;
  String OpenBtn = '';
  String CloseBtn = '';
  String accept = '';
  String? controllerType;
  List<String> _serialData = [];
  List<String> _data = [];
  String? deviceType;
  bool isAccept = false;
  bool _buttonVisible = true;
  bool _buttonPressed = false;
  double _progress = 0.0;
  final _formKey = GlobalKey<FormState>();
  StreamSubscription<String>? _subscription;
  List<int> _dataBuffer = [];
  Transaction<String>? _transaction;
  StreamSubscription<Uint8List>? _dataSubscription;
  String Door1 = '';
  String Door2 = '';
  double batteryVoltage = 0.0;
  double solarVoltage = 0.0;
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

  double? aimAvalue;
  double? aibarvalue;
  double? ai2mAvalue;
  double? ai2barvalue;
  AnimationController? _animationController;
  bool blink = false;
  bool inlet_blink = false;
  bool outlet_blink = false;

  bool PFCMD1_blink = false;
  bool PFCMD2_blink = false;
  bool PFCMD3_blink = false;
  bool PFCMD4_blink = false;
  bool PFCMD5_blink = false;
  bool PFCMD6_blink = false;

  bool open1 = false;
  bool close1 = false;
  bool open2 = false;
  bool close2 = false;
  bool open3 = false;
  bool close3 = false;
  bool open4 = false;
  bool close4 = false;
  bool open5 = false;
  bool close5 = false;
  bool open6 = false;
  bool close6 = false;

  bool open_pos = false;
  bool close_pos = false;

  String btnstate = '';
  String deviceName = '';
  String siteName = '';
  String nodeNo = '';
  bool isTextVisible = false;
  bool isText2Visible = false;
  bool isText3Visible = false;
  bool isShowpop = false;

  // outlet pt
  double? outlet_1_value_controller;
  double? outlet_1_actual_count_controller;

// outlet pt 2
  double? outlet_2_value_after_controller;

  double? outlet_2_actual_count_after_controller;

  // outlet pt 3
  double? outlet_3_value_controller;
  double? outlet_3_actual_count_controller;

  // outlet pt 4
  double? outlet_4_value_controller;
  double? outlet_4_actual_count_controller;

  // outlet pt 6
  double? outlet_6_value_controller;
  double? outlet_6_actual_count_controller;

  // outlet pt 5
  double? outlet_5_value_controller;
  double? outlet_5_actual_count_controller;

  Future<bool> _connectTo(UsbDevice? device) async {
    _response.clear();
    _serialdata.clear();

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

  void onDataReceived(Uint8List data) {
    _dataBuffer.addAll(data);
    String completeMessage = String.fromCharCodes(_dataBuffer);
    String hexData = hex.encode(_dataBuffer);
    _dataBuffer.clear();
    setState(() {
      _response.add(hexData);
      _data.add(completeMessage);
    });
    print(_data.join());
    if (_data.join().contains('INTG')) {
      if (_data.join().contains('BOCOM1')) {
        hexDecimalValue =
            reverseString(reverseString(_response.join()).substring(0, 70));
      } else if (_data.join().contains('BOCOM6')) {
        print('New Data:${_data.join()}');
        hexDecimalValue =
            reverseString(reverseString(_response.join()).substring(0, 172));
      }
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

  var hexDecimalValue = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Auto Commistioing'),
      ),
      body: getBodyWidget(),
    );
  }

  Widget getBodyWidget() {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final device in _devices)
              Card(
                elevation: 2,
                color: Colors.blue.shade100,
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
            ElevatedButton(
              child: Text("SINM"),
              onPressed: _port == null
                  ? null
                  : () async {
                      if (_port == null) {
                        return;
                      }
                      _progress = 0.0;
                      _startTask(6).whenComplete(() => Navigator.pop(context));
                      getpop_loader(context);
                      String data = "${'SINM'.toUpperCase()}\r\n";
                      _response.clear();
                      _data.clear();
                      hexDecimalValue = '';
                      await _port!.write(Uint8List.fromList(data.codeUnits));
                      await getSiteName();
                      // await setDatetime().then((_) {
                      //   getINTG();
                      // });
                    },
            ),
            if (hexDecimalValue.isNotEmpty) infoCardWidget(),
          ],
        ),
      ),
    );
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
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Card(
                        elevation: 7,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
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
                                    child: lora_comm.isEmpty
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
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
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
                                    child: getBatterVoltage() == 0.0
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
                                            batteryVoltage.toString(),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
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
                                    child: getBatterVoltage() == 0.0
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
                                            getSOLARVoltage().toString(),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
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
                                    child: getBatterVoltage() == 0.0
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
                                            '$Door1',
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
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
                                    child: getBatterVoltage() == 0.0
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
                                            '$Door2',
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
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    child: Text("INTG"),
                                    onPressed: _port == null
                                        ? null
                                        : () async {
                                            if (_port == null) {
                                              return;
                                            }
                                            _progress = 0.0;
                                            _startTask(6).whenComplete(
                                                () => Navigator.pop(context));
                                            getpop_loader(context);
                                            String data =
                                                "${'INTG'.toUpperCase()}\r\n";
                                            _response.clear();
                                            _data.clear();
                                            hexDecimalValue = '';
                                            await _port!.write(
                                                Uint8List.fromList(
                                                    data.codeUnits));
                                          },
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  ElevatedButton(
                                    child: Text(
                                      "Accept",
                                      style: TextStyle(
                                          color: _buttonPressed
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                    onPressed: _port == null
                                        ? null
                                        : () async {
                                            if (_port == null) {
                                              return;
                                            }

                                            setState(() {
                                              _buttonPressed =
                                                  true; // Set the button as pressed
                                            });

                                            inlet_blink = true;
                                            outlet_blink = true;
                                            await Future.delayed(
                                                    Duration(seconds: 3))
                                                .whenComplete(() {
                                              getAI1Value();
                                            });
                                          },
                                    style: ElevatedButton.styleFrom(
                                      primary: _buttonPressed
                                          ? Colors.green
                                          : Colors
                                              .white, // Button background color
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 190, 219, 243),
                            borderRadius: BorderRadius.circular(5)),
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'PT Valve Test',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Card(
                        elevation: 7,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: InkWell(
                                        onTap: () {},
                                        child: SizedBox(
                                            height: 50,
                                            child: Center(
                                                child: Text('Before Inlet PT',
                                                    style: TextStyle(
                                                        fontSize: 10)))),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        child: inlet_blink
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
                                            : Center(
                                                child: Text(
                                                  '${aimAvalue ?? ''} mA',
                                                ),
                                              ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        child: inlet_blink
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
                                            : Center(
                                                child: Text(
                                                  '${aibarvalue ?? ''} bar',
                                                ),
                                              ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                          height: 40,
                                          // width: 50,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  InletButton == 'Ok'
                                                      ? Colors.green
                                                      : Colors.blue,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(
                                                    5), // Set border radius to 0 for square shape
                                              ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                InletButton = 'Ok';
                                              });
                                            },
                                            child: Text(
                                              'OK',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize:
                                                      10), // Adjust the button font size here
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        SizedBox(
                                          height: 40,
                                          // width: 56,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  InletButton == 'Not Ok'
                                                      ? Colors.red
                                                      : Colors.blue,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(
                                                    5), // Set border radius to 0 for square shape
                                              ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                InletButton = 'Not Ok';
                                              });
                                            },
                                            child: Text(
                                              'Not Ok',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize:
                                                      10), // Adjust the button font size here
                                            ),
                                          ),
                                        ),
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
                                              child: Text('After Inlet PT',
                                                  style: TextStyle(
                                                      fontSize: 10)))),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        child: outlet_blink
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
                                            : Center(
                                                child: Text(
                                                  '${ai2mAvalue ?? ''} mA',
                                                ),
                                              ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        child: outlet_blink
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
                                            : Center(
                                                child: Text(
                                                  '${ai2barvalue ?? ''} Bar',
                                                ),
                                              ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                          height: 40,
                                          // width: 50,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  OutletButton == 'Ok'
                                                      ? Colors.green
                                                      : Colors.blue,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(
                                                    5), // Set border radius to 0 for square shape
                                              ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                OutletButton = 'Ok';
                                                isTextVisible = true;
                                              });
                                            },
                                            child: Text(
                                              'OK',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize:
                                                      10), // Adjust the button font size here
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        SizedBox(
                                          height: 40,
                                          // width: 56,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  OutletButton == 'Not Ok'
                                                      ? Colors.red
                                                      : Colors.blue,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(
                                                    5), // Set border radius to 0 for square shape
                                              ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                OutletButton = 'Not Ok';
                                                isTextVisible = true;
                                              });
                                            },
                                            child: Text(
                                              'Not Ok',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize:
                                                      10), // Adjust the button font size here
                                            ),
                                          ),
                                        ),
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 190, 219, 243),
                            borderRadius: BorderRadius.circular(5)),
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Outlet PT',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Card(
                        elevation: 7,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: InkWell(
                                        onTap: () {},
                                        child: SizedBox(
                                            height: 50,
                                            child: Center(
                                                child: Text('PFCMD1',
                                                    style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.bold)))),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        child: PFCMD1_blink
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
                                            : Center(
                                                child: Text(
                                                  '${outlet_1_value_controller ?? ''} mA',
                                                ),
                                              ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        child: PFCMD1_blink
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
                                            : Center(
                                                child: Text(
                                                  '${outlet_1_actual_count_controller ?? ''} bar',
                                                ),
                                              ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                          height: 40,
                                          // width: 50,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: PFCMD1 == 'Ok'
                                                  ? Colors.green
                                                  : Colors.blue,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(
                                                    5), // Set border radius to 0 for square shape
                                              ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                PFCMD1 = 'Ok';
                                              });
                                            },
                                            child: Text(
                                              'OK',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize:
                                                      10), // Adjust the button font size here
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        SizedBox(
                                          height: 40,
                                          // width: 56,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  PFCMD1 == 'Not Ok'
                                                      ? Colors.red
                                                      : Colors.blue,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(
                                                    5), // Set border radius to 0 for square shape
                                              ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                PFCMD1 = 'Not Ok';
                                              });
                                            },
                                            child: Text(
                                              'Not Ok',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize:
                                                      10), // Adjust the button font size here
                                            ),
                                          ),
                                        ),
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
                                      child: InkWell(
                                        onTap: () {},
                                        child: SizedBox(
                                            height: 50,
                                            child: Center(
                                                child: Text('PFCMD2',
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold)))),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        child: PFCMD2_blink
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
                                            : Center(
                                                child: Text(
                                                  '${outlet_2_value_after_controller ?? ''} mA',
                                                ),
                                              ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        child: PFCMD2_blink
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
                                            : Center(
                                                child: Text(
                                                  '${outlet_2_actual_count_after_controller ?? ''} Bar',
                                                ),
                                              ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                          height: 40,
                                          // width: 50,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: PFCMD2 == 'Ok'
                                                  ? Colors.green
                                                  : Colors.blue,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(
                                                    5), // Set border radius to 0 for square shape
                                              ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                PFCMD2 = 'Ok';
                                                isTextVisible = true;
                                              });
                                            },
                                            child: Text(
                                              'OK',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize:
                                                      10), // Adjust the button font size here
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        SizedBox(
                                          height: 40,
                                          // width: 56,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  PFCMD2 == 'Not Ok'
                                                      ? Colors.red
                                                      : Colors.blue,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(
                                                    5), // Set border radius to 0 for square shape
                                              ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                PFCMD2 = 'Not Ok';
                                                isTextVisible = true;
                                              });
                                            },
                                            child: Text(
                                              'Not Ok',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize:
                                                      10), // Adjust the button font size here
                                            ),
                                          ),
                                        ),
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
                                      child: InkWell(
                                        onTap: () {},
                                        child: SizedBox(
                                            height: 50,
                                            child: Center(
                                                child: Text('PFCMD3',
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold)))),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        child: PFCMD3_blink
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
                                            : Center(
                                                child: Text(
                                                  '${outlet_3_value_controller ?? ''} mA',
                                                ),
                                              ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        child: PFCMD3_blink
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
                                            : Center(
                                                child: Text(
                                                  '${outlet_3_actual_count_controller ?? ''} Bar',
                                                ),
                                              ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                          height: 40,
                                          // width: 50,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: PFCMD3 == 'Ok'
                                                  ? Colors.green
                                                  : Colors.blue,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(
                                                    5), // Set border radius to 0 for square shape
                                              ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                PFCMD3 = 'Ok';
                                                isTextVisible = true;
                                              });
                                            },
                                            child: Text(
                                              'OK',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize:
                                                      10), // Adjust the button font size here
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        SizedBox(
                                          height: 40,
                                          // width: 56,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  PFCMD3 == 'Not Ok'
                                                      ? Colors.red
                                                      : Colors.blue,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(
                                                    5), // Set border radius to 0 for square shape
                                              ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                PFCMD3 = 'Not Ok';
                                                isTextVisible = true;
                                              });
                                            },
                                            child: Text(
                                              'Not Ok',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize:
                                                      10), // Adjust the button font size here
                                            ),
                                          ),
                                        ),
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
                                      child: InkWell(
                                        onTap: () {},
                                        child: SizedBox(
                                            height: 50,
                                            child: Center(
                                                child: Text('PFCMD4',
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold)))),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        child: PFCMD4_blink
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
                                            : Center(
                                                child: Text(
                                                  '${outlet_4_value_controller ?? ''} mA',
                                                ),
                                              ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        child: PFCMD4_blink
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
                                            : Center(
                                                child: Text(
                                                  '${outlet_4_actual_count_controller ?? ''} Bar',
                                                ),
                                              ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                          height: 40,
                                          // width: 50,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: PFCMD4 == 'Ok'
                                                  ? Colors.green
                                                  : Colors.blue,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(
                                                    5), // Set border radius to 0 for square shape
                                              ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                PFCMD4 = 'Ok';
                                                isTextVisible = true;
                                              });
                                            },
                                            child: Text(
                                              'OK',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize:
                                                      10), // Adjust the button font size here
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        SizedBox(
                                          height: 40,
                                          // width: 56,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  PFCMD4 == 'Not Ok'
                                                      ? Colors.red
                                                      : Colors.blue,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(
                                                    5), // Set border radius to 0 for square shape
                                              ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                PFCMD4 = 'Not Ok';
                                                isTextVisible = true;
                                              });
                                            },
                                            child: Text(
                                              'Not Ok',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize:
                                                      10), // Adjust the button font size here
                                            ),
                                          ),
                                        ),
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
                                      child: InkWell(
                                        onTap: () {},
                                        child: SizedBox(
                                            height: 50,
                                            child: Center(
                                                child: Text('PFCMD5',
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold)))),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        child: PFCMD5_blink
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
                                            : Center(
                                                child: Text(
                                                  '${outlet_5_value_controller ?? ''} mA',
                                                ),
                                              ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        child: PFCMD5_blink
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
                                            : Center(
                                                child: Text(
                                                  '${outlet_5_actual_count_controller ?? ''} Bar',
                                                ),
                                              ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                          height: 40,
                                          // width: 50,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: PFCMD5 == 'Ok'
                                                  ? Colors.green
                                                  : Colors.blue,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(
                                                    5), // Set border radius to 0 for square shape
                                              ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                PFCMD5 = 'Ok';
                                                isTextVisible = true;
                                              });
                                            },
                                            child: Text(
                                              'OK',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize:
                                                      10), // Adjust the button font size here
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        SizedBox(
                                          height: 40,
                                          // width: 56,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  PFCMD5 == 'Not Ok'
                                                      ? Colors.red
                                                      : Colors.blue,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(
                                                    5), // Set border radius to 0 for square shape
                                              ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                PFCMD5 = 'Not Ok';
                                                isTextVisible = true;
                                              });
                                            },
                                            child: Text(
                                              'Not Ok',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize:
                                                      10), // Adjust the button font size here
                                            ),
                                          ),
                                        ),
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
                                      child: InkWell(
                                        onTap: () {},
                                        child: SizedBox(
                                            height: 50,
                                            child: Center(
                                                child: Text('PFCMD6',
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold)))),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        child: PFCMD6_blink
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
                                            : Center(
                                                child: Text(
                                                  '${outlet_6_value_controller ?? ''} mA',
                                                ),
                                              ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        child: PFCMD6_blink
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
                                            : Center(
                                                child: Text(
                                                  '${outlet_6_actual_count_controller ?? ''} Bar',
                                                ),
                                              ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                          height: 40,
                                          // width: 50,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: PFCMD6 == 'Ok'
                                                  ? Colors.green
                                                  : Colors.blue,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(
                                                    5), // Set border radius to 0 for square shape
                                              ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                PFCMD6 = 'Ok';
                                                isTextVisible = true;
                                              });
                                            },
                                            child: Text(
                                              'OK',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize:
                                                      10), // Adjust the button font size here
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        SizedBox(
                                          height: 40,
                                          // width: 56,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  PFCMD6 == 'Not Ok'
                                                      ? Colors.red
                                                      : Colors.blue,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(
                                                    5), // Set border radius to 0 for square shape
                                              ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                PFCMD6 = 'Not Ok';
                                                isTextVisible = true;
                                              });
                                            },
                                            child: Text(
                                              'Not Ok',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize:
                                                      10), // Adjust the button font size here
                                            ),
                                          ),
                                        ),
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 190, 219, 243),
                            borderRadius: BorderRadius.circular(5)),
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Solenoid Testing',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ),
                    ),
                    //Solonoid
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Card(
                        elevation: 7,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Card(
                                  color: Colors.blue,
                                  child: Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: Center(
                                        child: Text('PFCMD 1',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ))),
                                  )),
                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                        height: 50,
                                        child: Center(
                                            child: TextButton(
                                          child: FadeTransition(
                                              opacity: isTextVisible
                                                  ? _animationController!
                                                  : AlwaysStoppedAnimation(1.0),
                                              child: Text('OPEN')),
                                          onPressed: () {
                                            _data.clear();
                                            index = 1;
                                            (index!);
                                            open1 = true;
                                            isTextVisible = false;
                                            btnstate = 'Open';
                                            SetOpenCloseModePFCMD6(index!);
                                          },
                                        ))),
                                    Expanded(
                                      flex: 1,
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        child: open1
                                            ? Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    child: Center(
                                                      child:
                                                          SpinKitFadingCircle(
                                                        size: 30,
                                                        color: Colors.blue,
                                                      ),
                                                    ),
                                                    height: 30,
                                                    width: 20,
                                                  ),
                                                  SizedBox(height: 10),
                                                  CountdownTimerWidget(
                                                    duration: const Duration(
                                                        minutes: 4),
                                                  ),
                                                ],
                                              )
                                            : Center(
                                                child: Text(
                                                  '${openvalpos1 ?? ''} %',
                                                ),
                                              ),
                                      ),
                                    ),

                                    /*Expanded(
                                      flex: 1,
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        child: open1
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
                                            : Center(
                                                child: Text(
                                                  '${openvalpos1 ?? ''} %',
                                                ),
                                              ),
                                      ),
                                    ),*/
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        SizedBox(
                                            height: 50,
                                            child: Center(
                                              child: ElevatedButton(
                                                child: Text('OK',
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      valveOpen == 'Open'
                                                          ? Colors.green
                                                          : Colors.blue,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5), // Set border radius to 0 for square shape
                                                  ),
                                                ),
                                                onPressed: () {
                                                  OpenBtn = 'OK';
                                                  valveOpen = 'Open';
                                                  isText2Visible = true;
                                                },
                                              ),
                                            )),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        SizedBox(
                                            height: 50,
                                            child: Center(
                                              child: ElevatedButton(
                                                child: Text(
                                                  'NOT OK',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      valveOpen == 'Close'
                                                          ? Colors.red
                                                          : Colors.blue,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5), // Set border radius to 0 for square shape
                                                  ),
                                                ),
                                                onPressed: () {
                                                  valveOpen = 'Close';
                                                  OpenBtn = 'Not OK';
                                                  isText2Visible = true;
                                                },
                                              ),
                                            )),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                        height: 50,
                                        child: Center(
                                            child: TextButton(
                                          child: FadeTransition(
                                              opacity: isText2Visible
                                                  ? _animationController!
                                                  : AlwaysStoppedAnimation(1.0),
                                              child: Text('CLOSE')),
                                          onPressed: () {
                                            _data.clear;
                                            index = 1;
                                            setValveClosePFCMD6(index!);
                                            close1 = true;
                                            btnstate = 'Close';
                                            isText2Visible = false;
                                          },
                                        ))),
                                    Expanded(
                                      flex: 1,
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        child: close1
                                            ? Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    child: Center(
                                                      child:
                                                          SpinKitFadingCircle(
                                                        size: 30,
                                                        color: Colors.blue,
                                                      ),
                                                    ),
                                                    height: 30,
                                                    width: 20,
                                                  ),
                                                  SizedBox(height: 10),
                                                  CountdownTimerWidget(
                                                    duration: const Duration(
                                                        minutes: 4),
                                                  ),
                                                ],
                                              )
                                            : Center(
                                                child: Text(
                                                  '${closevalpos1 ?? ''} %',
                                                ),
                                              ),
                                      ),
                                    ),
                                    /* Expanded(
                                      flex: 1,
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        child: close1
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
                                            : Center(
                                                child: Text(
                                                  '${closevalpos1 ?? ''} %',
                                                ),
                                              ),
                                      ),
                                    ),*/
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        SizedBox(
                                            height: 50,
                                            child: Center(
                                              child: ElevatedButton(
                                                child: Text('OK',
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      valveClose == 'Open'
                                                          ? Colors.green
                                                          : Colors.blue,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5), // Set border radius to 0 for square shape
                                                  ),
                                                ),
                                                onPressed: () {
                                                  valveClose = 'Open';
                                                  CloseBtn = 'OK';
                                                  isText3Visible = true;
                                                },
                                              ),
                                            )),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        SizedBox(
                                            height: 50,
                                            child: Center(
                                              child: ElevatedButton(
                                                child: Text(
                                                  'NOT OK',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      valveClose == 'Close'
                                                          ? Colors.red
                                                          : Colors.blue,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5), // Set border radius to 0 for square shape
                                                  ),
                                                ),
                                                onPressed: () {
                                                  isText3Visible = true;
                                                  valveClose = 'Close';
                                                  CloseBtn = 'Not OK';
                                                },
                                              ),
                                            )),
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
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Card(
                        elevation: 7,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Card(
                                  color: Colors.blue,
                                  child: Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: Center(
                                        child: Text('PFCMD 2',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ))),
                                  )),
                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                        height: 50,
                                        child: Center(
                                            child: TextButton(
                                          child: FadeTransition(
                                              opacity: isTextVisible
                                                  ? _animationController!
                                                  : AlwaysStoppedAnimation(1.0),
                                              child: Text('OPEN')),
                                          onPressed: () {
                                            _data.clear();
                                            index = 2;
                                            SetOpenCloseModePFCMD6(index!);
                                            open2 = true;
                                            isTextVisible = false;
                                            btnstate = 'Open';
                                          },
                                        ))),
                                    Expanded(
                                      flex: 1,
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        child: open2
                                            ? Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    child: Center(
                                                      child:
                                                          SpinKitFadingCircle(
                                                        size: 30,
                                                        color: Colors.blue,
                                                      ),
                                                    ),
                                                    height: 30,
                                                    width: 20,
                                                  ),
                                                  SizedBox(height: 10),
                                                  CountdownTimerWidget(
                                                    duration: const Duration(
                                                        minutes: 4),
                                                  ),
                                                ],
                                              )
                                            : Center(
                                                child: Text(
                                                  '${openvalpos2 ?? ''} %',
                                                ),
                                              ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        SizedBox(
                                            height: 50,
                                            child: Center(
                                              child: ElevatedButton(
                                                child: Text('OK',
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      valveOpen2 == 'Open'
                                                          ? Colors.green
                                                          : Colors.blue,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5), // Set border radius to 0 for square shape
                                                  ),
                                                ),
                                                onPressed: () {
                                                  OpenBtn = 'OK';
                                                  valveOpen2 = 'Open';
                                                  isText2Visible = true;
                                                },
                                              ),
                                            )),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        SizedBox(
                                            height: 50,
                                            child: Center(
                                              child: ElevatedButton(
                                                child: Text(
                                                  'NOT OK',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      valveOpen2 == 'Close'
                                                          ? Colors.red
                                                          : Colors.blue,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5), // Set border radius to 0 for square shape
                                                  ),
                                                ),
                                                onPressed: () {
                                                  valveOpen2 = 'Close';
                                                  OpenBtn = 'Not OK';
                                                  isText2Visible = true;
                                                },
                                              ),
                                            )),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                        height: 50,
                                        child: Center(
                                            child: TextButton(
                                          child: FadeTransition(
                                              opacity: isText2Visible
                                                  ? _animationController!
                                                  : AlwaysStoppedAnimation(1.0),
                                              child: Text('CLOSE')),
                                          onPressed: () {
                                            _data.clear;
                                            index = 2;
                                            setValveClosePFCMD6(index!);
                                            close2 = true;
                                            btnstate = 'Close';
                                            isText2Visible = false;
                                          },
                                        ))),
                                    Expanded(
                                      flex: 1,
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        child: close2
                                            ? Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    child: Center(
                                                      child:
                                                          SpinKitFadingCircle(
                                                        size: 30,
                                                        color: Colors.blue,
                                                      ),
                                                    ),
                                                    height: 30,
                                                    width: 20,
                                                  ),
                                                  SizedBox(height: 10),
                                                  CountdownTimerWidget(
                                                    duration: const Duration(
                                                        minutes: 4),
                                                  ),
                                                ],
                                              )
                                            : Center(
                                                child: Text(
                                                  '${closevalpos2 ?? ''} %',
                                                ),
                                              ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        SizedBox(
                                            height: 50,
                                            child: Center(
                                              child: ElevatedButton(
                                                child: Text('OK',
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      valveClose2 == 'Open'
                                                          ? Colors.green
                                                          : Colors.blue,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5), // Set border radius to 0 for square shape
                                                  ),
                                                ),
                                                onPressed: () {
                                                  valveClose2 = 'Open';
                                                  CloseBtn = 'OK';
                                                  isText3Visible = true;
                                                },
                                              ),
                                            )),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        SizedBox(
                                            height: 50,
                                            child: Center(
                                              child: ElevatedButton(
                                                child: Text(
                                                  'NOT OK',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      valveClose2 == 'Close'
                                                          ? Colors.red
                                                          : Colors.blue,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5), // Set border radius to 0 for square shape
                                                  ),
                                                ),
                                                onPressed: () {
                                                  isText3Visible = true;
                                                  valveClose2 = 'Close';
                                                  CloseBtn = 'Not OK';
                                                },
                                              ),
                                            )),
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
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Card(
                        elevation: 7,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Card(
                                  color: Colors.blue,
                                  child: Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: Center(
                                        child: Text('PFCMD 3',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ))),
                                  )),
                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                        height: 50,
                                        child: Center(
                                            child: TextButton(
                                          child: FadeTransition(
                                              opacity: isTextVisible
                                                  ? _animationController!
                                                  : AlwaysStoppedAnimation(1.0),
                                              child: Text('OPEN')),
                                          onPressed: () {
                                            _data.clear();
                                            index = 3;
                                            SetOpenCloseModePFCMD6(index!);
                                            open3 = true;
                                            isTextVisible = false;
                                            btnstate = 'Open';
                                          },
                                        ))),
                                    Expanded(
                                      flex: 1,
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        child: open3
                                            ? Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    child: Center(
                                                      child:
                                                          SpinKitFadingCircle(
                                                        size: 30,
                                                        color: Colors.blue,
                                                      ),
                                                    ),
                                                    height: 30,
                                                    width: 20,
                                                  ),
                                                  SizedBox(height: 10),
                                                  CountdownTimerWidget(
                                                    duration: const Duration(
                                                        minutes: 4),
                                                  ),
                                                ],
                                              )
                                            : Center(
                                                child: Text(
                                                  '${openvalpos3 ?? ''} %',
                                                ),
                                              ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        SizedBox(
                                            height: 50,
                                            child: Center(
                                              child: ElevatedButton(
                                                child: Text('OK',
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      valveOpen3 == 'Open'
                                                          ? Colors.green
                                                          : Colors.blue,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5), // Set border radius to 0 for square shape
                                                  ),
                                                ),
                                                onPressed: () {
                                                  OpenBtn = 'OK';
                                                  valveOpen3 = 'Open';
                                                  isText2Visible = true;
                                                },
                                              ),
                                            )),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        SizedBox(
                                            height: 50,
                                            child: Center(
                                              child: ElevatedButton(
                                                child: Text(
                                                  'NOT OK',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      valveOpen3 == 'Close'
                                                          ? Colors.red
                                                          : Colors.blue,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5), // Set border radius to 0 for square shape
                                                  ),
                                                ),
                                                onPressed: () {
                                                  valveOpen3 = 'Close';
                                                  OpenBtn = 'Not OK';
                                                  isText2Visible = true;
                                                },
                                              ),
                                            )),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                        height: 50,
                                        child: Center(
                                            child: TextButton(
                                          child: FadeTransition(
                                              opacity: isText2Visible
                                                  ? _animationController!
                                                  : AlwaysStoppedAnimation(1.0),
                                              child: Text('CLOSE')),
                                          onPressed: () {
                                            _data.clear;
                                            index = 3;
                                            setValveClosePFCMD6(index!);
                                            close3 = true;
                                            btnstate = 'Close';
                                            isText2Visible = false;
                                          },
                                        ))),
                                    Expanded(
                                      flex: 1,
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        child: close3
                                            ? Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    child: Center(
                                                      child:
                                                          SpinKitFadingCircle(
                                                        size: 30,
                                                        color: Colors.blue,
                                                      ),
                                                    ),
                                                    height: 30,
                                                    width: 20,
                                                  ),
                                                  SizedBox(height: 10),
                                                  CountdownTimerWidget(
                                                    duration: const Duration(
                                                        minutes: 4),
                                                  ),
                                                ],
                                              )
                                            : Center(
                                                child: Text(
                                                  '${closevalpos3 ?? ''} %',
                                                ),
                                              ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        SizedBox(
                                            height: 50,
                                            child: Center(
                                              child: ElevatedButton(
                                                child: Text('OK',
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      valveClose3 == 'Open'
                                                          ? Colors.green
                                                          : Colors.blue,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5), // Set border radius to 0 for square shape
                                                  ),
                                                ),
                                                onPressed: () {
                                                  valveClose3 = 'Open';
                                                  CloseBtn = 'OK';
                                                  isText3Visible = true;
                                                },
                                              ),
                                            )),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        SizedBox(
                                            height: 50,
                                            child: Center(
                                              child: ElevatedButton(
                                                child: Text(
                                                  'NOT OK',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      valveClose3 == 'Close'
                                                          ? Colors.red
                                                          : Colors.blue,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5), // Set border radius to 0 for square shape
                                                  ),
                                                ),
                                                onPressed: () {
                                                  isText3Visible = true;
                                                  valveClose3 = 'Close';
                                                  CloseBtn = 'Not OK';
                                                },
                                              ),
                                            )),
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
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Card(
                        elevation: 7,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Card(
                                  color: Colors.blue,
                                  child: Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: Center(
                                        child: Text('PFCMD 4',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ))),
                                  )),
                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                        height: 50,
                                        child: Center(
                                            child: TextButton(
                                          child: FadeTransition(
                                              opacity: isTextVisible
                                                  ? _animationController!
                                                  : AlwaysStoppedAnimation(1.0),
                                              child: Text('OPEN')),
                                          onPressed: () {
                                            _data.clear();
                                            index = 4;
                                            SetOpenCloseModePFCMD6(index!);
                                            open4 = true;
                                            isTextVisible = false;
                                            btnstate = 'Open';
                                          },
                                        ))),
                                    Expanded(
                                      flex: 1,
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        child: open4
                                            ? Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    child: Center(
                                                      child:
                                                          SpinKitFadingCircle(
                                                        size: 30,
                                                        color: Colors.blue,
                                                      ),
                                                    ),
                                                    height: 30,
                                                    width: 20,
                                                  ),
                                                  SizedBox(height: 10),
                                                  CountdownTimerWidget(
                                                    duration: const Duration(
                                                        minutes: 4),
                                                  ),
                                                ],
                                              )
                                            : Center(
                                                child: Text(
                                                  '${openvalpos4 ?? ''} %',
                                                ),
                                              ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        SizedBox(
                                            height: 50,
                                            child: Center(
                                              child: ElevatedButton(
                                                child: Text('OK',
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      valveOpen4 == 'Open'
                                                          ? Colors.green
                                                          : Colors.blue,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5), // Set border radius to 0 for square shape
                                                  ),
                                                ),
                                                onPressed: () {
                                                  OpenBtn = 'OK';
                                                  valveOpen4 = 'Open';
                                                  isText2Visible = true;
                                                },
                                              ),
                                            )),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        SizedBox(
                                            height: 50,
                                            child: Center(
                                              child: ElevatedButton(
                                                child: Text(
                                                  'NOT OK',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      valveOpen4 == 'Close'
                                                          ? Colors.red
                                                          : Colors.blue,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5), // Set border radius to 0 for square shape
                                                  ),
                                                ),
                                                onPressed: () {
                                                  valveOpen4 = 'Close';
                                                  OpenBtn = 'Not OK';
                                                  isText2Visible = true;
                                                },
                                              ),
                                            )),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                        height: 50,
                                        child: Center(
                                            child: TextButton(
                                          child: FadeTransition(
                                              opacity: isText2Visible
                                                  ? _animationController!
                                                  : AlwaysStoppedAnimation(1.0),
                                              child: Text('CLOSE')),
                                          onPressed: () {
                                            _data.clear;
                                            index = 4;
                                            setValveClosePFCMD6(index!);
                                            close4 = true;
                                            btnstate = 'Close';
                                            isText2Visible = false;
                                          },
                                        ))),
                                    Expanded(
                                      flex: 1,
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        child: close4
                                            ? Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    child: Center(
                                                      child:
                                                          SpinKitFadingCircle(
                                                        size: 30,
                                                        color: Colors.blue,
                                                      ),
                                                    ),
                                                    height: 30,
                                                    width: 20,
                                                  ),
                                                  SizedBox(height: 10),
                                                  CountdownTimerWidget(
                                                    duration: const Duration(
                                                        minutes: 4),
                                                  ),
                                                ],
                                              )
                                            : Center(
                                                child: Text(
                                                  '${closevalpos4 ?? ''} %',
                                                ),
                                              ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        SizedBox(
                                            height: 50,
                                            child: Center(
                                              child: ElevatedButton(
                                                child: Text('OK',
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      valveClose4 == 'Open'
                                                          ? Colors.green
                                                          : Colors.blue,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5), // Set border radius to 0 for square shape
                                                  ),
                                                ),
                                                onPressed: () {
                                                  valveClose4 = 'Open';
                                                  CloseBtn = 'OK';
                                                  isText3Visible = true;
                                                },
                                              ),
                                            )),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        SizedBox(
                                            height: 50,
                                            child: Center(
                                              child: ElevatedButton(
                                                child: Text(
                                                  'NOT OK',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      valveClose4 == 'Close'
                                                          ? Colors.red
                                                          : Colors.blue,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5), // Set border radius to 0 for square shape
                                                  ),
                                                ),
                                                onPressed: () {
                                                  isText3Visible = true;
                                                  valveClose4 = 'Close';
                                                  CloseBtn = 'Not OK';
                                                },
                                              ),
                                            )),
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
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Card(
                        elevation: 7,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Card(
                                  color: Colors.blue,
                                  child: Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: Center(
                                        child: Text('PFCMD 5',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ))),
                                  )),
                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                        height: 50,
                                        child: Center(
                                            child: TextButton(
                                          child: FadeTransition(
                                              opacity: isTextVisible
                                                  ? _animationController!
                                                  : AlwaysStoppedAnimation(1.0),
                                              child: Text('OPEN')),
                                          onPressed: () {
                                            _data.clear();
                                            index = 5;
                                            SetOpenCloseModePFCMD6(index!);
                                            open5 = true;
                                            isTextVisible = false;
                                            btnstate = 'Open';
                                          },
                                        ))),
                                    Expanded(
                                      flex: 1,
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        child: open5
                                            ? Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    child: Center(
                                                      child:
                                                          SpinKitFadingCircle(
                                                        size: 30,
                                                        color: Colors.blue,
                                                      ),
                                                    ),
                                                    height: 30,
                                                    width: 20,
                                                  ),
                                                  SizedBox(height: 10),
                                                  CountdownTimerWidget(
                                                    duration: const Duration(
                                                        minutes: 4),
                                                  ),
                                                ],
                                              )
                                            : Center(
                                                child: Text(
                                                  '${openvalpos5 ?? ''} %',
                                                ),
                                              ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        SizedBox(
                                            height: 50,
                                            child: Center(
                                              child: ElevatedButton(
                                                child: Text('OK',
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      valveOpen5 == 'Open'
                                                          ? Colors.green
                                                          : Colors.blue,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5), // Set border radius to 0 for square shape
                                                  ),
                                                ),
                                                onPressed: () {
                                                  OpenBtn = 'OK';
                                                  valveOpen5 = 'Open';
                                                  isText2Visible = true;
                                                },
                                              ),
                                            )),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        SizedBox(
                                            height: 50,
                                            child: Center(
                                              child: ElevatedButton(
                                                child: Text(
                                                  'NOT OK',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      valveOpen5 == 'Close'
                                                          ? Colors.red
                                                          : Colors.blue,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5), // Set border radius to 0 for square shape
                                                  ),
                                                ),
                                                onPressed: () {
                                                  valveOpen5 = 'Close';
                                                  OpenBtn = 'Not OK';
                                                  isText2Visible = true;
                                                },
                                              ),
                                            )),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                        height: 50,
                                        child: Center(
                                            child: TextButton(
                                          child: FadeTransition(
                                              opacity: isText2Visible
                                                  ? _animationController!
                                                  : AlwaysStoppedAnimation(1.0),
                                              child: Text('CLOSE')),
                                          onPressed: () {
                                            _data.clear;
                                            index = 5;
                                            setValveClosePFCMD6(index!);
                                            close5 = true;
                                            btnstate = 'Close';
                                            isText2Visible = false;
                                          },
                                        ))),
                                    Expanded(
                                      flex: 1,
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        child: close5
                                            ? Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    child: Center(
                                                      child:
                                                          SpinKitFadingCircle(
                                                        size: 30,
                                                        color: Colors.blue,
                                                      ),
                                                    ),
                                                    height: 30,
                                                    width: 20,
                                                  ),
                                                  SizedBox(height: 10),
                                                  CountdownTimerWidget(
                                                    duration: const Duration(
                                                        minutes: 4),
                                                  ),
                                                ],
                                              )
                                            : Center(
                                                child: Text(
                                                  '${closevalpos5 ?? ''} %',
                                                ),
                                              ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        SizedBox(
                                            height: 50,
                                            child: Center(
                                              child: ElevatedButton(
                                                child: Text('OK',
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      valveClose5 == 'Open'
                                                          ? Colors.green
                                                          : Colors.blue,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5), // Set border radius to 0 for square shape
                                                  ),
                                                ),
                                                onPressed: () {
                                                  valveClose5 = 'Open';
                                                  CloseBtn = 'OK';
                                                  isText3Visible = true;
                                                },
                                              ),
                                            )),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        SizedBox(
                                            height: 50,
                                            child: Center(
                                              child: ElevatedButton(
                                                child: Text(
                                                  'NOT OK',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      valveClose5 == 'Close'
                                                          ? Colors.red
                                                          : Colors.blue,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5), // Set border radius to 0 for square shape
                                                  ),
                                                ),
                                                onPressed: () {
                                                  isText3Visible = true;
                                                  valveClose5 = 'Close';
                                                  CloseBtn = 'Not OK';
                                                },
                                              ),
                                            )),
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
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Card(
                        elevation: 7,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Card(
                                  color: Colors.blue,
                                  child: Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: Center(
                                        child: Text('PFCMD 6',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ))),
                                  )),
                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                        height: 50,
                                        child: Center(
                                            child: TextButton(
                                          child: FadeTransition(
                                              opacity: isTextVisible
                                                  ? _animationController!
                                                  : AlwaysStoppedAnimation(1.0),
                                              child: Text('OPEN')),
                                          onPressed: () {
                                            _data.clear();
                                            index = 6;
                                            SetOpenCloseModePFCMD6(index!);
                                            open6 = true;
                                            isTextVisible = false;
                                            btnstate = 'Open';
                                          },
                                        ))),
                                    Expanded(
                                      flex: 1,
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        child: open6
                                            ? Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    child: Center(
                                                      child:
                                                          SpinKitFadingCircle(
                                                        size: 30,
                                                        color: Colors.blue,
                                                      ),
                                                    ),
                                                    height: 30,
                                                    width: 20,
                                                  ),
                                                  SizedBox(height: 10),
                                                  CountdownTimerWidget(
                                                    duration: const Duration(
                                                        minutes: 4),
                                                  ),
                                                ],
                                              )
                                            : Center(
                                                child: Text(
                                                  '${openvalpos6 ?? ''} %',
                                                ),
                                              ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        SizedBox(
                                            height: 50,
                                            child: Center(
                                              child: ElevatedButton(
                                                child: Text('OK',
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      valveOpen6 == 'Open'
                                                          ? Colors.green
                                                          : Colors.blue,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5), // Set border radius to 0 for square shape
                                                  ),
                                                ),
                                                onPressed: () {
                                                  OpenBtn = 'OK';
                                                  valveOpen6 = 'Open';
                                                  isText2Visible = true;
                                                },
                                              ),
                                            )),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        SizedBox(
                                            height: 50,
                                            child: Center(
                                              child: ElevatedButton(
                                                child: Text(
                                                  'NOT OK',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      valveOpen6 == 'Close'
                                                          ? Colors.red
                                                          : Colors.blue,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5), // Set border radius to 0 for square shape
                                                  ),
                                                ),
                                                onPressed: () {
                                                  valveOpen6 = 'Close';
                                                  OpenBtn = 'Not OK';
                                                  isText2Visible = true;
                                                },
                                              ),
                                            )),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                        height: 50,
                                        child: Center(
                                            child: TextButton(
                                          child: FadeTransition(
                                              opacity: isText2Visible
                                                  ? _animationController!
                                                  : AlwaysStoppedAnimation(1.0),
                                              child: Text('CLOSE')),
                                          onPressed: () {
                                            _data.clear;
                                            index = 6;
                                            setValveClosePFCMD6(index!);
                                            close6 = true;
                                            btnstate = 'Close';
                                            isText2Visible = false;
                                          },
                                        ))),
                                    Expanded(
                                      flex: 1,
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        child: close6
                                            ? Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    child: Center(
                                                      child:
                                                          SpinKitFadingCircle(
                                                        size: 30,
                                                        color: Colors.blue,
                                                      ),
                                                    ),
                                                    height: 30,
                                                    width: 20,
                                                  ),
                                                  SizedBox(height: 10),
                                                  CountdownTimerWidget(
                                                    duration: const Duration(
                                                        minutes: 4),
                                                  ),
                                                ],
                                              )
                                            : Center(
                                                child: Text(
                                                  '${closevalpos6 ?? ''} %',
                                                ),
                                              ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        SizedBox(
                                            height: 50,
                                            child: Center(
                                              child: ElevatedButton(
                                                child: Text('OK',
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      valveClose6 == 'Open'
                                                          ? Colors.green
                                                          : Colors.blue,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5), // Set border radius to 0 for square shape
                                                  ),
                                                ),
                                                onPressed: () {
                                                  valveClose6 = 'Open';
                                                  CloseBtn = 'OK';
                                                  isText3Visible = true;
                                                },
                                              ),
                                            )),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        SizedBox(
                                            height: 50,
                                            child: Center(
                                              child: ElevatedButton(
                                                child: Text(
                                                  'NOT OK',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      valveClose6 == 'Close'
                                                          ? Colors.red
                                                          : Colors.blue,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5), // Set border radius to 0 for square shape
                                                  ),
                                                ),
                                                onPressed: () {
                                                  isText3Visible = true;
                                                  valveClose6 = 'Close';
                                                  CloseBtn = 'Not OK';
                                                },
                                              ),
                                            )),
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
                    if (isText3Visible)
                      Container(
                        child: Row(
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
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      } else if (controllerType!.contains('BOCOM1')) {
        return Expanded(
            child: SingleChildScrollView(
          child: Center(
            child: Container(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Card(
                      elevation: 7,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                  child: lora_comm.isEmpty
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
                                  child: getBatterVoltage() == 0.0
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
                                          batteryVoltage.toString(),
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
                                  child: getBatterVoltage() == 0.0
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
                                          getSOLARVoltage().toString(),
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
                                  child: getBatterVoltage() == 0.0
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
                                          '$Door1',
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
                                  child: getBatterVoltage() == 0.0
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
                                          '$Door2',
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
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  child: Text("INTG"),
                                  onPressed: _port == null
                                      ? null
                                      : () async {
                                          if (_port == null) {
                                            return;
                                          }
                                          _progress = 0.0;
                                          _startTask(6).whenComplete(
                                              () => Navigator.pop(context));
                                          getpop_loader(context);
                                          String data =
                                              "${'INTG'.toUpperCase()}\r\n";
                                          _response.clear();
                                          _data.clear();
                                          hexDecimalValue = '';
                                          await _port!.write(Uint8List.fromList(
                                              data.codeUnits));
                                        },
                                ),
                                /*ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      accept == 'accepted'
                                          ? Colors.green
                                          : Colors.blue,
                                    ),
                                    minimumSize:
                                        MaterialStateProperty.all(Size(30, 30)),
                                  ),
                                  onPressed: () async {
                                    setState(() {
                                      accept = 'accepted';
                                    });
                                    inlet_blink = true;
                                    outlet_blink = true;
                                    await Future.delayed(Duration(seconds: 3))
                                        .whenComplete(() {
                                      getAI1Value();
                                    });
                                  },
                                  child: Text(
                                    'Accept',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                               */
                                SizedBox(width: 5),
                                ElevatedButton(
                                  child: Text(
                                    "Accept",
                                    style: TextStyle(
                                        color: _buttonPressed
                                            ? Colors.white
                                            : Colors.black),
                                  ),
                                  onPressed: () async {
                                    setState(() {
                                      accept = 'accepted';
                                    });
                                    inlet_blink = true;
                                    outlet_blink = true;
                                    await Future.delayed(Duration(seconds: 3))
                                        .whenComplete(() {
                                      getAI1Value();
                                    });
                                  },
                                  /* onPressed: _port == null
                                      ? null
                                      : () async {
                                          if (_port == null) {
                                            return;
                                          }

                                          setState(() {
                                            _buttonPressed =
                                                true; // Set the button as pressed
                                          });

                                          inlet_blink = true;
                                          outlet_blink = true;
                                          await Future.delayed(
                                                  Duration(seconds: 3))
                                              .whenComplete(() {
                                            getAI1Value();
                                          });
                                        },*/
                                  style: ElevatedButton.styleFrom(
                                    primary: _buttonPressed
                                        ? Colors.green
                                        : Colors
                                            .white, // Button background color
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 190, 219, 243),
                          borderRadius: BorderRadius.circular(5)),
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'PT Valve Test',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Card(
                      elevation: 7,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: InkWell(
                                      onTap: () {},
                                      child: SizedBox(
                                          height: 50,
                                          child:
                                              Center(child: Text('Inlet PT'))),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.3,
                                      child: inlet_blink
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
                                          : Center(
                                              child: Text(
                                                '${aimAvalue ?? ''} mA',
                                              ),
                                            ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.3,
                                      child: inlet_blink
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
                                          : Center(
                                              child: Text(
                                                '${aibarvalue ?? ''} bar',
                                              ),
                                            ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          height: 40,
                                          width: 50,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  InletButton == 'Ok'
                                                      ? Colors.green
                                                      : Colors.blue,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(
                                                    5), // Set border radius to 0 for square shape
                                              ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                InletButton = 'Ok';
                                              });
                                            },
                                            child: Text(
                                              'OK',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize:
                                                      10), // Adjust the button font size here
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        SizedBox(
                                          height: 40,
                                          width: 56,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  InletButton == 'Not Ok'
                                                      ? Colors.red
                                                      : Colors.blue,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(
                                                    5), // Set border radius to 0 for square shape
                                              ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                InletButton = 'Not Ok';
                                              });
                                            },
                                            child: Text(
                                              'Not Ok',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize:
                                                      10), // Adjust the button font size here
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
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
                                        child:
                                            Center(child: Text('Outlet PT'))),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.3,
                                      child: outlet_blink
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
                                          : Center(
                                              child: Text(
                                                '${ai2mAvalue ?? ''} mA',
                                              ),
                                            ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.3,
                                      child: outlet_blink
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
                                          : Center(
                                              child: Text(
                                                '${ai2barvalue ?? ''} Bar',
                                              ),
                                            ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          height: 40,
                                          width: 50,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  OutletButton == 'Ok'
                                                      ? Colors.green
                                                      : Colors.blue,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(
                                                    5), // Set border radius to 0 for square shape
                                              ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                OutletButton = 'Ok';
                                                isTextVisible = true;
                                              });
                                            },
                                            child: Text(
                                              'OK',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize:
                                                      10), // Adjust the button font size here
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        SizedBox(
                                          height: 40,
                                          width: 56,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  OutletButton == 'Not Ok'
                                                      ? Colors.red
                                                      : Colors.blue,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(
                                                    5), // Set border radius to 0 for square shape
                                              ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                OutletButton = 'Not Ok';
                                                isTextVisible = true;
                                              });
                                            },
                                            child: Text(
                                              'Not Ok',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize:
                                                      10), // Adjust the button font size here
                                            ),
                                          ),
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
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 190, 219, 243),
                          borderRadius: BorderRadius.circular(5)),
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Solenoid Testing',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Card(
                      elevation: 7,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                      height: 50,
                                      child: Center(
                                          child: TextButton(
                                        child: FadeTransition(
                                            opacity: isTextVisible
                                                ? _animationController!
                                                : AlwaysStoppedAnimation(1.0),
                                            child: Text('OPEN')),
                                        onPressed: () {
                                          SetOpenCloseMode1PFCMD();
                                          open_pos = true;
                                          isTextVisible = false;
                                          btnstate = 'Open';
                                        },
                                      ))),
                                  Expanded(
                                    flex: 1,
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.3,
                                      child: open_pos
                                          ? Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  child: Center(
                                                    child: SpinKitFadingCircle(
                                                      size: 30,
                                                      color: Colors.blue,
                                                    ),
                                                  ),
                                                  height: 30,
                                                  width: 20,
                                                ),
                                                SizedBox(height: 10),
                                                CountdownTimerWidget(
                                                  duration: const Duration(
                                                      minutes: 4),
                                                ),
                                              ],
                                            )
                                          : Center(
                                              child: Text(
                                                '${postionvalue ?? ''} %',
                                              ),
                                            ),
                                    ),
                                  ),
                                  /*Expanded(
                                    flex: 1,
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.3,
                                      child: open_pos
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
                                          : Center(
                                              child: Text(
                                                '${postionvalue ?? ''} %',
                                              ),
                                            ),
                                    ),
                                  ),
                                  */
                                  Expanded(
                                    flex: 2,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        SizedBox(
                                            height: 50,
                                            child: Center(
                                              child: ElevatedButton(
                                                child: Text('OK',
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      valveOpen == 'Open'
                                                          ? Colors.green
                                                          : Colors.blue,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5), // Set border radius to 0 for square shape
                                                  ),
                                                ),
                                                onPressed: () {
                                                  OpenBtn = 'OK';
                                                  valveOpen = 'Open';
                                                  isText2Visible = true;
                                                },
                                              ),
                                            )),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        SizedBox(
                                            height: 50,
                                            child: Center(
                                              child: ElevatedButton(
                                                child: Text(
                                                  'NOT OK',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      valveOpen == 'Close'
                                                          ? Colors.red
                                                          : Colors.blue,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5), // Set border radius to 0 for square shape
                                                  ),
                                                ),
                                                onPressed: () {
                                                  valveOpen = 'Close';
                                                  OpenBtn = 'Not OK';
                                                  isText2Visible = true;
                                                },
                                              ),
                                            )),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                      height: 50,
                                      child: Center(
                                          child: TextButton(
                                        child: FadeTransition(
                                            opacity: isText2Visible
                                                ? _animationController!
                                                : AlwaysStoppedAnimation(1.0),
                                            child: Text('CLOSE')),
                                        onPressed: () {
                                          close_pos = true;
                                          btnstate = 'Close';
                                          isText2Visible = false;
                                          setValveClose1PFCMD();
                                        },
                                      ))),
                                  Expanded(
                                    flex: 1,
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.3,
                                      child: close_pos
                                          ? Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  child: Center(
                                                    child: SpinKitFadingCircle(
                                                      size: 30,
                                                      color: Colors.blue,
                                                    ),
                                                  ),
                                                  height: 30,
                                                  width: 20,
                                                ),
                                                SizedBox(height: 10),
                                                CountdownTimerWidget(
                                                  duration: const Duration(
                                                      minutes: 4),
                                                ),
                                              ],
                                            )
                                          : Center(
                                              child: Text(
                                                '${postionvalue ?? ''} %',
                                              ),
                                            ),
                                    ),
                                  ),
                                  /*Expanded(
                                    flex: 1,
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.3,
                                      child: close_pos
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
                                          : Center(
                                              child: Text(
                                                '${postionvalue ?? ''} %',
                                              ),
                                            ),
                                    ),
                                  ),
                                 */
                                  Expanded(
                                    flex: 2,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        SizedBox(
                                            height: 50,
                                            child: Center(
                                              child: ElevatedButton(
                                                child: Text('OK',
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      valveClose == 'Open'
                                                          ? Colors.green
                                                          : Colors.blue,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5), // Set border radius to 0 for square shape
                                                  ),
                                                ),
                                                onPressed: () {
                                                  valveClose = 'Open';
                                                  CloseBtn = 'OK';
                                                  isText3Visible = true;
                                                },
                                              ),
                                            )),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        SizedBox(
                                            height: 50,
                                            child: Center(
                                              child: ElevatedButton(
                                                child: Text(
                                                  'NOT OK',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      valveClose == 'Close'
                                                          ? Colors.red
                                                          : Colors.blue,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5), // Set border radius to 0 for square shape
                                                  ),
                                                ),
                                                onPressed: () {
                                                  isText3Visible = true;
                                                  valveClose = 'Close';
                                                  CloseBtn = 'Not OK';
                                                },
                                              ),
                                            )),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (isText3Visible)
                    Container(
                      child: Row(
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
                    ),
                ],
              ),
            ),
          ),
        ));
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
                  'You have connected to unknown device${controllerType!}',
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 25.0),
                  child: TextButton(
                    onPressed: () async {
                      _progress = 0.0;
                      _response.clear();
                      _data.clear();
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
          child: Text('Something  Went Wrong'),
        ),
      );
    }
  }

  setDatetime() async {
    try {
      String data = "${('dts 0000 00 00 00 00 00').toUpperCase()}\r\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 6)).whenComplete(() async {
        String res = _data.join('');
        int i = res.indexOf("DT");
        dtbefore = res.substring(i + 4, i + 18);
        _response = [];

        String rebootData = "${'RBT'.toUpperCase()}\r\n";
        await _port!.write(Uint8List.fromList(rebootData.codeUnits));

        await Future.delayed(Duration(seconds: 6)).whenComplete(() async {
          String newData = "${'dts'.toUpperCase()}\r\n";
          await _port!.write(Uint8List.fromList(newData.codeUnits));
          await Future.delayed(Duration(seconds: 6));
          res = _data.join('');
          i = res.indexOf("DT");
          dtafter = res.substring(i + 4, i + 21);
          if (dtbefore == dtafter) {
            lora_comm = 'Not Ok';
            if (lora_comm == 'Not Ok' && batteryVoltage == 0.0) {
              Future.delayed(Duration(seconds: 15)).whenComplete(() {
                blink = true;
              });
            }
          } else {
            lora_comm = 'Ok';
            if (lora_comm == 'Ok' && batteryVoltage == 0.0) {
              Future.delayed(Duration(seconds: 15)).whenComplete(() {
                blink = true;
              });
            }
          }
        });
      }).whenComplete(() => getINTG());
    } catch (_, ex) {
      _serialdata.add('Please Try Again...');
    }
  }

  getINTG() async {
    _data.clear();
    String data = "${'intg'.toUpperCase()}\r\n";
    _port!.write(Uint8List.fromList(data.codeUnits));
    new Future.delayed(Duration(seconds: 5)).whenComplete(() {
      String res = _data.join('');
      if (res.toLowerCase().contains('matched')) {
        getPostion();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Success"),
              content: Text("INTG Command Sent Successfully"),
              actions: [
                TextButton(
                  onPressed: () {
                    // getPostion_pfcmd_1();
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
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
                      'Command Revived Ended.',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
                    Text(
                      'Devices is not able to revive data',
                      textAlign: TextAlign.center,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 25.0),
                      child: TextButton(
                        onPressed: () {
                          getINTG();
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
        // return false;
      }
    });
  }

  getINTG2(int index) async {
    _data.clear();
    String data = "${'intg'.toUpperCase()}\r\n";
    _port!.write(Uint8List.fromList(data.codeUnits));
    new Future.delayed(Duration(seconds: 8)).whenComplete(() {
      String res = _data.join('');
      print(res);
      if (res.contains('PacketBOCOM6')) {
        switch (index) {
          case 1:
            getPostion_pfcmd_1();
            break;
          case 2:
            getPostion_pfcmd_2();
            break;
          case 3:
            getPostion_pfcmd_3();
            break;
          case 4:
            getPostion_pfcmd_4();
            break;
          case 5:
            getPostion_pfcmd_5();
            break;
          case 6:
            getPostion_pfcmd_6();
            break;
          default:
        }
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Success"),
              content: Text("INTG Command Sent Successfully"),
              actions: [
                TextButton(
                  onPressed: () {
                    // getPostion_pfcmd_1();
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      } else if (res.contains('PacketBOCOM1')) {
        getPostion();
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
                      'Command Revived Ended.',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
                    Text(
                      'Device is unable to fetch the data from device ',
                      textAlign: TextAlign.center,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 25.0),
                      child: TextButton(
                        onPressed: () {
                          getINTG2(index);
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
    });
  }

  SetOpenCloseMode1PFCMD() {
    String data = "${'PFCMD1TYPE  1 '.toUpperCase()}\r\n";
    _port!.write(Uint8List.fromList(data.codeUnits));
    new Future.delayed(Duration(seconds: 10)).whenComplete(() {
      String res = _data.join('');
      if (res.toLowerCase().contains('matched')) {
        setValveOpen1PFCMD();
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
                          SetOpenCloseMode1PFCMD();
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
    });
  }

  SetOpenCloseModePFCMD6(int index) {
    String data = "${'PFCMD6TYPE $index 1 '.toUpperCase()}\r\n";
    _port!.write(Uint8List.fromList(data.codeUnits));
    new Future.delayed(Duration(seconds: 10)).whenComplete(() {
      String res = _data.join('');
      if (res.toLowerCase().contains('matched')) {
        setValveOpenPFCMD6(index);
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
                          SetOpenCloseModePFCMD6(index);
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
    });
  }

  setValveOpenPFCMD6(int index) {
    _data.clear();
    String data = "${('PFCMD6ONOFF $index 1').toUpperCase()}\r\n";
    _port!.write(Uint8List.fromList(data.codeUnits));
    new Future.delayed(Duration(seconds: 10)).whenComplete(() {
      String res = _data.join('');

      if (res.toLowerCase().contains('pfcmd$index on')) {
        Future.delayed(Duration(minutes: 3)).whenComplete(() async {
          await getINTG2(index);
        });
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
      }
    });
  }

  setValveClosePFCMD6(int index) {
    _data.clear();
    String data = "${('PFCMD6ONOFF $index 0').toUpperCase()}\r\n";
    _port!.write(Uint8List.fromList(data.codeUnits));
    new Future.delayed(Duration(seconds: 10)).whenComplete(() {
      String res = _data.join('');

      if (res.toLowerCase().contains('pfcmd$index off')) {
        Future.delayed(Duration(minutes: 3)).whenComplete(() async {
          await getINTG2(index);
        });
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
      }
    });
  }

  setValveOpen1PFCMD() {
    _data.clear();
    String data = "${('PFCMD1ONOFF 1').toUpperCase()}\r\n";
    _port!.write(Uint8List.fromList(data.codeUnits));
    new Future.delayed(Duration(seconds: 10)).whenComplete(() {
      String res = _data.join('');

      if (res.toLowerCase().contains('pfcmd1 on')) {
        Future.delayed(Duration(minutes: 3)).whenComplete(() async {
          await getINTG2(0);
        });
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
                      'Command Revived Ended.',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
                    Text(
                      'Devices is not able to Open valve',
                      textAlign: TextAlign.center,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 25.0),
                      child: TextButton(
                        onPressed: () {
                          setValveOpen1PFCMD();
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
    });
  }

  setValveClose1PFCMD() {
    _data.clear();
    String data = "${('PFCMD1ONOFF 0').toUpperCase()}\r\n";
    _port!.write(Uint8List.fromList(data.codeUnits));
    new Future.delayed(Duration(seconds: 10)).whenComplete(() {
      String res = _data.join('');

      if (res.toLowerCase().contains('pfcmd1 off')) {
        Future.delayed(Duration(minutes: 3)).whenComplete(() async {
          await getINTG2(0);
        });
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
                      'Command Revived Ended.',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
                    Text(
                      'Devices is not able to Close Valve',
                      textAlign: TextAlign.center,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 25.0),
                      child: TextButton(
                        onPressed: () {
                          setValveClose1PFCMD();
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
    });
  }

  getpop(context) {
    return showDialog(
      barrierDismissible: false,
      useSafeArea: true,
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: AnimatedContainer(
          duration:
              Duration(milliseconds: 500), // Set the desired animation duration
          curve: Curves.easeInOut, // Set the desired animation curve
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),

          child: SizedBox(
            height: 260,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image(
                    image: AssetImage('assets/images/Iphone-spinner-2.gif'),
                    height: 80,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Sending Command...',
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  getPostion() {
    var subString3;
    try {
      subString3 = hexDecimalValue.substring(42, 46);
      int decimal = int.parse(subString3, radix: 16);
      postionvalue = (decimal / 100).toString();
      if (btnstate == 'Open') {
        open_pos = false;
      } else if (btnstate == 'Close') {
        close_pos = false;
      }
      print('data postion value' + postionvalue);
    } catch (_, ex) {
      postionvalue = 'NULL';
    }
  }

  double getBatterVoltage() {
    var subString2;
    // double batteryVoltage;
    try {
      subString2 = hexDecimalValue.substring(12, 16);
      int decimal = int.parse(subString2, radix: 16);
      batteryVoltage = (decimal / 100);
      getAlarms();
    } catch (_, ex) {
      batteryVoltage = 0.0;
    }
    return batteryVoltage;
  }

  getSOLARVoltage() {
    var subString3;
    // var BatteryVoltage;
    try {
      subString3 = hexDecimalValue.substring(16, 20);
      int decimal = int.parse(subString3, radix: 16);
      solarVoltage = (decimal / 100).toDouble();
    } catch (_, ex) {
      solarVoltage = 0.0;
    }
    return solarVoltage;
  }

  getAlarms() {
    var hexvalue;
    var BatteryVoltage;
    String binaryNumber;
    List<String> binaryValues = [];

    try {
      hexvalue = hexDecimalValue.substring(30, 34);
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

  getAI1Value() async {
    String ai1;
    String barvalue;
    try {
      String data = "${'ai 1'.toUpperCase()}\r\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 6)).whenComplete(
        () {
          print(_response);
          String res = _data.join('');
          int i = res.indexOf("AI");
          ai1 = res.substring(i + 5, i + 10);
          barvalue = res.substring(i + 10, i + 12);
          aibarvalue = double.parse(barvalue) / 1000;
          aimAvalue = double.parse(ai1);
          print('a1val0${res.substring(i + 5, i + 10)}');
          inlet_blink = false;
          getAI2Value();
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
                    'Devices is not able to revive data',
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 25.0),
                    child: TextButton(
                      onPressed: () {
                        inlet_blink = false;
                        getAI1Value();
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

      _serialdata.add('Please Try Again...');
    }
  }

  getAI2Value() async {
    String ai2;
    String barvalue;
    try {
      String data = "${'ai 2'.toUpperCase()}\r\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 6)).whenComplete(
        () async {
          print(_response);
          String res = _data.join('');
          int i = res.indexOf("AI");
          ai2 = res.substring(i + 5, i + 10);
          barvalue = res.substring(i + 10, i + 12);
          ai2barvalue = double.parse(barvalue) / 1000;
          ai2mAvalue = double.parse(ai2);
          print('a2val${res.substring(i + 5, i + 10)}');
          outlet_blink = false;
          PFCMD1_blink = true;
          PFCMD2_blink = true;
          PFCMD3_blink = true;
          PFCMD4_blink = true;
          PFCMD5_blink = true;
          PFCMD6_blink = true;

          await getAllData();
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
                    'Devices is not able to revive data',
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 25.0),
                    child: TextButton(
                      onPressed: () {
                        outlet_blink = false;
                        getAI1Value();
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

      _serialdata.add('Please Try Again...');
    }
  }

  getPostion_pfcmd_1() {
    var subString3;
    try {
      subString3 = hexDecimalValue.substring(42, 46);
      int decimal = int.parse(subString3, radix: 16);

      if (btnstate == 'Open') {
        openvalpos1 = (decimal / 100).toString();
        open1 = false;
      } else if (btnstate == 'Close') {
        closevalpos1 = (decimal / 100).toString();
        close1 = false;
      }
    } catch (_, ex) {
      print(ex);
    }
  }

  getPostion_pfcmd_2() {
    var subString3;
    try {
      subString3 = hexDecimalValue.substring(62, 66);
      int decimal = int.parse(subString3, radix: 16);
      if (btnstate == 'Open') {
        openvalpos2 = (decimal / 100).toString();
        open2 = false;
      } else if (btnstate == 'Close') {
        closevalpos2 = (decimal / 100).toString();
        close2 = false;
      }
    } catch (_, ex) {
      print(ex);
    }
  }

  getPostion_pfcmd_3() {
    var subString3;
    String postionvalue;
    try {
      subString3 = hexDecimalValue.substring(82, 86);
      int decimal = int.parse(subString3, radix: 16);
      if (btnstate == 'Open') {
        openvalpos3 = (decimal / 100).toString();
        open3 = false;
      } else if (btnstate == 'Close') {
        closevalpos3 = (decimal / 100).toString();
        close3 = false;
      }
    } catch (_, ex) {
      print(ex);
    }
  }

  getPostion_pfcmd_4() {
    var subString3;
    String postionvalue;
    try {
      subString3 = hexDecimalValue.substring(102, 106);
      int decimal = int.parse(subString3, radix: 16);
      if (btnstate == 'Open') {
        open4 = false;
        openvalpos4 = (decimal / 100).toString();
      } else if (btnstate == 'Close') {
        close4 = false;
        closevalpos4 = (decimal / 100).toString();
      }
    } catch (_, ex) {
      print(ex);
    }
  }

  getPostion_pfcmd_5() {
    var subString3;
    String postionvalue;
    try {
      subString3 = hexDecimalValue.substring(122, 126);
      int decimal = int.parse(subString3, radix: 16);
      if (btnstate == 'Open') {
        openvalpos5 = (decimal / 100).toString();
        open5 = false;
      } else if (btnstate == 'Close') {
        closevalpos5 = (decimal / 100).toString();
        close5 = false;
      }
    } catch (_, ex) {
      print(ex);
    }
  }

  getPostion_pfcmd_6() {
    var subString3;
    String postionvalue;
    try {
      subString3 = hexDecimalValue.substring(142, 146);
      int decimal = int.parse(subString3, radix: 16);
      if (btnstate == 'Open') {
        openvalpos6 = (decimal / 100).toString();
        open6 = false;
      } else if (btnstate == 'Close') {
        closevalpos6 = (decimal / 100).toString();
        close6 = false;
      }
    } catch (_, ex) {
      print(ex);
    }
  }
// outlet bar 6pfcmd

  get_outlet_pt_1_actual_val() async {
    try {
      String data = "${'AI 3'.toUpperCase()}\r\n";
      _data.clear();
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 14)).whenComplete(
        () {
          print(_data);
          String res = _data.join('');
          int i = res.indexOf("AI");

          var aisData = res.substring(i + 5);
          List<String> position_range = aisData.split(' ');
          print(position_range);

          outlet_1_value_controller = double.parse(position_range[0]);
          outlet_1_actual_count_controller = double.parse(
              position_range[1].trim().split('>').first.toString());
          print(outlet_1_value_controller.toString());
          print(outlet_1_actual_count_controller.toString());
          PFCMD1_blink = false;
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
                    'Command Revived Ended.',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                  Text(
                    'Devices is not able to revive data',
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 25.0),
                    child: TextButton(
                      onPressed: () {
                        PFCMD1_blink = true;
                        get_outlet_pt_1_actual_val();

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

      print(ex);
    }
  }

  get_outlet_pt_2_actual_val() async {
    try {
      String data = "${'AI 4'.toUpperCase()}\r\n";
      _data.clear();
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 14)).whenComplete(
        () {
          print(_data);
          String res = _data.join('');
          int i = res.indexOf("AI");

          var aisData = res.substring(i + 5);
          List<String> position_range = aisData.split(' ');
          print(position_range);

          outlet_2_value_after_controller = double.parse(position_range[0]);
          outlet_2_actual_count_after_controller = double.parse(
              position_range[1].trim().split('>').first.toString());
          print(outlet_2_value_after_controller.toString());
          print(outlet_2_actual_count_after_controller.toString());
          PFCMD2_blink = false;
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
                    'Command Revived Ended.',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                  Text(
                    'Devices is not able to revive data',
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 25.0),
                    child: TextButton(
                      onPressed: () {
                        PFCMD2_blink = true;
                        get_outlet_pt_2_actual_val();
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

      print(ex);
      _serialData.add('Please Try Again...');
    }
  }

  get_outlet_pt_3_actual_val() async {
    try {
      String data = "${'AI 5'.toUpperCase()}\r\n";
      _data.clear();
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 14)).whenComplete(
        () {
          print(_data);
          String res = _data.join('');
          int i = res.indexOf("AI");

          var aisData = res.substring(i + 5);
          List<String> position_range = aisData.split(' ');
          print(position_range);

          outlet_3_value_controller = double.parse(position_range[0]);
          outlet_3_actual_count_controller = double.parse(
              position_range[1].trim().split('>').first.toString());
          print(outlet_3_value_controller.toString());
          print(outlet_3_actual_count_controller.toString());
          PFCMD3_blink = false;
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
                    'Command Revived Ended.',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                  Text(
                    'Devices is not able to revive data',
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 25.0),
                    child: TextButton(
                      onPressed: () {
                        PFCMD3_blink = true;
                        get_outlet_pt_3_actual_val();
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

      print(ex);
      _serialData.add('Please Try Again...');
    }
  }

  get_outlet_pt_4_actual_val() async {
    try {
      String data = "${'AI 6'.toUpperCase()}\r\n";
      _data.clear();
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 14)).whenComplete(
        () {
          print(_data);
          String res = _data.join('');
          int i = res.indexOf("AI");

          var aisData = res.substring(i + 5);
          List<String> position_range = aisData.split(' ');
          print(position_range);

          outlet_4_value_controller = double.parse(position_range[0]);
          outlet_4_actual_count_controller = double.parse(
              position_range[1].trim().split('>').first.toString());
          print(outlet_4_value_controller.toString());
          print(outlet_4_actual_count_controller.toString());
          PFCMD4_blink = false;
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
                    'Command Revived Ended.',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                  Text(
                    'Devices is not able to revive data',
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 25.0),
                    child: TextButton(
                      onPressed: () {
                        PFCMD4_blink = true;
                        get_outlet_pt_4_actual_val();
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

      print(ex);
      _serialData.add('Please Try Again...');
    }
  }

  get_outlet_pt_5_actual_val() async {
    try {
      String data = "${'AI 7'.toUpperCase()}\r\n";
      _data.clear();
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 14)).whenComplete(
        () {
          print(_data);
          String res = _data.join('');
          int i = res.indexOf("AI");

          var aisData = res.substring(i + 5);
          List<String> position_range = aisData.split(' ');
          print(position_range);

          outlet_5_value_controller = double.parse(position_range[0]);
          outlet_5_actual_count_controller = double.parse(
              position_range[1].trim().split('>').first.toString());
          print(outlet_5_value_controller.toString());
          print(outlet_5_actual_count_controller.toString());
          PFCMD5_blink = false;
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
                    'Devices is not able to revive data',
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 25.0),
                    child: TextButton(
                      onPressed: () {
                        PFCMD5_blink = true;
                        get_outlet_pt_5_actual_val();
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

  get_outlet_pt_6_actual_val() async {
    try {
      String data = "${'AI 8'.toUpperCase()}\r\n";
      _data.clear();
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 14)).whenComplete(
        () {
          print(_data);
          String res = _data.join('');
          int i = res.indexOf("AI");

          var aisData = res.substring(i + 5);
          List<String> position_range = aisData.split(' ');
          print(position_range);

          outlet_6_value_controller = double.parse(position_range[0]);
          outlet_6_actual_count_controller = double.parse(
              position_range[1].trim().split('>').first.toString());
          print(outlet_6_value_controller.toString());
          print(outlet_6_actual_count_controller.toString());
          PFCMD6_blink = false;
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
                    'Devices is not able to revive data',
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 25.0),
                    child: TextButton(
                      onPressed: () {
                        PFCMD6_blink = true;
                        get_outlet_pt_6_actual_val();
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

// outlet get all func
  getAllData() async {
    await get_outlet_pt_1_actual_val();

    await get_outlet_pt_2_actual_val();

    await get_outlet_pt_3_actual_val();

    await get_outlet_pt_4_actual_val();

    await get_outlet_pt_5_actual_val();

    await get_outlet_pt_6_actual_val();
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
                  labelText: 'Device Name',
                ),
                onChanged: (value) {
                  deviceName = value;
                },
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Site Name',
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
                if (deviceName.isEmpty || siteName.isEmpty || nodeNo.isEmpty) {
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
    // Generate PDF

    if (controllerType!.contains('BOCOM1')) {
      final pdfWidgets.Document pdf = pdfWidgets.Document();
      pdf.addPage(pdfWidgets.Page(build: (context) {
        return pdfWidgets.Container(
          child: pdfWidgets.Column(
              mainAxisAlignment: pdfWidgets.MainAxisAlignment.start,
              crossAxisAlignment: pdfWidgets.CrossAxisAlignment.start,
              children: [
                pdfWidgets.Center(
                  child: pdfWidgets.Text(
                    'Auto Commissinning Report',
                    style: pdfWidgets.TextStyle(
                        fontSize: 24, fontWeight: pdfWidgets.FontWeight.bold),
                  ),
                ),
                pdfWidgets.Divider(),
                pdfWidgets.Container(
                  child: pdfWidgets.Column(
                    children: [
                      pdfWidgets.Row(
                        children: [
                          pdfWidgets.Text('Device Name :',
                              style: pdfWidgets.TextStyle(
                                  fontWeight: pdfWidgets.FontWeight.bold)),
                          pdfWidgets.SizedBox(width: 20),
                          pdfWidgets.Text(deviceName)
                        ],
                      ),
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
                                '$Door1',
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
                                '$Door2',
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
                pdfWidgets.Padding(
                  padding: const pdfWidgets.EdgeInsets.all(8.0),
                  child: pdfWidgets.Container(
                    decoration: pdfWidgets.BoxDecoration(
                        borderRadius: pdfWidgets.BorderRadius.circular(5)),
                    width: double.infinity,
                    child: pdfWidgets.Padding(
                      padding: const pdfWidgets.EdgeInsets.all(8.0),
                      child: pdfWidgets.Text(
                        'PT Valve Test',
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
                              child: pdfWidgets.Text('Inlet PT'),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                '${aimAvalue.toString()} mA',
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                '${aibarvalue.toString()} bar',
                              ),
                            ),
                          ),
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
                              child: pdfWidgets.Text('Outlet PT'),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                '${ai2mAvalue.toString() ?? ''} mA',
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                '${ai2barvalue.toString() ?? ''} mA',
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
                                  '${postionvalue.toString()} %',
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
                                  '${postionvalue.toString()} %',
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
                    pdfWidgets.Text(username!)
                  ],
                ),
                pdfWidgets.SizedBox(height: 10),
                pdfWidgets.Row(
                  children: [
                    pdfWidgets.Text('Date: ',
                        style: pdfWidgets.TextStyle(
                            fontWeight: pdfWidgets.FontWeight.bold)),
                    pdfWidgets.Text(Cdate!)
                  ],
                ),
              ]),
        );
      }));
      savePDF(pdf, context);
    } else if (controllerType!.contains('BOCOM6')) {
      final pdfWidgets.Document pdf = pdfWidgets.Document();
      pdf.addPage(pdfWidgets.Page(build: (context) {
        return pdfWidgets.Container(
          child: pdfWidgets.Column(
              mainAxisAlignment: pdfWidgets.MainAxisAlignment.start,
              crossAxisAlignment: pdfWidgets.CrossAxisAlignment.start,
              children: [
                pdfWidgets.Center(
                  child: pdfWidgets.Text(
                    'Auto Commissinning Report',
                    style: pdfWidgets.TextStyle(
                        fontSize: 24, fontWeight: pdfWidgets.FontWeight.bold),
                  ),
                ),
                pdfWidgets.Divider(),
                pdfWidgets.Container(
                  child: pdfWidgets.Column(
                    children: [
                      pdfWidgets.Row(
                        children: [
                          pdfWidgets.Text('Device Name :',
                              style: pdfWidgets.TextStyle(
                                  fontWeight: pdfWidgets.FontWeight.bold)),
                          pdfWidgets.SizedBox(width: 20),
                          pdfWidgets.Text(deviceName)
                        ],
                      ),
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
                                '$Door1',
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
                                '$Door2',
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
                              child: pdfWidgets.Text('Before Inlet PT'),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                '${aimAvalue.toString()} mA',
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                '${aibarvalue.toString()} bar',
                              ),
                            ),
                          ),
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
                              child: pdfWidgets.Text('After Inlet PT'),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                '${ai2mAvalue.toString() ?? ''} mA',
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                '${ai2barvalue.toString() ?? ''} mA',
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
                                '${outlet_1_value_controller.toString()} mA',
                              ),
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
                              child: pdfWidgets.Text('Outlet PT 2'),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                '${outlet_2_value_after_controller?.toString() ?? ''} mA',
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                '${outlet_2_actual_count_after_controller?.toString() ?? ''} mA',
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
                                '${outlet_3_value_controller?.toString() ?? ''} mA',
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                '${outlet_3_actual_count_controller?.toString() ?? ''} mA',
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
                                '${outlet_4_value_controller?.toString() ?? ''} mA',
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                '${outlet_4_actual_count_controller?.toString() ?? ''} mA',
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
                                '${outlet_5_value_controller?.toString() ?? ''} mA',
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                '${outlet_5_value_controller?.toString() ?? ''} mA',
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
                                '${outlet_6_value_controller?.toString() ?? ''} mA',
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                '${outlet_6_actual_count_controller?.toString() ?? ''} mA',
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
                    pdfWidgets.Text(username!)
                  ],
                ),
                pdfWidgets.SizedBox(height: 10),
                pdfWidgets.Row(
                  children: [
                    pdfWidgets.Text('Date: ',
                        style: pdfWidgets.TextStyle(
                            fontWeight: pdfWidgets.FontWeight.bold)),
                    pdfWidgets.Text(Cdate!)
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
                /* pdfWidgets.Center(
                  child: pdfWidgets.Text(
                    'Auto Commissinning Report',
                    style: pdfWidgets.TextStyle(
                        fontSize: 24, fontWeight: pdfWidgets.FontWeight.bold),
                  ),
                ),
                pdfWidgets.Divider(),
                pdfWidgets.Container(
                  child: pdfWidgets.Column(
                    children: [
                      pdfWidgets.Row(
                        children: [
                          pdfWidgets.Text('Device Name :',
                              style: pdfWidgets.TextStyle(
                                  fontWeight: pdfWidgets.FontWeight.bold)),
                          pdfWidgets.SizedBox(width: 20),
                          pdfWidgets.Text(deviceName)
                        ],
                      ),
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
                                '$Door1',
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
                                '$Door2',
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
                              child: pdfWidgets.Text('Before Inlet PT'),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                '${aimAvalue.toString()} mA',
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                '${aibarvalue.toString()} bar',
                              ),
                            ),
                          ),
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
                              child: pdfWidgets.Text('After Inlet PT'),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                '${ai2mAvalue.toString() ?? ''} mA',
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                '${ai2barvalue.toString() ?? ''} mA',
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
                                '${outlet_1_value_controller.toString()} mA',
                              ),
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
                              child: pdfWidgets.Text('Outlet PT 2'),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                '${outlet_2_value_after_controller?.toString() ?? ''} mA',
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                '${outlet_2_actual_count_after_controller?.toString() ?? ''} mA',
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
                                '${outlet_3_value_controller?.toString() ?? ''} mA',
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                '${outlet_3_actual_count_controller?.toString() ?? ''} mA',
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
                                '${outlet_4_value_controller?.toString() ?? ''} mA',
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                '${outlet_4_actual_count_controller?.toString() ?? ''} mA',
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
                                '${outlet_5_value_controller?.toString() ?? ''} mA',
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                '${outlet_5_value_controller?.toString() ?? ''} mA',
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
                                '${outlet_6_value_controller?.toString() ?? ''} mA',
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                '${outlet_6_actual_count_controller?.toString() ?? ''} mA',
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
                */
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
                    pdfWidgets.Text(username!)
                  ],
                ),
                pdfWidgets.SizedBox(height: 10),
                pdfWidgets.Row(
                  children: [
                    pdfWidgets.Text('Date: ',
                        style: pdfWidgets.TextStyle(
                            fontWeight: pdfWidgets.FontWeight.bold)),
                    pdfWidgets.Text(Cdate!)
                  ],
                ),
              ]),
        );
      }));

      savePDF(pdf, context);
    } else {
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
    // Save PDF to file
  }

  String? username;
  getusername() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    username = preferences.getString("firstname")!;
  }

  String? Cdate;
  getcurrentdate() async {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('d-MMM-y H:m:s');
    final String formatted = formatter.format(now);
    Cdate = formatted;
  }

  // void savePDF(pdfWidgets.Document pdf) async {
  //   String downloadPath = '/storage/emulated/0/Download';
  //   String pdfName = '${deviceName}-${siteName}-${nodeNo}.pdf';
  //   File file = File('$downloadPath/$pdfName');
  //   await file.writeAsBytes(await pdf.save());
  //   print('PDF saved successfully');
  // }

  void savePDF(pdfWidgets.Document pdf, BuildContext context) async {
    String downloadPath = '/storage/emulated/0/Download';
    String pdfName = '${deviceName}-${siteName}-${nodeNo}.pdf';
    File file = File('$downloadPath/$pdfName');
    try {
      await file.writeAsBytes(await pdf.save());
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

  Future<void> _startTask(int sec) async {
    // Simulating a 15-second task that updates progress every second
    for (int i = 1; i <= sec; i++) {
      await Future.delayed(Duration(seconds: 1));
      setState(() {
        _progress = i / sec; // Update the progress based on the task completion
      });
    }
  }

  getpop_loader(context) {
    return showDialog(
      barrierDismissible: false,
      useSafeArea: true,
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: AnimatedContainer(
          duration:
              Duration(milliseconds: 500), // Set the desired animation duration
          curve: Curves.easeInOut, // Set the desired animation curve
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),

          child: SizedBox(
            height: 260,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 130,
                      width: 130,
                      child: CircularProgressIndicator(
                        strokeWidth: 10,
                        value: _progress,
                        backgroundColor: Colors.grey,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ),
                    Text(
                      '${(_progress * 100).toStringAsFixed(1)}%',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(
                  height: 25,
                ),
                Text(
                  'Sending Commands...',
                  style: TextStyle(
                      color: Colors.black,
                      // fontWeight: FontWeight.bold,
                      fontSize: 19),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  getSiteName() async {
    try {
      _progress = 0.0;
      _startTask(30);
      getpop_loader(context);
      Future.delayed(Duration(milliseconds: 30400), () {
        Navigator.pop(context); //pop dialog
      });

      await Future.delayed(Duration(seconds: 9)).whenComplete(
        () async {
          String res = _data.join('');
          int i = res.indexOf("SI");
          controllerType = res.substring(i + 5, i + 13);
          if (controllerType!.toLowerCase().contains('boc')) {
            setState(() {
              controllerType = res.substring(i + 5, i + 13);
            });
            deviceType = _data.join();
            print('Controller Type :${controllerType!}');
            await setDatetime().then((_) {
              getINTG();
            });
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
                              _data.clear();
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
