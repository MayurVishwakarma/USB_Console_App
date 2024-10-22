// ignore_for_file: must_be_immutable, unused_field

import 'package:flutter/material.dart';
import 'package:usb_console_application/Screens/AutoCommisitoning/AutoCommistoning.dart';
import 'package:usb_console_application/Screens/AutoCommisitoning/RMS_Auto_Comm.dart';
import 'package:usb_console_application/Screens/FactorySetting/FactorySetting.dart';
import 'package:usb_console_application/Screens/ProcessMonitoring/ProcessMonitering.dart';
import 'package:usb_console_application/Widget/custom_stack_widget.dart';
import 'package:usb_console_application/Widget/dialog.dart';
import 'package:usb_console_application/models/NodeDetailsModel.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:usb_serial/transaction.dart';
import 'package:usb_serial/usb_serial.dart';

class USBConsoleMenu extends StatefulWidget {
  NodeDetailsModel? data;
  USBConsoleMenu(NodeDetailsModel nodedata, {super.key}) {
    data = nodedata;
  }

  @override
  State<USBConsoleMenu> createState() => _USBConsoleMenuState();
}

class _USBConsoleMenuState extends State<USBConsoleMenu> {
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.data?.chakNo ?? ''),
      ),
      body: SingleChildScrollView(
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
                                builder: (context) =>
                                    ProcessMonitoringScreen()),
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
                                builder: (context) => const FactorySetting()),
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
                                builder: (context) =>
                                    AutoCommistioningScreen(widget.data!, '')),
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
                                builder: (context) =>
                                    const RMSAutoCommScreen()),
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
      ),
    );
  }
}
