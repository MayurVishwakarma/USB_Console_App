// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously, avoid_unnecessary_containers, prefer_const_constructors_in_immutables, unused_field

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_usb2/Screens/AutoCommisitoning/AutoCommistoning.dart';
import 'package:flutter_application_usb2/Screens/FactorySetting/FactorySetting.dart';
import 'package:flutter_application_usb2/Screens/HardwareConfiguation/HardwareConfiguation.dart';
import 'package:flutter_application_usb2/Screens/Login/LoginScreen.dart';
import 'package:flutter_application_usb2/Screens/ProcessMonitoring/ProcessMonitering.dart';
import 'package:flutter_application_usb2/models/pdfbase64code.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:usb_serial/transaction.dart';
import 'package:usb_serial/usb_serial.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../FirmwareUpdate/test.dart';
import '../LocalOperation/LocalOperation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class DashboardScreen extends StatefulWidget {
  DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  UsbPort? _port;
  String _status = "Idle";
  List<UsbDevice> _devices = [];
  StreamSubscription<String>? _subscription;
  Transaction<String>? _transaction;
  Future<bool> _connectTo(UsbDevice? device) async {
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

    _transaction = Transaction.stringTerminated(
      _port!.inputStream as Stream<Uint8List>,
      Uint8List.fromList([13, 10]),
    );

    _subscription = _transaction!.stream.listen((String line) {});

    setState(() {
      _status = "Connected";
    });
    return true;
  }

  Future<void> _getPorts() async {
    final devices = await UsbSerial.listDevices();
    setState(() {
      _devices = devices;
    });
    _connectTo(devices.first);
  }

  @override
  void initState() {
    super.initState();
    UsbSerial.usbEventStream?.listen((UsbEvent event) {
      _getPorts();
    });
    _getPorts();
  }

  /*@override
  void dispose() {
    super.dispose();
    _connectTo(null);
  }
*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          Padding(
            padding: EdgeInsets.all(8),
            child: IconButton(
                icon: Icon(Icons.info),
                onPressed: () {
                  base64ToPdf(PdfConstant.base64pdf, 'Bluetooth Manual');
                }),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              child: Image(
                image: AssetImage('assets/images/turn-off.png'),
                height: 25,
              ),
              onTap: () async {
                SharedPreferences preferences =
                    await SharedPreferences.getInstance();
                await preferences.clear();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          )
        ],
      ),
      body: Container(
          child: GridView.count(
        crossAxisCount: 2, // Number of columns in the grid
        crossAxisSpacing: 10, // Spacing between columns
        mainAxisSpacing: 10, // Spacing between rows
        padding: EdgeInsets.all(10), // Padding around the grid
        children: [
          //Bluetooth Card
          Card(
            elevation: 5,
            child: GestureDetector(
              onTap: _port == null
                  ? () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: SizedBox(
                              height:
                                  230, //MediaQuery.of(context).size.height * 0.35,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image(
                                    image: AssetImage(
                                        'assets/images/work-in-progress.gif'),
                                    height: 120,
                                    width: 120,
                                  ),
                                  Text(
                                    'Work In Progress',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 25.0),
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        'OK',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
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
                  : () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: SizedBox(
                              height:
                                  230, //MediaQuery.of(context).size.height * 0.35,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image(
                                    image: AssetImage(
                                        'assets/images/work-in-progress.gif'),
                                    height: 120,
                                    width: 120,
                                  ),
                                  Text(
                                    'Work In Progress',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 25.0),
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        'OK',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image(
                        image: AssetImage('assets/images/bluetooth.png'),
                        height: 80,
                      ),
                    ),
                    Text(
                      'Bluetooth Pairing',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),

          //Process monitoring
          Card(
            elevation: 5,
            child: GestureDetector(
              onTap: _port == null
                  ? () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: SizedBox(
                              height:
                                  260, //MediaQuery.of(context).size.height * 0.35,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image(
                                    image: AssetImage(
                                        'assets/images/usb-cable.gif'),
                                    height: 120,
                                    width: 120,
                                  ),
                                  Text(
                                    'Device Not Connected',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey),
                                  ),
                                  Text(
                                    'Please connect USB Console device to proceed.',
                                    textAlign: TextAlign.center,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 25.0),
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        'OK',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
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
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProcessMonitoringScreen()),
                      );
                    },
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image(
                        image: AssetImage('assets/images/monitoring.png'),
                        height: 80,
                      ),
                    ),
                    Text(
                      'Process Monitoring',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),

          //Local Operation
          Card(
            elevation: 5,
            child: GestureDetector(
              onTap: _port == null
                  ? () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: SizedBox(
                              height:
                                  260, //MediaQuery.of(context).size.height * 0.35,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image(
                                    image: AssetImage(
                                        'assets/images/usb-cable.gif'),
                                    height: 120,
                                    width: 120,
                                  ),
                                  Text(
                                    'Device Not Connected',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey),
                                  ),
                                  Text(
                                    'Please connect USB Console device to proceed.',
                                    textAlign: TextAlign.center,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 25.0),
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        'OK',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // actions: [

                            // ],
                          );
                        },
                      );
                    }
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                local_op_new()), //LocalOperation_SinglePFCMD
                      );
                    },
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image(
                        image: AssetImage('assets/images/gear.png'),
                        height: 80,
                      ),
                    ),
                    Text(
                      'Local Operation',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),

          //Hardware Configuration
          Card(
            elevation: 5,
            child: GestureDetector(
              onTap: _port == null
                  ? () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: SizedBox(
                              height:
                                  260, //MediaQuery.of(context).size.height * 0.35,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image(
                                    image: AssetImage(
                                        'assets/images/usb-cable.gif'),
                                    height: 120,
                                    width: 120,
                                  ),
                                  Text(
                                    'Device Not Connected',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey),
                                  ),
                                  Text(
                                    'Please connect USB Console device to proceed.',
                                    textAlign: TextAlign.center,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 25.0),
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        'OK',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // actions: [

                            // ],
                          );
                        },
                      );
                    }
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Hardware_configration()),
                      );
                    },
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image(
                        image: AssetImage('assets/images/cogwheel.png'),
                        height: 80,
                      ),
                    ),
                    Center(
                      child: Text(
                        'Hardware Configuration',
                        textScaleFactor: 1,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          //Auto Commissoion
          Card(
            elevation: 5,
            child: GestureDetector(
              onTap: _port == null
                  ? () {
                      // showDialog(
                      //   context: context,
                      //   builder: (BuildContext context) {
                      //     return AlertDialog(
                      //       content: SizedBox(
                      //         height:
                      //             230, //MediaQuery.of(context).size.height * 0.35,
                      //         child: Column(
                      //           mainAxisAlignment: MainAxisAlignment.center,
                      //           children: [
                      //             Image(
                      //               image: AssetImage(
                      //                   'assets/images/work-in-progress.gif'),
                      //               height: 120,
                      //               width: 120,
                      //             ),
                      //             Text(
                      //               'Work In Progress',
                      //               style: TextStyle(
                      //                   fontSize: 18,
                      //                   fontWeight: FontWeight.bold,
                      //                   color: Colors.grey),
                      //             ),
                      //             Padding(
                      //               padding: const EdgeInsets.only(top: 25.0),
                      //               child: TextButton(
                      //                 onPressed: () {
                      //                   Navigator.of(context).pop();
                      //                 },
                      //                 child: Text(
                      //                   'OK',
                      //                   style: TextStyle(
                      //                       fontSize: 16,
                      //                       fontWeight: FontWeight.bold),
                      //                 ),
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //       // actions: [

                      //       // ],
                      //     );
                      //   },
                      // );
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: SizedBox(
                              height:
                                  260, //MediaQuery.of(context).size.height * 0.35,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image(
                                    image: AssetImage(
                                        'assets/images/usb-cable.gif'),
                                    height: 120,
                                    width: 120,
                                  ),
                                  Text(
                                    'Device Not Connected',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey),
                                  ),
                                  Text(
                                    'Please connect USB Console device to proceed.',
                                    textAlign: TextAlign.center,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 25.0),
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        'OK',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
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
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AutoCommistioningScreen()),
                      );
                      /*showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: SizedBox(
                              height:
                                  230, //MediaQuery.of(context).size.height * 0.35,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image(
                                    image: AssetImage(
                                        'assets/images/work-in-progress.gif'),
                                    height: 120,
                                    width: 120,
                                  ),
                                  Text(
                                    'Work In Progress',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 25.0),
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        'OK',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // actions: [

                            // ],
                          );
                        },
                      );
                    */
                    },
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image(
                        image: AssetImage('assets/images/exam.png'),
                        height: 80,
                      ),
                    ),
                    Text(
                      'Auto Commission',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Card(
            elevation: 5,
            child: GestureDetector(
              onTap: /* _port == null
                  ? () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: SizedBox(
                              height:
                                  260, //MediaQuery.of(context).size.height * 0.35,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image(
                                    image: AssetImage(
                                        'assets/images/usb-cable.gif'),
                                    height: 120,
                                    width: 120,
                                  ),
                                  Text(
                                    'Device Not Connected',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey),
                                  ),
                                  Text(
                                    'Please connect USB Console device to proceed.',
                                    textAlign: TextAlign.center,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 25.0),
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        'OK',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            */

                  // actions: [

                  // ],

                  //       );
                  //     },
                  //   );
                  // }
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FactorySetting()),
                );
              },
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image(
                        image: AssetImage('assets/images/manufacturing.png'),
                        height: 80,
                      ),
                    ),
                    Text(
                      'Factory Setting',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Card(
            elevation: 5,
            child: GestureDetector(
              onTap: _port == null
                  ? () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: SizedBox(
                              height:
                                  230, //MediaQuery.of(context).size.height * 0.35,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image(
                                    image: AssetImage(
                                        'assets/images/usb-cable.gif'),
                                    height: 120,
                                    width: 120,
                                  ),
                                  Text(
                                    'Work In Progress',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 25.0),
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        'OK',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
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
                  : () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: SizedBox(
                              height:
                                  230, //MediaQuery.of(context).size.height * 0.35,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image(
                                    image: AssetImage(
                                        'assets/images/work-in-progress.gif'),
                                    height: 120,
                                    width: 120,
                                  ),
                                  Text(
                                    'Work In Progress',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 25.0),
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        'OK',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image(
                        image: AssetImage('assets/images/update.png'),
                        height: 80,
                      ),
                    ),
                    Text(
                      'Firmware update',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),

          //Firmware Update
          /*Card(
            elevation: 5,
            child: GestureDetector(
              onTap: _port == null
                  ? () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: SizedBox(
                              height:
                                  260, //MediaQuery.of(context).size.height * 0.35,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image(
                                    image: AssetImage(
                                        'assets/images/usb-cable.gif'),
                                    height: 120,
                                    width: 120,
                                  ),
                                  Text(
                                    'Device Not Connected',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey),
                                  ),
                                  Text(
                                    'Please connect USB Console device to proceed.',
                                    textAlign: TextAlign.center,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 25.0),
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        'OK',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // actions: [

                            // ],
                          );
                        },
                      );
                    }
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UsbConsoleScreen_test()),
                      );
                    },
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image(
                        image: AssetImage('assets/images/update.png'),
                        height: 80,
                      ),
                    ),
                    Text(
                      'Firmware Update',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
*/
          // Add more containers for additional grid items
        ],
      )),
    );
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

  base64ToPdf(String base64String, String fileName) async {
    var bytes = base64Decode(base64String);
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/$fileName.pdf");
    await file.writeAsBytes(bytes.buffer.asUint8List());
    await OpenFilex.open("${output.path}/$fileName.pdf");
  }
}
