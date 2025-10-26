// ignore_for_file: prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, prefer_const_constructors, unused_field, non_constant_identifier_names, unused_local_variable, unused_catch_stack, file_names, prefer_final_fields, use_build_context_synchronously, prefer_typing_uninitialized_variables, avoid_print, sort_child_properties_last, depend_on_referenced_packages, unused_import, import_of_legacy_library_into_null_safe, void_checks, unnecessary_new, library_prefixes, unnecessary_string_interpolations, await_only_futures, must_be_immutable

import 'dart:async';
import 'dart:convert';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_serial_communication/flutter_serial_communication.dart';
import 'package:flutter_serial_communication/models/device_info.dart';
import 'package:usb_console_application/core/constants/SaveFile.dart';
import 'package:usb_console_application/models/DeviceDataModel.dart';
import 'package:usb_console_application/models/NodeDetailsModel.dart';
import 'package:usb_console_application/models/loginmodel.dart';
import 'package:hex/hex.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pdfWidgets;
import '../../core/app_export.dart';

class RMSAutoCommScreen extends StatefulWidget {
  NodeDetailsModel? data;
  String? projectName;
  RMSAutoCommScreen(NodeDetailsModel nodedata, String project, {super.key}) {
    data = nodedata;
    projectName = project;
  }

  @override
  State<RMSAutoCommScreen> createState() => _RMSAutoCommScreenState();
}

class _RMSAutoCommScreenState extends State<RMSAutoCommScreen>
    with SingleTickerProviderStateMixin {
  final FlutterSerialCommunication _port = FlutterSerialCommunication();
  String _status = "Idle";
  bool isCurrectFirmware = true;
  String? isBatterOk;
  bool isSolarOk = true;
  bool isDoorOpen = true;
  bool isDoorClose = true;
  bool isMacAddressOk = true;
  int noOfPfcmds = 1;
  List<DeviceInfo> _devices = [];
  List<String> _response = [];
  String btntxt = 'Connect';
  String hexDecimalValue = '';
  String? hexIntgValue = '';
  String macId = '';
  int _maxRetries = 5;
  bool? isMatched = false;
  bool? isSaved = false;
  String? filePath = '';

  // List<String> outletPT_Status_0bar = [];
  // List<double> outletPT_Values_0bar = [];
  // List<bool> offsetStatus = [];
  /*
  List<String> outletPT_Status_1bar = [];
  List<double> outletPT_Values_1bar = [];

  List<String> outletPT_Status_1bar_new = [];
  List<double> outletPT_Values_1bar_new = [];

  List<String>? outletPT_Status_3bar = [];
  List<double>? outletPT_Values_3bar = [];

  List<String>? outletPT_Status_3bar_new = [];
  List<double>? outletPT_Values_3bar_new = [];*/

  List<String>? position_status = [];
  List<double>? position_values = [];

  List<String>? solenoid_status = [];

  double? ptValue;

  int? index;
  String? controllerType;
  int? pfcmcdType = 1;
  List<String> _serialData = [];

  final _formKey = GlobalKey<FormState>();
  List<int> _dataBuffer = [];
  StreamSubscription<Uint8List>? _dataSubscription;

  double? batteryVoltage;
  double? batteryVoltageAftet;
  double? firmwareversion;
  double? solarVoltage;
  DateTime? deviceTime;

  double? filterInlet = 0.0;
  double? filterOutlet = 0.0;
  String inletPT_0bar = '';
  String outletPT_0bar = '';

  double? filterInlet3bar = 0.0;
  double? filterOutlet3bar = 0.0;
  String inletPT_3bar = '';
  String outletPT_3bar = '';

  double? filterInlet3bar_new = 0.0;
  double? filterOutlet3bar_new = 0.0;
  String inletPT_3bar_new = '';
  String outletPT_3bar_new = '';

  double? filterInlet1bar = 0.0;
  double? filterOutlet1bar = 0.0;
  String inletPT_1bar = '';
  String outletPT_1bar = '';

  double? filterInlet1bar_new = 0.0;
  double? filterOutlet1bar_new = 0.0;
  String inletPT_1bar_new = '';
  String outletPT_1bar_new = '';

  bool filterInletOffset = false;
  bool filterOutletOffset = false;

  bool isLoraOK = false;
  bool isProcessComplete = false;
  bool isStart = false;

  Future<bool> _connectTo(DeviceInfo? device) async {
    _response.clear();
    if (_status == 'Connected') {
      await _port.disconnect();
      // _port = null;
    }
    if (device == null) {
      setState(() {
        _status = "Disconnected";
        btntxt = 'Disconnected';
      });
      _showProcessingToast(
        context,
        content: '${device!.productName} disconnected sucessfully',
      );
      return true;
    }
    bool connectionSuccess = await _port.connect(device, 115200);
    debugPrint("Connection success: $connectionSuccess");
    /*_port = await device.create();
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
*/
    _port.getSerialMessageListener().receiveBroadcastStream().listen(
      (event) {
        onDataReceived(event);
        debugPrint("Serial Listener Event: ${Uint8List.fromList(event)}");
      },
      onError: (error) {
        debugPrint("Serial Listener Error: $error");
      },
    );
    /*  !.inputStream!.listen((Uint8List data) {
      onDataReceived(data);
    });
*/
    setState(() {
      _status = "Connected";
      btntxt = 'Connected';
    });
    _showProcessingToast(
      context,
      content: '${device.productName} connected sucessfully',
    );

    return true;
  }

  /*Future<bool> _connectTo(UsbDevice? device) async {
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
      _showProcessingToast(context,
          content: '${device!.productName} disconnected sucessfully');
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
    _showProcessingToast(context,
        content: '${device.productName} connected sucessfully');

    return true;
  }

*/
  /*void loadCheckList() {
    // Assuming the JSON is loaded from an asset or string here
    final jsonString =
        CheckList().checkList; // Replace this with actual JSON loading code

    final jsonResponse = jsonDecode(jsonString);
    final List<dynamic> responseList = jsonResponse['data']['Response'];
    setState(() {
      items = responseList.map((json) => CheckListItem.fromJson(json)).toList();
      imageList =
          items.where((element) => element.inputType == 'image').toList();
    });
  }*/

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
        hexDecimalValue = reverseString(
          reverseString(_response.join()).substring(0, 70),
        );
      } else if (_serialData.join().contains('BOCOM6')) {
        hexIntgValue = reverseString(
          reverseString(_response.join()).substring(0, 172),
        );
      } else if (_serialData.join().contains('BOCRMS')) {
        hexIntgValue = reverseString(
          reverseString(_response.join()).substring(0, 68),
        );
      }
    } else {
      hexDecimalValue = _response.join();
    }
  }

  @override
  void initState() {
    super.initState();
    _port.getDeviceConnectionListener().receiveBroadcastStream().listen((
      event,
    ) {
      setState(() {
        _status = event;
      });
    });
    _getPorts();
    // loadCheckList();
    // noOfPfcmds = widget.data!.subChakQty!;
    initializeLists();
  }

  void initializeLists() {
    // outletPT_Status_0bar = List.filled(noOfPfcmds, '');
    // outletPT_Values_0bar = List.filled(noOfPfcmds, 0.0);
    // offsetStatus = List.filled(noOfPfcmds, false);
    /*
    outletPT_Status_1bar = List.filled(noOfPfcmds, '');
    outletPT_Values_1bar = List.filled(noOfPfcmds, 0.0);

    outletPT_Status_1bar_new = List.filled(noOfPfcmds, '');
    outletPT_Values_1bar_new = List.filled(noOfPfcmds, 0.0);

    outletPT_Status_3bar = List.filled(noOfPfcmds, '');
    outletPT_Values_3bar = List.filled(noOfPfcmds, 0.0);

    outletPT_Status_3bar_new = List.filled(noOfPfcmds, '');
    outletPT_Values_3bar_new = List.filled(noOfPfcmds, 0.0);*/

    position_status = List.filled(1, '');
    position_values = List.filled(1, 0.0);

    solenoid_status = List.filled(1, '');
  }

  @override
  void dispose() {
    super.dispose();
    _connectTo(null);
  }

  Future<void> _getPorts() async {
    final devices = await _port.getAvailableDevices();
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
      appBar: AppBar(title: Text('${widget.data?.rmsNo}')),
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
                  color: Colors.blueAccent.shade100,
                ),
                child: ListTile(
                  leading: Container(
                    decoration: BoxDecoration(
                      color: Colors.lightBlue.shade200,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Icon(Icons.usb),
                    ),
                  ),
                  title: Text(device.productName),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 2,
                      backgroundColor:
                          _status == 'Disconnected' ? Colors.red : Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
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
            if (_devices.isNotEmpty) infoCardWidget(),
            if (_devices.isEmpty)
              Center(child: Text('No USB Device Connected')),
            if (_devices.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 200,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 253, 249, 249),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black),
                      ),
                      child: SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: _serialData
                              .map(
                                (message) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 5.0,
                                  ),
                                  child: Text(
                                    message,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors
                                          .black, // Set the desired text color here
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
              ),
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
      return Expanded(
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: ElevatedButton(
                        child: SizedBox(
                          height: 50,
                          child: Center(
                            child: Text(
                              "Start Auto Commission",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          elevation: 2,
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        onPressed: (_devices.isEmpty)
                            ? null
                            : () async {
                                if (_devices.isEmpty) {
                                  return;
                                }
                                if (!isStart) {
                                  setState(() {
                                    isStart = true;
                                  });
                                  await getSiteName();
                                  await getMID();
                                  await getDeviceTime();
                                  await getFirmwareVersion();
                                  await getBatteryVoltage();
                                  await getSolarVoltage();
                                  await checkPTatZeroBar();
                                  await setOffSetForALLPT();
                                  await changeSolenoidMode();
                                  await openAllSolenoids1();
                                  await closeAllSolenoids();
                                  await _showBoosterPumpDialog(
                                    context,
                                    () async {
                                      await checkForLeakage(1.0);
                                    },
                                    1.0,
                                  );
                                }
                              },
                      ),
                    ),
                  ),

                  //Site name
                  Container(
                    margin: EdgeInsets.all(5.5),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 1.5,
                          spreadRadius: 2.2,
                          offset: Offset(1.5, 2),
                        ),
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
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.5,
                                child: Text(
                                  'Site Name :',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.3,
                                child: Text(
                                  ("${controllerType ?? '-'}").toString(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
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
                                width: MediaQuery.of(context).size.width * 0.3,
                                child: Text(
                                  'MAC ID :',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.5,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "$macId",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (macId.isNotEmpty)
                                      Image.asset(
                                        "${isMacAddressOk ? 'assets/images/fullydone.png' : 'assets/images/Commented.png'}",
                                        height: 20,
                                      ),
                                  ],
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
                                width: MediaQuery.of(context).size.width * 0.5,
                                child: Text(
                                  'Device-Time :',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.3,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    if (deviceTime != null)
                                      Text(
                                        DateFormat(
                                          'dd-MMM-yyyy\nHH:mm:ss',
                                        ).format(deviceTime!),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    /*if (!isMatched! && deviceTime != null)
                                      IconButton(
                                          onPressed: () async {
                                            await showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title:
                                                      Text('Set Device Time'),
                                                  content: Text(
                                                      'the datetime fetched from the device is not mathing with the current datetime so please set the device datetime.'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () async {
                                                        Navigator.of(context)
                                                            .pop();
                                                        await setCurrDatetime();
                                                        await getDeviceTime();
                                                      },
                                                      child: Text('OK'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        // Code to guide users to device settings could go here, if needed.
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Text('Cancel'),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          icon: Icon(Icons.settings))
                                  */
                                  ],
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
                        ),
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
                                width: MediaQuery.of(context).size.width * 0.5,
                                child: Text(
                                  'General Checks',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              // ElevatedButton(
                              //   child: Text("Check"),
                              //   onPressed: (_port == null)
                              //       ? null
                              //       : () async {
                              //           if (_port == null) {
                              //             return;
                              //           }
                              // String data =
                              //     "${'INTG'.toUpperCase()}\r\n";
                              // _response.clear();
                              // _serialData.clear();
                              // hexIntgValue = '';
                              // await _port.write(Uint8List.fromList(
                              //     data.codeUnits));
                              //           Future.delayed(Duration(seconds: 6))
                              //               .whenComplete(() async {
                              //             await getAllINTGPacket();
                              //             await getAllPTValues();
                              //             // await getAllPositionSensorValue();
                              //           });
                              //         },
                              // ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Divider(),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.3,
                                child: Text(
                                  'Description',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Text(
                                  'Exp. Value',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Text(
                                  'Act. Value',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Text(
                                  "Remark",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
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
                                width: MediaQuery.of(context).size.width * 0.3,
                                child: Text(
                                  'Firmware Version',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Text(
                                  '${double.tryParse(widget.data?.firmwareVersion?.toString() ?? '0.0')?.toStringAsFixed(1) ?? 'Unknown'}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Text(
                                  '${firmwareversion ?? '-'}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: firmwareversion != null
                                    ? Text(
                                        "${isCurrectFirmware ? 'Ok' : 'Faluty'}",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : Text(
                                        '-',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
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
                                width: MediaQuery.of(context).size.width * 0.3,
                                child: Text(
                                  'Battery Voltage',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Text(
                                  '3.3 V',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Text(
                                  '${batteryVoltage ?? '-'} V',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Text(
                                  "${isBatterOk ?? '-'}",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
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
                                width: MediaQuery.of(context).size.width * 0.3,
                                child: Text(
                                  'Solar Voltage',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Text(
                                  '5 - 7.1 V',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Text(
                                  '${solarVoltage ?? '-'} V',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: solarVoltage != null
                                    ? Text(
                                        "${isSolarOk ? 'OK' : 'Faulty'}",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : Text(
                                        '-',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  //PT Valve Check at 0 bar
                  Container(
                    margin: EdgeInsets.all(5.5),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 1.5,
                          spreadRadius: 2.2,
                          offset: Offset(1.5, 2),
                        ),
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
                                'PT Valve Check At 0 Bar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Divider(),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Text(
                                  'Description',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Text(
                                  'Exp. Value',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Text(
                                  'Act. Value',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Text(
                                  "Remark",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Text(
                                  "Offset",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        //Inlet valve Check
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Container(
                                margin: EdgeInsets.all(8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.15,
                                      child: Text(
                                        "Inlet PT",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.15,
                                      child: Text(
                                        '4000 mA',
                                        textAlign: TextAlign.center,
                                        // style: TextStyle(
                                        //   fontSize: 16,
                                        //   fontWeight: FontWeight.bold,
                                        // ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.15,
                                      child: Text(
                                        '${filterInlet ?? ''} mA',
                                        textAlign: TextAlign.center,
                                        // style: TextStyle(
                                        //   fontSize: 16,
                                        //   fontWeight: FontWeight.bold,
                                        // ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.15,
                                      child: Text(
                                        "$inletPT_0bar",
                                        textAlign: TextAlign.center,
                                        // style: TextStyle(
                                        //   fontSize: 16,
                                        //   fontWeight: FontWeight.bold,
                                        // ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.15,
                                      child: Text(
                                        "${filterInletOffset ? 'Done' : 'Not Done'}",
                                        textAlign: TextAlign.center,
                                        // style: TextStyle(
                                        //   fontSize: 16,
                                        //   fontWeight: FontWeight.bold,
                                        // ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(),
                              Container(
                                margin: EdgeInsets.all(8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.15,
                                      child: Text(
                                        "Outlet PT",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.15,
                                      child: Text(
                                        '4000 mA',
                                        textAlign: TextAlign.center,
                                        // style: TextStyle(
                                        //   fontSize: 16,
                                        //   fontWeight: FontWeight.bold,
                                        // ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.15,
                                      child: Text(
                                        '${filterOutlet ?? ''} mA',
                                        textAlign: TextAlign.center,
                                        // style: TextStyle(
                                        //   fontSize: 16,
                                        //   fontWeight: FontWeight.bold,
                                        // ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.15,
                                      child: Text(
                                        "$outletPT_0bar",
                                        textAlign: TextAlign.center,
                                        // style: TextStyle(
                                        //   fontSize: 16,
                                        //   fontWeight: FontWeight.bold,
                                        // ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.15,
                                      child: Text(
                                        "${filterOutletOffset ? 'Done' : 'Not Done'}",
                                        textAlign: TextAlign.center,
                                        // style: TextStyle(
                                        //   fontSize: 16,
                                        //   fontWeight: FontWeight.bold,
                                        // ),
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
                  //PT Valve Check at 1 bar
                  Container(
                    margin: EdgeInsets.all(5.5),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 1.5,
                          spreadRadius: 2.2,
                          offset: Offset(1.5, 2),
                        ),
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
                                'PT Valve Check At 1 Bar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Divider(),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.3,
                                child: Text(
                                  'Description',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Text(
                                  'Exp. Value',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Text(
                                  'Act. Value',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Text(
                                  "Remark",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        //Inlet valve Check
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Container(
                                margin: EdgeInsets.all(8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.3,
                                      child: Text(
                                        "Inlet PT",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.15,
                                      child: Text(
                                        '0.5 - 1.2 bar',
                                        textAlign: TextAlign.center,
                                        // style: TextStyle(
                                        //   fontSize: 16,
                                        //   fontWeight: FontWeight.bold,
                                        // ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.15,
                                      child: Text(
                                        '${filterInlet1bar ?? ''} bar',
                                        textAlign: TextAlign.center,
                                        // style: TextStyle(
                                        //   fontSize: 16,
                                        //   fontWeight: FontWeight.bold,
                                        // ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.15,
                                      child: Text(
                                        "$inletPT_1bar",
                                        textAlign: TextAlign.center,
                                        // style: TextStyle(
                                        //   fontSize: 16,
                                        //   fontWeight: FontWeight.bold,
                                        // ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(),
                              Container(
                                margin: EdgeInsets.all(8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.3,
                                      child: Text(
                                        "Outlet PT",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.15,
                                      child: Text(
                                        '0.5 - 1.2 bar',
                                        textAlign: TextAlign.center,
                                        // style: TextStyle(
                                        //   fontSize: 16,
                                        //   fontWeight: FontWeight.bold,
                                        // ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.15,
                                      child: Text(
                                        '${filterOutlet1bar ?? ''} bar',
                                        textAlign: TextAlign.center,
                                        // style: TextStyle(
                                        //   fontSize: 16,
                                        //   fontWeight: FontWeight.bold,
                                        // ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.15,
                                      child: Text(
                                        "$outletPT_1bar",
                                        textAlign: TextAlign.center,
                                        // style: TextStyle(
                                        //   fontSize: 16,
                                        //   fontWeight: FontWeight.bold,
                                        // ),
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
                  //PT Valve Check at 1 bar after Open solenoid
                  Container(
                    margin: EdgeInsets.all(5.5),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 1.5,
                          spreadRadius: 2.2,
                          offset: Offset(1.5, 2),
                        ),
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
                              Expanded(
                                child: Text(
                                  'PT Valve Check At 1 Bar After Opening The Solenoid',
                                  overflow: TextOverflow.fade,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Divider(),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.3,
                                child: Text(
                                  'Description',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Text(
                                  'Exp. Value',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Text(
                                  'Act. Value',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Text(
                                  "Remark",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        //Inlet valve Check
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Container(
                                margin: EdgeInsets.all(8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.3,
                                      child: Text(
                                        "Inlet PT",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.15,
                                      child: Text(
                                        '0.5 - 1.2 bar',
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.15,
                                      child: Text(
                                        '${filterInlet1bar_new ?? ''} bar',
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.15,
                                      child: Text(
                                        "$inletPT_1bar_new",
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(),
                              Container(
                                margin: EdgeInsets.all(8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.3,
                                      child: Text(
                                        "Outlet PT",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.15,
                                      child: Text(
                                        '0.5 - 1.2 bar',
                                        textAlign: TextAlign.center,
                                        // style: TextStyle(
                                        //   fontSize: 16,
                                        //   fontWeight: FontWeight.bold,
                                        // ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.15,
                                      child: Text(
                                        '${filterOutlet1bar_new ?? ''} bar',
                                        textAlign: TextAlign.center,
                                        // style: TextStyle(
                                        //   fontSize: 16,
                                        //   fontWeight: FontWeight.bold,
                                        // ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.15,
                                      child: Text(
                                        "$outletPT_1bar_new",
                                        textAlign: TextAlign.center,
                                        // style: TextStyle(
                                        //   fontSize: 16,
                                        //   fontWeight: FontWeight.bold,
                                        // ),
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
                  //PT Valve Check at 3 bar
                  Container(
                    margin: EdgeInsets.all(5.5),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 1.5,
                          spreadRadius: 2.2,
                          offset: Offset(1.5, 2),
                        ),
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
                                'PT Valve Check At 3 Bar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Divider(),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.3,
                                child: Text(
                                  'Description',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Text(
                                  'Exp. Value',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Text(
                                  'Act. Value',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Text(
                                  "Remark",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        //Inlet valve Check
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Container(
                                margin: EdgeInsets.all(8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.3,
                                      child: Text(
                                        "Inlet PT",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.15,
                                      child: Text(
                                        '2.5 - 3.5 bar',
                                        textAlign: TextAlign.center,
                                        // style: TextStyle(
                                        //   fontSize: 16,
                                        //   fontWeight: FontWeight.bold,
                                        // ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.15,
                                      child: Text(
                                        '${filterInlet3bar ?? ''} bar',
                                        textAlign: TextAlign.center,
                                        // style: TextStyle(
                                        //   fontSize: 16,
                                        //   fontWeight: FontWeight.bold,
                                        // ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.15,
                                      child: Text(
                                        "$inletPT_3bar",
                                        textAlign: TextAlign.center,
                                        // style: TextStyle(
                                        //   fontSize: 16,
                                        //   fontWeight: FontWeight.bold,
                                        // ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(),
                              Container(
                                margin: EdgeInsets.all(8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.3,
                                      child: Text(
                                        "Outlet PT",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.15,
                                      child: Text(
                                        '2.5 - 3.5 bar',
                                        textAlign: TextAlign.center,
                                        // style: TextStyle(
                                        //   fontSize: 16,
                                        //   fontWeight: FontWeight.bold,
                                        // ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.15,
                                      child: Text(
                                        '${filterOutlet3bar ?? ''} bar',
                                        textAlign: TextAlign.center,
                                        // style: TextStyle(
                                        //   fontSize: 16,
                                        //   fontWeight: FontWeight.bold,
                                        // ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.15,
                                      child: Text(
                                        "$outletPT_3bar",
                                        textAlign: TextAlign.center,
                                        // style: TextStyle(
                                        //   fontSize: 16,
                                        //   fontWeight: FontWeight.bold,
                                        // ),
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
                  //PT Valve Check at 3 bar after Open solenoid
                  Container(
                    margin: EdgeInsets.all(5.5),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 1.5,
                          spreadRadius: 2.2,
                          offset: Offset(1.5, 2),
                        ),
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
                              Expanded(
                                child: Text(
                                  'PT Valve Check At 3 Bar After Opening The Solenoid',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Divider(),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.3,
                                child: Text(
                                  'Description',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Text(
                                  'Exp. Value',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Text(
                                  'Act. Value',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Text(
                                  "Remark",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        //Inlet valve Check
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Container(
                                margin: EdgeInsets.all(8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.3,
                                      child: Text(
                                        "Inlet PT",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.15,
                                      child: Text(
                                        '2.5 - 3.5 bar',
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.15,
                                      child: Text(
                                        '${filterInlet3bar_new ?? ''} bar',
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.15,
                                      child: Text(
                                        "$inletPT_3bar_new",
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(),
                              Container(
                                margin: EdgeInsets.all(8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.3,
                                      child: Text(
                                        "Outlet PT",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.15,
                                      child: Text(
                                        '2.5 - 3.5 bar',
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.15,
                                      child: Text(
                                        '${filterOutlet3bar_new ?? ''} bar',
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.15,
                                      child: Text(
                                        "$outletPT_3bar_new",
                                        textAlign: TextAlign.center,
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
                  //Solenoid block
                  Container(
                    margin: EdgeInsets.all(5.5),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 1.5,
                          spreadRadius: 2.2,
                          offset: Offset(1.5, 2),
                        ),
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
                                'Solenoid Test',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Divider(),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.3,
                                child: Text(
                                  'Description',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Text(
                                  "Remark",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        //Solenoid test
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: 1,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return Container(
                                margin: EdgeInsets.all(8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.3,
                                      child: Text(
                                        'Solenoid ${index + 1}',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.15,
                                      child: Text(
                                        "${solenoid_status?[index]}",
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  //Position Senson
                  Container(
                    margin: EdgeInsets.all(5.5),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 1.5,
                          spreadRadius: 2.2,
                          offset: Offset(1.5, 2),
                        ),
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
                                'Position Sensor ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Divider(),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.3,
                                child: Text(
                                  'Description',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.18,
                                child: Text(
                                  'Exp. Value',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Text(
                                  'Act. Value',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Text(
                                  "Remark",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListView.builder(
                            itemCount: 1,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return Container(
                                margin: EdgeInsets.all(8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.3,
                                      child: Text(
                                        'Position Sensor ${index + 1}',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.18,
                                      child: Text(
                                        '3000 - 20000 mA',
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.15,
                                      child: Text(
                                        '${position_values?[index] ?? ''} mA',
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.15,
                                      child: Text(
                                        "${position_status?[index]}",
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  //Door Status Check
                  Container(
                    margin: EdgeInsets.all(5.5),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 1.5,
                          spreadRadius: 2.2,
                          offset: Offset(1.5, 2),
                        ),
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
                                width: MediaQuery.of(context).size.width * 0.5,
                                child: Text(
                                  'Door Status Checks',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Divider(),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.20,
                                child: Text(
                                  'Open Door',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Text(
                                  'OPEN',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Text(
                                  '${isDoorOpen ? 'OPEN' : 'CLOSE'}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Text(
                                  "${isDoorOpen ? 'Ok' : 'Faulty'}",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
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
                                width: MediaQuery.of(context).size.width * 0.20,
                                child: Text(
                                  'Close Door',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Text(
                                  'CLOSE',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Text(
                                  '${isDoorClose ? 'CLOSE' : 'OPEN'}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Text(
                                  "${isDoorClose ? 'OK' : 'Faulty'}",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  //Battery After Test
                  Container(
                    margin: EdgeInsets.all(5.5),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 1.5,
                          spreadRadius: 2.2,
                          offset: Offset(1.5, 2),
                        ),
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
                                width: MediaQuery.of(context).size.width * 0.5,
                                child: Text(
                                  'Battery Drainage check',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Divider(),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.40,
                                child: Text(
                                  'Battery before start of tests : ',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Text(
                                  "${batteryVoltage ?? '-'}  V",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.40,
                                child: Text(
                                  'Battery After finish all tests : ',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Text(
                                  "${batteryVoltageAftet ?? '-'} V",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  //Lora Check
                  Container(
                    margin: EdgeInsets.all(5.5),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 1.5,
                          spreadRadius: 2.2,
                          offset: Offset(1.5, 2),
                        ),
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
                                'LoRa Check ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Divider(),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.3,
                                child: Text(
                                  'Description',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.18,
                                child: Text(
                                  '',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Text(
                                  '',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Text(
                                  "Remark",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.3,
                                child: Text(
                                  'LoRa Communication Check',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.18,
                                child: Text('', textAlign: TextAlign.center),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Text('', textAlign: TextAlign.center),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Text(
                                  "${isLoraOK ? 'Ok' : 'Not Ok'}",
                                  style: TextStyle(
                                    color: isLoraOK ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
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
                        if (isSaved!)
                          Container(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Your PDF was saved successfully ${filePath?.replaceAll('/', '>')}.',
                              ) /*now please set all the solenoid to Flow Control mode.*/,
                            ),
                          ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 25),
                              child: ElevatedButton(
                                child: Text(
                                  'Submit',
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      5,
                                    ), // Set border radius to 0 for square shape
                                  ),
                                ),
                                onPressed: isProcessComplete
                                    ? () {
                                        getusername();
                                        getcurrentdate();
                                        showSaveDialog(context);
                                        saveJSON();
                                      }
                                    : null,
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
      );
    } catch (ex, _) {
      return Container(
        child: Center(child: Text('Click On Get SINM to Find Device Type')),
      );
    }
  }

  Future<void> getSiteName() async {
    int attempt = 0;
    bool isSuccessful = false;

    while (attempt < _maxRetries && !isSuccessful) {
      try {
        _showProcessingToast(
          context,
          content: 'Getting Site Name (Attempt ${attempt + 1}/$_maxRetries)',
        );

        _serialData.clear();
        String data = "${'SINM'.toUpperCase()}\r\n";
        await _port.write(Uint8List.fromList(data.codeUnits));

        await Future.delayed(Duration(seconds: 5)).whenComplete(() async {
          String res = _serialData.join('');
          int i = res.indexOf("SI");

          if (i != -1) {
            controllerType = res.substring(i + 5, i + 13);

            if (controllerType!.toLowerCase().contains('boc')) {
              setState(() {
                controllerType = res.substring(i + 5, i + 13);
              });

              print('Controller Type: ${controllerType ?? ""}');
              // Call getMID if the controller type is valid
              isSuccessful = true; // Mark as successful
            } else {
              print("Invalid Site Name. Retrying...");
            }
          } else {
            print("Failed to get Site Name. Retrying...");
          }
        });

        _response = [];
      } catch (ex) {
        print("Error: $ex");
        attempt++;

        if (attempt >= _maxRetries) {
          _serialData.add('Please Try Again...');
          throw Exception("Failed to get Site Name after $attempt attempts.");
        }
      }
    }
  }

  void _showProcessingToast(BuildContext context, {String? content}) {
    CherryToast.info(
      title: Text(
        content ?? 'Processing data...',
        style: TextStyle(letterSpacing: 2),
      ),
      // displayTitle: true,
      // icon: Icons.hourglass_bottom,
      animationType: AnimationType.fromBottom,
      borderRadius: 20,
      toastDuration: Duration(seconds: 2),
    ).show(context);
  }

  // get Device Time
  Future<void> getDeviceTime() async {
    int attempt = 0;
    bool isSuccessful = false;
    while (attempt < _maxRetries && !isSuccessful) {
      try {
        _showProcessingToast(
          context,
          content: 'Getting device time (Attempt ${attempt + 1}/$_maxRetries)',
        );

        _response.clear();
        _serialData.clear();

        String data = "${'dts'.toUpperCase()}\r\n";
        await _port.write(Uint8List.fromList(data.codeUnits));

        await Future.delayed(Duration(seconds: 5)).whenComplete(() {
          print("Serial Data: $_serialData");
          String res = _serialData.join('');

          if (res.contains("DTS")) {
            print("Response received: $res");

            // Adjust indices based on the actual response format
            String dateTime =
                res.substring(res.indexOf("DTS") + 4, res.indexOf(">")).trim();

            print("Parsed dateTime: $dateTime");

            List<int> dateParts =
                dateTime.split(' ').map((part) => int.parse(part)).toList();

            int year = dateParts[0];
            int month = dateParts[1];
            int day = dateParts[2];
            int hour = dateParts[3];
            int minute = dateParts[4];
            int second = dateParts[5];

            DateTime deviceDateTime = DateTime(
              year,
              month,
              day,
              hour,
              minute,
              second,
            );
            DateTime currentDateTime = DateTime.now();

            Duration difference =
                currentDateTime.difference(deviceDateTime).abs();

            setState(() {
              if (difference.inMinutes <= 10) {
                isMatched = true;
              } else {
                isMatched = false;
                setCurrDatetime(); // You can add setCurrDatetime() logic here
              }
              deviceTime = deviceDateTime;
            });

            isSuccessful = true;
          } else {
            throw Exception("Invalid response format.");
          }
        });
      } catch (ex) {
        print("Error: $ex");
        attempt++;
        if (attempt >= _maxRetries) {
          setState(() {
            isMatched = false;
          });
          throw Exception("Failed to get device time after $attempt attempts.");
        }
      }
    }
  }

  // set Device Time
  Future<void> setCurrDatetime() async {
    int attempt = 0;
    bool isSuccessful = false;

    while (attempt < _maxRetries && !isSuccessful) {
      try {
        _showProcessingToast(
          context,
          content:
              'Setting current date/time (Attempt ${attempt + 1}/$_maxRetries)',
        );

        _serialData.clear();
        String dateTime = DateFormat(
          'yyyy MM dd HH mm ss',
        ).format(DateTime.now());

        List<int> dateParts =
            dateTime.split(' ').map((part) => int.parse(part)).toList();

        int year = dateParts[0];
        int month = dateParts[1];
        int day = dateParts[2];
        int hour = dateParts[3];
        int minute = dateParts[4];
        int second = dateParts[5];

        String data =
            "${('dts $year $month $day $hour $minute $second').toUpperCase()}\r\n";
        await _port.write(Uint8List.fromList(data.codeUnits));
        await Future.delayed(Duration(seconds: 5)).whenComplete(() async {
          String res = _serialData.join('');
          int i = res.indexOf("DT");

          if (res.contains('DTS')) {
            // Extract date and time substring
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

            // Create a DateTime object from the extracted date and time
            DateTime deviceDateTime = DateTime(
              year,
              month,
              day,
              hour,
              minute,
              second,
            );
            DateTime currentDateTime = DateTime.now();

            // Calculate the difference
            Duration difference =
                currentDateTime.difference(deviceDateTime).abs();

            // Check if the difference is within 10 minutes
            setState(() {
              if (difference.inMinutes <= 10) {
                isMatched = true;
              } else {
                isMatched = false;
                // setCurrDatetime();
              }
              deviceTime = deviceDateTime;
            });

            isSuccessful = true; // Mark as successful
          } else {
            print("Invalid response format.");
            throw Exception("Failed to parse device time");
          }
          /* if (i != -1) {
            dtbefore = res.substring(i + 4, i + 18);
            isSuccessful = true; // Mark as successful
            _response = [];
          } else {
            print("Failed to set date/time. Retrying...");
          }*/
        });
      } catch (ex) {
        print("Error: $ex");
        attempt++;

        if (attempt >= _maxRetries) {
          _serialData.add('Please Try Again...');
          throw Exception(
            "Failed to set current date/time after $attempt attempts.",
          );
        }
      }
    }
  }

  // get Device Firmware version
  Future<void> getFirmwareVersion() async {
    int attempt = 0;
    bool isSuccessful = false;

    while (attempt < _maxRetries && !isSuccessful) {
      try {
        _showProcessingToast(
          context,
          content:
              'Fetching firmware version (Attempt ${attempt + 1}/$_maxRetries)',
        );
        _serialData.clear();
        String data = "${'fwv'.toUpperCase()}\r\n";
        await _port.write(Uint8List.fromList(data.codeUnits));
        await Future.delayed(Duration(seconds: 5));

        String res = _serialData.join('');
        print(res);

        if (res.contains("CONSOLE COMMAND RECIEVED END")) {
          // Continue if this is an invalid response
          throw Exception("Invalid response: Command received end");
        }

        int i = res.indexOf("FW");
        if (i != -1 && i + 7 <= res.length) {
          String substring = res.substring(i + 4, i + 7);

          setState(() {
            isCurrectFirmware = (substring.toLowerCase() ==
                double.tryParse(
                  widget.data?.firmwareVersion?.toString() ?? '0.0',
                )?.toStringAsFixed(1).toLowerCase());
            firmwareversion = double.tryParse(substring);
          });

          isSuccessful =
              true; // Mark as successful if a proper response is received
          _response = [];
        } else {
          throw Exception("Invalid response format");
        }
      } catch (ex) {
        attempt++;
        if (attempt >= _maxRetries) {
          // _showErrorToast(context,
          //     content:
          //         'Failed to fetch firmware version after $attempt attempts.');
          setState(() {
            isCurrectFirmware = false;
            firmwareversion = double.tryParse('0.0');
          });
        }
      }
    }
  }

  // get Device Battery voltage during test
  Future<void> getBatteryVoltage() async {
    int attempt = 0;
    bool isSuccessful = false;

    while (attempt < _maxRetries && !isSuccessful) {
      try {
        _showProcessingToast(
          context,
          content:
              'Fetching battery voltage (Attempt ${attempt + 1}/$_maxRetries)',
        );
        _serialData.clear();
        String data = "${'bvtg'.toUpperCase()}\r\n";
        await _port.write(Uint8List.fromList(data.codeUnits));
        await Future.delayed(Duration(seconds: 5));

        String res = _serialData.join('');
        print(res);

        if (res.contains("Command received end")) {
          // Continue if this is an invalid response
          throw Exception("Invalid response: Command received end");
        }

        int i = res.indexOf("BV");
        if (i != -1 && i + 13 <= res.length) {
          String substring = res.substring(i + 5, i + 13);
          var bv = double.tryParse(substring)! / 1000;

          setState(() {
            if (bv >= 3.3) {
              isBatterOk = 'Ok';
            } else if (bv >= 2.0) {
              isBatterOk = 'Low Battery';
            } else {
              isBatterOk = 'Faulty';
            }
            batteryVoltage = bv;
          });

          isSuccessful =
              true; // Mark as successful if a proper response is received
          _response = [];
        } else {
          throw Exception("Invalid response format");
        }
      } catch (ex) {
        attempt++;
        if (attempt >= _maxRetries) {
          // _showErrorToast(context, content: 'Failed to fetch battery voltage after $attempt attempts.');
          setState(() {
            isBatterOk = 'Faulty';
            batteryVoltage = 0;
          });
        }
      }
    }
  }

  // Get Device Solar Voltage
  Future<void> getSolarVoltage() async {
    int attempt = 0;
    bool isSuccessful = false;

    while (attempt < _maxRetries && !isSuccessful) {
      try {
        _showProcessingToast(
          context,
          content:
              'Fetching solar voltage (Attempt ${attempt + 1}/$_maxRetries)',
        );
        _serialData.clear();
        String data = "${'svtg'.toUpperCase()}\r\n";
        await _port.write(Uint8List.fromList(data.codeUnits));
        await Future.delayed(Duration(seconds: 5));

        String res = _serialData.join('');
        print(res);

        if (res.contains("Command received end")) {
          throw Exception("Invalid response: Command received end");
        }

        int i = res.indexOf("SV");
        if (i != -1 && i + 13 <= res.length) {
          String substring = res.substring(i + 5, i + 13);
          var sv = double.tryParse(substring)! / 1000;

          // Check if sv is 0, if so, set isSolarOk to false and stop reattempting
          if (sv >= 0 && sv <= 0.5) {
            setState(() {
              isSolarOk = false;
              solarVoltage = sv;
              isSuccessful = true; // Stop reattempting if sv is 0
            });
            break;
          }

          // Check if sv is within the range of 5 to 7.1
          if (sv >= 5 && sv <= 7.1) {
            setState(() {
              isSolarOk = true;
              solarVoltage = sv;
            });
          } else {
            setState(() {
              isSolarOk = false;
              solarVoltage = sv;
            });
          }

          isSuccessful = true; // Mark as successful if valid sv is found
          _response = [];
        } else {
          throw Exception("Invalid response format");
        }
      } catch (ex) {
        attempt++;
        if (attempt >= _maxRetries) {
          // If max attempts reached and no valid response, set defaults
          setState(() {
            isSolarOk = false;
            solarVoltage = 0;
          });
        }
      }
    }
  }

  // set Device Time
  Future<void> setResteDatetime() async {
    int attempt = 0;
    bool isSuccessful = false;

    while (attempt < _maxRetries && !isSuccessful) {
      try {
        _showProcessingToast(
          context,
          content: 'Re-setting date/time (Attempt ${attempt + 1}/$_maxRetries)',
        );

        _serialData.clear();

        String data = "${('dts 0000 00 00 00 00 00').toUpperCase()}\r\n";
        await _port.write(Uint8List.fromList(data.codeUnits));
        await Future.delayed(Duration(seconds: 6)).whenComplete(() async {
          String res = _serialData.join('');
          int i = res.indexOf("DT");

          if (res.contains('DTS')) {
            isSuccessful = true; // Mark as successful
          } else {
            print("Invalid response format.");
            throw Exception("Failed to parse device time");
          }
        });
      } catch (ex) {
        print("Error: $ex");
        attempt++;

        if (attempt >= _maxRetries) {
          _serialData.add('Please Try Again...');
          throw Exception(
            "Failed to set current date/time after $attempt attempts.",
          );
        }
      }

      if (isSuccessful) {
        await Future.delayed(Duration(seconds: 3)).whenComplete(() async {
          await checkLora();
        });
      }
    }
  }

  Future<void> checkLora() async {
    int attempt = 0;
    bool isSuccessful = false;
    int maxAttempts = 2;

    while (attempt < maxAttempts && !isSuccessful) {
      try {
        _showProcessingToast(
          context,
          content: 'Rebooting the device (Attempt ${attempt + 1}/$maxAttempts)',
        );
        _serialData.clear();
        String data = "${'rbt'.toUpperCase()}\r\n";
        await _port.write(Uint8List.fromList(data.codeUnits));
        await Future.delayed(Duration(seconds: 20));

        String res = _serialData.join('');
        print(res);

        // Check if response contains "DOWNLINK_RECIEVED"
        if (res.contains("DOWNLINK_RECIEVED")) {
          setState(() {
            isLoraOK = true;
          });
          isSuccessful =
              true; // Mark as successful if "DOWNLINK_RECIEVED" is found
          _response = [];
        } else {
          setState(() {
            isLoraOK =
                false; // Set as false if "DOWNLINK_RECIEVED" is not found
          });
          // setCurrDatetime();
          throw Exception(
            "Invalid response format or DOWNLINK_RECIEVED not found",
          );
        }
      } catch (ex) {
        attempt++;
        if (attempt >= maxAttempts) {
          // If max attempts reached and no valid response, set isLoraOK to false
          setState(() {
            isLoraOK = false;
          });
          // setCurrDatetime();
        }
      }

      // if (!isLoraOK) {
      //   setCurrDatetime();
      // }
    }
    if (!isLoraOK) {
      setCurrDatetime();
    }
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/tap.png', height: 90, width: 90),
                  Text(
                    'Change the Mode of PFCMD',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Please click on confirm button to proceed with the mode change.",
                    style: TextStyle(fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 60),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 2,
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      for (int i = 0; i < noOfPfcmds; i += 1) {
                        int pin = i + 1;
                        int ptpin = i + 3;
                        await Future.delayed(
                          Duration(seconds: 2),
                        ).whenComplete(() => setSovFlowControl(pin));
                        await Future.delayed(
                          Duration(seconds: 2),
                        ).whenComplete(() => setSovAutoMode(pin));
                      }
                      await removeEMS();
                      await processCompletePopup();
                    },
                    child: Text('Confirm'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // get Door Open status
  Future<void> openDoor() async {
    int attempt = 0;
    bool isSuccessful = false;

    while (attempt < _maxRetries && !isSuccessful) {
      try {
        _showProcessingToast(
          context,
          content:
              'Checking door open status (Attempt ${attempt + 1}/$_maxRetries)',
        );
        _serialData.clear();
        String data = "${'di'.toUpperCase()}\r\n";
        await _port.write(Uint8List.fromList(data.codeUnits));
        await Future.delayed(Duration(seconds: 5));

        String res = _serialData.join('');
        print(res);

        if (res.contains("Command received end")) {
          throw Exception("Invalid response: Command received end");
        }

        // Find the index of "DI" in the response
        int i = res.indexOf("DI");
        if (i != -1 && i + 10 <= res.length) {
          String substring = res.substring(i + 3, i + 10);
          print("Extracted substring: $substring");

          // Split the substring to get individual digits
          List<String> digits = substring.split(' ');

          // Check if the second digit exists and is '1'
          if (digits.length > 1 && digits[1] == '1') {
            setState(() {
              isDoorOpen = true;
            });
          } else {
            setState(() {
              isDoorOpen = false;
            });
          }

          isSuccessful = true; // Mark as successful if door status is found
        } else {
          throw Exception("Invalid response format");
        }
      } catch (ex) {
        attempt++;
        if (attempt >= _maxRetries) {
          setState(() {
            isDoorOpen = false; // Set default if max retries reached
          });
        }
      }
    }

    if (isSuccessful) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: EdgeInsets.all(20),
              width: MediaQuery.of(context).size.width * 0.3,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 20),
                  Text(
                    'Please Close the door and press Test Button to proceed with the test',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await closeDoor();
                          await getBatteryVoltageAfterTest();
                          await setResteDatetime();
                        },
                        child: Text('Test'),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    _response = [];
  }

  // get Door Close status
  Future<void> closeDoor() async {
    int attempt = 0;
    bool isSuccessful = false;

    while (attempt < _maxRetries && !isSuccessful) {
      try {
        _showProcessingToast(
          context,
          content:
              'Checking door close status (Attempt ${attempt + 1}/$_maxRetries)',
        );
        _serialData.clear();
        String data = "${'di'.toUpperCase()}\r\n";
        await _port.write(Uint8List.fromList(data.codeUnits));
        await Future.delayed(Duration(seconds: 5));

        String res = _serialData.join('');
        print(res);

        if (res.contains("Command received end")) {
          throw Exception("Invalid response: Command received end");
        }

        // Find the index of "DI" in the response
        int i = res.indexOf("DI");
        if (i != -1 && i + 10 <= res.length) {
          String substring = res.substring(i + 3, i + 10);
          print("Extracted substring: $substring");

          // Split the substring to get individual digits
          List<String> digits = substring.split(' ');

          // Check if the second digit exists and is '0'
          if (digits.length > 1 && digits[1] == '0') {
            setState(() {
              isDoorClose = true;
            });
            isSuccessful =
                true; // Mark as successful if door close status is found
          } else {
            setState(() {
              isDoorClose = false;
            });
          }
        } else {
          throw Exception("Invalid response format");
        }
      } catch (ex) {
        attempt++;
        if (attempt >= _maxRetries) {
          setState(() {
            isDoorClose = false; // Set default if max retries reached
          });
        }
      }
    }
  }

  // Common function to handle the AI command and processing logic
  Future<void> checkOutletPT0bar(
    int aiNumber,
    Function setPFCMD,
    Function setController,
    String content,
  ) async {
    int attempt = 0;
    bool isSuccessful = false;

    while (attempt < _maxRetries && !isSuccessful) {
      try {
        _showProcessingToast(
          context,
          content: '$content  (Attempt ${attempt + 1}/$_maxRetries)',
        );

        _serialData.clear();
        String data = "AI $aiNumber\r\n".toUpperCase();
        await _port.write(Uint8List.fromList(data.codeUnits));
        await Future.delayed(Duration(seconds: 5));

        String res = _serialData.join('');
        print(res);

        // Find the index of "AI" and ">"
        int i = res.indexOf("AI");
        int j = res.indexOf(">");

        if (i != -1 && j != -1 && j > i) {
          // Extract the substring between "AI" and ">"
          String substring = res.substring(i + 4, j).trim();
          print("Extracted substring: $substring");

          // Split the substring into individual components
          List<String> digits =
              substring.split(' ').where((s) => s.isNotEmpty).toList();

          if (digits.length > 1) {
            int? value = int.tryParse(digits[1]);

            if (value != null) {
              if (value >= 3500 && value <= 4500) {
                setState(() {
                  setPFCMD('OK');
                  setController(value.toDouble());
                });
              } else {
                setState(() {
                  setPFCMD('Faulty');
                  setController(value.toDouble());
                });
              }
              isSuccessful = true; // Mark as successful
            } else {
              print("Failed to parse digits[1] as an integer.");
              setState(() {
                setPFCMD('Faulty');
              });
            }
          } else {
            print("No second digit found in the response.");
            setState(() {
              setPFCMD('Faulty');
            });
          }
        } else {
          print("Invalid response format.");
          setState(() {
            setPFCMD('Faulty');
          });
        }

        _response = [];
      } catch (ex) {
        print("Exception: $ex");
        attempt++;
        if (attempt >= _maxRetries) {
          setState(() {
            setPFCMD('Faulty');
          });
        }
      }
    }
  }

  /* Check Pressuer for PT at 0 bar*/
  checkFilterInletPT() async {
    await checkOutletPT0bar(
      1,
      (status) => inletPT_0bar = status,
      (value) => filterInlet = value,
      'Checking filter intlet PT',
    );
  }

  checkFilterOutletPT() async {
    await checkOutletPT0bar(
      2,
      (status) => outletPT_0bar = status,
      (value) => filterOutlet = value,
      'Checking filter outlet PT',
    );
  }

  /* Set Offset for PT */
  setOffSetFilterInlet() async {
    int attempt = 0;
    bool isSuccessful = false;

    while (attempt < _maxRetries && !isSuccessful) {
      try {
        _showProcessingToast(
          context,
          content:
              'Setting Offset value for Filter Inlet PT (Attempt ${attempt + 1}/$_maxRetries)',
        );
        _serialData.clear();
        String data = "${'ofc 1'.toUpperCase()}\r\n";
        await _port.write(Uint8List.fromList(data.codeUnits));
        await Future.delayed(Duration(seconds: 5));

        String res = _serialData.join('');
        print(res);

        if (res.contains("Command received end")) {
          throw Exception("Invalid response: Command received end");
        }

        if (res.contains("$controllerType OFC")) {
          setState(() {
            filterInletOffset = true;
          });
          _showProcessingToast(
            context,
            content: "OffSet Set for Filter Inlet PT",
          );

          isSuccessful = true;
          _response = [];
        } else {
          setState(() {
            filterInletOffset = false;
          });
          throw Exception("Invalid response format");
        }
      } catch (ex) {
        attempt++;
        if (attempt >= _maxRetries) {}
      }
    }
  }

  setOffSetFlilterOutlet() async {
    int attempt = 0;
    bool isSuccessful = false;

    while (attempt < _maxRetries && !isSuccessful) {
      try {
        _showProcessingToast(
          context,
          content:
              'Setting Offset value for Filter Inlet PT (Attempt ${attempt + 1}/$_maxRetries)',
        );
        _serialData.clear();
        String data = "${'ofc 2'.toUpperCase()}\r\n";
        await _port.write(Uint8List.fromList(data.codeUnits));
        await Future.delayed(Duration(seconds: 5));

        String res = _serialData.join('');
        print(res);

        if (res.contains("Command received end")) {
          throw Exception("Invalid response: Command received end");
        }

        if (res.contains("$controllerType OFC")) {
          setState(() {
            filterOutletOffset = true;
          });
          _showProcessingToast(
            context,
            content: "OffSet Set for Filter Inlet PT",
          );

          isSuccessful = true;
          _response = [];
        } else {
          setState(() {
            filterOutletOffset = false;
          });
          throw Exception("Invalid response format");
        }
      } catch (ex) {
        attempt++;
        if (attempt >= _maxRetries) {}
      }
    }
  }

  /*setOffSetPT(int pt) async {
    int attempt = 0;
    bool isSuccessful = false;
    int pin = pt + 2;

    while (attempt < _maxRetries && !isSuccessful) {
      try {
        _showProcessingToast(context,
            content:
                'Setting Offset value for PT-$pin (Attempt ${attempt + 1}/$_maxRetries)');
        _serialData.clear();
        String data = "${'ofc $pin'.toUpperCase()}\r\n";
        //  print('Data being sent: $data');
        await _port.write(Uint8List.fromList(data.codeUnits));
        await Future.delayed(Duration(seconds: 8));

        String res = _serialData.join('');
        print(res);

        if (res.contains("Command received end")) {
          throw Exception("Invalid response: Command received end");
        }

        if (res.contains("$controllerType OFC")) {
          _showProcessingToast(context, content: "OffSet Set for PT-$pin");
          setState(() {
            offsetStatus[pt - 1] = true;
          });

          isSuccessful = true;
          _response = [];
        } else {
          setState(() {
            offsetStatus[pt - 1] = false;
          });
          throw Exception("Invalid response format");
        }
      } catch (ex) {
        attempt++;
        if (attempt >= _maxRetries) {}
      }
    }
  }
*/
  // Set Offset for all PT one-by-one
  setOffSetForALLPT() async {
    if (inletPT_0bar == 'OK') {
      await Future.delayed(Duration(seconds: 5)).whenComplete(() async {
        await setOffSetFilterInlet();
      });
    }

    if (outletPT_0bar == 'OK') {
      await Future.delayed(Duration(seconds: 5)).whenComplete(() async {
        await setOffSetFlilterOutlet();
      });
    }

    // for (int i = 0; i < noOfPfcmds; i += 1) {
    //   int pin = i + 1;

    //   if (outletPT_Status_0bar[i] == 'OK') {
    //     await setOffSetPT(pin);
    //   }
    // }
  }

  Future<void> _showBoosterPumpDialog(
    BuildContext context,
    Function onOkPressed,
    double? pressure,
  ) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/tap.png', height: 90, width: 90),
                  Text(
                    'Booster Pump Activation At $pressure Bar',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Please turn on the booster pump for 10 seconds at $pressure bar. After 10 seconds, click the OK button to start the PT check.",
                    style: TextStyle(fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 60),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 2,
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.of(context).pop();

                      await onOkPressed();
                    },
                    child: Text('Start Check Up'),
                  ),
                  // OutlinedButton(onPressed: () {}, child: Text('Ok'))
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Common function to handle the AI command and processing logic
  Future<void> checkOutletPTTest(
    int aiNumber,
    Function setPFCMD,
    Function setController,
    String content,
    bool isFilter,
    double? pressure,
  ) async {
    int attempt = 0;
    bool isSuccessful = false;
    bool hasShownBoosterPumpDialog = false; // Track if dialog has been shown
    double lowerLimitNew = (pressure ?? 0.0) * (pressure == 1 ? 0.6 : 0.85);
    double upperLimitNew = (pressure ?? 0.0) * 1.2;

    while (attempt < _maxRetries && !isSuccessful) {
      try {
        _showProcessingToast(
          context,
          content: '$content (Attempt ${attempt + 1}/$_maxRetries)',
        );

        _serialData.clear();
        String data = "AI $aiNumber\r\n".toUpperCase();
        await _port.write(Uint8List.fromList(data.codeUnits));
        await Future.delayed(Duration(seconds: 5));

        String res = _serialData.join('');
        print(res);

        int i = res.indexOf("AI");
        int j = res.indexOf(">");

        if (i != -1 && j != -1 && j > i) {
          String substring = res.substring(i + 4, j).trim();
          print("Extracted substring: $substring");

          List<String> digits =
              substring.split(' ').where((s) => s.isNotEmpty).toList();

          if (digits.isNotEmpty) {
            double? value = double.tryParse(digits[0]);
            print("Outlet PT $aiNumber Values $value");

            if (value != null) {
              if (isFilter) {
                if (value >= lowerLimitNew && value <= upperLimitNew) {
                  setState(() {
                    setPFCMD('OK');
                    setController(value);
                  });
                } else {
                  setState(() {
                    setPFCMD('Faulty');
                    setController(value);
                  });
                }
              } else {
                const double upperLimits = 0.1;
                const double lowerLimits = 0.0;
                if (value >= lowerLimits && value <= upperLimits) {
                  setState(() {
                    setPFCMD('OK');
                    setController(value);
                  });
                } else {
                  setState(() {
                    setPFCMD('Faulty');
                    setController(value);
                  });
                }
              }

              isSuccessful = true; // Mark as successful
            } else {
              print("Failed to parse digits[0] as a double.");
              setState(() {
                setPFCMD('Faulty');
              });
            }
          } else {
            print("No valid digit found in the response.");
            setState(() {
              setPFCMD('Faulty');
            });
          }
        } else {
          print("Invalid response format.");
          setState(() {
            setPFCMD('Faulty');
          });
        }

        // Show booster pump dialog only once if conditions are met
        if (!hasShownBoosterPumpDialog && aiNumber == 2 && pressure == 1.0) {
          hasShownBoosterPumpDialog = true; // Mark as shown
          await closeAllSolenoids();
          await _showBoosterPumpDialog(context, () async {
            await checkForLeakage(3.0);
          }, 3.0);
        }

        _response = [];
      } catch (ex) {
        print("Exception: $ex");
        attempt++;
        if (attempt >= _maxRetries) {
          setState(() {
            setPFCMD('Faulty');
          });
        }
      }
    }
  }

  // get Device Mac-Id
  Future<void> getMID() async {
    int attempt = 0;
    bool isSuccessful = false;

    while (attempt < _maxRetries && !isSuccessful) {
      try {
        _showProcessingToast(
          context,
          content: 'Getting MID (Attempt ${attempt + 1}/$_maxRetries)',
        );

        _serialData.clear();
        String data = "${'mid'.toUpperCase()}\r\n";
        await _port.write(Uint8List.fromList(data.codeUnits));
        await Future.delayed(Duration(seconds: 5)).whenComplete(() {
          String res = _serialData.join('');
          print(res);

          int i = res.indexOf("MI");
          if (i != -1) {
            String substring = res.substring(i + 4, i + 20);
            RegExp pattern = RegExp(r'^[0-9A-F]{16}$');
            bool matchesPattern = pattern.hasMatch(substring);

            if (matchesPattern) {
              var macAddresss = res.substring(i + 4, i + 20);

              setState(() {
                macId = macAddresss;
                if (widget.data?.macAddress?.toLowerCase() ==
                    macAddresss.toLowerCase()) {
                  isMacAddressOk = true;
                } else {
                  isMacAddressOk = false;
                }
              });

              // if (!isMatched!) setCurrDatetime();
              isSuccessful = true; // Mark as successful
            } else {
              print("Invalid MID format. Retrying...");
            }
          } else {
            print("MID not found. Retrying...");
          }
        });

        _response = [];
      } catch (ex) {
        print("Error: $ex");
        attempt++;

        if (attempt >= _maxRetries) {
          setState(() {
            macId = 'NOT FOUND';
          });
          _serialData.add('Please Try Again...');
          throw Exception("Failed to get MID after $attempt attempts.");
        }
      }
    }
  }

  // get Device Battery Voltage after test
  Future<void> getBatteryVoltageAfterTest() async {
    int attempt = 0;
    bool isSuccessful = false;

    while (attempt < _maxRetries && !isSuccessful) {
      try {
        _showProcessingToast(
          context,
          content:
              'Fetching battery voltage (Attempt ${attempt + 1}/$_maxRetries)',
        );
        _serialData.clear();
        String data = "${'bvtg'.toUpperCase()}\r\n";
        await _port.write(Uint8List.fromList(data.codeUnits));
        await Future.delayed(Duration(seconds: 5));

        String res = _serialData.join('');
        print(res);

        if (res.contains("Command received end")) {
          // Continue if this is an invalid response
          throw Exception("Invalid response: Command received end");
        }

        int i = res.indexOf("BV");
        if (i != -1 && i + 13 <= res.length) {
          String substring = res.substring(i + 5, i + 13);
          var bv = double.tryParse(substring)! / 1000;

          setState(() {
            batteryVoltageAftet = bv;
          });

          isSuccessful =
              true; // Mark as successful if a proper response is received
          _response = [];
        } else {
          throw Exception("Invalid response format");
        }
      } catch (ex) {
        attempt++;
        if (attempt >= _maxRetries) {
          // _showErrorToast(context,
          //     content:
          //         'Failed to fetch battery voltage after $attempt attempts.');
          setState(() {
            batteryVoltageAftet = 0;
          });
        }
      }
    }
  }

  checkPTatZeroBar() async {
    await checkFilterInletPT();
    await checkFilterOutletPT();
    // for (int i = 0; i < noOfPfcmds; i += 1) {
    //   int pin = i + 1;
    //   int ptpin = i + 3;
    //   await checkOutletPT0bar(
    //       ptpin,
    //       (status) => outletPT_Status_0bar[i] = status,
    //       (value) => outletPT_Values_0bar[i] = value,
    //       'Checking outlet PT-$pin');
    // }
  }

  // Helper function to get the closest value to the provided pressure
  double _getClosestValue(double inlet, double outlet, double pressure) {
    return (pressure - inlet).abs() < (pressure - outlet).abs()
        ? inlet
        : outlet;
  }

  // // Helper method to retry writing to the port
  //   Future<void> _retryWriteToPort(String data) async {
  //     int attempt = 0;
  //     bool isSuccessful = false;

  //     while (attempt < _maxRetries && !isSuccessful) {
  //       try {
  //         await _port.write(Uint8List.fromList(data.codeUnits));
  //         isSuccessful = true;
  //       } catch (e) {
  //         attempt++;
  //         if (attempt >= _maxRetries) {
  //           throw Exception("Failed to write to port after $attempt attempts.");
  //         }
  //       }
  //     }
  //   }

  // Helper method to retry fetching filter values
  /*Future<double> _retryFetchFilterValue(int start, int end) async {
    int attempt = 0;
    bool isSuccessful = false;
    double value = 0.0;

    while (attempt < _maxRetries && !isSuccessful) {
      try {
        value = await _fetchFilterValue(start, end);
        isSuccessful = true;
      } catch (e) {
        attempt++;
        if (attempt >= _maxRetries) {
          throw Exception(
              "Failed to fetch filter value after $attempt attempts.");
        }
      }
    }

    return value;
  }
*/

  Future<void> checkForLeakage(double pressure) async {
    String data = "${'INTG'.toUpperCase()}\r\n";
    int attempt = 0;
    int maxRetries = 5; // Set max retries
    bool isSuccessful = false;

    double closestInitialValue = 0.0;
    double lowerLimitNew = pressure - 0.4; //pressure * 0.8;
    double upperLimitNew = pressure + 0.2; //pressure * 1.2;

    while (attempt < maxRetries && !isSuccessful) {
      try {
        _response.clear();
        _serialData.clear();
        hexIntgValue = '';

        await _port.write(Uint8List.fromList(data.codeUnits));
        _showProcessingToast(
          context,
          content:
              "Checking for leakage (Attempt ${attempt + 1}/$maxRetries)...",
        );

        // Fetch initial values
        double initialFilterInlet = await _fetchFilterValue(20, 24);
        double initialFilterOutlet = await _fetchFilterValue(24, 28);

        double delta = _calculateDelta(initialFilterInlet, initialFilterOutlet);
        print("Initial delta: $delta");

        closestInitialValue = _getClosestValue(
          initialFilterInlet,
          initialFilterOutlet,
          pressure,
        );
        print(
          "Closest initial value to pressure $pressure: $closestInitialValue",
        );

        // Check for success condition (i.e., valid data received)
        String res = _serialData.join('');
        if (res.contains("INTG PacketBOC")) {
          isSuccessful = true; // Stop retrying if we got the correct response
        } else {
          throw Exception("Expected response not received");
        }

        // Wait for 15 seconds before re-checking
        await Future.delayed(Duration(seconds: 10));
        isSuccessful = false;
        _response.clear();
        _serialData.clear();
        hexIntgValue = '';
        await _port.write(Uint8List.fromList(data.codeUnits));
        await Future.delayed(Duration(seconds: 5));
        res = _serialData.join('');
        if (res.contains("INTG PacketBOC")) {
          isSuccessful = true; // Stop retrying if we got the correct response
        } else {
          throw Exception("Expected response not received");
        }

        // Fetch updated values
        double updatedFilterInlet = await _fetchFilterValue(20, 24);
        double updatedFilterOutlet = await _fetchFilterValue(24, 28);

        double updatedDelta = _calculateDelta(
          updatedFilterInlet,
          updatedFilterOutlet,
        );
        print("Updated delta: $updatedDelta");

        double closestUpdatedValue = _getClosestValue(
          updatedFilterInlet,
          updatedFilterOutlet,
          pressure,
        );
        print(
          "Closest updated value to pressure $pressure: $closestUpdatedValue",
        );

        // Calculate the difference and check for leakage
        double difference = (closestInitialValue - closestUpdatedValue).abs();
        print("Difference: $difference");

        double referencePtValue = (difference < 0.5)
            ? (closestInitialValue > closestUpdatedValue
                ? closestInitialValue
                : closestUpdatedValue)
            : 0;

        if (difference > 0.5) {
          showLeakageFoundPopup(pressure);
        } else {
          // Check pressure and update the state accordingly
          if (pressure == 3.0) {
            _updateInletOutletStatus(
              updatedFilterInlet,
              updatedFilterOutlet,
              lowerLimitNew,
              upperLimitNew,
              true,
            );
          } else if (pressure == 1.0) {
            _updateInletOutletStatus(
              updatedFilterInlet,
              updatedFilterOutlet,
              lowerLimitNew,
              upperLimitNew,
              false,
            );
          }
          showCheckPTValuesPopup(context, pressure, referencePtValue);
        }
      } catch (ex) {
        attempt++;
        if (attempt >= maxRetries) {
          print("Failed to fetch leakage data after $attempt attempts.");
          showLeakageFoundPopup(pressure); // Show a failure message
        } else {
          print("Retrying... Attempt ${attempt + 1}");
        }
      }
    }
  }

  // Helper function to update the state based on pressure type (3bar or 1bar)
  void _updateInletOutletStatus(
    double updatedInlet,
    double updatedOutlet,
    double lowerLimit,
    double upperLimit,
    bool isThreeBar,
  ) {
    if (isThreeBar) {
      setState(() {
        filterInlet3bar = updatedInlet;
        print(filterInlet3bar);
        inletPT_3bar =
            (updatedInlet >= lowerLimit && updatedInlet <= upperLimit)
                ? 'OK'
                : 'Faulty';
        filterOutlet3bar = updatedOutlet;
        print(filterOutlet3bar);
        outletPT_3bar =
            (updatedOutlet >= lowerLimit && updatedOutlet <= upperLimit)
                ? 'OK'
                : 'Faulty';
      });
    } else {
      setState(() {
        filterInlet1bar = updatedInlet;
        print(filterInlet1bar);
        inletPT_1bar =
            (updatedInlet >= lowerLimit && updatedInlet <= upperLimit)
                ? 'OK'
                : 'Faulty';
        filterOutlet1bar = updatedOutlet;
        print(filterOutlet1bar);
        outletPT_1bar =
            (updatedOutlet >= lowerLimit && updatedOutlet <= upperLimit)
                ? 'OK'
                : 'Faulty';
      });
    }
  }

  Future<double> _fetchFilterValue(int startIndex, int endIndex) async {
    await Future.delayed(Duration(seconds: 5));
    print(hexIntgValue.toString());
    var hexValue = hexIntgValue?.substring(startIndex, endIndex);
    int decimal = int.parse(hexValue ?? "0", radix: 16);
    double pressureValue = decimal / 100;

    // bool isWithinRange =
    //     pressureValue >= lowerLimit && pressureValue <= upperLimit;
    // print(
    //     "Pressure value: ${pressureValue.toStringAsFixed(3)} - Is within range: $isWithinRange");

    return pressureValue;
  }

  double _calculateDelta(double inlet, double outlet) {
    return (3.0 - inlet).abs() < (3.0 - outlet).abs() ? inlet : outlet;
  }

  // Function to show the leakage found popup
  void showLeakageFoundPopup(double press) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/leak-detector.png',
                    height: 90,
                    width: 90,
                  ),
                  Text(
                    'Leakage Detected',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "A drop of more than 0.5 has been detected in the filter inlet or outlet pressure.",
                    style: TextStyle(fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 60),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 2,
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await _showBoosterPumpDialog(context, () {
                            checkForLeakage(press);
                          }, press);
                        },
                        child: Text('No Leakage Found'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 2,
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await _showBoosterPumpDialog(context, () {
                            checkForLeakage(press);
                          }, press);
                        },
                        child: Text('leakage solved'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> processCompletePopup() async {
    setState(() {
      isStart = false;
      isProcessComplete = true;
    });
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/pdf.png', height: 90, width: 90),
                  Text(
                    'Auto Dry Commisstioning Completed',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "please confirm and click on Submit button to save report.",
                    style: TextStyle(fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 60),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 2,
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      getusername();
                      getcurrentdate();
                      saveJSON();
                      _submitForm();
                      // showSaveDialog(context);
                    },
                    child: Text('Confirm & Submit'),
                  ),
                  // OutlinedButton(onPressed: () {}, child: Text('Ok'))
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Function to show the check PT values popup
  Future<void> showCheckPTValuesPopup(
    BuildContext context,
    double pressure,
    double referencePtValue,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/tap.png', height: 90, width: 90),
                  Text(
                    'Check PT Values',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "No leaks found. You can proceed with testing the PT.",
                    style: TextStyle(fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 60),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 2,
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      if (pressure == 3.0) {
                        await performPressure3Checks(context);
                      } else if (pressure == 1.0) {
                        await performPressure1Checks();
                      } else {
                        debugPrint('Pressure not match');
                      }
                      /*if (pressure == 3.0) {
                              var upperLimit_new = pressure + 0.5;
                              var lowerLimit_new = pressure - 0.5;
                              for (int i = 0; i < noOfPfcmds; i += 1) {
                                int bitlen = i * 20;

                                if (i == 4) {
                                  ptValue = await _retryFetchFilterValue(
                                      34 + bitlen, 38 + bitlen);
                                } else {
                                  ptValue = await _retryFetchFilterValue(
                                      38 + bitlen, 42 + bitlen);
                                }

                                // Limit ptValue to one decimal place
                                double roundedPtValue =
                                    double.parse(ptValue!.toStringAsFixed(1));
                                print(
                                    'PT ${i + 1} Value from INTG (rounded): $roundedPtValue');

                                setState(() {
                                  if (roundedPtValue >= lowerLimit_new &&
                                      roundedPtValue <= upperLimit_new) {
                                    // SET CLOSE STATUS SOLENOID OK AND PT OK
                                    outletPT_Status_3bar?[i] = 'OK';
                                    outletPT_Values_3bar?[i] = roundedPtValue;
                                  } else {
                                    // SET CLOSE STATUS SOLENOID FAULTY OR PT FAULTY
                                    outletPT_Status_3bar?[i] = 'Faulty';
                                    outletPT_Values_3bar?[i] = roundedPtValue;
                                  }
                                });
                              }
                              await performPressure3Checks(context);
                            } else if (pressure == 1.0) {
                              var upperLimit_new = pressure + 0.2;
                              var lowerLimit_new = pressure - 0.5;
                              for (int i = 0; i < noOfPfcmds; i += 1) {
                                int bitlen = i * 20;

                                if (i == 4) {
                                  ptValue = await _retryFetchFilterValue(
                                      34 + bitlen, 38 + bitlen);
                                } else {
                                  ptValue = await _retryFetchFilterValue(
                                      38 + bitlen, 42 + bitlen);
                                }

                                // Limit ptValue to one decimal place
                                double roundedPtValue =
                                    double.parse(ptValue!.toStringAsFixed(1));
                                print(
                                    'PT ${i + 1} Value from INTG (rounded): $roundedPtValue');

                                setState(() {
                                  if (roundedPtValue >= lowerLimit_new &&
                                      roundedPtValue <= upperLimit_new) {
                                    // SET CLOSE STATUS SOLENOID OK AND PT OK
                                    outletPT_Status_1bar[i] = 'OK';
                                    outletPT_Values_1bar[i] = roundedPtValue;
                                  } else {
                                    // SET CLOSE STATUS SOLENOID FAULTY OR PT FAULTY
                                    outletPT_Status_1bar[i] = 'Faulty';
                                    outletPT_Values_1bar[i] = roundedPtValue;
                                  }
                                });
                              }
                              await performPressure1Checks();
                            }*/
                    },
                    child: Text('Test PT'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Function to handle checks for pressure == 3.0
  Future<void> performPressure3Checks(BuildContext context) async {
    // Call the common function for different AI numbers
    await openAllSolenoids();
    await checkOutletPTTest(
      1,
      (status) => inletPT_3bar_new = status,
      (value) => filterInlet3bar_new = value,
      'Checking filter intlet PT',
      true,
      3.0,
    );

    await checkOutletPTTest(
      2,
      (status) {
        outletPT_3bar_new = status;
        solenoid_status?[0] = status;
      },
      (value) => filterOutlet3bar_new = value,
      'Checking filter outlet PT',
      true,
      3.0,
    );

    // for (int i = 0; i < noOfPfcmds; i += 1) {
    //   int pin = i + 1;
    //   int ptpin = i + 3;
    //  await Future.delayed(Duration(seconds: 2))
    //     .whenComplete(() => setSovOpen(pin));
    //   await Future.delayed(Duration(seconds: 5)).whenComplete(
    //     () => checkOutletPTTest(ptpin, (status) {
    //       outletPT_Status_3bar_new?[i] = status;
    //       solenoid_status?[i] = status;
    //     }, (value) => outletPT_Values_3bar_new?[i] = value, 'Outlet PT $pin',
    //         false, 3.0),
    //   );
    // }
    await performPositionSensorCheck();
  }

  Future<void> changeSolenoidMode() async {
    for (int i = 0; i < noOfPfcmds; i += 1) {
      int pin = i + 1;
      int ptpin = i + 3;
      await Future.delayed(
        Duration(seconds: 2),
      ).whenComplete(() => setSovOpenCloseMode(pin));
      await Future.delayed(
        Duration(seconds: 2),
      ).whenComplete(() => setSovManualMode(pin));
    }
  }

  //Open All Solenoids One By One
  Future<void> openAllSolenoids1() async {
    for (int i = 0; i < noOfPfcmds; i += 1) {
      int pin = i + 1;
      int ptpin = i + 3;
      await Future.delayed(
        Duration(seconds: 2),
      ).whenComplete(() => setSovOpen(pin));
    }
  }

  Future<void> closeAllSolenoids() async {
    int attempt = 0;
    bool isSuccessful = false;

    while (attempt < _maxRetries && !isSuccessful) {
      try {
        _response.clear();
        _serialData.clear();
        _showProcessingToast(context, content: "Closing All Solenoids");

        String data = "${'EMS 1'.toUpperCase()}\r\n";
        await _port.write(Uint8List.fromList(data.codeUnits));

        await Future.delayed(Duration(seconds: 5)).whenComplete(() {
          String res = _serialData.join('');
          if (res.toUpperCase().contains('EMS 1')) {
            print("emergency stop successfully");
            isSuccessful = true;
          } else {
            print("Failed to set Emergency Stop");
          }
        });
        _response = [];
      } catch (ex) {
        print("Exception: $ex");
      }

      if (!isSuccessful) {
        attempt++;
        if (attempt < _maxRetries) {
          print("Retrying for closing solenoids  (Attempt $attempt)...");
        } else {
          print("Failed to closing solenoids  after $attempt attempts.");
        }
      }
    }
  }

  Future<void> openAllSolenoids() async {
    int attempt = 0;
    bool isSuccessful = false;

    while (attempt < _maxRetries && !isSuccessful) {
      try {
        _response.clear();
        _serialData.clear();
        _showProcessingToast(context, content: "Opening All Solenoids");

        String data = "${'EMS 0'.toUpperCase()}\r\n";
        await _port.write(Uint8List.fromList(data.codeUnits));

        await Future.delayed(Duration(seconds: 5)).whenComplete(() {
          String res = _serialData.join('');
          if (res.toUpperCase().contains('EMS 0')) {
            print("emergency stop successfully");
            isSuccessful = true;
          } else {
            print("Failed to set Emergency Stop");
          }
        });
        _response = [];
      } catch (ex) {
        print("Exception: $ex");
      }

      if (!isSuccessful) {
        attempt++;
        if (attempt < _maxRetries) {
          print("Retrying for emergency stop  (Attempt $attempt)...");
        } else {
          print("Failed to emergency stop  after $attempt attempts.");
        }
      }
    }
  }

  Future<void> removeEMS() async {
    int attempt = 0;
    bool isSuccessful = false;

    while (attempt < _maxRetries && !isSuccessful) {
      try {
        _response.clear();
        _serialData.clear();
        _showProcessingToast(context, content: "Disabling Emergency Stop");

        String data = "${'EMS 0'.toUpperCase()}\r\n";
        await _port.write(Uint8List.fromList(data.codeUnits));

        await Future.delayed(Duration(seconds: 5)).whenComplete(() {
          String res = _serialData.join('');
          if (res.toUpperCase().contains('EMS 0')) {
            print("emergency stop successfully");
            isSuccessful = true;
          } else {
            print("Failed to set Emergency Stop");
          }
        });
        _response = [];
      } catch (ex) {
        print("Exception: $ex");
      }

      if (!isSuccessful) {
        attempt++;
        if (attempt < _maxRetries) {
          print("Retrying for emergency stop  (Attempt $attempt)...");
        } else {
          print("Failed to emergency stop  after $attempt attempts.");
        }
      }
    }
  }

  // Function to handle checks for pressure == 1
  Future<void> performPressure1Checks() async {
    // Call the common function for different AI numbers
    await openAllSolenoids();
    await checkOutletPTTest(
      1,
      (status) => inletPT_1bar_new = status,
      (value) => filterInlet1bar_new = value,
      'Checking filter intlet PT',
      true,
      1.0,
    );

    await checkOutletPTTest(
      2,
      (status) => outletPT_1bar_new = status,
      (value) => filterOutlet1bar_new = value,
      'Checking filter outlet PT',
      true,
      1.0,
    );

    /*for (int i = 0; i < noOfPfcmds; i += 1) {
      int pin = i + 1;
      int ptpin = i + 3;
      await Future.delayed(Duration(seconds: 5)).whenComplete(() =>
          checkOutletPTTest(ptpin, (status) {
            outletPT_Status_1bar_new[i] = status;
          }, (value) => outletPT_Values_1bar_new[i] = value, 'Outlet PT $pin',
              false, 1.0));
    }*/
  }

  Future<void> checkPositionSensor(
    int aiNumber,
    Function setPFCMD,
    Function setController,
    String content,
  ) async {
    int attempt = 0;
    bool isSuccessful = false;

    while (attempt < _maxRetries && !isSuccessful) {
      try {
        _showProcessingToast(
          context,
          content: '$content  (Attempt ${attempt + 1}/$_maxRetries)',
        );

        _serialData.clear();
        String data = "AI $aiNumber\r\n".toUpperCase();
        await _port.write(Uint8List.fromList(data.codeUnits));
        await Future.delayed(Duration(seconds: 5));

        String res = _serialData.join('');
        print(res);

        // Find the index of "AI" and ">"
        int i = res.indexOf("AI");
        int j = res.indexOf(">");

        if (i != -1 && j != -1 && j > i) {
          // Extract the substring between "AI" and ">"
          String substring = res.substring(i + 5, j).trim();
          print("Extracted substring: $substring");

          // Split the substring into individual components
          List<String> digits =
              substring.split(' ').where((s) => s.isNotEmpty).toList();

          if (digits.length > 1) {
            int? value = int.tryParse(digits[1]);

            if (value != null) {
              if (value >= 3000 && value <= 20000) {
                setState(() {
                  setPFCMD('OK');
                  setController(value.toDouble());
                });
              } else {
                setState(() {
                  setPFCMD('Faulty');
                  setController(value.toDouble());
                });
              }
              isSuccessful = true; // Mark as successful
            } else {
              print("Failed to parse digits[1] as an integer.");
              setState(() {
                setPFCMD('Faulty');
              });
            }
          } else {
            print("No second digit found in the response.");
            setState(() {
              setPFCMD('Faulty');
            });
          }
        } else {
          print("Invalid response format.");
          setState(() {
            setPFCMD('Faulty');
          });
        }

        _response = [];
      } catch (ex) {
        print("Exception: $ex");
        attempt++;
        if (attempt >= _maxRetries) {
          setState(() {
            setPFCMD('Faulty');
          });
        }
      }
    }
  }

  Future<void> calibratePositionSensor(
    int aiNumber,
    Function setPFCMD,
    Function setController,
    String content,
    int count,
  ) async {
    int attempt = 0;
    bool isSuccessful = false;

    while (attempt < _maxRetries && !isSuccessful) {
      try {
        _showProcessingToast(
          context,
          content: '$content  (Attempt ${attempt + 1}/$_maxRetries)',
        );

        _serialData.clear();
        String data =
            "AIS $aiNumber 0 100 ${count + 10000} $count\r\n".toUpperCase();
        await _port.write(Uint8List.fromList(data.codeUnits));
        await Future.delayed(Duration(seconds: 5));

        String res = _serialData.join('');
        print(res);

        // Find the index of "AI" and ">"
        int i = res.indexOf("AI");
        int j = res.indexOf(">");

        if (i != -1 && j != -1 && j > i) {
          // Extract the substring between "AI" and ">"
          String substring = res.substring(i + 5, j).trim();
          print("Extracted substring: $substring");

          // Split the substring into individual components
          List<String> digits =
              substring.split(' ').where((s) => s.isNotEmpty).toList();

          if (digits.length > 1) {
            int? value = int.tryParse(digits[1]);

            if (value != null) {
              if (value >= 3000 && value <= 20000) {
                setState(() {
                  setPFCMD('OK');
                  setController(value.toDouble());
                });
              } else {
                setState(() {
                  setPFCMD('Faulty');
                  setController(value.toDouble());
                });
              }
              isSuccessful = true; // Mark as successful
            } else {
              print("Failed to parse digits[1] as an integer.");
              setState(() {
                setPFCMD('Faulty');
              });
            }
          } else {
            print("No second digit found in the response.");
            setState(() {
              setPFCMD('Faulty');
            });
          }
        } else {
          print("Invalid response format.");
          setState(() {
            setPFCMD('Faulty');
          });
        }

        _response = [];
      } catch (ex) {
        print("Exception: $ex");
        attempt++;
        if (attempt >= _maxRetries) {
          setState(() {
            setPFCMD('Faulty');
          });
        }
      }
    }
  }

  Future<void> performPositionSensorCheck() async {
    for (int i = 0; i < noOfPfcmds; i += 1) {
      int pin = i + 1;
      int ptpin = i + 9;

      await checkPositionSensor(
        ptpin,
        (status) => position_status?[i] = status,
        (value) => position_values?[i] = value,
        'Checking Position Sensors $pin',
      );
    }
    await closeAllSolenoids();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            width: MediaQuery.of(context).size.width * 0.3,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 20),
                Text(
                  'Please Open the door and press Test Button to proceed with the test',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await openDoor();
                      },
                      child: Text('Test'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> calibrateAllPositionSensors() async {
    for (int i = 0; i < noOfPfcmds; i += 1) {
      int pin = i + 1;
      int ptpin = i + 9;

      await checkPositionSensor(
        ptpin,
        (status) => position_status?[i] = status,
        (value) => position_values?[i] = value,
        'Checking Position Sensors $pin',
      );
    }
  }

  // set Solenoid in Flow Control mode.
  Future<void> setSovFlowControl(int sovNumber) async {
    int attempt = 0;
    bool isSuccessful = false;

    while (attempt < _maxRetries && !isSuccessful) {
      try {
        _response.clear();
        _serialData.clear();
        _showProcessingToast(
          context,
          content: "Setting Solenoid $sovNumber to Flow Control mode...",
        );

        String data = "${'PFCMD1TYPE 2'.toUpperCase()}\r\n";
        await _port.write(Uint8List.fromList(data.codeUnits));

        await Future.delayed(Duration(seconds: 5)).whenComplete(() {
          String res = _serialData.join('');
          if (res.toUpperCase().contains('PFCMD1TYPE 2')) {
            print(
              "Solenoid $sovNumber is set to Flow Control mode successfully",
            );
            isSuccessful = true;
          } else {
            print("Failed to set SOV $sovNumber");
          }
        });
        _response = [];
      } catch (ex) {
        print("Exception: $ex");
      }

      if (!isSuccessful) {
        attempt++;
        if (attempt < _maxRetries) {
          print("Retrying to set SOV $sovNumber (Attempt $attempt)...");
        } else {
          print("Failed to set SOV $sovNumber after $attempt attempts.");
        }
      }
    }
  }

  // set Solenoid in Open/Close mode.
  Future<void> setSovOpenCloseMode(int sovNumber) async {
    int attempt = 0;
    bool isSuccessful = false;

    while (attempt < _maxRetries && !isSuccessful) {
      try {
        _response.clear();
        _serialData.clear();
        _showProcessingToast(
          context,
          content: "Setting Solenoid $sovNumber to Open/Close mode...",
        );

        String data = "${'PFCMD1TYPE 1'.toUpperCase()}\r\n";
        await _port.write(Uint8List.fromList(data.codeUnits));

        await Future.delayed(Duration(seconds: 5)).whenComplete(() {
          String res = _serialData.join('');
          if (res.toUpperCase().contains('PFCMD1TYPE 1')) {
            print("Solenoid $sovNumber is set to Open/Close mode successfully");
            isSuccessful = true;
          } else {
            print("Failed to set SOV $sovNumber");
          }
        });
        _response = [];
      } catch (ex) {
        print("Exception: $ex");
      }

      if (!isSuccessful) {
        attempt++;
        if (attempt < _maxRetries) {
          print("Retrying to set Solenoid $sovNumber (Attempt $attempt)...");
        } else {
          print("Failed to set Solenoid $sovNumber after $attempt attempts.");
        }
      }
    }
  }

  // set Solenoid in Manual mode.
  Future<void> setSovManualMode(int sovNumber) async {
    int attempt = 0;
    bool isSuccessful = false;

    while (attempt < _maxRetries && !isSuccessful) {
      try {
        _response.clear();
        _serialData.clear();
        _showProcessingToast(
          context,
          content: "Setting Solenoid $sovNumber to Manual mode...",
        );

        String data = "${'SMODE 2 1 1'.toUpperCase()}\r\n";
        await _port.write(Uint8List.fromList(data.codeUnits));

        await Future.delayed(Duration(seconds: 5)).whenComplete(() {
          String res = _serialData.join('');
          if (res.toUpperCase().contains('SMODE 2 1 1')) {
            print("Solenid $sovNumber is set to Manual mode successfully");
            isSuccessful = true;
          } else {
            print("Failed to set SOV $sovNumber");
          }
        });
        _response = [];
      } catch (ex) {
        print("Exception: $ex");
      }

      if (!isSuccessful) {
        attempt++;
        if (attempt < _maxRetries) {
          print("Retrying to set Solenoid $sovNumber (Attempt $attempt)...");
        } else {
          print("Failed to set Solenoid $sovNumber after $attempt attempts.");
        }
      }
    }
  }

  // set Solenoid in Manual mode.
  Future<void> setSovAutoMode(int sovNumber) async {
    int attempt = 0;
    bool isSuccessful = false;

    while (attempt < _maxRetries && !isSuccessful) {
      try {
        _response.clear();
        _serialData.clear();
        _showProcessingToast(
          context,
          content: "Setting Solenoid $sovNumber to Auto mode...",
        );

        String data = "${'SMODE 1 0 0'.toUpperCase()}\r\n";
        await _port.write(Uint8List.fromList(data.codeUnits));

        await Future.delayed(Duration(seconds: 5)).whenComplete(() {
          String res = _serialData.join('');
          if (res.toUpperCase().contains('SMODE 1 0 0')) {
            print("Solenoid $sovNumber is set to Auto mode successfully");
            isSuccessful = true;
          } else {
            print("Failed to set SOV $sovNumber");
          }
        });
        _response = [];
      } catch (ex) {
        print("Exception: $ex");
      }

      if (!isSuccessful) {
        attempt++;
        if (attempt < _maxRetries) {
          print("Retrying to set Solenoid $sovNumber (Attempt $attempt)...");
        } else {
          print("Failed to set Solenoid $sovNumber after $attempt attempts.");
        }
      }
    }
  }

  //Set Solenoid Open
  Future<void> setSovOpen(int index) async {
    int attempt = 0;
    bool isSuccessful = false;

    while (attempt < _maxRetries && !isSuccessful) {
      try {
        _serialData.clear();
        _showProcessingToast(context, content: "Opening SOV $index...");

        String data = "${('PFCMD1ONOFF 1').toUpperCase()}\r\n";
        await _port.write(Uint8List.fromList(data.codeUnits));

        await Future.delayed(Duration(seconds: 10)).whenComplete(() {
          String res = _serialData.join('');
          if (res.toLowerCase().contains('pfcmd$index on')) {
            print("PFCMD $index is OPEN now");

            isSuccessful = true;
          } else {
            print("Failed to open SOV $index");
          }
        });
      } catch (ex) {
        print("Exception: $ex");
      }

      if (!isSuccessful) {
        attempt++;
        if (attempt < _maxRetries) {
          print("Retrying to open SOV $index (Attempt $attempt)...");
        } else {
          print("Failed to open SOV $index after $attempt attempts.");
        }
      }
    }
  }

  void showSaveDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/pdf.png', height: 90, width: 90),
                  Text(
                    'Save PDF',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Please confirm that you want save the PDF.",
                    style: TextStyle(fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 60),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 2,
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        onPressed: () async {
                          saveJSON();
                          _submitForm();
                          Navigator.of(context).pop();
                        },
                        child: Text('Save'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 2,
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.of(context).pop();
                        },
                        child: Text('Cancel'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _submitForm() {
    final pdfWidgets.Document pdf = pdfWidgets.Document();
    //Page 1
    pdf.addPage(
      pdfWidgets.Page(
        build: (context) {
          return pdfWidgets.Container(
            child: pdfWidgets.Column(
              mainAxisAlignment: pdfWidgets.MainAxisAlignment.start,
              crossAxisAlignment: pdfWidgets.CrossAxisAlignment.start,
              children: [
                pdfWidgets.Center(
                  child: pdfWidgets.Text(
                    'RMS Auto Dry Commissioning Report',
                    style: pdfWidgets.TextStyle(
                      fontSize: 24,
                      fontWeight: pdfWidgets.FontWeight.bold,
                    ),
                  ),
                ),
                pdfWidgets.Divider(),
                //SiteName & MacID
                pdfWidgets.Container(
                  child: pdfWidgets.Column(
                    children: [
                      pdfWidgets.SizedBox(height: 10),
                      pdfWidgets.Row(
                        mainAxisAlignment:
                            pdfWidgets.MainAxisAlignment.spaceBetween,
                        children: [
                          pdfWidgets.Row(
                            children: [
                              pdfWidgets.Text(
                                'Site Name :',
                                style: pdfWidgets.TextStyle(
                                  fontWeight: pdfWidgets.FontWeight.bold,
                                ),
                              ),
                              pdfWidgets.SizedBox(width: 20),
                              pdfWidgets.Text('${widget.projectName}'),
                            ],
                          ),
                          pdfWidgets.Row(
                            children: [
                              pdfWidgets.Text(
                                'Node No :',
                                style: pdfWidgets.TextStyle(
                                  fontWeight: pdfWidgets.FontWeight.bold,
                                ),
                              ),
                              pdfWidgets.SizedBox(width: 20),
                              pdfWidgets.Text('${widget.data?.rmsNo}'),
                            ],
                          ),
                        ],
                      ),
                      pdfWidgets.Row(
                        children: [
                          pdfWidgets.Text(
                            'Mac ID :',
                            style: pdfWidgets.TextStyle(
                              fontWeight: pdfWidgets.FontWeight.bold,
                            ),
                          ),
                          pdfWidgets.SizedBox(width: 20),
                          pdfWidgets.Text(
                            macId,
                            style: pdfWidgets.TextStyle(
                              fontWeight: pdfWidgets.FontWeight.normal,
                            ),
                          ),
                          pdfWidgets.SizedBox(width: 20),
                          pdfWidgets.Text(
                            '${isMacAddressOk ? 'OK' : 'NOT OK'}',
                            style: pdfWidgets.TextStyle(
                              fontWeight: pdfWidgets.FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      pdfWidgets.Row(
                        children: [
                          pdfWidgets.Text(
                            'Device Time :',
                            style: pdfWidgets.TextStyle(
                              fontWeight: pdfWidgets.FontWeight.bold,
                            ),
                          ),
                          pdfWidgets.SizedBox(width: 20),
                          if (deviceTime != null)
                            pdfWidgets.Text(
                              DateFormat(
                                'dd-MMM-yyyy HH:mm:ss',
                              ).format(deviceTime!),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                pdfWidgets.Divider(),
                //General Check
                pdfWidgets.Column(
                  mainAxisAlignment: pdfWidgets.MainAxisAlignment.start,
                  crossAxisAlignment: pdfWidgets.CrossAxisAlignment.start,
                  children: [
                    pdfWidgets.Padding(
                      padding: const pdfWidgets.EdgeInsets.all(8.0),
                      child: pdfWidgets.Text(
                        'General Checks ',
                        style: pdfWidgets.TextStyle(
                          fontSize: 14,
                          fontWeight: pdfWidgets.FontWeight.bold,
                        ),
                      ),
                    ),
                    //Values
                    pdfWidgets.Padding(
                      padding: const pdfWidgets.EdgeInsets.all(8),
                      child: pdfWidgets.Table(
                        border: pdfWidgets.TableBorder.all(
                          width: 1,
                          color: PdfColors.black,
                        ),
                        children: [
                          pdfWidgets.TableRow(
                            children: [
                              pdfWidgets.Expanded(
                                flex: 1,
                                child: pdfWidgets.Container(
                                  height: 20,
                                  alignment: pdfWidgets.Alignment.center,
                                  child: pdfWidgets.Text(
                                    'Description',
                                    style: pdfWidgets.TextStyle(
                                      fontWeight: pdfWidgets.FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              pdfWidgets.Expanded(
                                flex: 1,
                                child: pdfWidgets.Container(
                                  height: 20,
                                  alignment: pdfWidgets.Alignment.center,
                                  child: pdfWidgets.Text(
                                    'Exp. Value',
                                    style: pdfWidgets.TextStyle(
                                      fontWeight: pdfWidgets.FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              pdfWidgets.Expanded(
                                flex: 1,
                                child: pdfWidgets.Container(
                                  height: 20,
                                  alignment: pdfWidgets.Alignment.center,
                                  child: pdfWidgets.Text(
                                    'Act. Value',
                                    style: pdfWidgets.TextStyle(
                                      fontWeight: pdfWidgets.FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              pdfWidgets.Expanded(
                                flex: 1,
                                child: pdfWidgets.Container(
                                  height: 20,
                                  alignment: pdfWidgets.Alignment.center,
                                  child: pdfWidgets.Text(
                                    'Remark',
                                    style: pdfWidgets.TextStyle(
                                      fontWeight: pdfWidgets.FontWeight.bold,
                                    ),
                                  ),
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
                                  child: pdfWidgets.Text('Firmware Version'),
                                ),
                              ),
                              pdfWidgets.Expanded(
                                flex: 1,
                                child: pdfWidgets.Container(
                                  height: 20,
                                  alignment: pdfWidgets.Alignment.center,
                                  child: pdfWidgets.Text(
                                    '${double.tryParse(widget.data?.firmwareVersion?.toString() ?? '0.0')?.toStringAsFixed(1)}',
                                  ),
                                ),
                              ),
                              pdfWidgets.Expanded(
                                flex: 1,
                                child: pdfWidgets.Container(
                                  height: 20,
                                  alignment: pdfWidgets.Alignment.center,
                                  child: pdfWidgets.Text('$firmwareversion '),
                                ),
                              ),
                              pdfWidgets.Expanded(
                                flex: 1,
                                child: pdfWidgets.Container(
                                  height: 20,
                                  alignment: pdfWidgets.Alignment.center,
                                  child: pdfWidgets.Text(
                                    isCurrectFirmware ? 'Ok' : 'Faulty',
                                  ),
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
                                  child: pdfWidgets.Text("Battery Voltage"),
                                ),
                              ),
                              pdfWidgets.Expanded(
                                flex: 1,
                                child: pdfWidgets.Container(
                                  height: 20,
                                  alignment: pdfWidgets.Alignment.center,
                                  child: pdfWidgets.Text("3.3 V"),
                                ),
                              ),
                              pdfWidgets.Expanded(
                                flex: 1,
                                child: pdfWidgets.Container(
                                  height: 20,
                                  alignment: pdfWidgets.Alignment.center,
                                  child: pdfWidgets.Text('$batteryVoltage V'),
                                ),
                              ),
                              pdfWidgets.Expanded(
                                flex: 1,
                                child: pdfWidgets.Container(
                                  height: 20,
                                  alignment: pdfWidgets.Alignment.center,
                                  child: pdfWidgets.Text(isBatterOk ?? ''),
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
                                  child: pdfWidgets.Text("Solar Voltage"),
                                ),
                              ),
                              pdfWidgets.Expanded(
                                flex: 1,
                                child: pdfWidgets.Container(
                                  height: 20,
                                  alignment: pdfWidgets.Alignment.center,
                                  child: pdfWidgets.Text("5 - 7.1 V"),
                                ),
                              ),
                              pdfWidgets.Expanded(
                                flex: 1,
                                child: pdfWidgets.Container(
                                  height: 20,
                                  alignment: pdfWidgets.Alignment.center,
                                  child: pdfWidgets.Text('$solarVoltage V'),
                                ),
                              ),
                              pdfWidgets.Expanded(
                                flex: 1,
                                child: pdfWidgets.Container(
                                  height: 20,
                                  alignment: pdfWidgets.Alignment.center,
                                  child: pdfWidgets.Text(
                                    isSolarOk ? 'Ok' : 'Faulty',
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
                //PT check At 0 Bar
                pdfWidgets.Padding(
                  padding: const pdfWidgets.EdgeInsets.all(8.0),
                  child: pdfWidgets.Text(
                    'PT Valve Check At 0 Bar',
                    style: pdfWidgets.TextStyle(
                      fontSize: 14,
                      fontWeight: pdfWidgets.FontWeight.bold,
                    ),
                  ),
                ),
                pdfWidgets.Padding(
                  padding: const pdfWidgets.EdgeInsets.all(8),
                  child: pdfWidgets.Table(
                    border: pdfWidgets.TableBorder.all(
                      width: 1,
                      color: PdfColors.black,
                    ),
                    children: [
                      pdfWidgets.TableRow(
                        children: [
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                'Description',
                                style: pdfWidgets.TextStyle(
                                  fontWeight: pdfWidgets.FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                'Exp. Value',
                                style: pdfWidgets.TextStyle(
                                  fontWeight: pdfWidgets.FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                'Act. Value',
                                style: pdfWidgets.TextStyle(
                                  fontWeight: pdfWidgets.FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                'Remark',
                                style: pdfWidgets.TextStyle(
                                  fontWeight: pdfWidgets.FontWeight.bold,
                                ),
                              ),
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
                              child: pdfWidgets.Text("Inlet PT"),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text('4000 mA'),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                '${filterInlet.toString()} mA',
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(inletPT_0bar),
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
                              child: pdfWidgets.Text("4000 mA"),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                '${filterOutlet.toString()} mA',
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(outletPT_0bar),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                //PT check At 1 Bar
                pdfWidgets.Padding(
                  padding: const pdfWidgets.EdgeInsets.all(8.0),
                  child: pdfWidgets.Text(
                    'PT Valve Check At 1 Bar',
                    style: pdfWidgets.TextStyle(
                      fontSize: 14,
                      fontWeight: pdfWidgets.FontWeight.bold,
                    ),
                  ),
                ),
                pdfWidgets.Padding(
                  padding: const pdfWidgets.EdgeInsets.all(8),
                  child: pdfWidgets.Table(
                    border: pdfWidgets.TableBorder.all(
                      width: 1,
                      color: PdfColors.black,
                    ),
                    children: [
                      pdfWidgets.TableRow(
                        children: [
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                'Description',
                                style: pdfWidgets.TextStyle(
                                  fontWeight: pdfWidgets.FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                'Exp. Value',
                                style: pdfWidgets.TextStyle(
                                  fontWeight: pdfWidgets.FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                'Act. Value',
                                style: pdfWidgets.TextStyle(
                                  fontWeight: pdfWidgets.FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                'Remark',
                                style: pdfWidgets.TextStyle(
                                  fontWeight: pdfWidgets.FontWeight.bold,
                                ),
                              ),
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
                              child: pdfWidgets.Text("Inlet PT"),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text('0.5 - 1.2 bar'),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                '${filterInlet1bar.toString()} bar',
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(inletPT_1bar),
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
                              child: pdfWidgets.Text("0.5 - 1.2 bar"),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                '${filterOutlet1bar.toString()} bar',
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(outletPT_1bar),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                //PT check At 3 Bar
                pdfWidgets.Padding(
                  padding: const pdfWidgets.EdgeInsets.all(8.0),
                  child: pdfWidgets.Text(
                    'PT Valve Check At 3 Bar',
                    style: pdfWidgets.TextStyle(
                      fontSize: 14,
                      fontWeight: pdfWidgets.FontWeight.bold,
                    ),
                  ),
                ),
                pdfWidgets.Padding(
                  padding: const pdfWidgets.EdgeInsets.all(8),
                  child: pdfWidgets.Table(
                    border: pdfWidgets.TableBorder.all(
                      width: 1,
                      color: PdfColors.black,
                    ),
                    children: [
                      pdfWidgets.TableRow(
                        children: [
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                'Description',
                                style: pdfWidgets.TextStyle(
                                  fontWeight: pdfWidgets.FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                'Exp. Value',
                                style: pdfWidgets.TextStyle(
                                  fontWeight: pdfWidgets.FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                'Act. Value',
                                style: pdfWidgets.TextStyle(
                                  fontWeight: pdfWidgets.FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                'Remark',
                                style: pdfWidgets.TextStyle(
                                  fontWeight: pdfWidgets.FontWeight.bold,
                                ),
                              ),
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
                              child: pdfWidgets.Text("Inlet PT"),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text('2.5 - 3.5 bar'),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                '${filterInlet3bar.toString()} bar',
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(inletPT_3bar),
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
                              child: pdfWidgets.Text("2.5 - 3.5 bar"),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                '${filterOutlet3bar.toString()} bar',
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(outletPT_3bar),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                //Solenoid Table
                pdfWidgets.Padding(
                  padding: const pdfWidgets.EdgeInsets.all(8.0),
                  child: pdfWidgets.Text(
                    'Solenoid Testing',
                    style: pdfWidgets.TextStyle(
                      fontSize: 14,
                      fontWeight: pdfWidgets.FontWeight.bold,
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
                      // Header row
                      pdfWidgets.TableRow(
                        children: [
                          pdfWidgets.Container(
                            height: 20,
                            alignment: pdfWidgets.Alignment.center,
                            child: pdfWidgets.Text(
                              'Solenoid',
                              style: pdfWidgets.TextStyle(
                                fontWeight: pdfWidgets.FontWeight.bold,
                              ),
                            ),
                          ),
                          pdfWidgets.Container(
                            height: 20,
                            alignment: pdfWidgets.Alignment.center,
                            child: pdfWidgets.Text(
                              'Pressure',
                              style: pdfWidgets.TextStyle(
                                fontWeight: pdfWidgets.FontWeight.bold,
                              ),
                            ),
                          ),
                          pdfWidgets.Container(
                            height: 20,
                            alignment: pdfWidgets.Alignment.center,
                            child: pdfWidgets.Text(
                              'Remark',
                              style: pdfWidgets.TextStyle(
                                fontWeight: pdfWidgets.FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Loop through solenoid statuses
                      ...List.generate(
                        1,
                        (index) {
                          return pdfWidgets.TableRow(
                            children: [
                              pdfWidgets.Container(
                                height: 20,
                                alignment: pdfWidgets.Alignment.center,
                                child: pdfWidgets.Text('Solenoid ${index + 1}'),
                              ),
                              pdfWidgets.Container(
                                height: 20,
                                alignment: pdfWidgets.Alignment.center,
                                child: pdfWidgets.Text(
                                  '${filterInlet3bar ?? ''} bar',
                                ),
                              ),
                              pdfWidgets.Container(
                                height: 20,
                                alignment: pdfWidgets.Alignment.center,
                                child: pdfWidgets.Text(
                                  solenoid_status?[index] ?? '',
                                ),
                              ),
                            ],
                          );
                        },
                      ).toList(), // Don't forget to convert the iterable into a list
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
    //Page 2
    pdf.addPage(
      pdfWidgets.Page(
        build: (context) {
          return pdfWidgets.Container(
            child: pdfWidgets.Column(
              mainAxisAlignment: pdfWidgets.MainAxisAlignment.start,
              crossAxisAlignment: pdfWidgets.CrossAxisAlignment.start,
              children: [
                // Position Sensor Table
                pdfWidgets.Padding(
                  padding: const pdfWidgets.EdgeInsets.all(8.0),
                  child: pdfWidgets.Text(
                    'Position Sensor Test',
                    style: pdfWidgets.TextStyle(
                      fontSize: 14,
                      fontWeight: pdfWidgets.FontWeight.bold,
                    ),
                  ),
                ),
                pdfWidgets.Padding(
                  padding: const pdfWidgets.EdgeInsets.all(8),
                  child: pdfWidgets.Table(
                    border: pdfWidgets.TableBorder.all(
                      width: 1,
                      color: PdfColors.black,
                    ),
                    children: [
                      pdfWidgets.TableRow(
                        children: [
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                'Description',
                                style: pdfWidgets.TextStyle(
                                  fontWeight: pdfWidgets.FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                'Exp. Value',
                                style: pdfWidgets.TextStyle(
                                  fontWeight: pdfWidgets.FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                'Act. Value',
                                style: pdfWidgets.TextStyle(
                                  fontWeight: pdfWidgets.FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                'Remark',
                                style: pdfWidgets.TextStyle(
                                  fontWeight: pdfWidgets.FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Loop through solenoid statuses
                      ...List.generate(1, (index) {
                        return pdfWidgets.TableRow(
                          children: [
                            pdfWidgets.Expanded(
                              flex: 1,
                              child: pdfWidgets.Container(
                                height: 20,
                                alignment: pdfWidgets.Alignment.center,
                                child: pdfWidgets.Text(
                                  'Position Sensor ${index + 1}',
                                ),
                              ),
                            ),
                            pdfWidgets.Expanded(
                              flex: 1,
                              child: pdfWidgets.Container(
                                height: 20,
                                alignment: pdfWidgets.Alignment.center,
                                child: pdfWidgets.Text('3000 - 20000 mA'),
                              ),
                            ),
                            pdfWidgets.Expanded(
                              flex: 1,
                              child: pdfWidgets.Container(
                                height: 20,
                                alignment: pdfWidgets.Alignment.center,
                                child: pdfWidgets.Text(
                                  '${position_values?[index].toString()} mA',
                                ),
                              ),
                            ),
                            pdfWidgets.Expanded(
                              flex: 1,
                              child: pdfWidgets.Container(
                                height: 20,
                                alignment: pdfWidgets.Alignment.center,
                                child: pdfWidgets.Text(
                                  position_status?[index] ?? '',
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
                // Door Status
                pdfWidgets.Padding(
                  padding: const pdfWidgets.EdgeInsets.all(8.0),
                  child: pdfWidgets.Text(
                    'Door Status Check',
                    style: pdfWidgets.TextStyle(
                      fontSize: 14,
                      fontWeight: pdfWidgets.FontWeight.bold,
                    ),
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
                          'Door Open :',
                          style: pdfWidgets.TextStyle(
                            fontWeight: pdfWidgets.FontWeight.bold,
                          ),
                        ),
                      ),

                      // Replace with your actual battery percentage
                      pdfWidgets.SizedBox(
                        child: pdfWidgets.Text(
                          '${isDoorOpen ? 'Ok' : 'Faulty'}', //${isDoorClose ? 'OK' : 'Faulty'}
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
                          'Door Close :',
                          style: pdfWidgets.TextStyle(
                            fontWeight: pdfWidgets.FontWeight.bold,
                          ),
                        ),
                      ),

                      // Replace with your actual battery percentage
                      pdfWidgets.SizedBox(
                        child: pdfWidgets.Text(
                          '${isDoorClose ? 'OK' : 'Faulty'}',
                          style: pdfWidgets.TextStyle(
                            fontWeight: pdfWidgets.FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                //Lora Communication
                pdfWidgets.Padding(
                  padding: const pdfWidgets.EdgeInsets.all(8.0),
                  child: pdfWidgets.Text(
                    'Lora Communication Check',
                    style: pdfWidgets.TextStyle(
                      fontSize: 14,
                      fontWeight: pdfWidgets.FontWeight.bold,
                    ),
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
                          'LoRa Communication :',
                          style: pdfWidgets.TextStyle(
                            fontWeight: pdfWidgets.FontWeight.bold,
                          ),
                        ),
                      ),

                      // Replace with your actual battery percentage
                      pdfWidgets.SizedBox(
                        child: pdfWidgets.Text(
                          '${isLoraOK ? 'Ok' : 'Not Ok'}',
                          style: pdfWidgets.TextStyle(
                            fontWeight: pdfWidgets.FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                //BATTERY VOLATGE TRACKING
                pdfWidgets.Padding(
                  padding: const pdfWidgets.EdgeInsets.all(8.0),
                  child: pdfWidgets.Text(
                    'Battery voltage at the start of the test ${batteryVoltage ?? 0.0} V and after the test ${batteryVoltageAftet ?? 0.0} V.',
                    style: pdfWidgets.TextStyle(
                      fontSize: 14,
                      fontWeight: pdfWidgets.FontWeight.bold,
                    ),
                  ),
                ),

                pdfWidgets.Divider(),
                pdfWidgets.Row(
                  children: [
                    pdfWidgets.Text(
                      'Done By:  ',
                      style: pdfWidgets.TextStyle(
                        fontWeight: pdfWidgets.FontWeight.bold,
                      ),
                    ),
                    pdfWidgets.Text(username ?? ""),
                  ],
                ),
                pdfWidgets.SizedBox(height: 10),
                pdfWidgets.Row(
                  children: [
                    pdfWidgets.Text(
                      'Date: ',
                      style: pdfWidgets.TextStyle(
                        fontWeight: pdfWidgets.FontWeight.bold,
                      ),
                    ),
                    pdfWidgets.Text(Cdate ?? ""),
                  ],
                ),
                pdfWidgets.Row(
                  children: [
                    pdfWidgets.Text(
                      'Application Version:  ',
                      style: pdfWidgets.TextStyle(
                        fontWeight: pdfWidgets.FontWeight.bold,
                      ),
                    ),
                    pdfWidgets.Text("v2.8.3"),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    savePDF(pdf, context, widget.projectName ?? '', widget.data?.rmsNo ?? '');

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

  Future<void> savePDF(
    pdfWidgets.Document pdf,
    BuildContext context,
    String projectName,
    String rmsNo,
  ) async {
    try {
      String formattedDate = await FileUtils.getFormattedDate();
      Directory directory = await FileUtils.createDirectory(
        projectName,
        formattedDate,
        'RMS',
      );

      String pdfName = 'AutoDry $rmsNo-$projectName.pdf';
      File file = File('${directory.path}/$pdfName');

      await file.writeAsBytes(await pdf.save());

      print('PDF saved successfully');

      setState(() {
        filePath = file.path.replaceAll('/storage/emulated/0/', '');
        isSaved = true;
      });

      await FileUtils.showAlertDialog(
        context,
        'PDF Saved',
        'The PDF was saved successfully.',
      );
    } catch (e) {
      print('Error saving PDF: $e');
      await FileUtils.showAlertDialog(
        context,
        'Error',
        'An error occurred while saving the PDF.',
      );
    }
  }

  Future<void> saveDeviceDataToFile(
    DeviceData deviceData,
    String projectName,
    String rmsNo,
  ) async {
    try {
      String formattedDate = await FileUtils.getFormattedDate();
      Directory directory = await FileUtils.createDirectory(
        projectName,
        formattedDate,
        'RMS',
      );

      // String fileName = 'AutoDry $rmsNo-$projectName.json';
      // File file = File('${directory.path}/$fileName');
      String fileName =
          'AutoDry ${widget.data?.rmsNo ?? ''}-${widget.projectName ?? ''}.json';
      File file = File('${directory.path}/$fileName');

      String jsonData = jsonEncode(deviceData.toJson());
      await file.writeAsString(jsonData);

      print("Data successfully written to ${file.path}");
    } catch (e) {
      await FileUtils.showAlertDialog(
        context,
        'Error',
        'An error occurred while saving the JSON.',
      );
    }
  }

  Future<void> saveJSON() async {
    print("Starting saveJSON method...");
    String? saveDate = DateFormat(
      'dd-MMM-yyyy HH:mm:ss',
    ).format(deviceTime ?? DateTime.now());

    try {
      DeviceData deviceData = DeviceData(
        controllerType: controllerType,
        batteryVoltage: batteryVoltage,
        batteryVoltageAftet: batteryVoltageAftet,
        firmwareVersion: firmwareversion,
        solarVoltage: solarVoltage,
        isBatteryOk: isBatterOk,
        deviceTime: saveDate,
        macId: macId,
        // outletPT_Status_0bar: outletPT_Status_0bar,
        // outletPT_Values_0bar: outletPT_Values_0bar,
        // outletPT_Status_1bar: outletPT_Status_1bar,
        // outletPT_Values_1bar: outletPT_Values_1bar,
        filterInlet3bar: filterInlet3bar,
        filterOutlet3bar: filterOutlet3bar,
        filterInlet1bar: filterInlet1bar,
        filterOutlet1bar: filterOutlet1bar,
        filterInlet: filterInlet,
        filterOutlet: filterOutlet,
        isSolarOk: isSolarOk,
        solenoidStatus: solenoid_status,
        positionValues: position_values,
        positionStatus: position_status,
        isDoorClose: isDoorClose,
        isDoorOpen: isDoorOpen,
        isLoraOK: isLoraOK,
        // outletPT_Status_3bar: outletPT_Status_3bar,
        // outletPT_Values_3bar: outletPT_Values_3bar,
        inletPT_3bar: inletPT_3bar,
        inletPT_1bar: inletPT_1bar,
        inletButton: inletPT_0bar,
        outletButton: outletPT_0bar,
        outletPT_3bar: outletPT_3bar,
        outletPT_1bar: outletPT_1bar,
        doneBy: username,
        doneOn: DateFormat('dd-MMM-yyyy HH:mm:ss').format(DateTime.now()),
      );

      // Save data to file
      await saveDeviceDataToFile(
        deviceData,
        widget.projectName!,
        widget.data?.rmsNo ?? '',
      );
      print("Data saved to JSON file successfully.");
    } catch (e) {
      await FileUtils.showAlertDialog(
        context,
        'Error',
        'An error occurred while saving the JSON.',
      );
    }
  }
}
