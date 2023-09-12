// ignore_for_file: prefer_const_constructors, unnecessary_null_comparison, unused_local_variable, prefer_typing_uninitialized_variables, non_constant_identifier_names, unused_catch_stack, unused_field, prefer_final_fields, prefer_const_constructors_in_immutables, prefer_interpolation_to_compose_strings, use_build_context_synchronously, unnecessary_new, sized_box_for_whitespace, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables, file_names, unused_import

import 'dart:async';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:hex/hex.dart';
import 'package:intl/intl.dart';
import 'package:usb_serial/transaction.dart';
import 'package:usb_serial/usb_serial.dart';

class IOStatusScreen extends StatefulWidget {
  IOStatusScreen({Key? key}) : super(key: key);

  @override
  State<IOStatusScreen> createState() => _IOStatusScreenState();
}

class _IOStatusScreenState extends State<IOStatusScreen> {
  UsbPort? _port;
  String _status = "Idle";
  List<UsbDevice> _devices = [];
  List<String> _response = [];
  List<String> _serialData = [];
  double _progress = 0.0;
  String btntxt = 'Connect';
  var hexDecimalValue = '';

  StreamSubscription<Uint8List>? _dataSubscription;
  List<int> _dataBuffer = [];
  List<String> _data = [];

  TextEditingController _textController = TextEditingController();

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
              child: Text("INTG"),
              onPressed: _port == null
                  ? null
                  : () async {
                      if (_port == null) {
                        return;
                      }
                      _progress = 0.0;
                      _startTask(6).whenComplete(() => Navigator.pop(context));
                      getpop_loader(context);
                      String data = 'INTG'.toUpperCase() + "\r\n";
                      _response.clear();
                      _data.clear();
                      hexDecimalValue = '';
                      await _port!.write(Uint8List.fromList(data.codeUnits));
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
      if (_data.join().contains('BOCOM1')) {
        return Expanded(
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                children: [
                  buildDataRow('DateTime:', getDateTime().toString(),
                      'PT Fail:', getAlarms(2)),
                  buildDataRow('Temperature:', getTemprature().toString(),
                      'POS Fail:', getAlarms(3)),
                  buildDataRow('AI 1:', getAI1().toString(), 'AI 2:',
                      getAI2().toString()),
                  buildDataRow('Emergency Stop:', getEmergencystrop(),
                      'Packet Idication:', getPocketIndication()),
                  buildDataRow('Batter Voltage:', getBatterVoltage().toString(),
                      'Solar Voltage:', getSOLARVoltage().toString()),
                  buildDataRow(
                      'Position:', getPostion(), 'PFCMD Flow:', getflowvalue()),
                  buildDataRow('Firmware Version:', getFirmwareVersion(),
                      'Output Bar:', getOutletbar()),
                  buildDataRow('Run Time:', getruntime(), 'Operation Mode:',
                      getOperationMode()),
                  buildDataRow('DI 1:', getAlarms(0).toString(),
                      'Filter Choke:', getAlarms(5).toString()),
                  buildDataRow('DI 2:', getAlarms(1).toString(),
                      'Flow Meter\n Volume:', Flowmeter_Volume().toString()),
                  buildDataRow('HIGH TEMP:', getAlarms(4).toString(),
                      'LOW BATTERY VOLTAGE:', getAlarms(6).toString()),
                  buildDataRow('Low inlet Pressure:', getAlarms(7).toString(),
                      'High Outlet Pressure:', getAlarms(8).toString()),
                  buildDataRow('All Valve Open:', getAlarms(9).toString(),
                      'Any valve Closed:', getAlarms(10).toString()),
                  buildDataRow('Control Mode:', getControllMode(),
                      'Any valve Closed:', getAlarms(10).toString()),
                  buildDataRow('Daily Vol:', getDailyvol(), '', ''),
                ],
              ),
            ),
          ),
        );
      } else if (_data.join().contains('BOCOM6')) {
        return Expanded(
          child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  children: [
                    // Text(_data.join()),
                    Card(
                      elevation: 10,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          /*ListTile(
                  title: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.lightBlue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      width: double.infinity,
                      padding: EdgeInsets.all(10.0),
                      child: Center(
                        child: Text(
                          '6 ',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                 */
                          Row(children: [
                            Padding(
                              padding: const EdgeInsets.all(9.0),
                              child: Text(
                                'Datetime :',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              child: Text(getDateTime()),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(9.0),
                              child: Text(
                                'Temprature :',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              width: 50,
                              child: Text(getTemprature(),
                                  style: TextStyle(fontSize: 13)),
                            ),
                          ]),
                          Row(children: [
                            Padding(
                              padding: const EdgeInsets.all(9.0),
                              child: Text(
                                'Battery Voltage :',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                                width: 40,
                                child: Text(getBatterVoltage().toString())),
                            Padding(
                              padding: const EdgeInsets.all(9.0),
                              child: Text(
                                'Solar Voltage :',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                                width: 40,
                                child:
                                    Text(getSOLARVoltage().toString() + ' V')),
                          ]),
                          Row(children: [
                            Padding(
                              padding: const EdgeInsets.all(9.0),
                              child: Text(
                                'AI 1 :',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              width: 120,
                              child: Text(getAI1().toString()),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(9.0),
                              child: Text(
                                'AI 2 :',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              child: Text(getAI2().toString()),
                            ),
                          ]),
                          Row(children: [
                            Padding(
                              padding: const EdgeInsets.all(9.0),
                              child: Text(
                                'Packet Indication :',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              width: 30,
                              child: Text(getPocketIndication().toString()),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(9.0),
                              child: Text(
                                'POS Fail :',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              width: 30,
                              child: Text(getAlarms(3).toString()),
                            ),
                          ]),
                          Row(children: [
                            Padding(
                              padding: const EdgeInsets.all(9.0),
                              child: Text(
                                'Firmware Version :',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              width: 30,
                              child: Text(getFirmwareVersion().toString()),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(9.0),
                              child: Text(
                                'PT Fail :',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              width: 50,
                              child: Text(getAlarms(2)),
                            ),
                          ]),
                        ],
                      ),
                    ),

                    Card(
                      elevation: 10,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            title: Center(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.lightBlue,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                width: double.infinity,
                                padding: EdgeInsets.all(10.0),
                                child: Center(
                                  child: Text(
                                    'PFCMD 1 ',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Row(children: [
                            Padding(
                              padding: const EdgeInsets.all(9.0),
                              child: Text(
                                'Flow :',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              child: Text(getflowvalue()),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(9.0),
                              child: Text(
                                'Outlet PT :',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              width: 50,
                              child: Text(getOutletbar()),
                            ),
                          ]),
                          Row(children: [
                            Padding(
                              padding: const EdgeInsets.all(9.0),
                              child: Text(
                                'Postion :',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                                width: 40,
                                child: Text(getPostion().toString())),
                            Padding(
                              padding: const EdgeInsets.all(9.0),
                              child: Text(
                                'Daily Volume :',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                                width: 40,
                                child: Text(getDailyvol().toString())),
                          ]),
                          Row(children: [
                            Padding(
                              padding: const EdgeInsets.all(9.0),
                              child: Text(
                                'Run Time',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              width: 120,
                              child: Text(getruntime().toString()),
                            ),
                          ]),
                        ],
                      ),
                    ),
                    Card(
                      elevation: 10,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            title: Center(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.lightBlue,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                width: double.infinity,
                                padding: EdgeInsets.all(10.0),
                                child: Center(
                                  child: Text(
                                    'PFCMD 2 ',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Row(children: [
                            Padding(
                              padding: const EdgeInsets.all(9.0),
                              child: Text(
                                'Flow :',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              child: Text(getflowvalue_pfcmd_2()),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(9.0),
                              child: Text(
                                'Outlet PT :',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              width: 50,
                              child: Text(getOutletbar_pfcmd_2()),
                            ),
                          ]),
                          Row(children: [
                            Padding(
                              padding: const EdgeInsets.all(9.0),
                              child: Text(
                                'Postion :',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                                width: 40,
                                child: Text(getPostion_pfcmd_2().toString())),
                            Padding(
                              padding: const EdgeInsets.all(9.0),
                              child: Text(
                                'Daily Volume :',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                                width: 40,
                                child: Text(getDailyvol_pfcmd_2().toString())),
                          ]),
                          Row(children: [
                            Padding(
                              padding: const EdgeInsets.all(9.0),
                              child: Text(
                                'Run Time',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              width: 120,
                              child: Text(getruntime_pfcmd_2().toString()),
                            ),
                          ]),
                        ],
                      ),
                    ),
                    Card(
                      elevation: 10,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            title: Center(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.lightBlue,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                width: double.infinity,
                                padding: EdgeInsets.all(10.0),
                                child: Center(
                                  child: Text(
                                    'PFCMD 3 ',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Row(children: [
                            Padding(
                              padding: const EdgeInsets.all(9.0),
                              child: Text(
                                'Flow :',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              child: Text(getflowvalue_pfcmd_3()),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(9.0),
                              child: Text(
                                'Outlet PT :',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              width: 50,
                              child: Text(getOutletbar_pfcmd_3()),
                            ),
                          ]),
                          Row(children: [
                            Padding(
                              padding: const EdgeInsets.all(9.0),
                              child: Text(
                                'Postion :',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                                width: 40,
                                child: Text(getPostion_pfcmd_3().toString())),
                            Padding(
                              padding: const EdgeInsets.all(9.0),
                              child: Text(
                                'Daily Volume :',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                                width: 40,
                                child: Text(getDailyvol_pfcmd_3().toString())),
                          ]),
                          Row(children: [
                            Padding(
                              padding: const EdgeInsets.all(9.0),
                              child: Text(
                                'Run Time',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              width: 120,
                              child: Text(getruntime_pfcmd_3().toString()),
                            ),
                          ]),
                        ],
                      ),
                    ),
                    Card(
                      elevation: 10,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            title: Center(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.lightBlue,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                width: double.infinity,
                                padding: EdgeInsets.all(10.0),
                                child: Center(
                                  child: Text(
                                    'PFCMD 4 ',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Row(children: [
                            Padding(
                              padding: const EdgeInsets.all(9.0),
                              child: Text(
                                'Flow :',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              child: Text(getflowvalue_pfcmd_4()),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(9.0),
                              child: Text(
                                'Outlet PT :',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              width: 50,
                              child: Text(getOutletbar_pfcmd_4()),
                            ),
                          ]),
                          Row(children: [
                            Padding(
                              padding: const EdgeInsets.all(9.0),
                              child: Text(
                                'Postion :',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                                width: 40,
                                child: Text(getPostion_pfcmd_4().toString())),
                            Padding(
                              padding: const EdgeInsets.all(9.0),
                              child: Text(
                                'Daily Volume :',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                                width: 40,
                                child: Text(getDailyvol_pfcmd_4().toString())),
                          ]),
                          Row(children: [
                            Padding(
                              padding: const EdgeInsets.all(9.0),
                              child: Text(
                                'Run Time',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              width: 120,
                              child: Text(getruntime_pfcmd_4().toString()),
                            ),
                          ]),
                        ],
                      ),
                    ),
                    Card(
                      elevation: 10,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            title: Center(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.lightBlue,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                width: double.infinity,
                                padding: EdgeInsets.all(10.0),
                                child: Center(
                                  child: Text(
                                    'PFCMD 5 ',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Row(children: [
                            Padding(
                              padding: const EdgeInsets.all(9.0),
                              child: Text(
                                'Flow :',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              child: Text(getflowvalue_pfcmd_5()),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(9.0),
                              child: Text(
                                'Outlet PT :',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              width: 50,
                              child: Text(getOutletbar_pfcmd_5()),
                            ),
                          ]),
                          Row(children: [
                            Padding(
                              padding: const EdgeInsets.all(9.0),
                              child: Text(
                                'Postion :',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                                width: 40,
                                child: Text(getPostion_pfcmd_5().toString())),
                            Padding(
                              padding: const EdgeInsets.all(9.0),
                              child: Text(
                                'Daily Volume :',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                                width: 40,
                                child: Text(getDailyvol_pfcmd_5().toString())),
                          ]),
                          Row(children: [
                            Padding(
                              padding: const EdgeInsets.all(9.0),
                              child: Text(
                                'Run Time',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              width: 120,
                              child: Text(getruntime_pfcmd_5().toString()),
                            ),
                          ]),
                        ],
                      ),
                    ),
                    Card(
                      elevation: 10,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            title: Center(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.lightBlue,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                width: double.infinity,
                                padding: EdgeInsets.all(10.0),
                                child: Center(
                                  child: Text(
                                    'PFCMD 6 ',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Row(children: [
                            Padding(
                              padding: const EdgeInsets.all(9.0),
                              child: Text(
                                'Flow :',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              child: Text(getflowvalue_pfcmd_6()),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(9.0),
                              child: Text(
                                'Outlet PT :',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              width: 50,
                              child: Text(getOutletbar_pfcmd_6()),
                            ),
                          ]),
                          Row(children: [
                            Padding(
                              padding: const EdgeInsets.all(9.0),
                              child: Text(
                                'Postion :',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                                width: 40,
                                child: Text(getPostion_pfcmd_6().toString())),
                            Padding(
                              padding: const EdgeInsets.all(9.0),
                              child: Text(
                                'Daily Volume :',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                                width: 40,
                                child: Text(getDailyvol_pfcmd_6().toString())),
                          ]),
                          Row(children: [
                            Padding(
                              padding: const EdgeInsets.all(9.0),
                              child: Text(
                                'Run Time',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              width: 120,
                              child: Text(getruntime_pfcmd_6().toString()),
                            ),
                          ]),
                        ],
                      ),
                    ),
                    Card(
                      elevation: 10,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            title: Center(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.lightBlue,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                width: double.infinity,
                                padding: EdgeInsets.all(10.0),
                                child: Center(
                                  child: Text(
                                    'PFCMD Mode data ',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Row(children: [
                            Padding(
                              padding: const EdgeInsets.all(9.0),
                              child: Text(
                                'PFCMD 1 :',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              child: Text(pfcmd_modedata_1().toString()),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(9.0),
                              child: Text(
                                'PFCMD 2 :',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              child: Text(pfcmd_modedata_2().toString()),
                            )
                          ]),
                          Row(children: [
                            Padding(
                              padding: const EdgeInsets.all(9.0),
                              child: Text(
                                'PFCMD 3 :',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              child: Text(pfcmd_modedata_3().toString()),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(9.0),
                              child: Text(
                                'PFCMD 4 :',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              child: Text(pfcmd_modedata_4().toString()),
                            )
                          ]),
                          Row(children: [
                            Padding(
                              padding: const EdgeInsets.all(9.0),
                              child: Text(
                                'PFCMD 5 :',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              child: Text(pfcmd_modedata_5().toString()),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(9.0),
                              child: Text(
                                'PFCMD 6 :',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              child: Text(pfcmd_modedata_6().toString()),
                            )
                          ]),
                        ],
                      ),
                    ),
                    /*Card(
                      elevation: 5,
                      child: Container(
                        height: 120,
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'DateTime: ',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              border: Border.all(
                                                  color: Colors.black)),
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.all(2.0),
                                            child: Text(getDateTime()),
                                          ))
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Battery Voltage: ',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              border: Border.all(
                                                  color: Colors.black)),
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.all(2.0),
                                            child: Text(getBatterVoltage()
                                                .toString()),
                                          ))
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'AI 1: ',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              border: Border.all(
                                                  color: Colors.black)),
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.all(2.0),
                                            child: Text(getAI1().toString()),
                                          ))
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        'Packet Idication: ',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              border: Border.all(
                                                  color: Colors.black)),
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.all(2.0),
                                            child: Text(getPocketIndication()
                                                .toString()),
                                          ))
                                    ],
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Temperature: ',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              border: Border.all(
                                                  color: Colors.black)),
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.all(2.0),
                                            child: Text(getTemprature()),
                                          ))
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        'Solar Voltage: ',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              border: Border.all(
                                                  color: Colors.black)),
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.all(2.0),
                                            child: Text(
                                                getSOLARVoltage().toString()),
                                          ))
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        'AI 2: ',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              border: Border.all(
                                                  color: Colors.black)),
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.all(2.0),
                                            child: Text(getAI2().toString()),
                                          ))
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        'Firmware Version: ',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              border: Border.all(
                                                  color: Colors.black)),
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.all(2.0),
                                            child: Text(getFirmwareVersion()),
                                          ))
                                    ],
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(width: 1),
                          borderRadius: BorderRadius.circular(5)),
                      height: 150,
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Column(
                          children: [
                            Center(
                              child: Text('PFCMD 1'),
                            ),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Flow: ',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                border: Border.all(
                                                    color: Colors.black)),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child: Text(getflowvalue()),
                                            ))
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Position: ',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                border: Border.all(
                                                    color: Colors.black)),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child: Text(
                                                  getPostion().toString()),
                                            ))
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'AI 1: ',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                border: Border.all(
                                                    color: Colors.black)),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child:
                                                  Text(getAI1().toString()),
                                            ))
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          'Packet Idication: ',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                border: Border.all(
                                                    color: Colors.black)),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child: Text(
                                                  getPocketIndication()
                                                      .toString()),
                                            ))
                                      ],
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Temperature: ',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                border: Border.all(
                                                    color: Colors.black)),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child: Text(getTemprature()),
                                            ))
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          'Solar Voltage: ',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                border: Border.all(
                                                    color: Colors.black)),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child: Text(getSOLARVoltage()
                                                  .toString()),
                                            ))
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          'AI 2: ',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                border: Border.all(
                                                    color: Colors.black)),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child:
                                                  Text(getAI2().toString()),
                                            ))
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          'Firmware Version: ',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                border: Border.all(
                                                    color: Colors.black)),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child:
                                                  Text(getFirmwareVersion()),
                                            ))
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    )*/
                  ],
                ),
              )),
        );
      } else {
        return Container(
          child: Center(
            child: Text('Command Recived Ended'),
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

  Widget buildDataRow(
      String label1, String value1, String label2, String value2) {
    return Container(
      decoration: BoxDecoration(border: Border.all(width: 1)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            flex: 3,
            child: Text(label1),
          ),
          Expanded(
            flex: 3,
            child: Text(value1),
          ),
          Expanded(
            flex: 3,
            child: Text(label2),
          ),
          Expanded(
            flex: 1,
            child: Text(value2),
          ),
        ],
      ),
    );
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
    String ai1;
    try {
      subString3 = hexDecimalValue.substring(20, 24);
      int decimal = int.parse(subString3, radix: 16);
      ai1 = (decimal / 100).toString();
    } catch (_, ex) {
      ai1 = '0.0';
    }
    return ai1;
  }

  getAI2() {
    var subString3;
    String ai2;
    try {
      subString3 = hexDecimalValue.substring(24, 28);
      int decimal = int.parse(subString3, radix: 16);
      ai2 = (decimal / 100).toString();
    } catch (_, ex) {
      ai2 = '0.0';
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

  String getPostion() {
    var subString3;
    String postionvalue;
    try {
      subString3 = hexDecimalValue.substring(42, 46);
      int decimal = int.parse(subString3, radix: 16);
      postionvalue = (decimal / 100).toString();
    } catch (_, ex) {
      postionvalue = '0.0 %';
    }
    return postionvalue + ' %';
  }

  String getflowvalue() {
    var subString3;
    String flowvalue;
    try {
      subString3 = hexDecimalValue.substring(46, 50);
      int decimal = int.parse(subString3, radix: 16);
      flowvalue = (decimal / 100).toString();
    } catch (_, ex) {
      flowvalue = '0.0 m³';
    }
    return flowvalue + ' m³';
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
      flowvalue = '0.0 m³';
    }
    return flowvalue + ' m³';
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

  String getruntime_pfcmd_2() {
    var subString3;
    String runtime;
    try {
      subString3 = hexDecimalValue.substring(75, 78);
      int decimal = int.parse(subString3, radix: 16);
      runtime = (decimal / 100).toString();
    } catch (_, ex) {
      runtime = '0.0';
    }
    return runtime;
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
      flowvalue = '0.0 m³';
    }
    return flowvalue + ' m³';
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

  String getruntime_pfcmd_3() {
    var subString3;
    String runtime;
    try {
      subString3 = hexDecimalValue.substring(94, 98);
      int decimal = int.parse(subString3, radix: 16);
      runtime = (decimal / 100).toString();
    } catch (_, ex) {
      runtime = '0.0';
    }
    return runtime;
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
      flowvalue = '0.0 m³';
    }
    return flowvalue + ' m³';
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

  String getruntime_pfcmd_4() {
    var subString3;
    String runtime;
    try {
      subString3 = hexDecimalValue.substring(114, 118);
      int decimal = int.parse(subString3, radix: 16);
      runtime = (decimal / 100).toString();
    } catch (_, ex) {
      runtime = '0.0';
    }
    return runtime;
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
      flowvalue = '0.0 m³';
    }
    return flowvalue + ' m³';
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

  String getruntime_pfcmd_5() {
    var subString3;
    String runtime;
    try {
      subString3 = hexDecimalValue.substring(134, 138);
      int decimal = int.parse(subString3, radix: 16);
      runtime = (decimal / 100).toString();
    } catch (_, ex) {
      runtime = '0.0';
    }
    return runtime;
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
      flowvalue = '0.0 m³';
    }
    return flowvalue + ' m³';
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

  String getruntime_pfcmd_6() {
    var subString3;
    String runtime;
    try {
      subString3 = hexDecimalValue.substring(154, 158);
      int decimal = int.parse(subString3, radix: 16);
      runtime = (decimal / 100).toString();
    } catch (_, ex) {
      runtime = '0.0';
    }
    return runtime;
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
