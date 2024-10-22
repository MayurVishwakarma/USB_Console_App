// ignore_for_file: prefer_const_constructors, prefer_interpolation_to_compose_strings, unused_import, camel_case_types, unused_field, prefer_final_fields

import 'dart:async';
import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:usb_console_application/core/app_export.dart';
import 'package:get/get.dart';
import 'package:hex/hex.dart';
import 'package:intl/intl.dart';
import 'package:usb_serial/transaction.dart';
import 'package:usb_serial/usb_serial.dart';

class operation_mode extends StatefulWidget {
  const operation_mode({super.key});

  @override
  State<operation_mode> createState() => _operation_modeState();
}

class _operation_modeState extends State<operation_mode> {
  UsbPort? _port;
  String _status = "Idle";
  List<UsbDevice> _devices = [];
  List<String> _serialdata = [];
  List<String> _response = [];
  String? _datetime;
  String btntxt = 'Connect';
  String contbtntxt = 'Control Panel';
  String? controllerType;
  double _progress = 0.0;
  String? deviceType;
  TextEditingController _datetimecontroller = TextEditingController();
  TextEditingController setOpreationTypesetOpreationTypesetOpreationType =
      TextEditingController();
  TextEditingController _sustainingcontroller = TextEditingController();
  TextEditingController _reducingcontroller = TextEditingController();
  // TextEditingController _positioncontroller = TextEditingController();
  TextEditingController _flowsetpointcontroller = TextEditingController();
  String openclosetbnname = '';
  String modebtntxt = 'Auto';
  String _name = '';
  String btnName = 'Flow Control';
  final _formKey = GlobalKey<FormState>();
  StreamSubscription<String>? _subscription;
  Transaction<String>? _transaction;
  StreamSubscription<Uint8List>? _dataSubscription;
  List<String> _serialData = [];
  List<int> _dataBuffer = [];
  List<String> _data = [];
  List<String> list = <String>[
    'PFCMD 1',
    'PFCMD 2',
    'PFCMD 3',
    'PFCMD 4',
    'PFCMD 5',
    'PFCMD 6'
  ];
  String? dropdownValue;
  int? pfcmdno = 1;
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
    dropdownValue = list.first;
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
      if (_data.join().contains('BOCOM1')) {
        hexDecimalValue =
            reverseString(reverseString(_response.join()).substring(0, 70));
      } else if (_data.join().contains('BOCOM6')) {
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
              onPressed: _port == null
                  ? null
                  : () async {
                      if (_port == null) {
                        return;
                      }
                      _progress = 0.0;
                      _startTask(6).whenComplete(() => Navigator.pop(context));
                      getpop_loader(context);
                      String data = 'SINM'.toUpperCase() + "\r\n";
                      _response.clear();
                      _data.clear();
                      hexDecimalValue = '';
                      await _port!.write(Uint8List.fromList(data.codeUnits));
                      await getSiteName();
                    },
              child: Text("SINM"),
            ),
            if (hexDecimalValue.isNotEmpty) infoCardWidget(),
          ],
        ),
      ),
    );
  }

  Widget infoCardWidget() {
    try {
      if (_data.join().contains('BOCOM1')) {
        return Card(
          elevation: 8,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(),
                      width: MediaQuery.of(context).size.width * 0.30,
                      child: Text(
                        "PFCMD OPERATION MODE",
                        textScaleFactor: 1,
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        height: 35,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        width: MediaQuery.of(context).size.width * 0.30,
                        child: Center(
                          child: Text(
                            "MANUAL",
                            textScaleFactor: 1,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                      width: 55,
                      child: ElevatedButton(
                          onPressed: _port == null
                              ? null
                              : () async {
                                  _progress = 0.0;
                                  _startTask(10);
                                  getpop_loader(context);
                                  Future.delayed(Duration(seconds: 12), () {
                                    Navigator.pop(context); //pop dialog
                                  });
                                  await SetMode();
                                },
                          child: Text('Set')),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(),
                      width: MediaQuery.of(context).size.width * 0.30,
                      child: Text(
                        "CONTROL MODE",
                        textScaleFactor: 1,
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        height: 35,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        width: MediaQuery.of(context).size.width * 0.30,
                        child: Center(
                          child: Text(
                            "Flow Control",
                            textScaleFactor: 1,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (_sustainingcontroller.text.isNotEmpty &&
                        _reducingcontroller.text.isNotEmpty &&
                        _flowsetpointcontroller.text.isNotEmpty)
                      SizedBox(
                        height: 30,
                        width: 55,
                        child: ElevatedButton(
                            onPressed: _port == null
                                ? null
                                : () async {
                                    _progress = 0.0;
                                    _startTask(10);
                                    getpop_loader(context);
                                    Future.delayed(Duration(seconds: 12), () {
                                      Navigator.pop(context); //pop dialog
                                    });
                                    await setOpreationType();
                                  },
                            child: Text('Set')),
                      )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.black)),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(9.0),
                              child: Text(
                                'Flow Set Point :',
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 85,
                              child: TextFormField(
                                controller: _flowsetpointcontroller,
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                validator: (name) {
                                  if (name!.isEmpty) {
                                    return 'Please enter a value';
                                  }
                                  final doubleValue = double.tryParse(name);
                                  if (doubleValue == null) {
                                    return 'Please enter a valid number';
                                  }
                                  if (doubleValue < 0 || doubleValue > 50) {
                                    return 'Please enter a value between 0 and 50';
                                  }
                                  return null; // Return null if the input is valid
                                },
                                // update the state variable when the text changes
                                onChanged: (text) => setState(() {
                                  _name = text;
                                  _formKey.currentState!.validate();
                                }),
                              ),
                            ),
                            Text('(lps)')
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(9.0),
                              child: Text(
                                'Sustaining Pressure :',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                            SizedBox(
                              width: 85,
                              child: TextFormField(
                                controller: _sustainingcontroller,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter a value';
                                  }
                                  final doubleValue = double.tryParse(value);
                                  if (doubleValue == null) {
                                    return 'Please enter a valid number';
                                  }
                                  if (doubleValue < 0 || doubleValue > 100) {
                                    return 'Please enter a value between 0 and 50';
                                  }
                                  return null; // Return null if the input is valid
                                },
                                // update the state variable when the text changes
                                onChanged: (value) => setState(() {
                                  _formKey.currentState!.validate();
                                }),
                              ),
                            ),
                            Text('(m)')
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(9.0),
                              child: Text(
                                'Reducing Pressure :',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                            SizedBox(
                              width: 85,
                              child: TextFormField(
                                controller: _reducingcontroller,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter a value';
                                  }
                                  final doubleValue = double.tryParse(value);
                                  if (doubleValue == null) {
                                    return 'Please enter a valid number';
                                  }
                                  if (doubleValue < 0 || doubleValue > 100) {
                                    return 'Please enter a value between 0 and 50';
                                  }
                                  return null; // Return null if the input is valid
                                },
                                // update the state variable when the text changes
                                onChanged: (value) => setState(() {
                                  _formKey.currentState!.validate();
                                }),
                              ),
                            ),
                            Text('(m)')
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(),
                      width: MediaQuery.of(context).size.width * 0.30,
                      child: Text(
                        "IRRIGATION",
                        textScaleFactor: 1,
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
                    SizedBox(width: 10),
                    Container(
                      height: 35,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      width: MediaQuery.of(context).size.width * 0.30,
                      child: Center(
                        child: Text(
                          "Enable",
                          textScaleFactor: 1,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    SizedBox(
                      height: 30,
                      width: 55,
                      child: ElevatedButton(
                        onPressed: _port == null
                            ? null
                            : () async {
                                _progress = 0.0;
                                _startTask(10);
                                getpop_loader(context);
                                Future.delayed(Duration(seconds: 12), () {
                                  Navigator.pop(context); //pop dialog
                                });
                                await Set_irrigation_mode();
                              },
                        child: Text('Set'),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(),
                      width: MediaQuery.of(context).size.width * 0.30,
                      child: Text(
                        "EMERGENCY STOP",
                        textScaleFactor: 1,
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
                    SizedBox(width: 10),
                    Container(
                      height: 35,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      width: MediaQuery.of(context).size.width * 0.30,
                      child: Center(
                        child: Text(
                          "Disable",
                          textScaleFactor: 1,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    SizedBox(
                      height: 30,
                      width: 55,
                      child: ElevatedButton(
                        onPressed: _port == null
                            ? null
                            : () async {
                                _progress = 0.0;
                                _startTask(10);
                                getpop_loader(context);
                                Future.delayed(Duration(seconds: 12), () {
                                  Navigator.pop(context); //pop dialog
                                });
                                await Set_Emergency_mode();
                              },
                        child: Text('Set'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      } else if (_data.join().contains('BOCOM6')) {
        return Expanded(
          child: SingleChildScrollView(
            child: Card(
              elevation: 8,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 168, 211, 237),
                          borderRadius: BorderRadius.circular(5)),
                      width: MediaQuery.of(context).size.width,
                      child: DropdownButton(
                        underline: Container(color: Colors.transparent),
                        isExpanded: true,
                        value: dropdownValue,
                        items: list.map((String items) {
                          return DropdownMenuItem(
                            value: items,
                            child: Center(
                              child: Text(
                                items,
                                textScaleFactor: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 11,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? seletedtype) {
                          dropdownValue = seletedtype;
                          if (seletedtype == 'PFCMD 1') {
                            setState(() {
                              pfcmdno = 1;
                            });
                          } else if (seletedtype == 'PFCMD 2') {
                            setState(() {
                              pfcmdno = 2;
                            });
                          } else if (seletedtype == 'PFCMD 3') {
                            setState(() {
                              pfcmdno = 3;
                            });
                          } else if (seletedtype == 'PFCMD 4') {
                            setState(() {
                              pfcmdno = 4;
                            });
                          } else if (seletedtype == 'PFCMD 5') {
                            setState(() {
                              pfcmdno = 5;
                            });
                          } else if (seletedtype == 'PFCMD 6') {
                            setState(() {
                              pfcmdno = 6;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(),
                          width: MediaQuery.of(context).size.width * 0.30,
                          child: Text(
                            "PFCMD OPERATION MODE",
                            textScaleFactor: 1,
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            height: 35,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            width: MediaQuery.of(context).size.width * 0.30,
                            child: Center(
                              child: Text(
                                "MANUAL",
                                textScaleFactor: 1,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                          width: 55,
                          child: ElevatedButton(
                              onPressed: _port == null
                                  ? null
                                  : () async {
                                      _progress = 0.0;
                                      _startTask(10);
                                      getpop_loader(context);
                                      Future.delayed(Duration(seconds: 12), () {
                                        Navigator.pop(context); //pop dialog
                                      });
                                      await SetMode6(pfcmdno!);
                                    },
                              child: Text('Set')),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(),
                          width: MediaQuery.of(context).size.width * 0.30,
                          child: Text(
                            "CONTROL MODE",
                            textScaleFactor: 1,
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            height: 35,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            width: MediaQuery.of(context).size.width * 0.30,
                            child: Center(
                              child: Text(
                                "Flow Control",
                                textScaleFactor: 1,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (_sustainingcontroller.text.isNotEmpty &&
                            _reducingcontroller.text.isNotEmpty &&
                            _flowsetpointcontroller.text.isNotEmpty)
                          SizedBox(
                            height: 30,
                            width: 55,
                            child: ElevatedButton(
                                onPressed: _port == null
                                    ? null
                                    : () async {
                                        _progress = 0.0;
                                        getpop_loader(context);
                                        _startTask(12).whenComplete(
                                            () => Navigator.pop(context));
                                        await setOpreationType6(pfcmdno!);
                                      },
                                child: Text('Set')),
                          )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: Colors.black)),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(9.0),
                                  child: Text(
                                    'Flow Set Point :',
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 85,
                                  child: TextFormField(
                                    controller: _flowsetpointcontroller,
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    validator: (name) {
                                      if (name!.isEmpty) {
                                        return 'Please enter a value';
                                      }
                                      final doubleValue =
                                          double.tryParse(name);
                                      if (doubleValue == null) {
                                        return 'Please enter a valid number';
                                      }
                                      if (doubleValue < 0 || doubleValue > 50) {
                                        return 'Please enter a value between 0 and 50';
                                      }
                                      return null; // Return null if the input is valid
                                    },
                                    // update the state variable when the text changes
                                    onChanged: (text) => setState(() {
                                      _name = text;
                                      _formKey.currentState!.validate();
                                    }),
                                  ),
                                ),
                                Text('(lps)')
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(9.0),
                                  child: Text(
                                    'Sustaining Pressure :',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                                SizedBox(
                                  width: 85,
                                  child: TextFormField(
                                    controller: _sustainingcontroller,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please enter a value';
                                      }
                                      final doubleValue =
                                          double.tryParse(value);
                                      if (doubleValue == null) {
                                        return 'Please enter a valid number';
                                      }
                                      if (doubleValue < 0 ||
                                          doubleValue > 100) {
                                        return 'Please enter a value between 0 and 50';
                                      }
                                      return null; // Return null if the input is valid
                                    },
                                    // update the state variable when the text changes
                                    onChanged: (value) => setState(() {
                                      _formKey.currentState!.validate();
                                    }),
                                  ),
                                ),
                                Text('(m)')
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(9.0),
                                  child: Text(
                                    'Reducing Pressure :',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                                SizedBox(
                                  width: 85,
                                  child: TextFormField(
                                    controller: _reducingcontroller,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please enter a value';
                                      }
                                      final doubleValue =
                                          double.tryParse(value);
                                      if (doubleValue == null) {
                                        return 'Please enter a valid number';
                                      }
                                      if (doubleValue < 0 ||
                                          doubleValue > 100) {
                                        return 'Please enter a value between 0 and 50';
                                      }
                                      return null; // Return null if the input is valid
                                    },
                                    // update the state variable when the text changes
                                    onChanged: (value) => setState(() {
                                      _formKey.currentState!.validate();
                                    }),
                                  ),
                                ),
                                Text('(m)')
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(),
                          width: MediaQuery.of(context).size.width * 0.30,
                          child: Text(
                            "IRRIGATION",
                            textScaleFactor: 1,
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ),
                        SizedBox(width: 10),
                        Container(
                          height: 35,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          width: MediaQuery.of(context).size.width * 0.30,
                          child: Center(
                            child: Text(
                              "Enable",
                              textScaleFactor: 1,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        SizedBox(
                          height: 30,
                          width: 55,
                          child: ElevatedButton(
                            onPressed: _port == null
                                ? null
                                : () async {
                                    _progress = 0.0;
                                    _startTask(10);
                                    getpop_loader(context);
                                    Future.delayed(Duration(seconds: 12), () {
                                      Navigator.pop(context); //pop dialog
                                    });
                                    await Set_irrigation_mode6(pfcmdno!);
                                  },
                            child: Text('Set'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(),
                          width: MediaQuery.of(context).size.width * 0.30,
                          child: Text(
                            "EMERGENCY STOP",
                            textScaleFactor: 1,
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ),
                        SizedBox(width: 10),
                        Container(
                          height: 35,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          width: MediaQuery.of(context).size.width * 0.30,
                          child: Center(
                            child: Text(
                              "Disable",
                              textScaleFactor: 1,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        SizedBox(
                          height: 30,
                          width: 55,
                          child: ElevatedButton(
                            onPressed: _port == null
                                ? null
                                : () async {
                                    _progress = 0.0;
                                    _startTask(10);
                                    getpop_loader(context);
                                    Future.delayed(Duration(seconds: 12), () {
                                      Navigator.pop(context); //pop dialog
                                    });
                                    await Set_Emergency_mode();
                                  },
                            child: Text('Set'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
                  'You have connected to unknown device' +
                      controllerType!.toString(),
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

  getSiteName() async {
    try {
      _startTask(30);
      getpop_loader(context);
      Future.delayed(Duration(milliseconds: 30400), () {
        Navigator.pop(context); //pop dialog
      });

      await Future.delayed(Duration(seconds: 9)).whenComplete(
        () {
          String res = _data.join('');
          int i = res.indexOf("SI");
          controllerType = res.substring(i + 5, i + 13);
          if (controllerType!.toLowerCase().contains('boc')) {
            setState(() {
              controllerType = res.substring(i + 5, i + 13);
            });
            deviceType = _data.join();
            print('Controller Type :' + controllerType!);
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
                              String data = 'SINM'.toUpperCase() + "\r\n";
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
    } catch (_) {
      _serialData.add('Please Try Again...');
    }
  }

  setOpreationType() {
    String data = ('PFCMD1TYPE 2 ' +
                _flowsetpointcontroller.text +
                ' ' +
                _sustainingcontroller.text +
                ' ' +
                _reducingcontroller.text)
            .toUpperCase() +
        "\r\n";
    _port!.write(Uint8List.fromList(data.codeUnits));
    Future.delayed(Duration(seconds: 5)).whenComplete(() {
      String res = _data.join('');
      print(res + 'resooos');
      if (res.toLowerCase().contains('matched')) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Success"),
              content: Text("Command Sent Successfully"),
              actions: [
                TextButton(
                  onPressed: () {
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
                          setOpreationType();
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

  SetMode() async {
    String data = 'SMODE 2 1 1'.toUpperCase() + "\r\n";
    await _port!.write(Uint8List.fromList(data.codeUnits));
    Future.delayed(Duration(seconds: 5)).whenComplete(() {
      String res = _data.join('');
      print(res + 'resooos');
      if (res.toLowerCase().contains('matched')) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Success"),
              content: Text("Command Sent Successfully"),
              actions: [
                TextButton(
                  onPressed: () {
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
                          SetMode();
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

  Set_irrigation_mode() async {
    String data = 'STPIRR 0'.toUpperCase() + "\r\n";
    await _port!.write(Uint8List.fromList(data.codeUnits));
    Future.delayed(Duration(seconds: 5)).whenComplete(() {
      String res = _data.join('');
      print(res + 'resooos');
      if (res.toLowerCase().contains('matched')) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Success"),
              content: Text("Command Sent Successfully"),
              actions: [
                TextButton(
                  onPressed: () {
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
                          Set_irrigation_mode();
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

  Set_Emergency_mode() async {
    String data = 'EMS 0'.toUpperCase() + "\r\n";
    await _port!.write(Uint8List.fromList(data.codeUnits));
    Future.delayed(Duration(seconds: 5)).whenComplete(() {
      String res = _data.join('');
      print(res + 'resooos');
      if (res.toLowerCase().contains('matched')) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Success"),
              content: Text("Command Sent Successfully"),
              actions: [
                TextButton(
                  onPressed: () {
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
                          Set_Emergency_mode();
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

  SetMode6(int index) async {
    String data = 'SMODE $index 2 1 1'.toUpperCase() + "\r\n";
    await _port!.write(Uint8List.fromList(data.codeUnits));
    Future.delayed(Duration(seconds: 5)).whenComplete(() {
      String res = _data.join('');
      print(res + 'resooos');
      if (res.toLowerCase().contains('matched')) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Success"),
              content: Text("Command Sent Successfully"),
              actions: [
                TextButton(
                  onPressed: () {
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
                          SetMode6(index);
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

  setOpreationType6(int index) {
    String data = ('PFCMD6TYPE $index 2 ' +
                _flowsetpointcontroller.text +
                ' ' +
                _sustainingcontroller.text +
                ' ' +
                _reducingcontroller.text)
            .toUpperCase() +
        "\r\n";
    _port!.write(Uint8List.fromList(data.codeUnits));

    Future.delayed(Duration(seconds: 5)).whenComplete(() {
      String res = _data.join('');
      print(res + 'resooos');
      if (res.toLowerCase().contains('matched')) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Success"),
              content: Text("Command Sent Successfully"),
              actions: [
                TextButton(
                  onPressed: () {
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
                          setOpreationType6(index);
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

  Set_irrigation_mode6(int i) async {
    String data = 'STPIRR $i 0'.toUpperCase() + "\r\n";
    await _port!.write(Uint8List.fromList(data.codeUnits));
    Future.delayed(Duration(seconds: 5)).whenComplete(() {
      String res = _data.join('');
      print(res + 'resooos');
      if (res.toLowerCase().contains('matched')) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Success"),
              content: Text("Command Sent Successfully"),
              actions: [
                TextButton(
                  onPressed: () {
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
                          Set_irrigation_mode6(i);
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
}
