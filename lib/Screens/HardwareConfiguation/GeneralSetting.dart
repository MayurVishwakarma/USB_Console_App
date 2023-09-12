// ignore_for_file: unused_import, file_names, prefer_const_constructors_in_immutables, prefer_const_constructors, unused_field, prefer_final_fields, prefer_interpolation_to_compose_strings, prefer_typing_uninitialized_variables, avoid_print, unused_catch_stack, sort_child_properties_last, unnecessary_new

import 'dart:async';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:hex/hex.dart';
import 'package:intl/intl.dart';
import 'package:usb_serial/transaction.dart';
import 'package:usb_serial/usb_serial.dart';

class GeneralSetting extends StatefulWidget {
  GeneralSetting({Key? key}) : super(key: key);

  @override
  State<GeneralSetting> createState() => _GeneralSettingState();
}

class _GeneralSettingState extends State<GeneralSetting> {
  UsbPort? _port;
  String _status = "Idle";
  List<UsbDevice> _devices = [];
  List<String> _serialdata = [];
  List<String> _response = [];
  String? _datetime;
  String btntxt = 'Connect';
  double _progress = 0.0;
  TextEditingController _datetimecontroller = TextEditingController();
  TextEditingController _sitenamecontroller = TextEditingController();
  TextEditingController _modemtypecontroller = TextEditingController();

  TextEditingController _irtcontroller = TextEditingController();
  TextEditingController _firmwarecontroller = TextEditingController();
  StreamSubscription<String>? _subscription;
  Transaction<String>? _transaction;

  Future<void> _getPorts() async {
    final devices = await UsbSerial.listDevices();
    setState(() {
      _devices = devices;
    });
    // _connectTo(devices.first);
  }

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

    _transaction = Transaction.stringTerminated(
      _port!.inputStream as Stream<Uint8List>,
      Uint8List.fromList([13, 10]),
    );

    _subscription = _transaction!.stream.listen((String line) {
      setState(() {
        _response.add(line);
        _serialdata.add(line);
      });
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
    _connectTo(null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
                // subtitle: Text(device.manufacturerName ?? 'Unknown Manufacturer'),
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
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: Color.fromARGB(255, 223, 235, 247),
                      borderRadius: BorderRadius.circular(5)),
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
                                'Datetime :',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Expanded(
                                child: TextField(
                              controller: _datetimecontroller,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Color.fromARGB(255, 45, 51, 74)),
                            )),
                            SizedBox(width: 5),
                            ElevatedButton(
                                onPressed: _port == null
                                    ? null
                                    : () async {
                                        _progress = 0.0;
                                        _startTask(10);
                                        getpop_loader(context);
                                        Future.delayed(Duration(seconds: 12),
                                            () {
                                          Navigator.pop(context); //pop dialog
                                        });
                                        await getDatetime();
                                      },
                                child: Text('Get')),
                            ElevatedButton(
                                onPressed: _port == null
                                    ? null
                                    : () async {
                                        _progress = 0.0;
                                        _startTask(10);
                                        getpop_loader(context);
                                        Future.delayed(Duration(seconds: 12),
                                            () {
                                          Navigator.pop(context); //pop dialog
                                        });
                                        await setDatetime();
                                      },
                                child: Text('Set'))
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(9.0),
                              child: Text(
                                'Site Name :',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            Expanded(
                                child: TextField(
                              controller: _sitenamecontroller,
                            )),
                            SizedBox(width: 5),
                            ElevatedButton(
                                onPressed: _port == null
                                    ? null
                                    : () async {
                                        _progress = 0.0;
                                        _startTask(10);
                                        getpop_loader(context);
                                        Future.delayed(Duration(seconds: 12),
                                            () {
                                          Navigator.pop(context); //pop dialog
                                        });
                                        await getSiteName();
                                      },
                                child: Text('Get')),
                            ElevatedButton(
                                onPressed: _port == null
                                    ? null
                                    : () async {
                                        _progress = 0.0;
                                        _startTask(10);
                                        getpop_loader(context);
                                        Future.delayed(Duration(seconds: 12),
                                            () {
                                          Navigator.pop(context); //pop dialog
                                        });
                                        await setSiteName();
                                      },
                                child: Text('Set'))
                          ],
                        ),
                        /*Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(9.0),
                              child: Text(
                                'Modem Name :',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            Expanded(
                                child: TextField(
                              controller: _modemtypecontroller,
                            )),
                            SizedBox(width: 5),
                            ElevatedButton(
                                onPressed: _port == null
                                    ? null
                                    : () async {
                                        getpop(context);
                                        new Future.delayed(new Duration(seconds: 6),
                                            () {
                                          Navigator.pop(context); //pop dialog
                                        });
                                        await getModemType();
                                      },
                                child: Text('Get')),
                            ElevatedButton(
                                onPressed: _port == null ? null : () {},
                                child: Text('Set'))
                          ],
                        ),
                       */
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(9.0),
                              child: Text(
                                'IO Interval :',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            Expanded(
                                child: TextField(
                              controller: _irtcontroller,
                            )),
                            SizedBox(width: 5),
                            ElevatedButton(
                                onPressed: _port == null
                                    ? null
                                    : () async {
                                        _progress = 0.0;
                                        _startTask(10);
                                        getpop_loader(context);
                                        Future.delayed(Duration(seconds: 12),
                                            () {
                                          Navigator.pop(context); //pop dialog
                                        });
                                        await getIRT();
                                      },
                                child: Text('Get')),
                            ElevatedButton(
                                onPressed: _port == null
                                    ? null
                                    : () async {
                                        _progress = 0.0;
                                        _startTask(10);
                                        getpop_loader(context);
                                        Future.delayed(Duration(seconds: 12),
                                            () {
                                          Navigator.pop(context); //pop dialog
                                        });
                                        await setIRT();
                                      },
                                child: Text('Set'))
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(9.0),
                              child: Text(
                                "Firmware Version :",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            Expanded(
                                child: TextField(
                              enabled: false,
                              controller: _firmwarecontroller,
                            )),
                            SizedBox(width: 5),
                            ElevatedButton(
                                onPressed: _port == null
                                    ? null
                                    : () async {
                                        _progress = 0.0;
                                        _startTask(10);
                                        getpop_loader(context);
                                        Future.delayed(Duration(seconds: 12),
                                            () {
                                          Navigator.pop(context); //pop dialog
                                        });
                                        await getFirmwareV();
                                      },
                                child: Text('Get')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Color.fromARGB(255, 125, 174, 213),
                            borderRadius: BorderRadius.circular(5)),
                        height: 45,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Pocket Response',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                textScaleFactor: 1,
                              ),
                            ),
                            TextButton(
                              child: Text(
                                'Clear',
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: _port == null
                                  ? null
                                  : () {
                                      _response.clear();
                                      _serialdata.clear();
                                    },
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      child: Column(
                        children: _serialdata
                            .map(
                              (widget) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5.0),
                                child: DefaultTextStyle.merge(
                                  style: TextStyle(
                                    color: Colors
                                        .green, // Set the desired text color here
                                  ),
                                  child: Text(widget),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF232323),
                        borderRadius: BorderRadius.circular(8),

                        // padding : NEVER FOLD
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  getDatetime() async {
    try {
      String data = 'dts'.toUpperCase() + "\r\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 12)).whenComplete(
        () {
          print(_response);
          String res = _response.join('');
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
          _datetimecontroller.text = formatter
              .format(DateTime(year, month, day, hour, minute, second));
        },
      );
      _response = [];
    } catch (_, ex) {
      print(ex);
      _serialdata.add('Please Try Again...');
    }
  }

  setDatetime() async {
    try {
      final DateFormat inputFormatter = DateFormat('yyyy/MM/dd HH:mm:ss');
      final DateFormat outputFormatter = DateFormat('yyyy M d H m s');
      String dateTime = outputFormatter
          .format(inputFormatter.parse(_datetimecontroller.text));
      String data = ('dts ' + dateTime).toUpperCase() + "\r\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 6)).whenComplete(() {
        String res = _response.join('');
        print(res);
      });
    } catch (_, ex) {
      print(ex);
      _serialdata.add('Please Try Again...');
    }
  }

  getSiteName() async {
    try {
      String data = 'sinm'.toUpperCase() + "\r\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 6)).whenComplete(
        () {
          print(_response);
          String res = _response.join('');
          int i = res.indexOf("SI");
          _sitenamecontroller.text = res.substring(i + 5, i + 13);
          print(res.substring(i + 5, i + 13));
        },
      );
      _response = [];
    } catch (_, ex) {
      print(ex);
      _serialdata.add('Please Try Again...');
    }
  }

  setSiteName() async {
    try {
      String data = ('sinm ' + _sitenamecontroller.text).toUpperCase() + "\r\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 6)).whenComplete(
        () {
          print(_response);
          String res = _response.join('');
          print(res);
        },
      );
      _response = [];
    } catch (_, ex) {
      print(ex);
      _serialdata.add('Please Try Again...');
    }
  }

  getModemType() async {
    String Status;
    try {
      String data = 'mdm'.toUpperCase() + "\r\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 6)).whenComplete(
        () {
          print(_response);
          String res = _response.join('');
          int i = res.indexOf("md");
          Status = res.substring(i + 2, i + 3);
          if (Status == '0') {
            _modemtypecontroller.text = 'WIFI';
          } else if (Status == '1') {
            _modemtypecontroller.text = 'GSM';
          } else if (Status == '2') {
            _modemtypecontroller.text = 'Lora';
          } else {
            print('Error');
          }
          print(res.substring(i + 2, i + 3));
        },
      );
      _response = [];
    } catch (_, ex) {
      print(ex);
      _serialdata.add('Please Try Again...');
    }
  }

  getIRT() async {
    try {
      String data = 'irt'.toUpperCase() + "\r\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 6)).whenComplete(
        () {
          print(_response);
          String res = _response.join('');
          int i = res.indexOf("IR");
          _irtcontroller.text = res.substring(i + 4, i + 8);
          print(res.substring(i + 5, i + 8));
        },
      );
      _response = [];
    } catch (_, ex) {
      print(ex);
      _serialdata.add('Please Try Again...');
    }
  }

  setIRT() async {
    try {
      String data = ('irt ' + _irtcontroller.text).toUpperCase() + "\r\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 6)).whenComplete(
        () {
          print(_response);
          String res = _response.join('');
          print(res);
        },
      );
      _response = [];
    } catch (_, ex) {
      print(ex);
      _serialdata.add('Please Try Again...');
    }
  }

  getFirmwareV() async {
    try {
      String data = 'fwv'.toUpperCase() + "\r\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 6)).whenComplete(
        () {
          print(_response);

          String res = _response.join('');
          int i = res.indexOf("FW");
          _firmwarecontroller.text = res.substring(i + 3, i + 7);
          print(res.substring(i + 3, i + 6));
        },
      );
      _response = [];
    } catch (_, ex) {
      print(ex);
      _serialdata.add('Please Try Again...');
    }
  }

  // getpop(context) {
  //   return showDialog(
  //     barrierDismissible: false,
  //     useSafeArea: true,
  //     context: context,
  //     builder: (ctx) => Dialog(
  //       backgroundColor: Colors.transparent,
  //       child: AnimatedContainer(
  //         duration:
  //             Duration(milliseconds: 500), // Set the desired animation duration
  //         curve: Curves.easeInOut, // Set the desired animation curve
  //         padding: EdgeInsets.all(16),
  //         decoration: BoxDecoration(
  //           color: Colors.white,
  //           borderRadius: BorderRadius.circular(8),
  //         ),

  //         child: SizedBox(
  //           height: 260,
  //           child: Column(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               Padding(
  //                 padding: const EdgeInsets.all(8.0),
  //                 child: Image(
  //                   image: AssetImage('assets/images/Iphone-spinner-2.gif'),
  //                   height: 80,
  //                 ),
  //               ),
  //               SizedBox(height: 10),
  //               Text(
  //                 'Sending Command...',
  //                 style: TextStyle(color: Colors.black),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
  void _startTask(int sec) async {
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
