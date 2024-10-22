// ignore_for_file: prefer_const_constructors, unnecessary_null_comparison, unused_local_variable, prefer_typing_uninitialized_variables, non_constant_identifier_names, unused_catch_stack, unused_field, prefer_final_fields, prefer_const_constructors_in_immutables, prefer_interpolation_to_compose_strings, use_build_context_synchronously, unnecessary_new, sized_box_for_whitespace, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables, file_names, unused_import, avoid_print

import 'dart:async';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:hex/hex.dart';
import 'package:intl/intl.dart';
import 'package:usb_serial/transaction.dart';
import 'package:usb_serial/usb_serial.dart';

class ProcessMonitoringScreen extends StatefulWidget {
  ProcessMonitoringScreen({Key? key}) : super(key: key);

  @override
  State<ProcessMonitoringScreen> createState() =>
      _ProcessMonitoringScreenState();
}

class _ProcessMonitoringScreenState extends State<ProcessMonitoringScreen> {
  UsbPort? _port;
  String _status = "Idle";
  List<UsbDevice> _devices = [];
  List<String> _response = [];
  List<String> _serialData = [];
  double _progress = 0.0;
  String macId = '';
  String btntxt = 'Connect';
  var hexDecimalValue = '';
  String? controllerType;
  String? deviceType;
  String openclosetbnname = '';
  StreamSubscription<Uint8List>? _dataSubscription;
  List<int> _dataBuffer = [];
  List<String> _data = [];
  final _formKey = GlobalKey<FormState>();
  TextEditingController _flowsetpointcontroller = TextEditingController();
  TextEditingController _sustainingcontroller = TextEditingController();
  TextEditingController _reducingcontroller = TextEditingController();
  TextEditingController _positioncontroller = TextEditingController();
  TextEditingController _textController = TextEditingController();
  TextEditingController _datetimecontroller = TextEditingController();
  String modebtntxt = '';
  String _name = '';
  String btnName = '';
  String contbtntxt = 'Control Panel';
  bool isShowpop = false;
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

  getMID() async {
    try {
      String data = 'mid'.toUpperCase() + "\r\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
      _startTask(15).whenComplete(() {
        Navigator.pop(context);
      });
      getpop_loader(context);
      await Future.delayed(Duration(seconds: 10)).whenComplete(
        () {
          String res = _data.join('');
          print(res);
          int i = res.indexOf("MI");
          String substring = res.substring(i + 4, i + 20);
          RegExp pattern = RegExp(r'^[0-9A-F]{16}$');
          bool matchesPattern = pattern.hasMatch(substring);
          if (matchesPattern) {
            setState(() {
              macId = res.substring(i + 4, i + 20);
            });
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
                              controllerType!.toString(),
                          textAlign: TextAlign.center,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 25.0),
                          child: TextButton(
                            onPressed: () {
                              _progress = 0.0;
                              Navigator.of(context).pop();
                              getINTGCommand();
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
                              _startTask(15);
                              getpop_loader(context);
                              Future.delayed(Duration(milliseconds: 15), () {
                                Navigator.pop(context); //pop dialog
                              });
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
                        getINTGCommand();
                        _progress = 0.0;
                        _startTask(15);
                        getpop_loader(context);
                        Future.delayed(Duration(seconds: 16), () {
                          Navigator.pop(context); //pop dialog
                        });
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

            new Future.delayed(Duration(seconds: 12))
                .whenComplete(() => getMID());
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
    } catch (_, ex) {
      _serialData.add('Please Try Again...');
    }
  }

  getINTGCommand() async {
    _startTask(6).whenComplete(() => Navigator.pop(context));
    getpop_loader(context);
    String data = 'INTG'.toUpperCase() + "\r\n";
    _response.clear();
    _data.clear();

    hexDecimalValue = '';
    await _port!.write(Uint8List.fromList(data.codeUnits));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Process Monitering'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _progress = 0.0;
          await getINTGCommand();
        },
        child: Container(
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
                        _startTask(6)
                            .whenComplete(() => Navigator.pop(context));
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
      ),
    );
  }

  Widget infoCardWidget() {
    try {
      if (controllerType!.contains('BOCOM1')) {
        return Expanded(
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          offset: const Offset(
                            2.0,
                            2.0,
                          ),
                          blurRadius: 5.0,
                          spreadRadius: 1.0,
                        ), //BoxShadow
                      ],
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15)),
                  width: MediaQuery.of(context).size.width * 0.95,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15))),
                        height: 30,
                        width: MediaQuery.of(context).size.width * 0.97,
                        child: Center(
                          child: Text(
                            'Mac Id : ' + macId,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 10, right: 10),
                            child: Column(
                              children: [
                                Image(
                                  image: AssetImage(
                                      "assets/images/thermometer.png"),
                                  height: 30,
                                  width: 30,
                                  alignment: Alignment.centerRight,
                                ),
                                Text(
                                  getTemprature().toString(),
                                  style: TextStyle(fontSize: 8),
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10, right: 10),
                            child: Column(
                              children: [
                                Image(
                                  image: AssetImage(
                                      "assets/images/solar_weak.png"),
                                  height: 30,
                                  width: 30,
                                  alignment: Alignment.centerRight,
                                ),
                                Text(
                                  getSOLARVoltage().toString(),
                                  style: TextStyle(fontSize: 8),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            padding: EdgeInsets.only(left: 8),
                            // color: Colors.lightBlue.shade300,

                            width: 150,
                            height: 100,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Door: ',
                                      textScaleFactor: 1,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      getAlarms(0) == '1' || getAlarms(1) == '1'
                                          ? 'OPEN'
                                          : 'CLOSE',
                                      textScaleFactor: 1,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: getAlarms(0) == '1' ||
                                                getAlarms(1) == '1'
                                            ? Colors.red
                                            : Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Solar Voltage : ',
                                      textScaleFactor: 1,
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      getSOLARVoltage().toString() + " V",
                                      textScaleFactor: 1,
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: getSolarColor(0.0),
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Inlet Press : ',
                                      textScaleFactor: 1,
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      getAI2().toString() + " m",
                                      textScaleFactor: 1,
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: 16.12 != 0
                                              ? Colors.green
                                              : Colors.red),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          Container(
                            // color: Colors.deepPurple.shade300,
                            width: 150,
                            height: 100,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'FW Version : ',
                                      textScaleFactor: 1,
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Expanded(
                                      child: Text(
                                        getFirmwareVersion().toString(),
                                        textScaleFactor: 1,
                                        // values[index].areaName!,
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Battery Voltage : ',
                                      textScaleFactor: 1,
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(getBatterVoltage().toString(),
                                        textScaleFactor: 1,
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: ((16.3) > 17
                                                ? Colors.green
                                                : Colors.red),
                                            fontWeight: FontWeight.bold))
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Outlet Press : ',
                                      textScaleFactor: 1,
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(getOutletbar().toString() + " m",
                                        textScaleFactor: 1,
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: 10.0 != 0
                                                ? Colors.green
                                                : Colors.red))
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 30.0),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Column(
                                                children: [
                                                  ///text
                                                  Container(
                                                    height: 16,
                                                    child: Text(
                                                      getAI2().toString() +
                                                          ' m',
                                                      style: TextStyle(
                                                          fontSize: 10),
                                                    ),
                                                  ),

                                                  ///Pipe
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        top: 5,
                                                        bottom: 5,
                                                        left: 3),
                                                    decoration: BoxDecoration(
                                                        gradient: LinearGradient(
                                                            begin: Alignment
                                                                .topCenter,
                                                            end: Alignment
                                                                .bottomCenter,
                                                            colors: [
                                                          Colors.grey.shade500,
                                                          Colors.grey.shade500,
                                                          Color.fromARGB(26,
                                                              199, 199, 199),
                                                          Colors.grey.shade500,
                                                          Colors.grey.shade500,
                                                        ])),
                                                    // color: Colors.red,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.11,
                                                    height: 15,
                                                  ),

                                                  ///text
                                                  SizedBox(
                                                    height: 16,
                                                    child: Text(
                                                      getflowvalue()
                                                              .toString() +
                                                          ' lps',
                                                      style: TextStyle(
                                                          fontSize: 10),
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              ///pipe cap2
                                              Container(
                                                width: 4,
                                                height: 20,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade500,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  5.0),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  5.0)),
                                                ),
                                              ),

                                              ///pipe cap1
                                              Container(
                                                width: 6,
                                                // width: width * 0.1,
                                                height: 30,
                                                decoration: BoxDecoration(
                                                    color: Colors.grey.shade500,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                5.0))),
                                              ),

                                              ///PFCMD
                                              Container(
                                                width: 45,
                                                height: 140,
                                                // color: Colors.blue,
                                                child: Stack(
                                                  children: [
                                                    Positioned(
                                                      top: 60,
                                                      child: Container(
                                                        width: 50,
                                                        height: 20,
                                                        decoration:
                                                            BoxDecoration(
                                                          //dcc600
                                                          color: getpfcmdcolor(
                                                            getPostion(),
                                                            getflowvalue(),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      getControllMode()
                                                          .toString(),
                                                      softWrap: true,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        // fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    Positioned(
                                                      top: 45,
                                                      left: 10,
                                                      child: Text(
                                                        getPostion()
                                                                .toString() +
                                                            ' %',
                                                        softWrap: true,
                                                        textScaleFactor: 1,
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          // fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned(
                                                        bottom: 20,
                                                        child: Container(
                                                          width: 40,
                                                          child: FittedBox(
                                                            child: Text(
                                                                getOperationMode()
                                                                    .toString()),
                                                          ),
                                                        ))
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    ///pipe cap1
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 30.0),
                                      child: Container(
                                        width: 6,
                                        // width: width * 0.1,
                                        height: 30,
                                        decoration: BoxDecoration(
                                            color: Colors.grey.shade500,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5.0))
                                            // BorderRadius.only(
                                            //     bottomLeft: Radius
                                            //         .circular(
                                            //             5.0),
                                            //     bottomRight: Radius
                                            //         .circular(
                                            //             5.0)),
                                            ),
                                      ),
                                    ),

                                    ///pipe cap2
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 30.0),
                                      child: Container(
                                        width: 4,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade500,
                                          borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(5.0),
                                              bottomRight:
                                                  Radius.circular(5.0)),
                                        ),
                                      ),
                                    ),

                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 30.0),
                                      child: Column(
                                        children: [
                                          Container(
                                            height: 16,
                                            child: Text(
                                              getOutletbar().toString() + ' m',
                                              style: TextStyle(fontSize: 10),
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.symmetric(
                                                vertical: 5),
                                            decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                    colors: [
                                                  Colors.grey.shade500,
                                                  Colors.grey.shade500,
                                                  Color.fromARGB(
                                                      26, 199, 199, 199),
                                                  Colors.grey.shade500,
                                                  Colors.grey.shade500,
                                                ])),
                                            width: 40,
                                            height: 15,
                                          ),
                                          SizedBox(
                                            height: 16,
                                            child: Text(
                                              Flowmeter_Volume().toString() +
                                                  ' m³',
                                              style: TextStyle(fontSize: 10),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: ElevatedButton(
                          child: Text(contbtntxt),
                          onPressed: () async {
                            isShowpop = !isShowpop;
                          },
                        ),
                      ),
                      if (isShowpop) getControllpanel(),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Text(
                              'Device DateTime : ',
                            ),
                            Text(
                              getDateTime()!.toString(),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          ),
        );
      } else if (controllerType!.contains('BOCOM6')) {
        var width = 180;
        var height = 400;
        return Expanded(
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        offset: const Offset(
                          2.0,
                          2.0,
                        ),
                        blurRadius: 5.0,
                        spreadRadius: 1.0,
                      ), //BoxShadow
                    ],
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15)),
                width: MediaQuery.of(context).size.width * 0.95,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15))),
                      height: 30,
                      width: MediaQuery.of(context).size.width * 0.97,
                      child: Center(
                        child: Text(
                          'Mac Id : ' + macId,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10, right: 10),
                          child: Column(
                            children: [
                              Image(
                                image:
                                    AssetImage("assets/images/thermometer.png"),
                                height: 30,
                                width: 30,
                                alignment: Alignment.centerRight,
                              ),
                              Text(
                                getTemprature().toString(),
                                style: TextStyle(fontSize: 8),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10, right: 10),
                          child: Column(
                            children: [
                              Image(
                                image:
                                    AssetImage("assets/images/solar_weak.png"),
                                height: 30,
                                width: 30,
                                alignment: Alignment.centerRight,
                              ),
                              Text(
                                getSOLARVoltage().toString(),
                                style: TextStyle(fontSize: 8),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          padding: EdgeInsets.only(left: 8),
                          // color: Colors.lightBlue.shade300,

                          width: 150,
                          height: 100,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Door: ',
                                    textScaleFactor: 1,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    getAlarms(0) == '1' || getAlarms(1) == '1'
                                        ? 'OPEN'
                                        : 'CLOSE',
                                    textScaleFactor: 1,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: getAlarms(0) == '1' ||
                                              getAlarms(1) == '1'
                                          ? Colors.red
                                          : Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Solar Voltage : ',
                                    textScaleFactor: 1,
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    getSOLARVoltage().toString() + " V",
                                    textScaleFactor: 1,
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: getSolarColor(0.0),
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Inlet Press : ',
                                    textScaleFactor: 1,
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    getAI2().toString() + " m",
                                    textScaleFactor: 1,
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: 16.12 != 0
                                            ? Colors.green
                                            : Colors.red),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        Container(
                          // color: Colors.deepPurple.shade300,
                          width: 150,
                          height: 100,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'FW Version : ',
                                    textScaleFactor: 1,
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Expanded(
                                    child: Text(
                                      getFirmwareVersion().toString(),
                                      textScaleFactor: 1,
                                      // values[index].areaName!,
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Battery Voltage : ',
                                    textScaleFactor: 1,
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(getBatterVoltage().toString(),
                                      textScaleFactor: 1,
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: ((16.3) > 17
                                              ? Colors.green
                                              : Colors.red),
                                          fontWeight: FontWeight.bold))
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Outlet Press : ',
                                    textScaleFactor: 1,
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(getOutletbar().toString() + " m",
                                      textScaleFactor: 1,
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: 10.0 != 0
                                              ? Colors.green
                                              : Colors.red))
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: 3.00,
                          // top: 2.00,
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 0.0),
                                    child: Row(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(
                                              left: 7, top: 10),
                                          // width: height * 0.03,
                                          height: height * 0.07,
                                          //color: Colors.grey,
                                          child: Text(
                                            "P1 : \n" +
                                                getAI1().toString() +
                                                "m",
                                            textScaleFactor: 1,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 8,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        Container(
                                          margin:
                                              const EdgeInsets.only(top: 10),
                                          // color: Colors.grey,
                                          height: height * 0.07,
                                          // color: Colors.grey,
                                          child: Text(
                                            "P2 : \n" +
                                                getAI2().toString() +
                                                "m",
                                            textScaleFactor: 1,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 8,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                margin: const EdgeInsets.only(left: 2),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      // crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.only(
                                                right: 20,
                                                left: 20,
                                              ),
                                              height: height * 0.01,
                                              width: width * 0.09,
                                              decoration: const BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(10)),
                                                  color: Colors.black),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          height: 15,
                                          width: 4,
                                          color: Colors.black,
                                        ),
                                        Row(
                                          children: [
                                            Center(
                                              child: Container(
                                                height: height * 0.055,
                                                width: width * 0.025,
                                                decoration: const BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(10)),
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                            Center(
                                              child: Container(
                                                width: 12,
                                                height: 14,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Container(
                                              width: width * 0.13,
                                              height: height * 0.08,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.grey),
                                                borderRadius:
                                                    const BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(5),
                                                        topRight:
                                                            Radius.circular(5)),
                                                color: Colors.black,
                                              ),
                                              child: Center(
                                                child: Container(
                                                  height: height * 0.02,
                                                  width: height * 0.02,
                                                  decoration: BoxDecoration(
                                                    gradient: RadialGradient(
                                                        radius: 5,
                                                        colors: 1 == 0
                                                            ? [
                                                                Colors
                                                                    .lightGreen,
                                                                Colors.green,
                                                                Colors.white
                                                              ]
                                                            : [
                                                                Colors.red
                                                                    .shade700,
                                                                Colors.red
                                                                    .shade800,
                                                                Colors.white
                                                              ]),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                10)),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Center(
                                              child: Container(
                                                width: 12,
                                                height: 14,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Center(
                                              child: Container(
                                                height: height * 0.055,
                                                width: width * 0.025,
                                                decoration: const BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(10)),
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          height: height * 0.01,
                                          width: width * 0.15,
                                          decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10)),
                                            color: Colors.black,
                                          ),
                                        ),
                                        Container(
                                          width: width * 0.13,
                                          height: height * 0.115,
                                          decoration: BoxDecoration(
                                            border:
                                                Border.all(color: Colors.grey),
                                            borderRadius:
                                                const BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(5),
                                                    bottomRight:
                                                        Radius.circular(5)),
                                            color: Colors.black,
                                          ),
                                        ),
                                        Container(
                                          height: height * 0.03,
                                          width: width * 0.025,
                                          decoration: const BoxDecoration(
                                            color: Colors.black,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Container(
                                              height: height * 0.03,
                                              width: width * 0.022,
                                              decoration: const BoxDecoration(
                                                color: Colors.black,
                                              ),
                                            ),
                                            Container(
                                              height: height * 0.01,
                                              width: width * 0.045,
                                              decoration: const BoxDecoration(
                                                  color: Colors.black),
                                            ),
                                            Container(
                                              width: width * 0.065,
                                              height: height * 0.0325,
                                              decoration: const BoxDecoration(
                                                color: Colors.black,
                                              ),
                                            ),
                                            SizedBox(
                                              height: height * 0.01,
                                              width: width * 0.045,
                                            ),
                                            SizedBox(
                                              height: height * 0.03,
                                              width: width * 0.025,
                                            )
                                          ],
                                        ),
                                        Container(
                                          height: height * 0.02,
                                          width: width * 0.025,
                                          decoration: const BoxDecoration(
                                            color: Colors.black,
                                          ),
                                        ),
                                        SizedBox(
                                          height: height * 0.015,
                                        ),
                                        Text(
                                          "△P : \n" +
                                              (getAI1() - getAI2())
                                                  .toStringAsFixed(2) +
                                              "m",
                                          textScaleFactor: 1,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 8,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    for (var i = 1; i <= 6; i++)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 28.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Colors.grey.shade500,
                                                  Colors.grey.shade500,
                                                  Color.fromARGB(
                                                      26, 199, 199, 199),
                                                  Colors.grey.shade500,
                                                  Colors.grey.shade500
                                                ],
                                              )),
                                              width: 50,
                                              height: 14,
                                              // color: Colors.grey,
                                            ),
                                            Column(
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                    colors: [
                                                      Colors.grey.shade500,
                                                      Colors.grey.shade500,
                                                      Color.fromARGB(
                                                          26, 199, 199, 199),
                                                      Colors.grey.shade500,
                                                      Colors.grey.shade500
                                                    ],
                                                  )),
                                                  width: width * 0.06,
                                                  height: height * 0.04,
                                                  // color: Colors.grey,
                                                ),
                                                Container(
                                                  width: width * 0.08,
                                                  height: height * 0.01,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade500,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    5.0),
                                                            topRight: Radius
                                                                .circular(5.0)),
                                                  ),
                                                ),
                                                Container(
                                                  width: 27,
                                                  height: height * 0.015,
                                                  decoration: BoxDecoration(
                                                    color: Color.fromARGB(
                                                        255, 158, 158, 158),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                5.0)),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 14.0),
                                                  child: Row(
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                              right: 2,
                                                              // top: 5,
                                                              // bottom:5
                                                            ),
                                                            child: Container(
                                                              width: 13,
                                                              height: 13,
                                                              color: Colors
                                                                  .grey[350],
                                                              child: Center(
                                                                child: Text(
                                                                    getmodevalve(
                                                                            i)
                                                                        .toString(),
                                                                    textScaleFactor:
                                                                        1,
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        fontWeight:
                                                                            FontWeight.w500)),
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    right: 2,
                                                                    top: 5,
                                                                    bottom: 5),
                                                            child: Container(
                                                              width: 13,
                                                              height: 13,
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            5)),
                                                                color: Colors
                                                                    .grey[350],
                                                              ),
                                                              // color: Colors
                                                              //         .grey[
                                                              //     350],
                                                              child: Center(
                                                                child: Text(
                                                                    getsmodevalve(
                                                                            i)
                                                                        .toString(),
                                                                    textScaleFactor:
                                                                        1,
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        fontWeight:
                                                                            FontWeight.w500)),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Container(
                                                          width: 20,
                                                          height: 40,
                                                          color:
                                                              getPFCMDContainerColor(
                                                                  2, i))
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  width: 27,
                                                  // width: width * 0.1,
                                                  height: height * 0.015,
                                                  decoration: BoxDecoration(
                                                      color:
                                                          Colors.grey.shade500,
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  5.0))
                                                      // BorderRadius.only(
                                                      //     bottomLeft: Radius
                                                      //         .circular(
                                                      //             5.0),
                                                      //     bottomRight: Radius
                                                      //         .circular(
                                                      //             5.0)),
                                                      ),
                                                ),
                                                Container(
                                                  width: width * 0.08,
                                                  height: height * 0.01,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade500,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    5.0),
                                                            bottomRight: Radius
                                                                .circular(5.0)),
                                                  ),
                                                ),
                                                Container(
                                                  decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                    colors: [
                                                      Colors.grey.shade500,
                                                      Colors.grey.shade500,
                                                      Color.fromARGB(
                                                          26, 199, 199, 199),
                                                      Colors.grey.shade500,
                                                      Colors.grey.shade500
                                                    ],
                                                  )),
                                                  width: width * 0.06,
                                                  height: height * 0.04,
                                                  // color: Colors.red,
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.all(2.0),
                                                  child: Text(
                                                    "PFCMD" + i.toString(),
                                                    textScaleFactor: 1,
                                                    style: TextStyle(
                                                        color: Colors.lightBlue,
                                                        fontSize: 9,
                                                        fontWeight:
                                                            FontWeight.w900),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    getTable(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Text(
                            'Device Date : ',
                          ),
                          Text(
                            getDateTime()!.toString(),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )
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
                  'INTG Data Not Found',
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
                      // String data = 'INTG'.toUpperCase() + "\r\n";
                      _response.clear();
                      _data.clear();
                      hexDecimalValue = '';
                      getINTGCommand();
                      // _startTask(15);
                      // getpop_loader(context);
                      // Future.delayed(Duration(milliseconds: 15), () {
                      //   Navigator.pop(context); //pop dialog
                      // });
                      // await _port!.write(Uint8List.fromList(data.codeUnits));
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

  getPFCMDContainerColor(double model, int index) {
    double posValve = 0.0, flowValve = 0.0;
    switch (index) {
      case 1:
        posValve = (model ?? 0.0);
        flowValve = (model ?? 0.0);
        break;
      case 2:
        posValve = (model ?? 0.0);
        flowValve = (model ?? 0.0);
        break;
      case 3:
        posValve = (model ?? 0.0);
        flowValve = (model ?? 0.0);
        break;
      case 4:
        posValve = (model ?? 0.0);
        flowValve = (model ?? 0.0);
        break;
      case 5:
        posValve = (model ?? 0.0);
        flowValve = (model ?? 0.0);
        break;
      case 6:
        posValve = model ?? 0.0;
        flowValve = model ?? 0.0;
        break;
    }
    if (posValve < 2) {
      return Colors.red[900];
    } else if (posValve >= 2 && flowValve == 0) {
      return Colors.yellow;
    } else if (posValve >= 2 && flowValve > 0) {
      return Colors.green;
    } else {
      return Colors.grey;
    }
  }

  Widget getTable() {
    var subChakQty = 6;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ///PFCMD
              Container(
                padding: EdgeInsets.all(3),
                height: 30,
                width: MediaQuery.of(context).size.width * 0.880,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(
                      -0.11693549743786386,
                      5.232387891851431e-7,
                    ),
                    end: Alignment(
                      1.016128983862346,
                      0.8571436124054905,
                    ),
                    colors: [
                      Colors.blue,
                      Colors.cyan,
                    ],
                  ),
                  // Color.fromARGB(255, 235, 232, 169),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(5),
                    topRight: Radius.circular(5),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: 60,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          'VALVE\nDETAILS',
                          textScaleFactor: 1,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    if ((subChakQty) >= 1)
                      Container(
                        width: 45,
                        child: Padding(
                          padding: EdgeInsets.only(right: 2),
                          child: Text(
                            'PFCMD1',
                            textScaleFactor: 1,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    if ((subChakQty) >= 2)
                      Container(
                        width: 45,
                        child: Padding(
                          padding: EdgeInsets.only(right: 2),
                          child: Text(
                            'PFCMD2',
                            textScaleFactor: 1,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    if ((subChakQty) >= 3)
                      Container(
                        width: 45,
                        child: Padding(
                          padding: EdgeInsets.only(right: 2),
                          child: Text(
                            'PFCMD3',
                            textScaleFactor: 1,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    if ((subChakQty) >= 4)
                      Container(
                        width: 45,
                        child: Padding(
                          padding: EdgeInsets.only(right: 2),
                          child: Text(
                            'PFCMD4',
                            textScaleFactor: 1,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    if ((subChakQty) >= 5)
                      Container(
                        width: 45,
                        child: Padding(
                          padding: EdgeInsets.only(right: 2),
                          child: Text(
                            'PFCMD5',
                            textScaleFactor: 1,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    if ((subChakQty) >= 6)
                      Container(
                        width: 45,
                        child: Padding(
                          padding: EdgeInsets.only(right: 2),
                          child: Text(
                            'PFCMD6',
                            textScaleFactor: 1,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              ///PT
              Container(
                height: 30,
                width: MediaQuery.of(context).size.width * 0.88,
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 168, 211, 237),
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        decoration: BoxDecoration(),
                        width: 70,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Text(
                            "PT (m)",
                            textScaleFactor: 1,
                            style: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      if ((subChakQty) >= 1)
                        Container(
                          width: 48,
                          child: Padding(
                              padding: EdgeInsets.only(right: 15),
                              child: Text(
                                getOutletbar().toString(),
                                textScaleFactor: 1,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500),
                              )),
                        ),
                      if ((subChakQty) >= 2)
                        Container(
                          width: 48,
                          child: Padding(
                              padding: EdgeInsets.only(right: 15),
                              child: Text(
                                getOutletbar_pfcmd_2().toString(),
                                textScaleFactor: 1,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500),
                              )),
                        ),
                      if ((subChakQty) >= 3)
                        Container(
                          width: 48,
                          child: Padding(
                              padding: EdgeInsets.only(right: 15),
                              child: Text(
                                getOutletbar_pfcmd_3().toString(),
                                textScaleFactor: 1,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500),
                              )),
                        ),
                      if ((subChakQty) >= 4)
                        Container(
                          width: 48,
                          child: Padding(
                              padding: EdgeInsets.only(right: 15),
                              child: Text(
                                getOutletbar_pfcmd_4().toString(),
                                textScaleFactor: 1,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500),
                              )),
                        ),
                      if ((subChakQty) >= 5)
                        Container(
                          width: 48,
                          child: Padding(
                              padding: EdgeInsets.only(right: 15),
                              child: Text(
                                getOutletbar_pfcmd_5().toString(),
                                textScaleFactor: 1,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500),
                              )),
                        ),
                      if ((subChakQty) >= 6)
                        Container(
                          width: 48,
                          child: Padding(
                              padding: EdgeInsets.only(right: 15),
                              child: Text(
                                getOutletbar_pfcmd_6().toString(),
                                textScaleFactor: 1,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500),
                              )),
                        ),
                    ]),
              ),

              ///POS
              Container(
                height: 30,
                width: MediaQuery.of(context).size.width * 0.88,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 168, 211, 237),
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: 70,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Text(
                            "Position(%)",
                            textScaleFactor: 1,
                            style: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      if ((subChakQty) >= 1)
                        Container(
                          width: 48,
                          child: Padding(
                              padding: EdgeInsets.only(right: 15),
                              child: Text(
                                getPostion().toString(),
                                textScaleFactor: 1,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500),
                              )),
                        ),
                      if ((subChakQty) >= 2)
                        Container(
                          width: 48,
                          child: Padding(
                              padding: EdgeInsets.only(right: 15),
                              child: Text(
                                getPostion_pfcmd_2().toString(),
                                textScaleFactor: 1,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500),
                              )),
                        ),
                      if ((subChakQty) >= 3)
                        Container(
                          width: 48,
                          child: Padding(
                              padding: EdgeInsets.only(right: 15),
                              child: Text(
                                getPostion_pfcmd_3().toString(),
                                textScaleFactor: 1,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500),
                              )),
                        ),
                      if ((subChakQty) >= 4)
                        Container(
                          width: 48,
                          child: Padding(
                              padding: EdgeInsets.only(right: 15),
                              child: Text(
                                getPostion_pfcmd_4().toString(),
                                textScaleFactor: 1,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500),
                              )),
                        ),
                      if ((subChakQty) >= 5)
                        Container(
                          width: 48,
                          child: Padding(
                              padding: EdgeInsets.only(right: 15),
                              child: Text(
                                getPostion_pfcmd_5().toString(),
                                textScaleFactor: 1,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500),
                              )),
                        ),
                      if ((subChakQty) >= 6)
                        Container(
                          width: 48,
                          child: Padding(
                              padding: EdgeInsets.only(right: 15),
                              child: Text(
                                getPostion_pfcmd_6().toString(),
                                textScaleFactor: 1,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500),
                              )),
                        ),
                    ]),
              ),

              ///POS SET
              /* Container(
                height: 30,
                width: MediaQuery.of(context).size.width * 0.88,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 168, 211, 237),
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: 70,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Text(
                            "Pos Set\n Point (%)",
                            textScaleFactor: 1,
                            style: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      if ((subChakQty) >= 1)
                        Container(
                          width: 48,
                          child: Padding(
                              padding: EdgeInsets.only(
                                right: 15,
                              ),
                              child: Text(
                                0.0 == null ? "0.0" : 0.0.toString(),
                                textScaleFactor: 1,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500),
                              )),
                        ),
                      if ((subChakQty) >= 2)
                        Container(
                          width: 48,
                          child: Padding(
                              padding: EdgeInsets.only(
                                right: 15,
                              ),
                              child: Text(
                                0.0 == null ? "0.0" : 0.0.toString(),
                                textScaleFactor: 1,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500),
                              )),
                        ),
                      if ((subChakQty) >= 3)
                        Container(
                          width: 48,
                          child: Padding(
                              padding: EdgeInsets.only(
                                right: 15,
                              ),
                              child: Text(
                                0.0 == null ? "0.0" : 0.0.toString(),
                                textScaleFactor: 1,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500),
                              )),
                        ),
                      if ((subChakQty) >= 4)
                        Container(
                          width: 48,
                          child: Padding(
                              padding: EdgeInsets.only(
                                right: 15,
                              ),
                              child: Text(
                                0.0 == null ? "0.0" : 0.0.toString(),
                                textScaleFactor: 1,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500),
                              )),
                        ),
                      if ((subChakQty) >= 5)
                        Container(
                          width: 48,
                          child: Padding(
                              padding: EdgeInsets.only(
                                right: 15,
                              ),
                              child: Text(
                                0.0 == null ? "0.0" : 0.0.toString(),
                                textScaleFactor: 1,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500),
                              )),
                        ),
                      if ((subChakQty) >= 6)
                        Container(
                          width: 48,
                          child: Padding(
                              padding: EdgeInsets.only(
                                right: 15,
                              ),
                              child: Text(
                                0.0 == null ? "0.0" : 0.0.toString(),
                                textScaleFactor: 1,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500),
                              )),
                        ),
                    ]),
              ),
*/
              ///FLOW
              Container(
                height: 30,
                width: MediaQuery.of(context).size.width * 0.88,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 168, 211, 237),
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: 70,
                        child: Padding(
                          padding: EdgeInsets.only(left: 5),
                          child: Text(
                            "Flow(LPS)",
                            textScaleFactor: 1,
                            style: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      if ((subChakQty) >= 1)
                        Container(
                          width: 48,
                          child: Padding(
                              padding: EdgeInsets.only(
                                right: 15,
                              ),
                              child: Text(
                                getflowvalue().toString(),
                                textScaleFactor: 1,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500),
                              )),
                        ),
                      if ((subChakQty) >= 2)
                        Container(
                          width: 48,
                          child: Padding(
                              padding: EdgeInsets.only(
                                right: 15,
                              ),
                              child: Text(
                                getflowvalue_pfcmd_2().toString(),
                                textScaleFactor: 1,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500),
                              )),
                        ),
                      if ((subChakQty) >= 3)
                        Container(
                          width: 48,
                          child: Padding(
                              padding: EdgeInsets.only(
                                right: 15,
                              ),
                              child: Text(
                                getflowvalue_pfcmd_3().toString(),
                                textScaleFactor: 1,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500),
                              )),
                        ),
                      if ((subChakQty) >= 4)
                        Container(
                          width: 48,
                          child: Padding(
                              padding: EdgeInsets.only(
                                right: 15,
                              ),
                              child: Text(
                                getflowvalue_pfcmd_4().toString(),
                                textScaleFactor: 1,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500),
                              )),
                        ),
                      if ((subChakQty) >= 5)
                        Container(
                          width: 48,
                          child: Padding(
                              padding: EdgeInsets.only(
                                right: 15,
                              ),
                              child: Text(
                                getflowvalue_pfcmd_5().toString(),
                                textScaleFactor: 1,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500),
                              )),
                        ),
                      if ((subChakQty) >= 6)
                        Container(
                          width: 48,
                          child: Padding(
                              padding: EdgeInsets.only(
                                right: 15,
                              ),
                              child: Text(
                                getflowvalue_pfcmd_6().toString(),
                                textScaleFactor: 1,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500),
                              )),
                        ),
                    ]),
              ),

              ///FLOW SET
              /* Container(
                height: 30,
                width: MediaQuery.of(context).size.width * 0.88,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 168, 211, 237),
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: 70,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Text(
                            "Flow Set\nPoint(lps)",
                            textScaleFactor: 1,
                            style: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      if ((subChakQty) >= 1)
                        Container(
                          width: 48,
                          child: Padding(
                              padding: EdgeInsets.only(
                                right: 15,
                              ),
                              child: Text(
                                0.0 == null
                                    ? "0.0"
                                    : convertm3hrToLps(0.0).toString(),
                                textScaleFactor: 1,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500),
                              )),
                        ),
                      if ((subChakQty) >= 2)
                        Container(
                          width: 48,
                          child: Padding(
                              padding: EdgeInsets.only(
                                right: 15,
                              ),
                              child: Text(
                                0.0 == null
                                    ? "0.0"
                                    : convertm3hrToLps(0.0).toString(),
                                textScaleFactor: 1,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500),
                              )),
                        ),
                      if ((subChakQty) >= 3)
                        Container(
                          width: 48,
                          child: Padding(
                              padding: EdgeInsets.only(
                                right: 15,
                              ),
                              child: Text(
                                0.03 == null
                                    ? "0.0"
                                    : convertm3hrToLps(0.0).toString(),
                                textScaleFactor: 1,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500),
                              )),
                        ),
                      if ((subChakQty) >= 4)
                        Container(
                          width: 48,
                          child: Padding(
                              padding: EdgeInsets.only(
                                right: 15,
                              ),
                              child: Text(
                                0.04 == null
                                    ? "0.0"
                                    : convertm3hrToLps(0.04).toString(),
                                textScaleFactor: 1,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500),
                              )),
                        ),
                      if ((subChakQty) >= 5)
                        Container(
                          width: 48,
                          child: Padding(
                              padding: EdgeInsets.only(
                                right: 15,
                              ),
                              child: Text(
                                0.05 == null
                                    ? "0.0"
                                    : convertm3hrToLps(0.05).toString(),
                                textScaleFactor: 1,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500),
                              )),
                        ),
                      if ((subChakQty) >= 6)
                        Container(
                          width: 48,
                          child: Padding(
                              padding: EdgeInsets.only(
                                right: 15,
                              ),
                              child: Text(
                                0.06 == null
                                    ? "0.0"
                                    : convertm3hrToLps(0.06).toString(),
                                textScaleFactor: 1,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500),
                              )),
                        ),
                    ]),
              ),
*/
              ///VOL
              Container(
                height: 30,
                width: MediaQuery.of(context).size.width * 0.88,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 168, 211, 237),
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: 70,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Text(
                            "Vol(m³)",
                            textScaleFactor: 1,
                            style: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      if ((subChakQty) >= 1)
                        Container(
                          width: 48,
                          child: Padding(
                              padding: EdgeInsets.only(right: 15),
                              child: Text(
                                getDailyvol().toString(),
                                textScaleFactor: 1,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500),
                              )),
                        ),
                      if ((subChakQty) >= 2)
                        Container(
                          width: 48,
                          child: Padding(
                              padding: EdgeInsets.only(right: 15),
                              child: Text(
                                getDailyvol_pfcmd_2().toString(),
                                textScaleFactor: 1,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500),
                              )),
                        ),
                      if ((subChakQty) >= 3)
                        Container(
                          width: 48,
                          child: Padding(
                              padding: EdgeInsets.only(right: 15),
                              child: Text(
                                getDailyvol_pfcmd_3().toString(),
                                textScaleFactor: 1,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500),
                              )),
                        ),
                      if ((subChakQty) >= 4)
                        Container(
                          width: 48,
                          child: Padding(
                              padding: EdgeInsets.only(right: 15),
                              child: Text(
                                getDailyvol_pfcmd_4().toString(),
                                textScaleFactor: 1,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500),
                              )),
                        ),
                      if ((subChakQty) >= 5)
                        Container(
                          width: 48,
                          child: Padding(
                              padding: EdgeInsets.only(right: 15),
                              child: Text(
                                getDailyvol_pfcmd_5().toString(),
                                textScaleFactor: 1,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500),
                              )),
                        ),
                      if ((subChakQty) >= 6)
                        Container(
                          width: 48,
                          child: Padding(
                              padding: EdgeInsets.only(right: 15),
                              child: Text(
                                getDailyvol_pfcmd_6().toString(),
                                textScaleFactor: 1,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500),
                              )),
                        ),
                    ]),
              ),

              ///PR-SUS
              /* Container(
                height: 30,
                width: MediaQuery.of(context).size.width * 0.88,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 168, 211, 237),
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: 70,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Text(
                            "Pr-Sus(m)",
                            textScaleFactor: 1,
                            style: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      if ((subChakQty) >= 1)
                        Container(
                          width: 48,
                          child: Padding(
                              padding: EdgeInsets.only(right: 15),
                              child: Text(
                                0.0 == null
                                    ? "0.0"
                                    : convertBartoMeter(0.0).toString(),
                                textScaleFactor: 1,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500),
                              )),
                        ),
                      if ((subChakQty) >= 2)
                        Container(
                          width: 48,
                          child: Padding(
                              padding: EdgeInsets.only(right: 15),
                              child: Text(
                                0.0 == null
                                    ? "0.0"
                                    : convertBartoMeter(0.0).toString(),
                                textScaleFactor: 1,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500),
                              )),
                        ),
                      if ((subChakQty) >= 3)
                        Container(
                          width: 48,
                          child: Padding(
                              padding: EdgeInsets.only(right: 15),
                              child: Text(
                                0.0 == null
                                    ? "0.0"
                                    : convertBartoMeter(0.0).toString(),
                                textScaleFactor: 1,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500),
                              )),
                        ),
                      if ((subChakQty) >= 4)
                        Container(
                          width: 48,
                          child: Padding(
                              padding: EdgeInsets.only(right: 15),
                              child: Text(
                                0.0 == null
                                    ? "0.0"
                                    : convertBartoMeter(0.0).toString(),
                                textScaleFactor: 1,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500),
                              )),
                        ),
                      if ((subChakQty) >= 5)
                        Container(
                          width: 48,
                          child: Padding(
                              padding: EdgeInsets.only(right: 15),
                              child: Text(
                                0.0 == null
                                    ? "0.0"
                                    : convertBartoMeter(0.0).toString(),
                                textScaleFactor: 1,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500),
                              )),
                        ),
                      if ((subChakQty) >= 6)
                        Container(
                          width: 48,
                          child: Padding(
                              padding: EdgeInsets.only(right: 15),
                              child: Text(
                                0.0 == null
                                    ? "0.0"
                                    : convertBartoMeter(0.0).toString(),
                                textScaleFactor: 1,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500),
                              )),
                        ),
                    ]),
              ),

              ///PR-RED
              Container(
                height: 30,
                width: MediaQuery.of(context).size.width * 0.88,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 168, 211, 237),
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: 70,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Text(
                            "Pr-Red(m)",
                            textScaleFactor: 1,
                            style: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      if ((subChakQty) >= 1)
                        Container(
                          width: 48,
                          child: Padding(
                              padding: EdgeInsets.only(right: 15),
                              child: Text(
                                0.0 == null
                                    ? "0.0"
                                    : convertBartoMeter(0.0).toString(),
                                textScaleFactor: 1,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500),
                              )),
                        ),
                      if ((subChakQty) >= 2)
                        Container(
                          width: 48,
                          child: Padding(
                              padding: EdgeInsets.only(right: 15),
                              child: Text(
                                0.0 == null
                                    ? "0.0"
                                    : convertBartoMeter(0.0).toString(),
                                textScaleFactor: 1,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500),
                              )),
                        ),
                      if ((subChakQty) >= 3)
                        Container(
                          width: 48,
                          child: Padding(
                              padding: EdgeInsets.only(right: 15),
                              child: Text(
                                0.0 == null
                                    ? "0.0"
                                    : convertBartoMeter(0.0).toString(),
                                textScaleFactor: 1,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500),
                              )),
                        ),
                      if ((subChakQty) >= 4)
                        Container(
                          width: 48,
                          child: Padding(
                              padding: EdgeInsets.only(right: 15),
                              child: Text(
                                0.0 == null
                                    ? "0.0"
                                    : convertBartoMeter(0.0).toString(),
                                textScaleFactor: 1,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500),
                              )),
                        ),
                      if ((subChakQty) >= 5)
                        Container(
                          width: 48,
                          child: Padding(
                              padding: EdgeInsets.only(right: 15),
                              child: Text(
                                0.0 == null
                                    ? "0.0"
                                    : convertBartoMeter(0.0).toString(),
                                textScaleFactor: 1,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500),
                              )),
                        ),
                      if ((subChakQty) >= 6)
                        Container(
                          width: 48,
                          child: Padding(
                              padding: EdgeInsets.only(right: 15),
                              child: Text(
                                0.0 == null
                                    ? "0.0"
                                    : convertBartoMeter(0.0).toString(),
                                textScaleFactor: 1,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500),
                              )),
                        ),
                    ]),
              ),
*/
              ///Schedule
              /* Container(
                height: 30,
                width: MediaQuery.of(context).size.width * 0.88,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 168, 211, 237),
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: 70,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Text(
                            "Schedule\nPresent/abs",
                            textScaleFactor: 1,
                            style: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      if ((subChakQty) >= 1)
                        Container(
                          width: 48,
                          child: Padding(
                              padding: EdgeInsets.only(right: 15),
                              child: Text(
                                'Present'.toString(),
                                textScaleFactor: 1,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500),
                              )),
                        ),
                      if ((subChakQty) >= 2)
                        Container(
                          width: 48,
                          child: Padding(
                              padding: EdgeInsets.only(right: 0),
                              child: Text(
                                'Present'.toString(),
                                textScaleFactor: 1,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500),
                              )),
                        ),
                      if ((subChakQty) >= 3)
                        Container(
                          width: 48,
                          child: Padding(
                              padding: EdgeInsets.only(right: 15),
                              child: Text(
                                'Present'.toString(),
                                textScaleFactor: 1,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500),
                              )),
                        ),
                      if ((subChakQty) >= 4)
                        Container(
                          width: 48,
                          child: Padding(
                              padding: EdgeInsets.only(right: 0),
                              child: Text(
                                'Present'.toString(),
                                textScaleFactor: 1,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500),
                              )),
                        ),
                      if ((subChakQty) >= 5)
                        Container(
                          width: 48,
                          child: Padding(
                              padding: EdgeInsets.only(right: 0),
                              child: Text(
                                'Present'.toString(),
                                textScaleFactor: 1,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500),
                              )),
                        ),
                      if ((subChakQty) >= 6)
                        Container(
                          width: 48,
                          child: Padding(
                              padding: EdgeInsets.only(right: 0),
                              child: Text(
                                'Present'.toString(),
                                textScaleFactor: 1,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500),
                              )),
                        ),
                    ]),
              ),

              ///Irrigation Status
              Container(
                height: 30,
                width: MediaQuery.of(context).size.width * 0.88,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 168, 211, 237),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(5),
                    bottomRight: Radius.circular(5),
                  ),
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: 70,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Text(
                            "Irrigation\nStatus",
                            textScaleFactor: 1,
                            style: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      if ((subChakQty) >= 1)
                        Container(
                          width: 48,
                          child: Padding(
                              padding: EdgeInsets.only(right: 15, left: 2),
                              child: Text(
                                getIrrigationStatus(1),
                                textScaleFactor: 1,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500),
                              )),
                        ),
                      if ((subChakQty) >= 2)
                        Container(
                          width: 48,
                          child: Padding(
                              padding: EdgeInsets.only(right: 15, left: 2),
                              child: Text(
                                getIrrigationStatus(1),
                                textScaleFactor: 1,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500),
                              )),
                        ),
                      if ((subChakQty) >= 3)
                        Container(
                          width: 48,
                          child: Padding(
                              padding: EdgeInsets.only(right: 15, left: 2),
                              child: Text(
                                getIrrigationStatus(1),
                                textScaleFactor: 1,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500),
                              )),
                        ),
                      if ((subChakQty) >= 4)
                        Container(
                          width: 48,
                          child: Padding(
                              padding: EdgeInsets.only(right: 15, left: 2),
                              child: Text(
                                getIrrigationStatus(1),
                                textScaleFactor: 1,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500),
                              )),
                        ),
                      if ((subChakQty) >= 5)
                        Container(
                          width: 48,
                          child: Padding(
                              padding: EdgeInsets.only(right: 15, left: 2),
                              child: Text(
                                getIrrigationStatus(1),
                                textScaleFactor: 1,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500),
                              )),
                        ),
                      if ((subChakQty) >= 6)
                        Container(
                          width: 48,
                          child: Padding(
                              padding: EdgeInsets.only(right: 15, left: 2),
                              child: Text(
                                getIrrigationStatus(1),
                                textScaleFactor: 1,
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w500),
                              )),
                        ),
                    ]),
              )
           */
            ],
          )
        ],
      ),
    );
  }

  getControllpanel() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            color: Color.fromARGB(255, 223, 235, 247),
            borderRadius: BorderRadius.circular(5)),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(3),
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(5),
                    topRight: Radius.circular(5),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.25,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          'Sub-Chak Mode Details',
                          textScaleFactor: 1,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.55,
                      child: Padding(
                        padding: EdgeInsets.only(right: 2),
                        child: Center(
                          child: Text(
                            'PFCMD1',
                            textScaleFactor: 1,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              /// Mode Selection
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                Container(
                  decoration: BoxDecoration(),
                  width: MediaQuery.of(context).size.width * 0.20,
                  child: Text(
                    "MODE SELECTION",
                    textScaleFactor: 1,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
                SizedBox(
                  height: 50,
                  width: MediaQuery.of(context).size.width * 0.65,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                  modebtntxt == 'Auto'
                                      ? Colors.green
                                      : Colors.blue),
                              minimumSize: WidgetStateProperty.all(
                                  Size(30, 30)), // Adjust the button size here
                            ),
                            onPressed: () {
                              setState(() {
                                modebtntxt = 'Auto';
                              });
                            },
                            child: Text(
                              'AUTO',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize:
                                      10), // Adjust the button font size here
                            ),
                          ),
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                  modebtntxt == 'Manual'
                                      ? Colors.green
                                      : Colors.blue),
                              minimumSize: WidgetStateProperty.all(
                                  Size(30, 30)), // Adjust the button size here
                            ),
                            onPressed: () {
                              setState(() {
                                modebtntxt = 'Manual';
                              });
                            },
                            child: Text(
                              'MANUAL',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize:
                                      10), // Adjust the button font size here
                            ),
                          ),
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                  modebtntxt == 'Test'
                                      ? Colors.green
                                      : Colors.blue),
                              minimumSize: WidgetStateProperty.all(
                                  Size(30, 30)), // Adjust the button size here
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Dialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Container(
                                      padding: EdgeInsets.all(16.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextField(
                                            controller: _datetimecontroller,
                                            decoration: InputDecoration(
                                              hintText: 'Enter duration',
                                            ),
                                          ),
                                          Text(
                                            ' Please enter duration between 0 - 3600 minutes',
                                          ),
                                          SizedBox(height: 16.0),
                                          ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                modebtntxt = 'Test';
                                              });
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('OK'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            child: Text(
                              'TEST',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize:
                                      10), // Adjust the button font size here
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ]),

              ///Operation
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.20,
                  child: Text(
                    "OPERATION TYPE",
                    textScaleFactor: 1,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.65,
                  height: 50,
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                                btnName == 'Flow Control'
                                    ? Colors.green
                                    : Colors.blue),
                            minimumSize: WidgetStateProperty.all(
                                Size(30, 30)), // Adjust the button size here
                          ),
                          onPressed: () {
                            setState(() {
                              btnName = 'Flow Control';
                            });
                            // setOpreationType('Flow Control');
                          },
                          child: Text(
                            'FLOW',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize:
                                    10), // Adjust the button font size here
                          ),
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                                btnName == 'Position'
                                    ? Colors.green
                                    : Colors.blue),
                            minimumSize: WidgetStateProperty.all(
                                Size(30, 30)), // Adjust the button size here
                          ),
                          onPressed: () {
                            setState(() {
                              btnName = 'Position';
                            });
                            // setOpreationType('Position');
                          },
                          child: Text(
                            'POS',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize:
                                    10), // Adjust the button font size here
                          ),
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                                btnName == 'Open/Close'
                                    ? Colors.green
                                    : Colors.blue),
                            minimumSize: WidgetStateProperty.all(
                                Size(30, 30)), // Adjust the button size here
                          ),
                          onPressed: () {
                            setState(() {
                              btnName = 'Open/Close';
                            });
                            // setOpreationType('Open/Close');
                          },
                          child: Text(
                            'OPN/CLS',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize:
                                    10), // Adjust the button font size here
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
              if (btnName == 'Flow Control')
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
                                  'Flow Set Point (lps):',
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Expanded(
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
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(9.0),
                                child: Text(
                                  'Sustaining Pressure (m):',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                              Expanded(
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
                              )),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(9.0),
                                child: Text(
                                  'Reducing Pressure (m):',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                              Expanded(
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
                              )),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              if (btnName == 'Position')
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
                                  'Poition Set Point:',
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Expanded(
                                  child: TextFormField(
                                controller: _positioncontroller,
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
                                // style: TextStyle(color: Color.fromARGB(255, 45, 51, 74)),
                              )),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (btnName == 'Open/Close')
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
                              Text(
                                'Open/Close:',
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    ElevatedButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            WidgetStateProperty.all(
                                                openclosetbnname == 'Open'
                                                    ? Colors.green
                                                    : Colors.blue),
                                        minimumSize: WidgetStateProperty.all(Size(
                                            50,
                                            30)), // Adjust the button size here
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          openclosetbnname = 'Open';
                                        });
                                      },
                                      child: Text(
                                        'Open',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize:
                                                10), // Adjust the button font size here
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    ElevatedButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            WidgetStateProperty.all(
                                                openclosetbnname == 'Close'
                                                    ? Colors.red
                                                    : Colors.blue),
                                        minimumSize: WidgetStateProperty.all(Size(
                                            50,
                                            30)), // Adjust the button size here
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          openclosetbnname = 'Close';
                                        });
                                      },
                                      child: Text(
                                        'Close',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize:
                                                10), // Adjust the button font size here
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    ElevatedButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            WidgetStateProperty.all(
                                                openclosetbnname == 'Stop'
                                                    ? Colors.red
                                                    : Colors.blue),
                                        minimumSize: WidgetStateProperty.all(Size(
                                            50,
                                            30)), // Adjust the button size here
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          openclosetbnname = 'Stop';
                                        });
                                      },
                                      child: Text(
                                        'Stop',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize:
                                                10), // Adjust the button font size here
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                WidgetStateProperty.all(Colors.green),
                            minimumSize: WidgetStateProperty.all(
                                Size(50, 30)), // Adjust the button size here
                          ),
                          onPressed: () async {
                            await setControllMode();
                            _progress = 0.0;
                            _startTask(15);
                            getpop_loader(context);
                            Future.delayed(Duration(seconds: 15), () {
                              Navigator.pop(context); //pop dialog
                            });
                          },
                          child: Text(
                            'Set',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize:
                                    12), // Adjust the button font size here
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
    );
  }

  setControllMode() async {
    SetMode();
    await Future.delayed(Duration(seconds: 5)).whenComplete(
      () {
        setOpreationType(btnName);
      },
    );
  }

  setOpreationType(String mode) {
    if (mode.contains('Open/Close')) {
      String data = 'PFCMD1TYPE 1 '.toUpperCase() + "\r\n";
      _port!.write(Uint8List.fromList(data.codeUnits));
      new Future.delayed(Duration(seconds: 4))
          .whenComplete(() => setOpenCloseMode(openclosetbnname));
    } else if (mode.contains('Flow Control')) {
      String data = ('PFCMD1TYPE 2 ' +
                  _flowsetpointcontroller.text +
                  ' ' +
                  _sustainingcontroller.text +
                  ' ' +
                  _reducingcontroller.text)
              .toUpperCase() +
          "\r\n";
      _port!.write(Uint8List.fromList(data.codeUnits));
      new Future.delayed(Duration(seconds: 4))
          .whenComplete(() => getINTGCommand());
    } else if (mode.contains('Position')) {
      String data =
          ('PFCMD1TYPE 3 ' + _positioncontroller.text).toUpperCase() + "\r\n";
      _port!.write(Uint8List.fromList(data.codeUnits));
      new Future.delayed(Duration(seconds: 4))
          .whenComplete(() => getINTGCommand());
    } else {
      print('error');
    }
  }

  SetMode() async {
    if (modebtntxt == 'Auto') {
      String data = 'SMODE 1 1 1'.toUpperCase() + "\r\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
    } else if (modebtntxt == 'Manual') {
      String data = 'SMODE 2 1 1'.toUpperCase() + "\r\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
    } else if (modebtntxt == 'Test') {
      String data =
          ('SMODE 3 1 ' + _datetimecontroller.text).toUpperCase() + "\r\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
    }
  }

  setOpenCloseMode(String mode) {
    if (mode == 'Open') {
      String data = ('PFCMD1ONOFF 1').toUpperCase() + "\r\n";
      _port!.write(Uint8List.fromList(data.codeUnits));
      // new Future.delayed(Duration(seconds: 5));
      //.whenComplete(() => getINTGCommand());
    } else if (mode == 'Close') {
      String data = ('PFCMD1ONOFF 0').toUpperCase() + "\r\n";
      _port!.write(Uint8List.fromList(data.codeUnits));
      // new Future.delayed(Duration(seconds: 4))
      //     .whenComplete(() => getINTGCommand());
    } else if (mode == 'Stop') {
      String data = ('PFCMD1ONOFF 2').toUpperCase() + "\r\n";
      _port!.write(Uint8List.fromList(data.codeUnits));
      // new Future.delayed(Duration(seconds: 4))
      //     .whenComplete(() => getINTGCommand());
    }
  }

  getIrrigationStatus(int irristatus) {
    try {
      if (irristatus == 1) {
        return 'Start';
      } else if (irristatus == 0) {
        return 'Stop';
      } else {
        return 'Not Set';
      }
    } catch (_, ex) {
      return 'Not Set';
    }
  }

  getDateTime() {
    String subString3 = hexDecimalValue.substring(0, 8);
    int date = int.parse(subString3, radix: 16);
    var dateTime = DateTime.fromMillisecondsSinceEpoch(date * 1000);
    var formatter = DateFormat('dd-MM-yyyy');
    var formattedDate = formatter.format(dateTime);

    return formattedDate;
  }

  getTemprature() {
    var subString2;
    String temp;
    try {
      subString2 = hexDecimalValue.substring(8, 12);
      int decimal = int.parse(subString2, radix: 16);
      temp = (decimal / 100).toString();
      temp = temp + ' °C';
    } catch (_, ex) {
      temp = '0.0 °C';
    }
    return temp;
  }

  getBatterVoltage() {
    var subString2;
    String batteryVoltage;
    try {
      subString2 = hexDecimalValue.substring(12, 16);
      int decimal = int.parse(subString2, radix: 16);
      batteryVoltage = (decimal / 100).toString();
      batteryVoltage = batteryVoltage + ' V';
    } catch (_, ex) {
      batteryVoltage = '0.0 V';
    }
    return batteryVoltage;
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

  getAI1() {
    var subString3;
    double ai1;
    try {
      subString3 = hexDecimalValue.substring(20, 24);
      int decimal = int.parse(subString3, radix: 16);
      ai1 = (decimal / 100);
    } catch (_, ex) {
      ai1 = 0.0;
    }
    return ai1;
  }

  String convertm3hrToLps(double data) {
    double res = 0.0;
    try {
      res = (data / 3.6);
    } catch (_, ex) {}
    return res.toStringAsFixed(2);
  }

  getAI2() {
    var subString3;
    double ai2;
    try {
      subString3 = hexDecimalValue.substring(24, 28);
      int decimal = int.parse(subString3, radix: 16);
      ai2 = (decimal / 100);
    } catch (_, ex) {
      ai2 = 0.0;
    }
    return ai2;
  }

  String getFirmwareVersion() {
    var subString3;
    String firmwareversion;
    try {
      subString3 = hexDecimalValue.substring(28, 30);
      int decimal = int.parse(subString3, radix: 16);
      firmwareversion = (decimal / 10).toString();
    } catch (_, ex) {
      firmwareversion = '0.0';
    }
    return firmwareversion;
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

    if (index >= 0 && index < binaryValues.length) {
      return binaryValues[index];
    } else {
      return '';
    }
  }

  String getPocketIndication() {
    var subString3;
    String packetIndication;
    String binaryNumber;
    String returnvalue = '';
    try {
      subString3 = hexDecimalValue.substring(34, 36);
      int decimalNumber = int.parse(subString3, radix: 16);
      binaryNumber = decimalNumber.toRadixString(2).padLeft(8, '0');
      if (binaryNumber[5] == '1') {
        returnvalue = 'Alarm';
      } else if (binaryNumber[6] == '1') {
        returnvalue = 'INTG';
      } else if (binaryNumber[7] == '1') {
        returnvalue = 'IRT';
      }
    } catch (_, ex) {
      returnvalue = '';
    }
    return returnvalue;
  }

  String getEmergencystrop() {
    var subString3;
    String emergencystop;
    String binaryNumber;
    String returnvalue = '';
    try {
      subString3 = hexDecimalValue.substring(36, 38);
      int decimalNumber = int.parse(subString3, radix: 16);
      binaryNumber = decimalNumber.toRadixString(2).padLeft(8, '0');
      if (binaryNumber[6] == '0') {
        returnvalue = 'Emergency Stop';
      } else if (binaryNumber[7] == '1') {
        returnvalue = 'Stop Irrigation';
      }
    } catch (_, ex) {
      returnvalue = '';
    }
    return returnvalue;
/*
    if (binaryNumber.length >= 7) {
      binaryValues.add(binaryNumber[6]);
      binaryValues.add(binaryNumber[7]);
    }

    if (index >= 0 && index < binaryValues.length) {
      return binaryValues[index];
    } else {
      return '';
    }*/
  }

  String getOutletbar() {
    var subString3;
    String outletbar;
    try {
      subString3 = hexDecimalValue.substring(38, 42);
      int decimal = int.parse(subString3, radix: 16);
      outletbar = (decimal / 100).toString();
    } catch (_, ex) {
      outletbar = '0.0';
    }
    return outletbar;
  }

  double getPostion() {
    var subString3;
    double postionvalue;
    try {
      subString3 = hexDecimalValue.substring(42, 46);
      int decimal = int.parse(subString3, radix: 16);
      postionvalue = (decimal / 100);
    } catch (_, ex) {
      postionvalue = 0.0;
    }
    return postionvalue;
  }

  double getflowvalue() {
    var subString3;
    double flowvalue;
    try {
      subString3 = hexDecimalValue.substring(46, 50);
      int decimal = int.parse(subString3, radix: 16);
      flowvalue = (decimal / 100);
    } catch (_, ex) {
      flowvalue = 0.0;
    }
    return flowvalue;
  }

  String getDailyvol() {
    var subString3;
    String dailyvol;
    try {
      subString3 = hexDecimalValue.substring(50, 54);
      int decimal = int.parse(subString3, radix: 16);
      dailyvol = (decimal / 100).toString();
    } catch (_, ex) {
      dailyvol = '0.0';
    }
    return dailyvol;
  }

  String getruntime() {
    var subString3;
    String runtime;
    try {
      subString3 = hexDecimalValue.substring(54, 58);
      int decimal = int.parse(subString3, radix: 16);
      runtime = (decimal / 100).toString();
    } catch (_, ex) {
      runtime = '0.0';
    }
    return runtime;
  }

  getpfcmdcolor(var valpos, var flow) {
    try {
      if (valpos < 2) {
        return Colors.red;
      } else if (valpos > 2 && flow == 0) {
        return Colors.yellow;
      } else if (valpos > 2 && flow > 0) {
        return Colors.green;
      }
    } catch (ex) {
      return Colors.red;
    }
  }

  getSolarColor(double LevelStatus) {
    if (LevelStatus == null) {
      return Colors.red;
    } else if (LevelStatus <= 0) {
      return Colors.red;
    } else if (LevelStatus > 0 && LevelStatus < 21) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  convertBartoMeter(dynamic data) {
    if (data == null) {
      return '0.0';
    } else {
      var converted = data * 10.2;
      return converted.toStringAsFixed(2);
    }
  }

  String getOperationMode() {
    var data;
    String mode;
    String binaryNumber;
    try {
      data = hexDecimalValue.substring(58, 60);
      int decimalNumber = int.parse(data, radix: 16);
      binaryNumber = decimalNumber.toRadixString(2).padLeft(8, '0');
      if (binaryNumber[4] == '1') {
        mode = 'Test';
      } else if (binaryNumber[5] == '1') {
        mode = 'Manual';
      } else if (binaryNumber[6] == '1') {
        mode = 'Auto';
      } else {
        mode = '';
      }
    } catch (_, ex) {
      mode = '';
    }
    return mode;
  }

  String getControllMode() {
    var data;
    String mode;
    String binaryNumber;
    try {
      data = hexDecimalValue.substring(58, 60);
      int decimalNumber = int.parse(data, radix: 16);
      binaryNumber = decimalNumber.toRadixString(2).padLeft(8, '0');
      if (binaryNumber[1] == '1') {
        mode = 'Position Control';
      } else if (binaryNumber[2] == '1') {
        mode = 'Flow Control';
      } else if (binaryNumber[3] == '1') {
        mode = 'Open/Close';
      } else {
        mode = '';
      }
    } catch (_, ex) {
      mode = '';
    }
    return mode;
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

  getsmodevalve(int mode) {
    switch (mode) {
      case 1:
        var subString3;
        String binaryNumber;
        List<String> autom = [];
        try {
          subString3 = hexDecimalValue.substring(158, 160);
          int decimalNumber = int.parse(subString3, radix: 16);
          // binaryNumber = decimalNumber.toRadixString(2);
          binaryNumber = decimalNumber.toRadixString(2).padLeft(8, '0');
        } catch (_, ex) {
          binaryNumber = '0.0';
        }

        if (binaryNumber.length >= 5) {
          autom.add(binaryNumber[4]);
          autom.add(binaryNumber[5]);
          autom.add(binaryNumber[6]);
        }
        if (autom[0] == "1") {
          return 'T';
        } else if (autom[1] == "1") {
          return 'M';
        } else if (autom[2] == "1") {
          return 'A';
        } else {
          return 'N';
        }

      case 2:
        var subString3;
        String binaryNumber;
        List<String> autom = [];
        try {
          subString3 = hexDecimalValue.substring(160, 162);
          int decimalNumber = int.parse(subString3, radix: 16);
          // binaryNumber = decimalNumber.toRadixString(2);
          binaryNumber = decimalNumber.toRadixString(2).padLeft(8, '0');
        } catch (_, ex) {
          binaryNumber = '0.0';
        }

        if (binaryNumber.length >= 5) {
          autom.add(binaryNumber[4]);
          autom.add(binaryNumber[5]);
          autom.add(binaryNumber[6]);
          // autom.add(binaryNumber[6]);
        }
        if (int.parse(autom[0]) == 1) {
          return 'T';
        } else if (int.parse(autom[1]) == 1) {
          return 'M';
        } else if (int.parse(autom[2]) == 1) {
          return 'A';
        } else {
          return 'N';
        }

      case 3:
        var subString3;
        String binaryNumber;
        List<String> autom = [];
        try {
          subString3 = hexDecimalValue.substring(162, 164);
          int decimalNumber = int.parse(subString3, radix: 16);
          // binaryNumber = decimalNumber.toRadixString(2);
          binaryNumber = decimalNumber.toRadixString(2).padLeft(8, '0');
        } catch (_, ex) {
          binaryNumber = '0.0';
        }

        if (binaryNumber.length >= 5) {
          autom.add(binaryNumber[4]);
          autom.add(binaryNumber[5]);
          autom.add(binaryNumber[6]);
        }
        if (int.parse(autom[0]) == 1) {
          return 'T';
        } else if (int.parse(autom[1]) == 1) {
          return 'M';
        } else if (int.parse(autom[2]) == 1) {
          return 'A';
        } else
          return 'N';
      case 4:
        var subString3;
        String binaryNumber;
        List<String> autom = [];
        try {
          subString3 = hexDecimalValue.substring(164, 166);
          int decimalNumber = int.parse(subString3, radix: 16);
          // binaryNumber = decimalNumber.toRadixString(2);
          binaryNumber = decimalNumber.toRadixString(2).padLeft(8, '0');
        } catch (_, ex) {
          binaryNumber = '0.0';
        }

        if (binaryNumber.length >= 5) {
          autom.add(binaryNumber[4]);
          autom.add(binaryNumber[5]);
          autom.add(binaryNumber[6]);
        }
        if (int.parse(autom[0]) == 1) {
          return 'T';
        } else if (int.parse(autom[1]) == 1) {
          return 'M';
        } else if (int.parse(autom[2]) == 1) {
          return 'A';
        } else
          return 'N';
      case 5:
        var subString3;
        String binaryNumber;
        List<String> autom = [];
        try {
          subString3 = hexDecimalValue.substring(166, 168);
          int decimalNumber = int.parse(subString3, radix: 16);
          // binaryNumber = decimalNumber.toRadixString(2);
          binaryNumber = decimalNumber.toRadixString(2).padLeft(8, '0');
        } catch (_, ex) {
          binaryNumber = '0.0';
        }

        if (binaryNumber.length >= 5) {
          autom.add(binaryNumber[4]);
          autom.add(binaryNumber[5]);
          autom.add(binaryNumber[6]);
        }
        if (int.parse(autom[0]) == 1) {
          return 'T';
        } else if (int.parse(autom[1]) == 1) {
          return 'M';
        } else if (int.parse(autom[2]) == 1) {
          return 'A';
        } else
          return 'N';
      case 6:
        var subString3;
        String binaryNumber;
        List<String> autom = [];
        try {
          subString3 = hexDecimalValue.substring(168, 170);
          int decimalNumber = int.parse(subString3, radix: 16);
          // binaryNumber = decimalNumber.toRadixString(2);
          binaryNumber = decimalNumber.toRadixString(2).padLeft(8, '0');
        } catch (_, ex) {
          binaryNumber = '0.0';
        }

        if (binaryNumber.length >= 5) {
          autom.add(binaryNumber[4]);
          autom.add(binaryNumber[5]);
          autom.add(binaryNumber[6]);
        }
        if (int.parse(autom[0]) == 1) {
          return 'T';
        } else if (int.parse(autom[1]) == 1) {
          return 'M';
        } else if (int.parse(autom[2]) == 1) {
          return 'A';
        } else
          return 'N';
    }
  }

  getmodevalve(int mode) {
    switch (mode) {
      case 1:
        var subString3;
        String binaryNumber;
        List<String> openclose = [];
        try {
          subString3 = hexDecimalValue.substring(158, 160);
          int decimalNumber = int.parse(subString3, radix: 16);
          // binaryNumber = decimalNumber.toRadixString(2);
          binaryNumber = decimalNumber.toRadixString(2).padLeft(8, '0');
        } catch (_, ex) {
          binaryNumber = '0.0';
        }

        if (binaryNumber.length >= 5) {
          openclose.add(binaryNumber[1]);
          openclose.add(binaryNumber[2]);
          openclose.add(binaryNumber[3]);
        }
        if (int.parse(openclose[2]) == 1) {
          return 'O';
        } else if (int.parse(openclose[1]) == 1) {
          return 'F';
        } else if (int.parse(openclose[0]) == 1) {
          return 'P';
        } else
          return 'N';
      case 2:
        var subString3;
        String binaryNumber;
        List<String> openclose = [];
        try {
          subString3 = hexDecimalValue.substring(160, 162);
          int decimalNumber = int.parse(subString3, radix: 16);
          binaryNumber = decimalNumber.toRadixString(2).padLeft(8, '0');
          // binaryNumber = decimalNumber.toRadixString(2);
        } catch (_, ex) {
          binaryNumber = '0.0';
        }

        if (binaryNumber.length >= 5) {
          openclose.add(binaryNumber[1]);
          openclose.add(binaryNumber[2]);
          openclose.add(binaryNumber[3]);
          // autom.add(binaryNumber[3]);
          // autom.add(binaryNumber[4]);
          // autom.add(binaryNumber[5]);
          // autom.add(binaryNumber[6]);
        }
        if (openclose[2] == '1') {
          return 'O';
        } else if (openclose[1] == '1') {
          return 'F';
        } else if (openclose[0] == '1') {
          return 'P';
        } else
          return 'N';

      case 3:
        var subString3;
        String binaryNumber;
        List<String> openclose = [];
        try {
          subString3 = hexDecimalValue.substring(162, 164);
          int decimalNumber = int.parse(subString3, radix: 16);
          // binaryNumber = decimalNumber.toRadixString(2);
          binaryNumber = decimalNumber.toRadixString(2).padLeft(8, '0');
        } catch (_, ex) {
          binaryNumber = '0.0';
        }

        if (binaryNumber.length >= 5) {
          openclose.add(binaryNumber[1]);
          openclose.add(binaryNumber[2]);
          openclose.add(binaryNumber[3]);
          // autom.add(binaryNumber[3]);
          // autom.add(binaryNumber[4]);
          // autom.add(binaryNumber[5]);
          // autom.add(binaryNumber[6]);
        }
        if (openclose[2] == '1') {
          return 'O';
        } else if (openclose[1] == '1') {
          return 'F';
        } else if (openclose[0] == '1') {
          return 'P';
        } else
          return 'N';

      case 4:
        var subString3;
        String binaryNumber;
        List<String> openclose = [];
        try {
          subString3 = hexDecimalValue.substring(164, 166);
          int decimalNumber = int.parse(subString3, radix: 16);
          // binaryNumber = decimalNumber.toRadixString(2);
          binaryNumber = decimalNumber.toRadixString(2).padLeft(8, '0');
        } catch (_, ex) {
          binaryNumber = '0.0';
        }

        if (binaryNumber.length >= 5) {
          openclose.add(binaryNumber[1]);
          openclose.add(binaryNumber[2]);
          openclose.add(binaryNumber[3]);
          // autom.add(binaryNumber[3]);
          // autom.add(binaryNumber[4]);
          // autom.add(binaryNumber[5]);
          // autom.add(binaryNumber[6]);
        }
        if (openclose[2] == '1') {
          return 'O';
        } else if (openclose[1] == '1') {
          return 'F';
        } else if (openclose[0] == '1') {
          return 'P';
        } else
          return 'N';
      case 5:
        var subString3;
        String binaryNumber;
        List<String> openclose = [];
        try {
          subString3 = hexDecimalValue.substring(166, 168);
          int decimalNumber = int.parse(subString3, radix: 16);
          // binaryNumber = decimalNumber.toRadixString(2);
          binaryNumber = decimalNumber.toRadixString(2).padLeft(8, '0');
        } catch (_, ex) {
          binaryNumber = '0.0';
        }

        if (binaryNumber.length >= 5) {
          openclose.add(binaryNumber[1]);
          openclose.add(binaryNumber[2]);
          openclose.add(binaryNumber[3]);
          // autom.add(binaryNumber[3]);
          // autom.add(binaryNumber[4]);
          // autom.add(binaryNumber[5]);
          // autom.add(binaryNumber[6]);
        }
        if (openclose[2] == '1') {
          return 'O';
        } else if (openclose[1] == '1') {
          return 'F';
        } else if (openclose[0] == '1') {
          return 'P';
        } else
          return 'N';

      case 6:
        var subString3;
        String binaryNumber;
        List<String> openclose = [];
        try {
          subString3 = hexDecimalValue.substring(168, 170);
          int decimalNumber = int.parse(subString3, radix: 16);
          // binaryNumber = decimalNumber.toRadixString(2);

          binaryNumber = decimalNumber.toRadixString(2).padLeft(8, '0');
        } catch (_, ex) {
          binaryNumber = '0.0';
        }

        if (binaryNumber.length >= 5) {
          openclose.add(binaryNumber[1]);
          openclose.add(binaryNumber[2]);
          openclose.add(binaryNumber[3]);
          // autom.add(binaryNumber[3]);
          // autom.add(binaryNumber[4]);
          // autom.add(binaryNumber[5]);
          // autom.add(binaryNumber[6]);
        }
        if (openclose[2] == '1') {
          return 'O';
        } else if (openclose[1] == '1') {
          return 'F';
        } else if (openclose[0] == '1') {
          return 'P';
        } else
          return 'N';
    }
  }

  getPDeltaValue(double pt1, double pt2) {
    double value = 0.0;
    try {
      value = double.parse(convertBartoMeter(pt1)) -
          double.parse(convertBartoMeter(pt2));
      if (value < 0) value = value * (-1);
    } catch (_, ex) {}
    return value;
  }

  String pfcmd_modedata_1() {
    var subString3;
    String runtime;
    try {
      subString3 = hexDecimalValue.substring(158, 160);
      int decimal = int.parse(subString3, radix: 16);
      runtime = (decimal / 100).toString();
    } catch (_, ex) {
      runtime = '0.0';
    }
    return runtime;
  }

  String pfcmd_modedata_2() {
    var subString3;
    String runtime;
    try {
      subString3 = hexDecimalValue.substring(160, 162);
      int decimal = int.parse(subString3, radix: 16);
      runtime = (decimal / 100).toString();
    } catch (_, ex) {
      runtime = '0.0';
    }
    return runtime;
  }

  String pfcmd_modedata_3() {
    var subString3;
    String runtime;
    try {
      subString3 = hexDecimalValue.substring(162, 164);
      int decimal = int.parse(subString3, radix: 16);
      runtime = (decimal / 100).toString();
    } catch (_, ex) {
      runtime = '0.0';
    }
    return runtime;
  }

  String pfcmd_modedata_4() {
    var subString3;
    String runtime;
    try {
      subString3 = hexDecimalValue.substring(164, 166);
      int decimal = int.parse(subString3, radix: 16);
      runtime = (decimal / 100).toString();
    } catch (_, ex) {
      runtime = '0.0';
    }
    return runtime;
  }

  String pfcmd_modedata_5() {
    var subString3;
    String runtime;
    try {
      subString3 = hexDecimalValue.substring(166, 168);
      int decimal = int.parse(subString3, radix: 16);
      runtime = (decimal / 100).toString();
    } catch (_, ex) {
      runtime = '0.0';
    }
    return runtime;
  }

  String pfcmd_modedata_6() {
    var subString3;
    String runtime;
    try {
      subString3 = hexDecimalValue.substring(168, 170);
      int decimal = int.parse(subString3, radix: 16);
      runtime = (decimal / 100).toString();
    } catch (_, ex) {
      runtime = '0.0';
    }
    return runtime;
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

  String getOutletbar_pfcmd_2() {
    var subString3;
    String outletbar;
    try {
      subString3 = hexDecimalValue.substring(58, 62);
      int decimal = int.parse(subString3, radix: 16);
      outletbar = (decimal / 100).toString();
    } catch (_, ex) {
      outletbar = '0.0';
    }
    return outletbar;
  }

  String getPostion_pfcmd_2() {
    var subString3;
    String postionvalue;
    try {
      subString3 = hexDecimalValue.substring(62, 66);
      int decimal = int.parse(subString3, radix: 16);
      postionvalue = (decimal / 100).toString();
    } catch (_, ex) {
      postionvalue = '0.0';
    }
    return postionvalue;
  }

  String getflowvalue_pfcmd_2() {
    var subString3;
    String flowvalue;
    try {
      subString3 = hexDecimalValue.substring(66, 70);
      int decimal = int.parse(subString3, radix: 16);
      flowvalue = (decimal / 100).toString();
    } catch (_, ex) {
      flowvalue = '0.0';
    }
    return flowvalue;
  }

  String getDailyvol_pfcmd_2() {
    var subString3;
    String dailyvol;
    try {
      subString3 = hexDecimalValue.substring(70, 74);
      int decimal = int.parse(subString3, radix: 16);
      dailyvol = (decimal / 100).toString();
    } catch (_, ex) {
      dailyvol = '0.0';
    }
    return dailyvol;
  }

// pfcmd 3 data

  String getOutletbar_pfcmd_3() {
    var subString3;
    String outletbar;
    try {
      subString3 = hexDecimalValue.substring(78, 82);
      int decimal = int.parse(subString3, radix: 16);
      outletbar = (decimal / 100).toString();
    } catch (_, ex) {
      outletbar = '0.0';
    }
    return outletbar;
  }

  String getPostion_pfcmd_3() {
    var subString3;
    String postionvalue;
    try {
      subString3 = hexDecimalValue.substring(82, 86);
      int decimal = int.parse(subString3, radix: 16);
      postionvalue = (decimal / 100).toString();
    } catch (_, ex) {
      postionvalue = '0.0';
    }
    return postionvalue;
  }

  String getflowvalue_pfcmd_3() {
    var subString3;
    String flowvalue;
    try {
      subString3 = hexDecimalValue.substring(86, 90);
      int decimal = int.parse(subString3, radix: 16);
      flowvalue = (decimal / 100).toString();
    } catch (_, ex) {
      flowvalue = '0.0';
    }
    return flowvalue;
  }

  String getDailyvol_pfcmd_3() {
    var subString3;
    String dailyvol;
    try {
      subString3 = hexDecimalValue.substring(90, 94);
      int decimal = int.parse(subString3, radix: 16);
      dailyvol = (decimal / 100).toString();
    } catch (_, ex) {
      dailyvol = '0.0';
    }
    return dailyvol;
  }

// pfcmd 4 data

  String getOutletbar_pfcmd_4() {
    var subString3;
    String outletbar;
    try {
      subString3 = hexDecimalValue.substring(98, 102);
      int decimal = int.parse(subString3, radix: 16);
      outletbar = (decimal / 100).toString();
    } catch (_, ex) {
      outletbar = '0.0';
    }
    return outletbar;
  }

  String getPostion_pfcmd_4() {
    var subString3;
    String postionvalue;
    try {
      subString3 = hexDecimalValue.substring(108, 106);
      int decimal = int.parse(subString3, radix: 16);
      postionvalue = (decimal / 100).toString();
    } catch (_, ex) {
      postionvalue = '0.0';
    }
    return postionvalue;
  }

  String getflowvalue_pfcmd_4() {
    var subString3;
    String flowvalue;
    try {
      subString3 = hexDecimalValue.substring(106, 110);
      int decimal = int.parse(subString3, radix: 16);
      flowvalue = (decimal / 100).toString();
    } catch (_, ex) {
      flowvalue = '0.0';
    }
    return flowvalue;
  }

  String getDailyvol_pfcmd_4() {
    var subString3;
    String dailyvol;
    try {
      subString3 = hexDecimalValue.substring(110, 114);
      int decimal = int.parse(subString3, radix: 16);
      dailyvol = (decimal / 100).toString();
    } catch (_, ex) {
      dailyvol = '0.0';
    }
    return dailyvol;
  }

  // pfcmd 5 data

  String getOutletbar_pfcmd_5() {
    var subString3;
    String outletbar;
    try {
      subString3 = hexDecimalValue.substring(118, 122);
      int decimal = int.parse(subString3, radix: 16);
      outletbar = (decimal / 100).toString();
    } catch (_, ex) {
      outletbar = '0.0';
    }
    return outletbar;
  }

  String getPostion_pfcmd_5() {
    var subString3;
    String postionvalue;
    try {
      subString3 = hexDecimalValue.substring(122, 126);
      int decimal = int.parse(subString3, radix: 16);
      postionvalue = (decimal / 100).toString();
    } catch (_, ex) {
      postionvalue = '0.0';
    }
    return postionvalue;
  }

  String getflowvalue_pfcmd_5() {
    var subString3;
    String flowvalue;
    try {
      subString3 = hexDecimalValue.substring(126, 130);
      int decimal = int.parse(subString3, radix: 16);
      flowvalue = (decimal / 100).toString();
    } catch (_, ex) {
      flowvalue = '0.0';
    }
    return flowvalue;
  }

  String getDailyvol_pfcmd_5() {
    var subString3;
    String dailyvol;
    try {
      subString3 = hexDecimalValue.substring(130, 134);
      int decimal = int.parse(subString3, radix: 16);
      dailyvol = (decimal / 100).toString();
    } catch (_, ex) {
      dailyvol = '0.0';
    }
    return dailyvol;
  }

// 6 pfcnd data

  String getOutletbar_pfcmd_6() {
    var subString3;
    String outletbar;
    try {
      subString3 = hexDecimalValue.substring(138, 142);
      int decimal = int.parse(subString3, radix: 16);
      outletbar = (decimal / 100).toString();
    } catch (_, ex) {
      outletbar = '0.0';
    }
    return outletbar;
  }

  String getPostion_pfcmd_6() {
    var subString3;
    String postionvalue;
    try {
      subString3 = hexDecimalValue.substring(142, 146);
      int decimal = int.parse(subString3, radix: 16);
      postionvalue = (decimal / 100).toString();
    } catch (_, ex) {
      postionvalue = '0.0';
    }
    return postionvalue;
  }

  String getflowvalue_pfcmd_6() {
    var subString3;
    String flowvalue;
    try {
      subString3 = hexDecimalValue.substring(146, 150);
      int decimal = int.parse(subString3, radix: 16);
      flowvalue = (decimal / 100).toString();
    } catch (_, ex) {
      flowvalue = '0.0';
    }
    return flowvalue;
  }

  String getDailyvol_pfcmd_6() {
    var subString3;
    String dailyvol;
    try {
      subString3 = hexDecimalValue.substring(150, 154);
      int decimal = int.parse(subString3, radix: 16);
      dailyvol = (decimal / 100).toString();
    } catch (_, ex) {
      dailyvol = '0.0';
    }
    return dailyvol;
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
