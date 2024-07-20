// ignore_for_file: unused_import, file_names, prefer_const_constructors_in_immutables, prefer_const_constructors, unused_field, prefer_final_fields, prefer_interpolation_to_compose_strings, prefer_typing_uninitialized_variables, avoid_print, unused_catch_stack, sort_child_properties_last, unnecessary_new, non_constant_identifier_names

import 'dart:async';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:hex/hex.dart';
import 'package:intl/intl.dart';
import 'package:usb_serial/transaction.dart';
import 'package:usb_serial/usb_serial.dart';

class GeneralFactorySetting extends StatefulWidget {
  GeneralFactorySetting({Key? key}) : super(key: key);

  @override
  State<GeneralFactorySetting> createState() => _GeneralFactorySettingState();
}

class _GeneralFactorySettingState extends State<GeneralFactorySetting> {
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
  TextEditingController _Alarm = TextEditingController();
  StreamSubscription<String>? _subscription;
  Transaction<String>? _transaction;
  var alarm_data;
  String? date_before;
  String? Site_name_before;
  String? Io_interval_before;
  String? Alarm_before;
  final List<ProcessModel> dropdownItems = [
    ProcessModel(id: 0, processName: 'Disable'),
    ProcessModel(id: 1, processName: 'Enable')
  ];

  ProcessModel? selectedProcessStatus;

  String? processStatus;

  Future<void> _getPorts() async {
    final devices = await UsbSerial.listDevices();
    setState(() {
      _devices = devices;
    });
    _connectTo(devices.first);
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
            ListTile(
              title: Text(device.productName ?? 'Unknown Device'),
              subtitle: Text(device.manufacturerName ?? 'Unknown Manufacturer'),
              trailing: ElevatedButton(
                child: Text(btntxt),
                onPressed: () {
                  if (_status == 'Disconnected') {
                    _connectTo(device);
                  } else if (_status == 'Connected') {
                    _connectTo(null);
                  }
                },
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      // height: 500,
                      decoration: BoxDecoration(
                          color: Color.fromARGB(255, 223, 235, 247),
                          borderRadius: BorderRadius.circular(5)),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    _progress = 0.0;
                                    _startTask(100);
                                    getpop_loader(context);
                                    Future.delayed(Duration(seconds: 75), () {
                                      Navigator.pop(context); //pop dialog
                                    });
                                    getAllData();
                                  },
                                  child: Text('Get All',
                                      style: TextStyle(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          5), // Set border radius to 0 for square shape
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(9.0),
                                  child: Text(
                                    'Datetime :',
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Expanded(
                                    child: TextField(
                                  controller: _datetimecontroller,
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 45, 51, 74),
                                      fontSize: 14),
                                )),
                                SizedBox(width: 5),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton(
                                      onPressed: _port == null
                                          ? null
                                          : () async {
                                              _progress = 0.0;
                                              _startTask(12);
                                              getpop_loader(context);
                                              Future.delayed(
                                                  Duration(seconds: 14), () {
                                                Navigator.pop(
                                                    context); //pop dialog
                                              });
                                              await getDatetime();
                                            },
                                      child: Text(
                                        'Get',
                                        softWrap: true,
                                      )),
                                ),
                                ElevatedButton(
                                    onPressed: _port == null
                                        ? null
                                        : () async {
                                            _progress = 0.0;
                                            _startTask(12);
                                            getpop_loader(context);
                                            Future.delayed(
                                                Duration(seconds: 14), () {
                                              Navigator.pop(
                                                  context); //pop dialog
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
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                                Expanded(
                                    child: TextField(
                                  controller: _sitenamecontroller,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 45, 51, 74),
                                      fontSize: 14),
                                )),
                                SizedBox(width: 5),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    child: ElevatedButton(
                                        onPressed: _port == null
                                            ? null
                                            : () async {
                                                _progress = 0.0;
                                                _startTask(12);
                                                getpop_loader(context);
                                                Future.delayed(
                                                    Duration(seconds: 14), () {
                                                  Navigator.pop(
                                                      context); //pop dialog
                                                });
                                                await getSiteName();
                                              },
                                        child: Text('Get')),
                                  ),
                                ),
                                SizedBox(
                                  child: ElevatedButton(
                                      onPressed: _port == null
                                          ? null
                                          : () async {
                                              _progress = 0.0;
                                              _startTask(12);
                                              getpop_loader(context);
                                              Future.delayed(
                                                  Duration(seconds: 14), () {
                                                Navigator.pop(
                                                    context); //pop dialog
                                              });
                                              await setSiteName();
                                            },
                                      child: Text('Set')),
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(9.0),
                                  child: Text(
                                    'IO Interval :',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                                Expanded(
                                    child: TextField(
                                  controller: _irtcontroller,
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 45, 51, 74),
                                      fontSize: 14),
                                )),
                                SizedBox(width: 5),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    child: ElevatedButton(
                                        onPressed: _port == null
                                            ? null
                                            : () async {
                                                _progress = 0.0;
                                                _startTask(12);
                                                getpop_loader(context);
                                                Future.delayed(
                                                    Duration(seconds: 14), () {
                                                  Navigator.pop(
                                                      context); //pop dialog
                                                });
                                                await getIRT();
                                              },
                                        child: Text('Get')),
                                  ),
                                ),
                                SizedBox(
                                  child: ElevatedButton(
                                      onPressed: _port == null
                                          ? null
                                          : () async {
                                              _progress = 0.0;
                                              _startTask(12);
                                              getpop_loader(context);
                                              Future.delayed(
                                                  Duration(seconds: 14), () {
                                                Navigator.pop(
                                                    context); //pop dialog
                                              });
                                              await setIRT();
                                            },
                                      child: Text('Set')),
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(9.0),
                                  child: Text(
                                    "Firmware Version :",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                                Expanded(
                                    child: TextField(
                                  enabled: false,
                                  controller: _firmwarecontroller,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 45, 51, 74),
                                      fontSize: 14),
                                )),
                                SizedBox(width: 5),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    child: ElevatedButton(
                                        onPressed: _port == null
                                            ? null
                                            : () async {
                                                _progress = 0.0;
                                                _startTask(12);
                                                getpop_loader(context);
                                                Future.delayed(
                                                    Duration(seconds: 14), () {
                                                  Navigator.pop(
                                                      context); //pop dialog
                                                });
                                                await getFirmwareV();
                                              },
                                        child: Text('Get')),
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
                                    'Alarm  En/Ds :',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                                Expanded(
                                    child: TextField(
                                  controller: _Alarm,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 45, 51, 74),
                                      fontSize: 14),
                                )),
                                SizedBox(width: 5),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    child: ElevatedButton(
                                        onPressed: _port == null
                                            ? null
                                            : () async {
                                                _progress = 0.0;
                                                _startTask(13);
                                                getpop_loader(context);
                                                Future.delayed(
                                                    Duration(seconds: 15), () {
                                                  Navigator.pop(
                                                      context); //pop dialog
                                                });
                                                await getalarm();
                                              },
                                        child: Text('Get')),
                                  ),
                                ),
                                SizedBox(
                                  child: ElevatedButton(
                                      onPressed: _port == null
                                          ? null
                                          : () async {
                                              _progress = 0.0;
                                              _startTask(12);
                                              getpop_loader(context);
                                              Future.delayed(
                                                  Duration(seconds: 14), () {
                                                Navigator.pop(
                                                    context); //pop dialog
                                              });
                                              await setalarm();
                                            },
                                      child: Text('Set')),
                                )
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                // width: MediaQuery.of(context).size.width / 2,
                                child: ElevatedButton(
                                  onPressed: () {
                                    _progress = 0.0;
                                    _startTask(12);
                                    getpop_loader(context);
                                    Future.delayed(Duration(seconds: 14), () {
                                      Navigator.pop(context); //pop dialog
                                    });
                                    SetAllData();
                                  },
                                  child: Text('Set All',
                                      style: TextStyle(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          5), // Set border radius to 0 for square shape
                                    ),
                                  ),
                                ),
                              ),
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
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 5.0),
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
                ],
              ),
            ),
          )
          /* Expanded(

            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  // height: 500,
                  decoration: BoxDecoration(
                      color: Color.fromARGB(255, 223, 235, 247),
                      borderRadius: BorderRadius.circular(5)),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () {},
                              child: Text('Get All',
                                  style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      5), // Set border radius to 0 for square shape
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(9.0),
                              child: Text(
                                'Datetime :',
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Expanded(
                                child: TextField(
                              controller: _datetimecontroller,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Color.fromARGB(255, 45, 51, 74),
                                  fontSize: 14),
                            )),
                            SizedBox(width: 5),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                height: 30,
                                width: 55,
                                child: ElevatedButton(
                                    onPressed: _port == null
                                        ? null
                                        : () async {
                                            getpop(context);
                                            new Future.delayed(
                                                new Duration(seconds: 6), () {
                                              Navigator.pop(
                                                  context); //pop dialog
                                            });
                                            await getDatetime();
                                          },
                                    child: Text('Get')),
                              ),
                            ),
                            SizedBox(
                              height: 30,
                              width: 55,
                              child: ElevatedButton(
                                  onPressed: _port == null
                                      ? null
                                      : () async {
                                          getpop(context);
                                          new Future.delayed(
                                              new Duration(seconds: 6), () {
                                            Navigator.pop(context); //pop dialog
                                          });
                                          await setDatetime();
                                        },
                                  child: Text('Set')),
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(9.0),
                              child: Text(
                                'Site Name :',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                            Expanded(
                                child: TextField(
                              controller: _sitenamecontroller,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Color.fromARGB(255, 45, 51, 74),
                                  fontSize: 14),
                            )),
                            SizedBox(width: 5),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                height: 30,
                                width: 55,
                                child: ElevatedButton(
                                    onPressed: _port == null
                                        ? null
                                        : () async {
                                            getpop(context);
                                            new Future.delayed(
                                                new Duration(seconds: 6), () {
                                              Navigator.pop(
                                                  context); //pop dialog
                                            });
                                            await getSiteName();
                                          },
                                    child: Text('Get')),
                              ),
                            ),
                            SizedBox(
                              height: 30,
                              width: 55,
                              child: ElevatedButton(
                                  onPressed: _port == null
                                      ? null
                                      : () async {
                                          getpop(context);
                                          new Future.delayed(
                                              new Duration(seconds: 6), () {
                                            Navigator.pop(context); //pop dialog
                                          });
                                          await setSiteName();
                                        },
                                  child: Text('Set')),
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(9.0),
                              child: Text(
                                'IO Interval :',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                            Expanded(
                                child: TextField(
                              controller: _irtcontroller,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Color.fromARGB(255, 45, 51, 74),
                                  fontSize: 14),
                            )),
                            SizedBox(width: 5),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                height: 30,
                                width: 55,
                                child: ElevatedButton(
                                    onPressed: _port == null
                                        ? null
                                        : () async {
                                            getpop(context);
                                            new Future.delayed(
                                                new Duration(seconds: 6), () {
                                              Navigator.pop(
                                                  context); //pop dialog
                                            });
                                            await getIRT();
                                          },
                                    child: Text('Get')),
                              ),
                            ),
                            SizedBox(
                              height: 30,
                              width: 55,
                              child: ElevatedButton(
                                  onPressed: _port == null
                                      ? null
                                      : () async {
                                          getpop(context);
                                          new Future.delayed(
                                              new Duration(seconds: 6), () {
                                            Navigator.pop(context); //pop dialog
                                          });
                                          await setIRT();
                                        },
                                  child: Text('Set')),
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(9.0),
                              child: Text(
                                "Firmware Version :",
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                            Expanded(
                                child: TextField(
                              enabled: false,
                              controller: _firmwarecontroller,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Color.fromARGB(255, 45, 51, 74),
                                  fontSize: 14),
                            )),
                            SizedBox(width: 5),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                height: 30,
                                width: 55,
                                child: ElevatedButton(
                                    onPressed: _port == null
                                        ? null
                                        : () async {
                                            getpop(context);
                                            new Future.delayed(
                                                new Duration(seconds: 6), () {
                                              Navigator.pop(
                                                  context); //pop dialog
                                            });
                                            await getFirmwareV();
                                          },
                                    child: Text('Get')),
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
                                'Alarm  Un/Ds :',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                            Expanded(
                                child: TextField(
                              controller: _modemtypecontroller,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Color.fromARGB(255, 45, 51, 74),
                                  fontSize: 14),
                            )),
                            SizedBox(width: 5),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                height: 30,
                                width: 55,
                                child: ElevatedButton(
                                    onPressed: _port == null
                                        ? null
                                        : () async {
                                            getpop(context);
                                            new Future.delayed(
                                                new Duration(seconds: 6), () {
                                              Navigator.pop(
                                                  context); //pop dialog
                                            });
                                            await getModemType();
                                          },
                                    child: Text('Get')),
                              ),
                            ),
                            SizedBox(
                              height: 30,
                              width: 55,
                              child: ElevatedButton(
                                  onPressed: _port == null ? null : () {},
                                  child: Text('Set')),
                            )
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            // width: MediaQuery.of(context).size.width / 2,
                            child: ElevatedButton(
                              onPressed: () {},
                              child: Text('Set All',
                                  style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      5), // Set border radius to 0 for square shape
                                ),
                              ),
                            ),
                          ),
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
       */
        ],
      ),
    );
  }

  getDatetime() async {
    try {
      String data = 'dts'.toUpperCase() + "\r\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 20)).whenComplete(
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
          if (_datetimecontroller.text.isEmpty) {
            getDatetime();
          }
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

  void getAllData() async {
    await getDatetime();
    await getSiteName();
    await getIRT();
    await getFirmwareV();
    await getalarm();
  }

  SetAllData() async {
    if (_datetimecontroller.text != date_before) await setDatetime();
    if (_sitenamecontroller.text != Site_name_before) await setSiteName();
    if (_irtcontroller.text != Io_interval_before) await setIRT();

    if (_Alarm.text != Alarm_before) await setalarm();
  }

  getalarm() async {
    // await get_alarm('almr 0', "AL", 7, 8, alarm_data, 12);
    try {
      String data = ('ALMR 0').toUpperCase() + "\r\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 20)).whenComplete(
        () {
          print(_response);
          String res = _response.join('');
          int i = res.indexOf('AL');
          alarm_data = res.substring(i + 7, i + 8);

          if (alarm_data == '1') {
            _Alarm.text = 'Enable';
            Alarm_before = 'Enable';
          } else {
            _Alarm.text = 'Disable';
            Alarm_before = 'Disable';
          }
          print(res.substring(i + 7, i + 8));
          if (_Alarm.text.isEmpty) {
            getalarm();
          }
        },
      );
      _response = [];
    } catch (_, ex) {
      print(ex);
      _serialdata.add('Please Try Again...');
    }
  }

  setalarm() async {
    // await get_alarm('almr 0', "AL", 7, 8, alarm_data, 12);
    try {
      if (_Alarm.toString().toLowerCase().contains('enable')) {
        String data = ('ALMR 0 1').toUpperCase() + "\r\n";
        await _port!.write(Uint8List.fromList(data.codeUnits));
      } else if (_Alarm.toString().toLowerCase().contains('disable')) {
        String data = ('ALMR 0 0').toUpperCase() + "\r\n";
        await _port!.write(Uint8List.fromList(data.codeUnits));
      }
    } catch (_, ex) {
      print(ex);
      _serialdata.add('Please Try Again...');
    }
  }

  getSiteName() async {
    try {
      String data = 'sinm'.toUpperCase() + "\r\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 20)).whenComplete(
        () {
          print(_response);
          String res = _response.join('');
          int i = res.indexOf("SI");
          _sitenamecontroller.text = res.substring(i + 5, i + 13);
          Site_name_before = res.substring(i + 5, i + 13);
          print(res.substring(i + 5, i + 13));
          if (_sitenamecontroller.text.isEmpty) {
            getSiteName();
          }
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

  getIRT() async {
    try {
      String data = 'irt'.toUpperCase() + "\r\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 20)).whenComplete(
        () {
          print(_response);
          String res = _response.join('');
          int i = res.indexOf("IR");
          _irtcontroller.text = res.substring(i + 4, i + 8);
          Io_interval_before = res.substring(i + 4, i + 8);
          print(res.substring(i + 5, i + 8));
          if (_irtcontroller.text.isEmpty) {
            getIRT();
          }
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
      await Future.delayed(Duration(seconds: 20)).whenComplete(
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
      await Future.delayed(Duration(seconds: 20)).whenComplete(
        () {
          print(_response);
          String res = _response.join('');
          int i = res.indexOf("FW");
          _firmwarecontroller.text = res.substring(i + 3, i + 7);
          print(res.substring(i + 3, i + 6));
          if (_firmwarecontroller.text.isEmpty) {
            getFirmwareV();
          }
        },
      );
      _response = [];
    } catch (_, ex) {
      print(ex);
      _serialdata.add('Please Try Again...');
    }
  }

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

  getProcessStatus(BuildContext context, List<ProcessModel> values) {
    try {
      return Container(
        padding: EdgeInsets.all(5),
        // decoration: BoxDecoration(
        //     color: Color.fromARGB(255, 168, 211, 237),
        //     borderRadius: BorderRadius.circular(5)),
        child: DropdownButton(
          underline: Container(color: Colors.transparent),
          value: _Alarm.text.isNotEmpty
              ? values.firstWhere(
                  (element) => element.processName == _Alarm.text,
                  orElse: () => values.first,
                )
              : values.first,
          isExpanded: true,
          items: values.map((ProcessModel processModel) {
            return DropdownMenuItem<ProcessModel>(
              value: processModel,
              child: Center(
                child: FittedBox(
                  child: Text(
                    processModel.processName!,
                    textScaleFactor: 1,
                    softWrap: true,
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            );
          }).toList(),
          onChanged: (textvalue) async {
            var data = textvalue as ProcessModel;

            setState(() {
              _Alarm.text = data.processName!;

              processStatus = data.id.toString();
            });
          },
        ),
      );
    } catch (_, ex) {
      print(ex);
      return Container();
    }
  }
}

class ProcessModel {
  int? id;
  String? processName;

  ProcessModel({
    this.id,
    this.processName,
  });
}
