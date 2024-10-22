// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously, avoid_unnecessary_containers, prefer_const_constructors_in_immutables, unused_field, cast_from_null_always_fails

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:usb_console_application/Screens/AutoCommisitoning/AutoCommistoning.dart';
import 'package:usb_console_application/Screens/AutoCommisitoning/RMS_Auto_Comm.dart';
import 'package:usb_console_application/Screens/AutoCommisitoning/auto_commission_screen_bluetooth.dart';
import 'package:usb_console_application/Screens/Bluetooth/bluetooth_screen.dart';
import 'package:usb_console_application/Screens/FactorySetting/FactorySetting.dart';
import 'package:usb_console_application/Screens/Login/LoginScreen.dart';
import 'package:usb_console_application/Screens/ProcessMonitoring/ProcessMonitering.dart';
import 'package:usb_console_application/Screens/ProcessMonitoring/process_moniter_screen_bt.dart';
import 'package:usb_console_application/Screens/rms/rms_bluetooth.dart';
import 'package:usb_console_application/Widget/custom_stack_widget.dart';
import 'package:usb_console_application/Widget/dialog.dart';
import 'package:usb_console_application/core/utils/appColors..dart';
import 'package:usb_console_application/models/NodeDetailsModel.dart';
import 'package:usb_console_application/models/pdfbase64code.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:usb_serial/transaction.dart';
import 'package:usb_serial/usb_serial.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class DashboardScreen extends StatefulWidget {
  static const routeName = "/dashboard";
  DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Dashboard'),
          bottom: TabBar(indicatorColor: AppColors.primaryColor, tabs: [
            Text(
              "Bluetooth",
              style: TextStyle(fontSize: 20),
            ),
            Text(
              "USB",
              style: TextStyle(fontSize: 20),
            )
          ]),
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
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    LoginPageScreen.routeName,
                    (Route<dynamic> route) => false,
                  );
                },
              ),
            )
          ],
        ),
        body: TabBarView(
          children: [BluetoothWidget(), UsbWidget()],
        ),
      ),
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

class BluetoothWidget extends StatelessWidget {
  const BluetoothWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomStackWidget(
                  onTap: () {
                    Navigator.pushNamed(context, BluetoothScreen.routeName);
                  },
                  title: "Bluetooth",
                  image: "assets/images/bluetooth.png",
                ),
                CustomStackWidget(
                  onTap: () {
                    Navigator.pushNamed(
                        context, ProcessMoniterScreenBT.routeName);
                  },
                  title: "Process\nMonitoring",
                  image: "assets/images/monitoring.png",
                )
              ],
            ),
            /*const SizedBox(
              height: 16,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomStackWidget(
                  onTap: () {
                    Navigator.pushNamed(
                        context, AutoDryCommissionScreenBluetooth.routeName);
                  },
                  title: "Auto \nCommission",
                  image: "assets/images/exam.png",
                ),
                SizedBox(
                  height: 200,
                  width: (MediaQuery.of(context).size.width > 600)
                      ? 200
                      : MediaQuery.of(context).size.width / 2.2,
                )
              ],
            ),
           */
            const SizedBox(
              height: 16,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomStackWidget(
                  onTap: () {
                    Navigator.pushNamed(
                        context, AutoDryCommissionScreenBluetooth.routeName);
                  },
                  title: "OMS Auto \nCommission",
                  image: "assets/images/exam.png",
                ),
                CustomStackWidget(
                  onTap: () {
                    Navigator.pushNamed(
                        context, RMSAutoDryCommissionScreenBluetooth.routeName);
                  },
                  title: "RMS Auto \nCommission",
                  image: "assets/images/exam.png",
                ),
                // SizedBox(
                //   height: 200,
                //   width: (MediaQuery.of(context).size.width > 600)
                //       ? 200
                //       : MediaQuery.of(context).size.width / 2.2,
                // )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class UsbWidget extends StatefulWidget {
  const UsbWidget({super.key});

  @override
  State<UsbWidget> createState() => _UsbWidgetState();
}

class _UsbWidgetState extends State<UsbWidget> {
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

  @override
  void dispose() {
    super.dispose();
    _connectTo(null);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
          child: Column(
        children: [
          const SizedBox(
            height: 50,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CustomStackWidget(
                image: "assets/images/monitoring.png",
                title: "Process Monitoring",
                onTap: _port == null
                    ? () => deviceNotConnectedDialog(context)
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProcessMonitoringScreen()),
                        );
                      },
              ),
              CustomStackWidget(
                image: "assets/images/manufacturing.png",
                title: "Factory Setting",
                onTap: _port == null
                    ? () => deviceNotConnectedDialog(context)
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FactorySetting()),
                        );
                      },
              ),
            ],
          ),
          const SizedBox(
            height: 16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CustomStackWidget(
                image: "assets/images/exam.png",
                title: "OMS Auto Commission",
                onTap: _port == null
                    ? () => deviceNotConnectedDialog(context)
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AutoCommistioningScreen(
                                  null as NodeDetailsModel, '')),
                        );
                      },
              ),
              CustomStackWidget(
                image: "assets/images/exam.png",
                title: "RMS Auto Commission",
                onTap: _port == null
                    ? () => deviceNotConnectedDialog(context)
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RMSAutoCommScreen()),
                        );
                      },
              ),
            ],
          ),
          /* const SizedBox(
            height: 16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CustomStackWidget(
                image: "assets/images/uploadreport.png",
                title: "Connect to ECM",
                onTap: _port == null
                    ? () => deviceNotConnectedDialog(context)
                    : () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //       builder: (context) => AutoCommistioningScreen()),
                        // );
                      },
              ),
              SizedBox(
                height: 200,
                width: (MediaQuery.of(context).size.width > 600)
                    ? 200
                    : MediaQuery.of(context).size.width / 2.2,
              )
              /* CustomStackWidget(
                image: "assets/images/exam.png",
                title: "RMS Auto Commission",
                onTap: _port == null
                    ? () => deviceNotConnectedDialog(context)
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RMSAutoCommScreen()),
                        );
                      },
              ),
           */
            ],
          )*/
        ],
      )),
    );
  }
}
