// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_final_fields, non_constant_identifier_names, unused_field, sort_child_properties_last, prefer_interpolation_to_compose_strings, depend_on_referenced_packages, prefer_const_constructors_in_immutables, unused_import, avoid_print

import 'dart:async';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_usb2/Widget/ExapndedTile.dart';

import 'package:usb_serial/transaction.dart';
import 'package:usb_serial/usb_serial.dart';
import 'package:percent_indicator/percent_indicator.dart';

class IOConfigurationPage extends StatefulWidget {
  IOConfigurationPage({Key? key}) : super(key: key);

  @override
  State<IOConfigurationPage> createState() => _IOConfigurationPageState();
}

class _IOConfigurationPageState extends State<IOConfigurationPage> {
  UsbPort? _port;
  String _status = "Idle";
  List<UsbDevice> _devices = [];
  List<String> _serialData = [];
  List<String> _response = [];
  double _progress = 0.0;
  var hexDecimalValue = '';
  bool showbutton = false;
// inlet pt before
  TextEditingController _inlet_actual_value_before_controller =
      TextEditingController();
  TextEditingController _inlet_actual_count_before_controller =
      TextEditingController();
  TextEditingController inlet_before_Range_Min_controller =
      TextEditingController();
  TextEditingController inlet_before_Range_Max_controller =
      TextEditingController();
  TextEditingController inlet_before_Raw_Min_controller =
      TextEditingController();
  TextEditingController inlet_before_Raw_Max_controller =
      TextEditingController();
// inlet pt after
  TextEditingController _inlet_actual_value_after_controller =
      TextEditingController();
  TextEditingController _inlet_actual_count_after_controller =
      TextEditingController();
  TextEditingController inlet_after_Range_Min_controller =
      TextEditingController();
  TextEditingController inlet_after_Range_Max_controller =
      TextEditingController();
  TextEditingController inlet_after_Raw_Min_controller =
      TextEditingController();
  TextEditingController inlet_after_Raw_Max_controller =
      TextEditingController();
// outlet pt 1
  TextEditingController outlet_value_after_controller = TextEditingController();
  TextEditingController outlet_actual_count_after_controller =
      TextEditingController();
  TextEditingController outlet_Range_Min_controller = TextEditingController();
  TextEditingController oultet_Range_Max_controller = TextEditingController();
  TextEditingController outlet_Raw_Min_controller = TextEditingController();
  TextEditingController outlet_Raw_Max_controller = TextEditingController();

// outlet pt 2
  TextEditingController outlet_2_value_after_controller =
      TextEditingController();
  TextEditingController outlet_2_actual_count_after_controller =
      TextEditingController();
  TextEditingController outlet_2_Range_Min_controller = TextEditingController();
  TextEditingController oultet_2_Range_Max_controller = TextEditingController();
  TextEditingController outlet_2_Raw_Min_controller = TextEditingController();
  TextEditingController outlet_2_Raw_Max_controller = TextEditingController();

  // outlet pt 3
  TextEditingController outlet_3_value_controller = TextEditingController();
  TextEditingController outlet_3_actual_count_controller =
      TextEditingController();
  TextEditingController outlet_3_Range_Min_controller = TextEditingController();
  TextEditingController oultet_3_Range_Max_controller = TextEditingController();
  TextEditingController outlet_3_Raw_Min_controller = TextEditingController();
  TextEditingController outlet_3_Raw_Max_controller = TextEditingController();

  // outlet pt 4
  TextEditingController outlet_4_value_controller = TextEditingController();
  TextEditingController outlet_4_actual_count_controller =
      TextEditingController();
  TextEditingController outlet_4_Range_Min_controller = TextEditingController();
  TextEditingController oultet_4_Range_Max_controller = TextEditingController();
  TextEditingController outlet_4_Raw_Min_controller = TextEditingController();
  TextEditingController outlet_4_Raw_Max_controller = TextEditingController();

  // outlet pt 5
  TextEditingController outlet_5_value_controller = TextEditingController();
  TextEditingController outlet_5_actual_count_controller =
      TextEditingController();
  TextEditingController outlet_5_Range_Min_controller = TextEditingController();
  TextEditingController oultet_5_Range_Max_controller = TextEditingController();
  TextEditingController outlet_5_Raw_Min_controller = TextEditingController();
  TextEditingController outlet_5_Raw_Max_controller = TextEditingController();

  // outlet pt 6
  TextEditingController outlet_6_value_controller = TextEditingController();
  TextEditingController outlet_6_actual_count_controller =
      TextEditingController();
  TextEditingController outlet_6_Range_Min_controller = TextEditingController();
  TextEditingController oultet_6_Range_Max_controller = TextEditingController();
  TextEditingController outlet_6_Raw_Min_controller = TextEditingController();
  TextEditingController outlet_6_Raw_Max_controller = TextEditingController();

  // position sensor pfcmd6 pos 1
  TextEditingController position_value_1_controller = TextEditingController();
  TextEditingController postion_actual_1_count_controller =
      TextEditingController();
  TextEditingController position_1_Range_Min_controller =
      TextEditingController();
  TextEditingController position_1_Range_Max_controller =
      TextEditingController();
  TextEditingController position_1_Raw_Min_controller = TextEditingController();
  TextEditingController position_1_Raw_Max_controller = TextEditingController();

  // position sensor pfcmd6 pos 2
  TextEditingController position_value_2_controller = TextEditingController();
  TextEditingController postion_actual_2_count_controller =
      TextEditingController();
  TextEditingController position_2_Range_Min_controller =
      TextEditingController();
  TextEditingController position_2_Range_Max_controller =
      TextEditingController();
  TextEditingController position_2_Raw_Min_controller = TextEditingController();
  TextEditingController position_2_Raw_Max_controller = TextEditingController();

  // position sensor pfcmd6 pos 3
  TextEditingController position_value_3_controller = TextEditingController();
  TextEditingController postion_actual_3_count_controller =
      TextEditingController();
  TextEditingController position_3_Range_Min_controller =
      TextEditingController();
  TextEditingController position_3_Range_Max_controller =
      TextEditingController();
  TextEditingController position_3_Raw_Min_controller = TextEditingController();
  TextEditingController position_3_Raw_Max_controller = TextEditingController();

  // position sensor pfcmd6 pos 4
  TextEditingController position_value_4_controller = TextEditingController();
  TextEditingController postion_actual_4_count_controller =
      TextEditingController();
  TextEditingController position_4_Range_Min_controller =
      TextEditingController();
  TextEditingController position_4_Range_Max_controller =
      TextEditingController();
  TextEditingController position_4_Raw_Min_controller = TextEditingController();
  TextEditingController position_4_Raw_Max_controller = TextEditingController();

  // position sensor pfcmd6 pos 5
  TextEditingController position_value_5_controller = TextEditingController();
  TextEditingController postion_actual_5_count_controller =
      TextEditingController();
  TextEditingController position_5_Range_Min_controller =
      TextEditingController();
  TextEditingController position_5_Range_Max_controller =
      TextEditingController();
  TextEditingController position_5_Raw_Min_controller = TextEditingController();
  TextEditingController position_5_Raw_Max_controller = TextEditingController();

  // position sensor pfcmd6 pos 6
  TextEditingController position_value_6_controller = TextEditingController();
  TextEditingController postion_actual_6_count_controller =
      TextEditingController();
  TextEditingController position_6_Range_Min_controller =
      TextEditingController();
  TextEditingController position_6_Range_Max_controller =
      TextEditingController();
  TextEditingController position_6_Raw_Min_controller = TextEditingController();
  TextEditingController position_6_Raw_Max_controller = TextEditingController();
  // position sensor
  TextEditingController position_value__controller = TextEditingController();
  TextEditingController postion_actual_count_controller =
      TextEditingController();
  TextEditingController position_Range_Min_controller = TextEditingController();
  TextEditingController position_Range_Max_controller = TextEditingController();
  TextEditingController position_Raw_Min_controller = TextEditingController();
  TextEditingController position_Raw_Max_controller = TextEditingController();

// doors
  TextEditingController door1 = TextEditingController();
  TextEditingController door2 = TextEditingController();

  TextEditingController _textController = TextEditingController();

// inlet pt 1
  TextEditingController _inlet_1_actual_value_controller =
      TextEditingController();
  TextEditingController _inlet__1_actual_count_controller =
      TextEditingController();
  TextEditingController inlet_1_Range_Min_controller = TextEditingController();
  TextEditingController inlet_1_Range_Max_controller = TextEditingController();
  TextEditingController inlet_1_Raw_Min_controller = TextEditingController();
  TextEditingController inlet_1_Raw_Max_controller = TextEditingController();
  // String inlet_1_range_min = '';
  // String inlet_1_range_max = '';

// inlet pt 2
  TextEditingController _inlet_2_actual_value_controller =
      TextEditingController();
  TextEditingController _inlet__2_actual_count_controller =
      TextEditingController();
  TextEditingController inlet_2_Range_Min_controller = TextEditingController();
  TextEditingController inlet_2_Range_Max_controller = TextEditingController();
  TextEditingController inlet_2_Raw_Min_controller = TextEditingController();
  TextEditingController inlet_2_Raw_Max_controller = TextEditingController();

  // outlet pt
  TextEditingController outlet_1_value_controller = TextEditingController();
  TextEditingController outlet_1_actual_count_controller =
      TextEditingController();
  TextEditingController outlet_1_Range_Min_controller = TextEditingController();
  TextEditingController oultet_1_Range_Max_controller = TextEditingController();
  TextEditingController outlet_1_Raw_Min_controller = TextEditingController();
  TextEditingController outlet_1_Raw_Max_controller = TextEditingController();

  String btntxt = 'Connect';
// set all variables
  String before_inlet_range_min = '';
  String before_inlet_range_max = '';

  String after_inlet_range_min = '';
  String after_inlet_range_max = '';

  String before_outlet_range_min = '';
  String before_outlet_range_max = '';

  String before_pos_raw_min = '';
  String before_pos_raw_max = '';

  StreamSubscription<String>? _subscription;
  Transaction<String>? _transaction;
  int percent = 0;

  String? deviceType;

  StreamSubscription<Uint8List>? _dataSubscription;
  List<int> _dataBuffer = [];
  List<String> _data = [];
  List<String> data_cards = [];
  Future<bool> _connectTo(UsbDevice? device) async {
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
      if (completeMessage.contains("INTG")) {
        data_cards.add(completeMessage);
        print(data_cards);
      }
      // data_cards.add(completeMessage);
    });
    if (_data.join().contains('INTG')) {
      data_cards.join();
      hexDecimalValue =
          reverseString(reverseString(_response.join()).substring(0, 70));
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
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: Color.fromRGBO(255, 255, 255, 1),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final device in _devices)
              ListTile(
                title: Text(device.productName ?? 'Unknown Device'),
                subtitle:
                    Text(device.manufacturerName ?? 'Unknown Manufacturer'),
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
            if (_port != null)
              Container(
                padding: EdgeInsets.all(8.0),
                child: ElevatedButton(
                  child: Text("SINM"),
                  onPressed: _port == null
                      ? null
                      : () async {
                          if (_port == null) {
                            return;
                          }
                          _progress = 0.0;
                          _startTask(6)
                              .whenComplete(() => Navigator.pop(context));
                          getpop_loader(context);
                          String data = 'SINM'.toUpperCase() + "\r\n";
                          _response.clear();
                          _data.clear();
                          hexDecimalValue = '';
                          await _port!
                              .write(Uint8List.fromList(data.codeUnits));
                          await getSiteName();
                        },
                ),
              ),
            getWidget()
          ],
        ),
      ),
    );
  }

  getWidget() {
    try {
      if (deviceType!.contains('BOCOM1')) {
        return Padding(
          padding: EdgeInsets.all(2),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _progress = 0.0;
                        _startTask(130);
                        getpop_loader(context);
                        Future.delayed(Duration(seconds: 130), () {
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
                    // ElevatedButton(
                    //   onPressed: () {},
                    //   child:
                    //       Text('Set All', style: TextStyle(color: Colors.white)),
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: Colors.blue,
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(
                    //           5), // Set border radius to 0 for square shape
                    //     ),
                    //   ),
                    // )
                  ],
                ),
              ),
              Container(
                color: Colors.white,
                height: 60,
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        'DI :',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 100,
                        child: Container(
                          height: 40,
                          child: TextField(
                            controller: door1,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 20, color: Colors.greenAccent),
                                // borderRadius: BorderRadius.circular(50.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: Container(
                        height: 40,
                        child: TextField(
                          controller: door2,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 3, color: Colors.greenAccent),
                              // borderRadius: BorderRadius.circular(50.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 5),
                    ElevatedButton(
                      onPressed: _port == null
                          ? null
                          : () async {
                              _progress = 0.0;
                              _startTask(14);
                              getpop_loader(context);
                              Future.delayed(Duration(seconds: 16), () {
                                Navigator.pop(context); //pop dialog
                              });

                              await getdoors();
                            },
                      child: Text('Get', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              5), // Set border radius to 0 for square shape
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Container(
                  width: double.infinity,
                  child: Text(
                    'Analog Input Status',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.start,
                  ),
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
                              'Inlet PT Before',
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
                          'Actual Value :',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          controller: _inlet_actual_value_before_controller,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          style:
                              TextStyle(color: Color.fromARGB(255, 45, 51, 74)),
                        ),
                      ),
                      // SizedBox(width: 5),
                      Text('mA'),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 30,
                          // width: 55,
                          child: ElevatedButton(
                              onPressed: _port == null
                                  ? null
                                  : () {
                                      _progress = 0.0;
                                      _startTask(16);
                                      getpop_loader(context);
                                      Future.delayed(Duration(seconds: 14), () {
                                        Navigator.pop(context); //pop dialog
                                      });

                                      get_Inlet_pt_before_actual_val();
                                    },
                              child: Text('Get')),
                        ),
                      ),
                    ]),
                    Row(children: [
                      Padding(
                        padding: const EdgeInsets.all(9.0),
                        child: Text(
                          'Actual Count :',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          controller: _inlet_actual_count_before_controller,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          style:
                              TextStyle(color: Color.fromARGB(255, 45, 51, 74)),
                        ),
                      ),
                    ]),
                    Row(children: [
                      Padding(
                        padding: const EdgeInsets.all(9.0),
                        child: Text(
                          'Range :',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          controller: inlet_before_Range_Min_controller,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          style:
                              TextStyle(color: Color.fromARGB(255, 45, 51, 74)),
                        ),
                      ),
                      Text('Min'),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 30,
                          // width: 55,
                          child: ElevatedButton(
                              onPressed: _port == null
                                  ? null
                                  : () {
                                      _progress = 0.0;
                                      _startTask(16);
                                      getpop_loader(context);
                                      Future.delayed(Duration(seconds: 16), () {
                                        Navigator.pop(context); //pop dialog
                                      });

                                      get_Inlet_before_range();
                                    },
                              child: Text('Get')),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 30,
                          // width: 55,
                          child: ElevatedButton(
                              onPressed: _port == null
                                  ? null
                                  : () {
                                      _progress = 0.0;
                                      _startTask(16);
                                      getpop_loader(context);
                                      Future.delayed(Duration(seconds: 18), () {
                                        Navigator.pop(context); //pop dialog
                                      });

                                      Set_Inlet_before_range();
                                    },
                              child: Text('Set')),
                        ),
                      )
                    ]),
                    Row(children: [
                      Padding(
                        padding: const EdgeInsets.all(9.0),
                        child: Text(
                          'Range :',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          controller: inlet_before_Range_Max_controller,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          style:
                              TextStyle(color: Color.fromARGB(255, 45, 51, 74)),
                        ),
                      ),
                      Text('Max')
                    ]),
                    Row(children: [
                      Padding(
                        padding: const EdgeInsets.all(9.0),
                        child: Text(
                          'Raw Count:',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          enabled: false,
                          controller: inlet_before_Raw_Min_controller,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(color: Color.fromARGB(255, 45, 51, 74)),
                        ),
                      ),
                      Text('Min'),
                    ]),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(children: [
                        Text(
                          'Raw Count:',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(
                          width: 80,
                          child: TextField(
                            enabled: false,
                            controller: inlet_before_Raw_Max_controller,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                                color: Color.fromARGB(255, 45, 51, 74)),
                          ),
                        ),
                        Text('Max'),
                      ]),
                    ),
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
                              'Inlet PT After',
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
                          'Actual Value :',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          controller: _inlet_actual_value_after_controller,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          style:
                              TextStyle(color: Color.fromARGB(255, 45, 51, 74)),
                        ),
                      ),
                      // SizedBox(width: 5),
                      Text('mA'),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 30,
                          // width: 55,
                          child: ElevatedButton(
                              onPressed: _port == null
                                  ? null
                                  : () {
                                      _progress = 0.0;
                                      _startTask(16);
                                      getpop_loader(context);
                                      Future.delayed(Duration(seconds: 16), () {
                                        Navigator.pop(context); //pop dialog
                                      });

                                      get_Inlet_pt_after_actual_val();
                                    },
                              child: Text('Get')),
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.all(8.0),
                      //   child: SizedBox(
                      //     height: 30,
                      //    // width: 55,
                      //     child: ElevatedButton(
                      //         onPressed: _port == null ? null : () {},
                      //         child: Text('Set')),
                      //   ),
                      // )
                    ]),
                    Row(children: [
                      Padding(
                        padding: const EdgeInsets.all(9.0),
                        child: Text(
                          'Actual Count :',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          controller: _inlet_actual_count_after_controller,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          style:
                              TextStyle(color: Color.fromARGB(255, 45, 51, 74)),
                        ),
                      ),
                    ]),
                    Row(children: [
                      Padding(
                        padding: const EdgeInsets.all(9.0),
                        child: Text(
                          'Range :',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          controller: inlet_after_Range_Min_controller,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          style:
                              TextStyle(color: Color.fromARGB(255, 45, 51, 74)),
                        ),
                      ),
                      Text('Min'),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 30,
                          // width: 55,
                          child: ElevatedButton(
                              onPressed: _port == null
                                  ? null
                                  : () {
                                      _progress = 0.0;
                                      _startTask(16);
                                      getpop_loader(context);
                                      Future.delayed(Duration(seconds: 16), () {
                                        Navigator.pop(context); //pop dialog
                                      });

                                      get_Inlet_after_range();
                                    },
                              child: Text('Get')),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 30,
                          // width: 55,
                          child: ElevatedButton(
                              onPressed: _port == null
                                  ? null
                                  : () {
                                      _progress = 0.0;
                                      _startTask(16);
                                      getpop_loader(context);
                                      Future.delayed(Duration(seconds: 18), () {
                                        Navigator.pop(context); //pop dialog
                                      });

                                      Set_Inlet_after_range();
                                    },
                              child: Text('Set')),
                        ),
                      )
                    ]),
                    Row(children: [
                      Padding(
                        padding: const EdgeInsets.all(9.0),
                        child: Text(
                          'Range :',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          controller: inlet_after_Range_Max_controller,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          style:
                              TextStyle(color: Color.fromARGB(255, 45, 51, 74)),
                        ),
                      ),
                      Text('Max')
                    ]),
                    Row(children: [
                      Padding(
                        padding: const EdgeInsets.all(9.0),
                        child: Text(
                          'Raw Count:',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          enabled: false,
                          controller: inlet_after_Raw_Min_controller,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          style:
                              TextStyle(color: Color.fromARGB(255, 45, 51, 74)),
                        ),
                      ),
                      Text('Min'),
                    ]),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(children: [
                        Text(
                          'Raw Count:',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(
                          width: 80,
                          child: TextField(
                            enabled: false,
                            controller: inlet_after_Raw_Max_controller,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                                color: Color.fromARGB(255, 45, 51, 74)),
                          ),
                        ),
                        Text('Max'),
                      ]),
                    ),
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
                              'Outlet PT',
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
                          'Actual Value :',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          controller: outlet_value_after_controller,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(color: Color.fromARGB(255, 45, 51, 74)),
                        ),
                      ),
                      // SizedBox(width: 5),
                      Text('mA'),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 30,
                          // width: 55,
                          child: ElevatedButton(
                              onPressed: _port == null
                                  ? null
                                  : () {
                                      _progress = 0.0;
                                      _startTask(16);
                                      getpop_loader(context);
                                      Future.delayed(Duration(seconds: 16), () {
                                        Navigator.pop(context); //pop dialog
                                      });

                                      get_outlet_pt_actual_val();
                                    },
                              child: Text('Get')),
                        ),
                      ),
                    ]),
                    Row(children: [
                      Padding(
                        padding: const EdgeInsets.all(9.0),
                        child: Text(
                          'Actual Count :',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          controller: outlet_actual_count_after_controller,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(color: Color.fromARGB(255, 45, 51, 74)),
                        ),
                      ),
                    ]),
                    Row(children: [
                      Padding(
                        padding: const EdgeInsets.all(9.0),
                        child: Text(
                          'Range :',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          controller: outlet_Range_Min_controller,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          style:
                              TextStyle(color: Color.fromARGB(255, 45, 51, 74)),
                        ),
                      ),
                      Text('Min'),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 30,
                          // width: 55,
                          child: ElevatedButton(
                              onPressed: _port == null
                                  ? null
                                  : () {
                                      _progress = 0.0;
                                      _startTask(16);
                                      getpop_loader(context);
                                      Future.delayed(Duration(seconds: 16), () {
                                        Navigator.pop(context); //pop dialog
                                      });

                                      get_outlet_range();
                                    },
                              child: Text('Get')),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 30,
                          // width: 55,
                          child: ElevatedButton(
                              onPressed: _port == null
                                  ? null
                                  : () {
                                      _progress = 0.0;
                                      _startTask(16);
                                      getpop_loader(context);
                                      Future.delayed(Duration(seconds: 18), () {
                                        Navigator.pop(context); //pop dialog
                                      });

                                      Set_outlet_range();
                                    },
                              child: Text('Set')),
                        ),
                      )
                    ]),
                    Row(children: [
                      Padding(
                        padding: const EdgeInsets.all(9.0),
                        child: Text(
                          'Range :',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          controller: oultet_Range_Max_controller,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          style:
                              TextStyle(color: Color.fromARGB(255, 45, 51, 74)),
                        ),
                      ),
                      Text('Max')
                    ]),
                    Row(children: [
                      Padding(
                        padding: const EdgeInsets.all(9.0),
                        child: Text(
                          'Raw Count :',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          enabled: false,
                          controller: outlet_Raw_Min_controller,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(color: Color.fromARGB(255, 45, 51, 74)),
                        ),
                      ),
                      Text('Min'),
                    ]),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(children: [
                        Text(
                          'Raw Count:',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(
                          width: 80,
                          child: TextField(
                            enabled: false,
                            controller: outlet_Raw_Max_controller,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                                color: Color.fromARGB(255, 45, 51, 74)),
                          ),
                        ),
                        Text('Max'),
                      ]),
                    ),
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
                              'Position Sensor',
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
                          'Actual Value :',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          controller: position_value__controller,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          style:
                              TextStyle(color: Color.fromARGB(255, 45, 51, 74)),
                        ),
                      ),
                      // SizedBox(width: 5),
                      Text('mA'),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 30,
                          // width: 55,
                          child: ElevatedButton(
                              onPressed: _port == null
                                  ? null
                                  : () {
                                      _progress = 0.0;
                                      _startTask(16);
                                      getpop_loader(context);
                                      Future.delayed(Duration(seconds: 18), () {
                                        Navigator.pop(context); //pop dialog
                                      });

                                      get_position_actual_val();
                                    },
                              child: Text('Get')),
                        ),
                      ),
                    ]),
                    Row(children: [
                      Padding(
                        padding: const EdgeInsets.all(9.0),
                        child: Text(
                          'Actual Count :',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          controller: postion_actual_count_controller,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          style:
                              TextStyle(color: Color.fromARGB(255, 45, 51, 74)),
                        ),
                      ),
                    ]),
                    Row(children: [
                      Padding(
                        padding: const EdgeInsets.all(9.0),
                        child: Text(
                          'Range :',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          enabled: false,
                          controller: position_Range_Min_controller,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          style:
                              TextStyle(color: Color.fromARGB(255, 45, 51, 74)),
                        ),
                      ),
                      Text('Min'),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 30,
                          // width: 55,
                          child: ElevatedButton(
                              onPressed: _port == null
                                  ? null
                                  : () {
                                      _progress = 0.0;
                                      _startTask(16);
                                      getpop_loader(context);
                                      Future.delayed(Duration(seconds: 18), () {
                                        Navigator.pop(context); //pop dialog
                                      });

                                      get_position_range();
                                    },
                              child: Text('Get')),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 30,
                          // width: 55,
                          child: ElevatedButton(
                              onPressed: _port == null
                                  ? null
                                  : () {
                                      _progress = 0.0;
                                      _startTask(16);
                                      getpop_loader(context);
                                      Future.delayed(Duration(seconds: 18), () {
                                        Navigator.pop(context); //pop dialog
                                      });

                                      Set_position_range();
                                    },
                              child: Text('Set')),
                        ),
                      )
                    ]),
                    Row(children: [
                      Padding(
                        padding: const EdgeInsets.all(9.0),
                        child: Text(
                          'Range :',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          enabled: false,
                          controller: position_Range_Max_controller,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          style:
                              TextStyle(color: Color.fromARGB(255, 45, 51, 74)),
                        ),
                      ),
                      Text('Max')
                    ]),
                    Row(children: [
                      Padding(
                        padding: const EdgeInsets.all(9.0),
                        child: Text(
                          'Raw Count:',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          controller: position_Raw_Min_controller,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          style:
                              TextStyle(color: Color.fromARGB(255, 45, 51, 74)),
                        ),
                      ),
                      Text('Min'),
                    ]),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(children: [
                        Text(
                          'Raw Count:',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(
                          width: 80,
                          child: TextField(
                            controller: position_Raw_Max_controller,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                                color: Color.fromARGB(255, 45, 51, 74)),
                          ),
                        ),
                        Text('Max'),
                      ]),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _progress = 0.0;
                  _startTask(125);
                  getpop_loader(context);
                  Future.delayed(Duration(seconds: 130), () {
                    Navigator.pop(context); //pop dialog
                  });

                  SetAllData();
                },
                child: Text('Set All', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        5), // Set border radius to 0 for square shape
                  ),
                ),
              ),
            ],
          ),
        );
      } else if (deviceType!.contains('BOCOM6')) {
        return Padding(
          padding: EdgeInsets.all(2),
          child: Column(
            children: [
              Container(
                color: Colors.white,
                height: 60,
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        'DI :',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 100,
                        child: Container(
                          height: 40,
                          child: TextField(
                            controller: door1,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 20, color: Colors.greenAccent),
                                // borderRadius: BorderRadius.circular(50.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: Container(
                        height: 40,
                        child: TextField(
                          controller: door2,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 3, color: Colors.greenAccent),
                              // borderRadius: BorderRadius.circular(50.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 5),
                    ElevatedButton(
                      child: Text("Get"),
                      onPressed: _port == null
                          ? null
                          : () async {
                              if (_port == null) {
                                return;
                              }
                              _progress = 0.0;
                              _startTask(14);
                              getpop_loader(context);
                              Future.delayed(Duration(seconds: 16), () {
                                Navigator.pop(context); //pop dialog
                              });
                              String data = 'DI'.toUpperCase() + "\r\n";
                              _response.clear();
                              hexDecimalValue = '';
                              await _port!
                                  .write(Uint8List.fromList(data.codeUnits));
                              await Future.delayed(Duration(seconds: 6))
                                  .whenComplete(
                                () {
                                  print(_data);
                                  String res = _data.join('');
                                  int i = res.indexOf("DI");
                                  var aisData = res.substring(i + 3);
                                  List<String> position_range =
                                      aisData.split(' ');
                                  print(position_range);
                                  if (position_range[1] == '1') {
                                    door1.text = 'Open';
                                  } else {
                                    door1.text = 'Close';
                                  }
                                  String temp =
                                      position_range[3].replaceAll('>', '');
                                  if (temp == '1') {
                                    door2.text = 'Open';
                                  } else {
                                    door2.text = 'Close';
                                  }

                                  // door2.text = position_range[3].replaceAll('>', '');
                                  aisData = '';
                                  // print(res.substring(i + 6, i + 20));
                                },
                              );
                            },
                    ),
                    /* ElevatedButton(
                    onPressed: _port == null
                        ? null
                        : () async {
                            // _progress = 0.0;
                            // _startTask(14);
                            // getpop_loader(context);
                            // Future.delayed(Duration(seconds: 16), () {
                            //   Navigator.pop(context); //pop dialog
                            // });

                            await getdoors();
                          },
                    child: Text('Get', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            5), // Set border radius to 0 for square shape
                      ),
                    ),
                  )
               */
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Container(
                  width: double.infinity,
                  child: Text(
                    'Analog Input Status',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
              ),
              ListView(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.all(20),
                children: <Widget>[
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ExpandableTile(
                          title: Text(
                            'Inlet PT 1'.toUpperCase(),
                            softWrap: true,
                          ),
                          body: Card(
                            elevation: 10,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Actual Value :',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      controller:
                                          _inlet_1_actual_value_controller,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                  // SizedBox(width: 5),
                                  Text('mA'),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      height: 30,
                                      //// width: 55,
                                      child: ElevatedButton(
                                          onPressed: _port == null
                                              ? null
                                              : () {
                                                  _progress = 0.0;
                                                  _startTask(16);
                                                  getpop_loader(context);
                                                  Future.delayed(
                                                      Duration(seconds: 14),
                                                      () {
                                                    Navigator.pop(
                                                        context); //pop dialog
                                                  });

                                                  get_Inlet_pt_1_actual_val();
                                                },
                                          child: Text('Get')),
                                    ),
                                  ),
                                ]),
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Actual Count :',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      controller:
                                          _inlet__1_actual_count_controller,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                ]),
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Range :',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      controller: inlet_1_Range_Min_controller,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                  Text('Min'),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      height: 30,
                                      // width: 55,
                                      child: ElevatedButton(
                                          onPressed: _port == null
                                              ? null
                                              : () {
                                                  _progress = 0.0;
                                                  _startTask(16);
                                                  getpop_loader(context);
                                                  Future.delayed(
                                                      Duration(seconds: 16),
                                                      () {
                                                    Navigator.pop(
                                                        context); //pop dialog
                                                  });

                                                  get_Inlet_1_range();
                                                },
                                          child: Text('Get')),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      height: 30,
                                      // width: 55,
                                      child: ElevatedButton(
                                          onPressed: _port == null
                                              ? null
                                              : () {
                                                  _progress = 0.0;
                                                  _startTask(16);
                                                  getpop_loader(context);
                                                  Future.delayed(
                                                      Duration(seconds: 18),
                                                      () {
                                                    Navigator.pop(
                                                        context); //pop dialog
                                                  });

                                                  Set_Inlet_1_range();
                                                },
                                          child: Text('Set')),
                                    ),
                                  )
                                ]),
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Range :',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      controller: inlet_1_Range_Max_controller,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                  Text('Max')
                                ]),
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Raw Count:',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      enabled: false,
                                      controller: inlet_1_Raw_Min_controller,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                  Text('Min'),
                                ]),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(children: [
                                    Text(
                                      'Raw Count:',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 80,
                                      child: TextField(
                                        enabled: false,
                                        controller: inlet_1_Raw_Max_controller,
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 45, 51, 74)),
                                      ),
                                    ),
                                    Text('Max'),
                                  ]),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ExpandableTile(
                          title: Text(
                            'Inlet PT 2'.toUpperCase(),
                            softWrap: true,
                          ),
                          body: Card(
                            elevation: 10,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Actual Value :',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      controller:
                                          _inlet_2_actual_value_controller,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                  // SizedBox(width: 5),
                                  Text('mA'),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      height: 30,
                                      // width: 55,
                                      child: ElevatedButton(
                                          onPressed: _port == null
                                              ? null
                                              : () {
                                                  _progress = 0.0;
                                                  _startTask(16);
                                                  getpop_loader(context);
                                                  Future.delayed(
                                                      Duration(seconds: 14),
                                                      () {
                                                    Navigator.pop(
                                                        context); //pop dialog
                                                  });

                                                  get_Inlet_pt_2_actual_val();
                                                },
                                          child: Text('Get')),
                                    ),
                                  ),
                                ]),
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Actual Count :',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      controller:
                                          _inlet__2_actual_count_controller,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                ]),
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Range :',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      controller: inlet_2_Range_Min_controller,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                  Text('Min'),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      height: 30,
                                      // width: 55,
                                      child: ElevatedButton(
                                          onPressed: _port == null
                                              ? null
                                              : () {
                                                  _progress = 0.0;
                                                  _startTask(16);
                                                  getpop_loader(context);
                                                  Future.delayed(
                                                      Duration(seconds: 16),
                                                      () {
                                                    Navigator.pop(
                                                        context); //pop dialog
                                                  });

                                                  get_Inlet_2_range();
                                                },
                                          child: Text('Get')),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      height: 30,
                                      // width: 55,
                                      child: ElevatedButton(
                                          onPressed: _port == null
                                              ? null
                                              : () {
                                                  _progress = 0.0;
                                                  _startTask(16);
                                                  getpop_loader(context);
                                                  Future.delayed(
                                                      Duration(seconds: 18),
                                                      () {
                                                    Navigator.pop(
                                                        context); //pop dialog
                                                  });

                                                  Set_Inlet_2_range();
                                                },
                                          child: Text('Set')),
                                    ),
                                  )
                                ]),
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Range :',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      controller: inlet_2_Range_Max_controller,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                  Text('Max')
                                ]),
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Raw Count:',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      enabled: false,
                                      controller: inlet_2_Raw_Min_controller,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                  Text('Min'),
                                ]),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(children: [
                                    Text(
                                      'Raw Count:',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 80,
                                      child: TextField(
                                        enabled: false,
                                        controller: inlet_2_Raw_Max_controller,
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 45, 51, 74)),
                                      ),
                                    ),
                                    Text('Max'),
                                  ]),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ExpandableTile(
                          title: Text(
                            'Outlet PT 1'.toUpperCase(),
                            softWrap: true,
                          ),
                          body: Card(
                            elevation: 10,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Actual Value :',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      controller: outlet_1_value_controller,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                  // SizedBox(width: 5),
                                  Text('mA'),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      height: 30,
                                      // width: 55,
                                      child: ElevatedButton(
                                          onPressed: _port == null
                                              ? null
                                              : () {
                                                  _progress = 0.0;
                                                  _startTask(16);
                                                  getpop_loader(context);
                                                  Future.delayed(
                                                      Duration(seconds: 16),
                                                      () {
                                                    Navigator.pop(
                                                        context); //pop dialog
                                                  });

                                                  get_outlet_pt_1_actual_val();
                                                },
                                          child: Text('Get')),
                                    ),
                                  ),
                                  // Padding(
                                  //   padding: const EdgeInsets.all(8.0),
                                  //   child: SizedBox(
                                  //     height: 30,
                                  //    // width: 55,
                                  //     child: ElevatedButton(
                                  //         onPressed: _port == null ? null : () {},
                                  //         child: Text('Set')),
                                  //   ),
                                  // )
                                ]),
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Actual Count :',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      controller:
                                          outlet_1_actual_count_controller,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                ]),
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Range :',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      controller: outlet_1_Range_Min_controller,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                  Text('Min'),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      height: 30,
                                      // width: 55,
                                      child: ElevatedButton(
                                          onPressed: _port == null
                                              ? null
                                              : () {
                                                  _progress = 0.0;
                                                  _startTask(16);
                                                  getpop_loader(context);
                                                  Future.delayed(
                                                      Duration(seconds: 16),
                                                      () {
                                                    Navigator.pop(
                                                        context); //pop dialog
                                                  });

                                                  get_outlet_1_range();
                                                },
                                          child: Text('Get')),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      height: 30,
                                      // width: 55,
                                      child: ElevatedButton(
                                          onPressed: _port == null
                                              ? null
                                              : () {
                                                  _progress = 0.0;
                                                  _startTask(16);
                                                  getpop_loader(context);
                                                  Future.delayed(
                                                      Duration(seconds: 18),
                                                      () {
                                                    Navigator.pop(
                                                        context); //pop dialog
                                                  });

                                                  Set_outlet_1_range();
                                                },
                                          child: Text('Set')),
                                    ),
                                  )
                                ]),
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Range :',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      controller: oultet_1_Range_Max_controller,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                  Text('Max')
                                ]),
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Raw Count :',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      enabled: false,
                                      controller: outlet_1_Raw_Min_controller,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                  Text('Min'),
                                ]),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(children: [
                                    Text(
                                      'Raw Count:',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 80,
                                      child: TextField(
                                        enabled: false,
                                        controller: outlet_1_Raw_Max_controller,
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 45, 51, 74)),
                                      ),
                                    ),
                                    Text('Max'),
                                  ]),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ExpandableTile(
                          title: Text(
                            'Outlet PT 2'.toUpperCase(),
                            softWrap: true,
                          ),
                          body: Card(
                            elevation: 10,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Actual Value :',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      controller:
                                          outlet_2_value_after_controller,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                  // SizedBox(width: 5),
                                  Text('mA'),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      height: 30,
                                      // width: 55,
                                      child: ElevatedButton(
                                          onPressed: _port == null
                                              ? null
                                              : () {
                                                  _progress = 0.0;
                                                  _startTask(16);
                                                  getpop_loader(context);
                                                  Future.delayed(
                                                      Duration(seconds: 16),
                                                      () {
                                                    Navigator.pop(
                                                        context); //pop dialog
                                                  });

                                                  get_outlet_pt_2_actual_val();
                                                },
                                          child: Text('Get')),
                                    ),
                                  ),
                                  // Padding(
                                  //   padding: const EdgeInsets.all(8.0),
                                  //   child: SizedBox(
                                  //     height: 30,
                                  //    // width: 55,
                                  //     child: ElevatedButton(
                                  //         onPressed: _port == null ? null : () {},
                                  //         child: Text('Set')),
                                  //   ),
                                  // )
                                ]),
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Actual Count :',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      controller:
                                          outlet_2_actual_count_after_controller,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                ]),
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Range :',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      controller: outlet_2_Range_Min_controller,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                  Text('Min'),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      height: 30,
                                      // width: 55,
                                      child: ElevatedButton(
                                          onPressed: _port == null
                                              ? null
                                              : () {
                                                  // _progress = 0.0;
                                                  _startTask(16);
                                                  getpop_loader(context);
                                                  Future.delayed(
                                                      Duration(seconds: 16),
                                                      () {
                                                    Navigator.pop(
                                                        context); //pop dialog
                                                  });

                                                  get_outlet_2_range();
                                                },
                                          child: Text('Get')),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      height: 30,
                                      // width: 55,
                                      child: ElevatedButton(
                                          onPressed: _port == null
                                              ? null
                                              : () {
                                                  _progress = 0.0;
                                                  _startTask(16);
                                                  getpop_loader(context);
                                                  Future.delayed(
                                                      Duration(seconds: 18),
                                                      () {
                                                    Navigator.pop(
                                                        context); //pop dialog
                                                  });

                                                  Set_outlet_2_range();
                                                },
                                          child: Text('Set')),
                                    ),
                                  )
                                ]),
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Range :',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      controller: oultet_2_Range_Max_controller,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                  Text('Max')
                                ]),
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Raw Count :',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      enabled: false,
                                      controller: outlet_2_Raw_Min_controller,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                  Text('Min'),
                                ]),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(children: [
                                    Text(
                                      'Raw Count:',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 80,
                                      child: TextField(
                                        enabled: false,
                                        controller: outlet_2_Raw_Max_controller,
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 45, 51, 74)),
                                      ),
                                    ),
                                    Text('Max'),
                                  ]),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ExpandableTile(
                          title: Text(
                            'Outlet PT 3'.toUpperCase(),
                            softWrap: true,
                          ),
                          body: Card(
                            elevation: 10,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Actual Value :',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      controller: outlet_3_value_controller,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                  // SizedBox(width: 5),
                                  Text('mA'),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      height: 30,
                                      // width: 55,
                                      child: ElevatedButton(
                                          onPressed: _port == null
                                              ? null
                                              : () {
                                                  _progress = 0.0;
                                                  _startTask(16);
                                                  getpop_loader(context);
                                                  Future.delayed(
                                                      Duration(seconds: 16),
                                                      () {
                                                    Navigator.pop(
                                                        context); //pop dialog
                                                  });

                                                  get_outlet_pt_3_actual_val();
                                                },
                                          child: Text('Get')),
                                    ),
                                  ),
                                  // Padding(
                                  //   padding: const EdgeInsets.all(8.0),
                                  //   child: SizedBox(
                                  //     height: 30,
                                  //    // width: 55,
                                  //     child: ElevatedButton(
                                  //         onPressed: _port == null ? null : () {},
                                  //         child: Text('Set')),
                                  //   ),
                                  // )
                                ]),
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Actual Count :',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      controller:
                                          outlet_3_actual_count_controller,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                ]),
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Range :',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      controller: outlet_3_Range_Min_controller,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                  Text('Min'),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      height: 30,
                                      // width: 55,
                                      child: ElevatedButton(
                                          onPressed: _port == null
                                              ? null
                                              : () {
                                                  _progress = 0.0;
                                                  _startTask(16);
                                                  getpop_loader(context);
                                                  Future.delayed(
                                                      Duration(seconds: 16),
                                                      () {
                                                    Navigator.pop(
                                                        context); //pop dialog
                                                  });

                                                  get_outlet_3_range();
                                                },
                                          child: Text('Get')),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      height: 30,
                                      // width: 55,
                                      child: ElevatedButton(
                                          onPressed: _port == null
                                              ? null
                                              : () {
                                                  _progress = 0.0;
                                                  _startTask(16);
                                                  getpop_loader(context);
                                                  Future.delayed(
                                                      Duration(seconds: 18),
                                                      () {
                                                    Navigator.pop(
                                                        context); //pop dialog
                                                  });

                                                  Set_outlet_3_range();
                                                },
                                          child: Text('Set')),
                                    ),
                                  )
                                ]),
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Range :',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      controller: oultet_3_Range_Max_controller,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                  Text('Max')
                                ]),
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Raw Count :',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      enabled: false,
                                      controller: outlet_3_Raw_Min_controller,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                  Text('Min'),
                                ]),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(children: [
                                    Text(
                                      'Raw Count:',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 80,
                                      child: TextField(
                                        enabled: false,
                                        controller: outlet_3_Raw_Max_controller,
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 45, 51, 74)),
                                      ),
                                    ),
                                    Text('Max'),
                                  ]),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ExpandableTile(
                          title: Text(
                            'Outlet PT 4'.toUpperCase(),
                            softWrap: true,
                          ),
                          body: Card(
                            elevation: 10,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Actual Value :',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      controller: outlet_4_value_controller,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                  // SizedBox(width: 5),
                                  Text('mA'),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      height: 30,
                                      // width: 55,
                                      child: ElevatedButton(
                                          onPressed: _port == null
                                              ? null
                                              : () {
                                                  _progress = 0.0;
                                                  _startTask(16);
                                                  getpop_loader(context);
                                                  Future.delayed(
                                                      Duration(seconds: 16),
                                                      () {
                                                    Navigator.pop(
                                                        context); //pop dialog
                                                  });

                                                  get_outlet_pt_4_actual_val();
                                                },
                                          child: Text('Get')),
                                    ),
                                  ),
                                  // Padding(
                                  //   padding: const EdgeInsets.all(8.0),
                                  //   child: SizedBox(
                                  //     height: 30,
                                  //    // width: 55,
                                  //     child: ElevatedButton(
                                  //         onPressed: _port == null ? null : () {},
                                  //         child: Text('Set')),
                                  //   ),
                                  // )
                                ]),
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Actual Count :',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      controller:
                                          outlet_4_actual_count_controller,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                ]),
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Range :',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      controller: outlet_4_Range_Min_controller,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                  Text('Min'),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      height: 30,
                                      // width: 55,
                                      child: ElevatedButton(
                                          onPressed: _port == null
                                              ? null
                                              : () {
                                                  _progress = 0.0;
                                                  _startTask(16);
                                                  getpop_loader(context);
                                                  Future.delayed(
                                                      Duration(seconds: 16),
                                                      () {
                                                    Navigator.pop(
                                                        context); //pop dialog
                                                  });

                                                  get_outlet_4_range();
                                                },
                                          child: Text('Get')),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      height: 30,
                                      // width: 55,
                                      child: ElevatedButton(
                                          onPressed: _port == null
                                              ? null
                                              : () {
                                                  _progress = 0.0;
                                                  _startTask(16);
                                                  getpop_loader(context);
                                                  Future.delayed(
                                                      Duration(seconds: 18),
                                                      () {
                                                    Navigator.pop(
                                                        context); //pop dialog
                                                  });

                                                  Set_outlet_4_range();
                                                },
                                          child: Text('Set')),
                                    ),
                                  )
                                ]),
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Range :',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      controller: oultet_4_Range_Max_controller,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                  Text('Max')
                                ]),
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Raw Count :',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      enabled: false,
                                      controller: outlet_4_Raw_Min_controller,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                  Text('Min'),
                                ]),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(children: [
                                    Text(
                                      'Raw Count:',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 80,
                                      child: TextField(
                                        enabled: false,
                                        controller: outlet_4_Raw_Max_controller,
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 45, 51, 74)),
                                      ),
                                    ),
                                    Text('Max'),
                                  ]),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ExpandableTile(
                          title: Text(
                            'Outlet PT 5'.toUpperCase(),
                            softWrap: true,
                          ),
                          body: Card(
                            elevation: 10,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Actual Value :',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      controller: outlet_5_value_controller,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                  // SizedBox(width: 5),
                                  Text('mA'),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      height: 30,
                                      // width: 55,
                                      child: ElevatedButton(
                                          onPressed: _port == null
                                              ? null
                                              : () {
                                                  _progress = 0.0;
                                                  _startTask(16);
                                                  getpop_loader(context);
                                                  Future.delayed(
                                                      Duration(seconds: 16),
                                                      () {
                                                    Navigator.pop(
                                                        context); //pop dialog
                                                  });

                                                  get_outlet_pt_5_actual_val();
                                                },
                                          child: Text('Get')),
                                    ),
                                  ),
                                  // Padding(
                                  //   padding: const EdgeInsets.all(8.0),
                                  //   child: SizedBox(
                                  //     height: 30,
                                  //    // width: 55,
                                  //     child: ElevatedButton(
                                  //         onPressed: _port == null ? null : () {},
                                  //         child: Text('Set')),
                                  //   ),
                                  // )
                                ]),
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Actual Count :',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      controller:
                                          outlet_5_actual_count_controller,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                ]),
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Range :',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      controller: outlet_5_Range_Min_controller,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                  Text('Min'),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      height: 30,
                                      // width: 55,
                                      child: ElevatedButton(
                                          onPressed: _port == null
                                              ? null
                                              : () {
                                                  _progress = 0.0;
                                                  _startTask(16);
                                                  getpop_loader(context);
                                                  Future.delayed(
                                                      Duration(seconds: 16),
                                                      () {
                                                    Navigator.pop(
                                                        context); //pop dialog
                                                  });

                                                  get_outlet_5_range();
                                                },
                                          child: Text('Get')),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      height: 30,
                                      // width: 55,
                                      child: ElevatedButton(
                                          onPressed: _port == null
                                              ? null
                                              : () {
                                                  _progress = 0.0;
                                                  _startTask(16);
                                                  getpop_loader(context);
                                                  Future.delayed(
                                                      Duration(seconds: 18),
                                                      () {
                                                    Navigator.pop(
                                                        context); //pop dialog
                                                  });

                                                  Set_outlet_5_range();
                                                },
                                          child: Text('Set')),
                                    ),
                                  )
                                ]),
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Range :',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      controller: oultet_5_Range_Max_controller,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                  Text('Max')
                                ]),
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Raw Count :',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      enabled: false,
                                      controller: outlet_5_Raw_Min_controller,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                  Text('Min'),
                                ]),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(children: [
                                    Text(
                                      'Raw Count:',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 80,
                                      child: TextField(
                                        enabled: false,
                                        controller: outlet_5_Raw_Max_controller,
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 45, 51, 74)),
                                      ),
                                    ),
                                    Text('Max'),
                                  ]),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ExpandableTile(
                          title: Text(
                            'Outlet PT 6'.toUpperCase(),
                            softWrap: true,
                          ),
                          body: Card(
                            elevation: 10,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Actual Value :',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      controller: outlet_6_value_controller,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                  // SizedBox(width: 5),
                                  Text('mA'),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      height: 30,
                                      // width: 55,
                                      child: ElevatedButton(
                                          onPressed: _port == null
                                              ? null
                                              : () {
                                                  _progress = 0.0;
                                                  _startTask(16);
                                                  getpop_loader(context);
                                                  Future.delayed(
                                                      Duration(seconds: 16),
                                                      () {
                                                    Navigator.pop(
                                                        context); //pop dialog
                                                  });

                                                  get_outlet_pt_6_actual_val();
                                                },
                                          child: Text('Get')),
                                    ),
                                  ),
                                  // Padding(
                                  //   padding: const EdgeInsets.all(8.0),
                                  //   child: SizedBox(
                                  //     height: 30,
                                  //    // width: 55,
                                  //     child: ElevatedButton(
                                  //         onPressed: _port == null ? null : () {},
                                  //         child: Text('Set')),
                                  //   ),
                                  // )
                                ]),
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Actual Count :',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      controller:
                                          outlet_6_actual_count_controller,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                ]),
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Range :',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      controller: outlet_6_Range_Min_controller,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                  Text('Min'),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      height: 30,
                                      // width: 55,
                                      child: ElevatedButton(
                                          onPressed: _port == null
                                              ? null
                                              : () {
                                                  _progress = 0.0;
                                                  _startTask(16);
                                                  getpop_loader(context);
                                                  Future.delayed(
                                                      Duration(seconds: 16),
                                                      () {
                                                    Navigator.pop(
                                                        context); //pop dialog
                                                  });

                                                  get_outlet_6_range();
                                                },
                                          child: Text('Get')),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      height: 30,
                                      // width: 55,
                                      child: ElevatedButton(
                                          onPressed: _port == null
                                              ? null
                                              : () {
                                                  _progress = 0.0;
                                                  _startTask(16);
                                                  getpop_loader(context);
                                                  Future.delayed(
                                                      Duration(seconds: 18),
                                                      () {
                                                    Navigator.pop(
                                                        context); //pop dialog
                                                  });

                                                  Set_outlet_6_range();
                                                },
                                          child: Text('Set')),
                                    ),
                                  )
                                ]),
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Range :',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      controller: oultet_6_Range_Max_controller,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                  Text('Max')
                                ]),
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Raw Count :',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      enabled: false,
                                      controller: outlet_6_Raw_Min_controller,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                  Text('Min'),
                                ]),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(children: [
                                    Text(
                                      'Raw Count:',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 80,
                                      child: TextField(
                                        enabled: false,
                                        controller: outlet_6_Raw_Max_controller,
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 45, 51, 74)),
                                      ),
                                    ),
                                    Text('Max'),
                                  ]),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ExpandableTile(
                          title: Text(
                            'Position Sensor 1'.toUpperCase(),
                            softWrap: true,
                          ),
                          body: Card(
                            elevation: 10,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Actual Value :',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      controller: position_value_1_controller,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                  // SizedBox(width: 5),
                                  Text('mA'),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      height: 30,
                                      // width: 55,
                                      child: ElevatedButton(
                                          onPressed: _port == null
                                              ? null
                                              : () {
                                                  _progress = 0.0;
                                                  _startTask(16);
                                                  getpop_loader(context);
                                                  Future.delayed(
                                                      Duration(seconds: 18),
                                                      () {
                                                    Navigator.pop(
                                                        context); //pop dialog
                                                  });

                                                  get_position_pt_1_actual_val();
                                                },
                                          child: Text('Get')),
                                    ),
                                  ),
                                ]),
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Actual Count :',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      controller:
                                          postion_actual_1_count_controller,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                ]),
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Range :',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      enabled: false,
                                      controller:
                                          position_1_Range_Min_controller,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                  Text('Min'),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      height: 30,
                                      // width: 55,
                                      child: ElevatedButton(
                                          onPressed: _port == null
                                              ? null
                                              : () {
                                                  _progress = 0.0;
                                                  _startTask(16);
                                                  getpop_loader(context);
                                                  Future.delayed(
                                                      Duration(seconds: 18),
                                                      () {
                                                    Navigator.pop(
                                                        context); //pop dialog
                                                  });

                                                  get_position_1_range();
                                                },
                                          child: Text('Get')),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      height: 30,
                                      // width: 55,
                                      child: ElevatedButton(
                                          onPressed: _port == null
                                              ? null
                                              : () {
                                                  _progress = 0.0;
                                                  _startTask(16);
                                                  getpop_loader(context);
                                                  Future.delayed(
                                                      Duration(seconds: 18),
                                                      () {
                                                    Navigator.pop(
                                                        context); //pop dialog
                                                  });

                                                  set_position_1_range();
                                                },
                                          child: Text('Set')),
                                    ),
                                  )
                                ]),
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Range :',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      enabled: false,
                                      controller:
                                          position_1_Range_Max_controller,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                  Text('Max')
                                ]),
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Raw Count:',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      controller: position_1_Raw_Min_controller,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                  Text('Min'),
                                ]),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(children: [
                                    Text(
                                      'Raw Count:',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 80,
                                      child: TextField(
                                        controller:
                                            position_1_Raw_Max_controller,
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 45, 51, 74)),
                                      ),
                                    ),
                                    Text('Max'),
                                  ]),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ExpandableTile(
                          title: Text(
                            'Position Sensor 2'.toUpperCase(),
                            softWrap: true,
                          ),
                          body: Card(
                            elevation: 10,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Actual Value :',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      controller: position_value_2_controller,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                  // SizedBox(width: 5),
                                  Text('mA'),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      height: 30,
                                      // width: 55,
                                      child: ElevatedButton(
                                          onPressed: _port == null
                                              ? null
                                              : () {
                                                  _progress = 0.0;
                                                  _startTask(16);
                                                  getpop_loader(context);
                                                  Future.delayed(
                                                      Duration(seconds: 18),
                                                      () {
                                                    Navigator.pop(
                                                        context); //pop dialog
                                                  });

                                                  get_position_pt_2_actual_val();
                                                },
                                          child: Text('Get')),
                                    ),
                                  ),
                                ]),
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Actual Count :',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      controller:
                                          postion_actual_2_count_controller,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                ]),
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Range :',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      enabled: false,
                                      controller:
                                          position_2_Range_Min_controller,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                  Text('Min'),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      height: 30,
                                      // width: 55,
                                      child: ElevatedButton(
                                          onPressed: _port == null
                                              ? null
                                              : () {
                                                  _progress = 0.0;
                                                  _startTask(16);
                                                  getpop_loader(context);
                                                  Future.delayed(
                                                      Duration(seconds: 18),
                                                      () {
                                                    Navigator.pop(
                                                        context); //pop dialog
                                                  });

                                                  get_position_2_range();
                                                },
                                          child: Text('Get')),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      height: 30,
                                      // width: 55,
                                      child: ElevatedButton(
                                          onPressed: _port == null
                                              ? null
                                              : () {
                                                  _progress = 0.0;
                                                  _startTask(16);
                                                  getpop_loader(context);
                                                  Future.delayed(
                                                      Duration(seconds: 18),
                                                      () {
                                                    Navigator.pop(
                                                        context); //pop dialog
                                                  });

                                                  set_position_2_range();
                                                },
                                          child: Text('Set')),
                                    ),
                                  )
                                ]),
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Range :',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      enabled: false,
                                      controller:
                                          position_2_Range_Max_controller,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                  Text('Max')
                                ]),
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Raw Count:',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      controller: position_2_Raw_Min_controller,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                  Text('Min'),
                                ]),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(children: [
                                    Text(
                                      'Raw Count:',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 80,
                                      child: TextField(
                                        controller:
                                            position_2_Raw_Max_controller,
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 45, 51, 74)),
                                      ),
                                    ),
                                    Text('Max'),
                                  ]),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ExpandableTile(
                          title: Text(
                            'Position Sensor 3'.toUpperCase(),
                            softWrap: true,
                          ),
                          body: Card(
                            elevation: 10,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Actual Value :',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      controller: position_value_3_controller,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                  // SizedBox(width: 5),
                                  Text('mA'),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      height: 30,
                                      // width: 55,
                                      child: ElevatedButton(
                                          onPressed: _port == null
                                              ? null
                                              : () {
                                                  _progress = 0.0;
                                                  _startTask(16);
                                                  getpop_loader(context);
                                                  Future.delayed(
                                                      Duration(seconds: 18),
                                                      () {
                                                    Navigator.pop(
                                                        context); //pop dialog
                                                  });

                                                  get_position_pt_3_actual_val();
                                                },
                                          child: Text('Get')),
                                    ),
                                  ),
                                ]),
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Actual Count :',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      controller:
                                          postion_actual_3_count_controller,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                ]),
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Range :',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      enabled: false,
                                      controller:
                                          position_3_Range_Min_controller,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                  Text('Min'),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      height: 30,
                                      // width: 55,
                                      child: ElevatedButton(
                                          onPressed: _port == null
                                              ? null
                                              : () {
                                                  _progress = 0.0;
                                                  _startTask(16);
                                                  getpop_loader(context);
                                                  Future.delayed(
                                                      Duration(seconds: 18),
                                                      () {
                                                    Navigator.pop(
                                                        context); //pop dialog
                                                  });

                                                  get_position_3_range();
                                                },
                                          child: Text('Get')),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      height: 30,
                                      // width: 55,
                                      child: ElevatedButton(
                                          onPressed: _port == null
                                              ? null
                                              : () {
                                                  _progress = 0.0;
                                                  _startTask(16);
                                                  getpop_loader(context);
                                                  Future.delayed(
                                                      Duration(seconds: 18),
                                                      () {
                                                    Navigator.pop(
                                                        context); //pop dialog
                                                  });

                                                  set_position_3_range();
                                                },
                                          child: Text('Set')),
                                    ),
                                  )
                                ]),
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Range :',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      enabled: false,
                                      controller:
                                          position_3_Range_Max_controller,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                  Text('Max')
                                ]),
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Raw Count:',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      controller: position_3_Raw_Min_controller,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                  Text('Min'),
                                ]),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(children: [
                                    Text(
                                      'Raw Count:',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 80,
                                      child: TextField(
                                        controller:
                                            position_3_Raw_Max_controller,
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 45, 51, 74)),
                                      ),
                                    ),
                                    Text('Max'),
                                  ]),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ExpandableTile(
                          title: Text(
                            'Position Sensor 4'.toUpperCase(),
                            softWrap: true,
                          ),
                          body: Card(
                            elevation: 10,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Actual Value :',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      controller: position_value_4_controller,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                  // SizedBox(width: 5),
                                  Text('mA'),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      height: 30,
                                      // width: 55,
                                      child: ElevatedButton(
                                          onPressed: _port == null
                                              ? null
                                              : () {
                                                  _progress = 0.0;
                                                  _startTask(16);
                                                  getpop_loader(context);
                                                  Future.delayed(
                                                      Duration(seconds: 18),
                                                      () {
                                                    Navigator.pop(
                                                        context); //pop dialog
                                                  });

                                                  get_position_pt_4_actual_val();
                                                },
                                          child: Text('Get')),
                                    ),
                                  ),
                                ]),
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Actual Count :',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      controller:
                                          postion_actual_4_count_controller,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                ]),
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Range :',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      enabled: false,
                                      controller:
                                          position_4_Range_Min_controller,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                  Text('Min'),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      height: 30,
                                      // width: 55,
                                      child: ElevatedButton(
                                          onPressed: _port == null
                                              ? null
                                              : () {
                                                  _progress = 0.0;
                                                  _startTask(16);
                                                  getpop_loader(context);
                                                  Future.delayed(
                                                      Duration(seconds: 18),
                                                      () {
                                                    Navigator.pop(
                                                        context); //pop dialog
                                                  });

                                                  get_position_4_range();
                                                },
                                          child: Text('Get')),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      height: 30,
                                      // width: 55,
                                      child: ElevatedButton(
                                          onPressed: _port == null
                                              ? null
                                              : () {
                                                  _progress = 0.0;
                                                  _startTask(16);
                                                  getpop_loader(context);
                                                  Future.delayed(
                                                      Duration(seconds: 18),
                                                      () {
                                                    Navigator.pop(
                                                        context); //pop dialog
                                                  });

                                                  set_position_4_range();
                                                },
                                          child: Text('Set')),
                                    ),
                                  )
                                ]),
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Range :',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      enabled: false,
                                      controller:
                                          position_4_Range_Max_controller,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                  Text('Max')
                                ]),
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Raw Count:',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      controller: position_4_Raw_Min_controller,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                  Text('Min'),
                                ]),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(children: [
                                    Text(
                                      'Raw Count:',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 80,
                                      child: TextField(
                                        controller:
                                            position_4_Raw_Max_controller,
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 45, 51, 74)),
                                      ),
                                    ),
                                    Text('Max'),
                                  ]),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ExpandableTile(
                          title: Text(
                            'Position Sensor 5'.toUpperCase(),
                            softWrap: true,
                          ),
                          body: Card(
                            elevation: 10,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Actual Value :',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      controller: position_value_5_controller,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                  // SizedBox(width: 5),
                                  Text('mA'),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      height: 30,
                                      // width: 55,
                                      child: ElevatedButton(
                                          onPressed: _port == null
                                              ? null
                                              : () {
                                                  _progress = 0.0;
                                                  _startTask(16);
                                                  getpop_loader(context);
                                                  Future.delayed(
                                                      Duration(seconds: 18),
                                                      () {
                                                    Navigator.pop(
                                                        context); //pop dialog
                                                  });

                                                  get_position_pt_5_actual_val();
                                                },
                                          child: Text('Get')),
                                    ),
                                  ),
                                ]),
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Actual Count :',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      controller:
                                          postion_actual_5_count_controller,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                ]),
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Range :',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      enabled: false,
                                      controller:
                                          position_5_Range_Min_controller,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                  Text('Min'),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      height: 30,
                                      // width: 55,
                                      child: ElevatedButton(
                                          onPressed: _port == null
                                              ? null
                                              : () {
                                                  _progress = 0.0;
                                                  _startTask(16);
                                                  getpop_loader(context);
                                                  Future.delayed(
                                                      Duration(seconds: 18),
                                                      () {
                                                    Navigator.pop(
                                                        context); //pop dialog
                                                  });

                                                  get_position_5_range();
                                                },
                                          child: Text('Get')),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      height: 30,
                                      // width: 55,
                                      child: ElevatedButton(
                                          onPressed: _port == null
                                              ? null
                                              : () {
                                                  _progress = 0.0;
                                                  _startTask(16);
                                                  getpop_loader(context);
                                                  Future.delayed(
                                                      Duration(seconds: 18),
                                                      () {
                                                    Navigator.pop(
                                                        context); //pop dialog
                                                  });

                                                  set_position_5_range();
                                                },
                                          child: Text('Set')),
                                    ),
                                  )
                                ]),
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Range :',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      enabled: false,
                                      controller:
                                          position_5_Range_Max_controller,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                  Text('Max')
                                ]),
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Raw Count:',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      controller: position_5_Raw_Min_controller,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                  Text('Min'),
                                ]),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(children: [
                                    Text(
                                      'Raw Count:',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 80,
                                      child: TextField(
                                        controller:
                                            position_5_Raw_Max_controller,
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 45, 51, 74)),
                                      ),
                                    ),
                                    Text('Max'),
                                  ]),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ExpandableTile(
                          title: Text(
                            'Position Sensor 6'.toUpperCase(),
                            softWrap: true,
                          ),
                          body: Card(
                            elevation: 10,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Actual Value :',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      controller: position_value_6_controller,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                  // SizedBox(width: 5),
                                  Text('mA'),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      height: 30,
                                      // width: 55,
                                      child: ElevatedButton(
                                          onPressed: _port == null
                                              ? null
                                              : () {
                                                  _progress = 0.0;
                                                  _startTask(16);
                                                  getpop_loader(context);
                                                  Future.delayed(
                                                      Duration(seconds: 18),
                                                      () {
                                                    Navigator.pop(
                                                        context); //pop dialog
                                                  });

                                                  get_position_pt_6_actual_val();
                                                },
                                          child: Text('Get')),
                                    ),
                                  ),
                                ]),
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Actual Count :',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      controller:
                                          postion_actual_6_count_controller,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                ]),
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Range :',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      enabled: false,
                                      controller:
                                          position_6_Range_Min_controller,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                  Text('Min'),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      height: 30,
                                      // width: 55,
                                      child: ElevatedButton(
                                          onPressed: _port == null
                                              ? null
                                              : () {
                                                  _progress = 0.0;
                                                  _startTask(16);
                                                  getpop_loader(context);
                                                  Future.delayed(
                                                      Duration(seconds: 18),
                                                      () {
                                                    Navigator.pop(
                                                        context); //pop dialog
                                                  });

                                                  get_position_6_range();
                                                },
                                          child: Text('Get')),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      height: 30,
                                      // width: 55,
                                      child: ElevatedButton(
                                          onPressed: _port == null
                                              ? null
                                              : () {
                                                  _progress = 0.0;
                                                  _startTask(16);
                                                  getpop_loader(context);
                                                  Future.delayed(
                                                      Duration(seconds: 18),
                                                      () {
                                                    Navigator.pop(
                                                        context); //pop dialog
                                                  });

                                                  set_position_6_range();
                                                },
                                          child: Text('Set')),
                                    ),
                                  )
                                ]),
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Range :',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      enabled: false,
                                      controller:
                                          position_6_Range_Max_controller,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                  Text('Max')
                                ]),
                                Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(9.0),
                                    child: Text(
                                      'Raw Count:',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      controller: position_6_Raw_Min_controller,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 51, 74)),
                                    ),
                                  ),
                                  Text('Min'),
                                ]),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(children: [
                                    Text(
                                      'Raw Count:',
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 80,
                                      child: TextField(
                                        controller:
                                            position_6_Raw_Max_controller,
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 45, 51, 74)),
                                      ),
                                    ),
                                    Text('Max'),
                                  ]),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      /*Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ExpandableTile(
                        title: Text(
                          'Position Sensor 2'.toUpperCase(),
                          softWrap: true,
                        ),
                        body: Card(
                          elevation: 10,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Row(children: [
                                Padding(
                                  padding: const EdgeInsets.all(9.0),
                                  child: Text(
                                    'Actual Value :',
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 80,
                                  child: TextField(
                                    //controller: position_value__controller,
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 45, 51, 74)),
                                  ),
                                ),
                                // SizedBox(width: 5),
                                Text('mA'),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    height: 30,
                                   // width: 55,
                                    child: ElevatedButton(
                                        onPressed: //_port == null
                                            //? null
                                            () {
                                          // _progress = 0.0;
                                          // _startTask(16);
                                          // getpop_loader(context);
                                          // Future.delayed(Duration(seconds: 18), () {
                                          //   Navigator.pop(context); //pop dialog
                                          // });

                                          // get_position_actual_val();
                                        },
                                        child: Text('Get')),
                                  ),
                                ),
                              ]),
                              Row(children: [
                                Padding(
                                  padding: const EdgeInsets.all(9.0),
                                  child: Text(
                                    'Actual Count :',
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 80,
                                  child: TextField(
                                    //controller: postion_actual_count_controller,
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 45, 51, 74)),
                                  ),
                                ),
                              ]),
                              Row(children: [
                                Padding(
                                  padding: const EdgeInsets.all(9.0),
                                  child: Text(
                                    'Range :',
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 80,
                                  child: TextField(
                                    enabled: false,
                                    //controller: position_Range_Min_controller,
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 45, 51, 74)),
                                  ),
                                ),
                                Text('Min'),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    height: 30,
                                   // width: 55,
                                    child: ElevatedButton(
                                        onPressed: //_port == null
                                            //? null
                                            () {
                                          // _progress = 0.0;
                                          // _startTask(16);
                                          // getpop_loader(context);
                                          // Future.delayed(Duration(seconds: 18), () {
                                          //   Navigator.pop(context); //pop dialog
                                          // });

                                          // get_position_range();
                                        },
                                        child: Text('Get')),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    height: 30,
                                   // width: 55,
                                    child: ElevatedButton(
                                        onPressed: //_port == null
                                            //? null
                                            () {
                                          // _progress = 0.0;
                                          // _startTask(16);
                                          // getpop_loader(context);
                                          // Future.delayed(Duration(seconds: 18), () {
                                          //   Navigator.pop(context); //pop dialog
                                          // });

                                          // Set_position_range();
                                        },
                                        child: Text('Set')),
                                  ),
                                )
                              ]),
                              Row(children: [
                                Padding(
                                  padding: const EdgeInsets.all(9.0),
                                  child: Text(
                                    'Range :',
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 80,
                                  child: TextField(
                                    enabled: false,
                                    //controller: position_Range_Max_controller,
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 45, 51, 74)),
                                  ),
                                ),
                                Text('Max')
                              ]),
                              Row(children: [
                                Padding(
                                  padding: const EdgeInsets.all(9.0),
                                  child: Text(
                                    'Raw Count:',
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 80,
                                  child: TextField(
                                    //controller: position_Raw_Min_controller,
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 45, 51, 74)),
                                  ),
                                ),
                                Text('Min'),
                              ]),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(children: [
                                  Text(
                                    'Raw Count:',
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      //controller: position_Raw_Max_controller,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          color: Color.fromARGB(
                                              255, 45, 51, 74)),
                                    ),
                                  ),
                                  Text('Max'),
                                ]),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ExpandableTile(
                        title: Text(
                          'Position Sensor 3'.toUpperCase(),
                          softWrap: true,
                        ),
                        body: Card(
                          elevation: 10,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Row(children: [
                                Padding(
                                  padding: const EdgeInsets.all(9.0),
                                  child: Text(
                                    'Actual Value :',
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 80,
                                  child: TextField(
                                    //controller: position_value__controller,
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 45, 51, 74)),
                                  ),
                                ),
                                // SizedBox(width: 5),
                                Text('mA'),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    height: 30,
                                   // width: 55,
                                    child: ElevatedButton(
                                        onPressed: //_port == null
                                            //? null
                                            () {
                                          // _progress = 0.0;
                                          // _startTask(16);
                                          // getpop_loader(context);
                                          // Future.delayed(Duration(seconds: 18), () {
                                          //   Navigator.pop(context); //pop dialog
                                          // });

                                          // get_position_actual_val();
                                        },
                                        child: Text('Get')),
                                  ),
                                ),
                              ]),
                              Row(children: [
                                Padding(
                                  padding: const EdgeInsets.all(9.0),
                                  child: Text(
                                    'Actual Count :',
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 80,
                                  child: TextField(
                                    //controller: postion_actual_count_controller,
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 45, 51, 74)),
                                  ),
                                ),
                              ]),
                              Row(children: [
                                Padding(
                                  padding: const EdgeInsets.all(9.0),
                                  child: Text(
                                    'Range :',
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 80,
                                  child: TextField(
                                    enabled: false,
                                    //controller: position_Range_Min_controller,
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 45, 51, 74)),
                                  ),
                                ),
                                Text('Min'),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    height: 30,
                                   // width: 55,
                                    child: ElevatedButton(
                                        onPressed: //_port == null
                                            //? null
                                            () {
                                          // _progress = 0.0;
                                          // _startTask(16);
                                          // getpop_loader(context);
                                          // Future.delayed(Duration(seconds: 18), () {
                                          //   Navigator.pop(context); //pop dialog
                                          // });

                                          // get_position_range();
                                        },
                                        child: Text('Get')),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    height: 30,
                                   // width: 55,
                                    child: ElevatedButton(
                                        onPressed: //_port == null
                                            //? null
                                            () {
                                          // _progress = 0.0;
                                          // _startTask(16);
                                          // getpop_loader(context);
                                          // Future.delayed(Duration(seconds: 18), () {
                                          //   Navigator.pop(context); //pop dialog
                                          // });

                                          // Set_position_range();
                                        },
                                        child: Text('Set')),
                                  ),
                                )
                              ]),
                              Row(children: [
                                Padding(
                                  padding: const EdgeInsets.all(9.0),
                                  child: Text(
                                    'Range :',
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 80,
                                  child: TextField(
                                    enabled: false,
                                    //controller: position_Range_Max_controller,
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 45, 51, 74)),
                                  ),
                                ),
                                Text('Max')
                              ]),
                              Row(children: [
                                Padding(
                                  padding: const EdgeInsets.all(9.0),
                                  child: Text(
                                    'Raw Count:',
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 80,
                                  child: TextField(
                                    //controller: position_Raw_Min_controller,
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 45, 51, 74)),
                                  ),
                                ),
                                Text('Min'),
                              ]),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(children: [
                                  Text(
                                    'Raw Count:',
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      //controller: position_Raw_Max_controller,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          color: Color.fromARGB(
                                              255, 45, 51, 74)),
                                    ),
                                  ),
                                  Text('Max'),
                                ]),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ExpandableTile(
                        title: Text(
                          'Position Sensor 4'.toUpperCase(),
                          softWrap: true,
                        ),
                        body: Card(
                          elevation: 10,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Row(children: [
                                Padding(
                                  padding: const EdgeInsets.all(9.0),
                                  child: Text(
                                    'Actual Value :',
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 80,
                                  child: TextField(
                                    //controller: position_value__controller,
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 45, 51, 74)),
                                  ),
                                ),
                                // SizedBox(width: 5),
                                Text('mA'),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    height: 30,
                                   // width: 55,
                                    child: ElevatedButton(
                                        onPressed: //_port == null
                                            //? null
                                            () {
                                          // _progress = 0.0;
                                          // _startTask(16);
                                          // getpop_loader(context);
                                          // Future.delayed(Duration(seconds: 18), () {
                                          //   Navigator.pop(context); //pop dialog
                                          // });

                                          // get_position_actual_val();
                                        },
                                        child: Text('Get')),
                                  ),
                                ),
                              ]),
                              Row(children: [
                                Padding(
                                  padding: const EdgeInsets.all(9.0),
                                  child: Text(
                                    'Actual Count :',
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 80,
                                  child: TextField(
                                    //controller: postion_actual_count_controller,
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 45, 51, 74)),
                                  ),
                                ),
                              ]),
                              Row(children: [
                                Padding(
                                  padding: const EdgeInsets.all(9.0),
                                  child: Text(
                                    'Range :',
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 80,
                                  child: TextField(
                                    enabled: false,
                                    //controller: position_Range_Min_controller,
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 45, 51, 74)),
                                  ),
                                ),
                                Text('Min'),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    height: 30,
                                   // width: 55,
                                    child: ElevatedButton(
                                        onPressed: //_port == null
                                            //? null
                                            () {
                                          // _progress = 0.0;
                                          // _startTask(16);
                                          // getpop_loader(context);
                                          // Future.delayed(Duration(seconds: 18), () {
                                          //   Navigator.pop(context); //pop dialog
                                          // });

                                          // get_position_range();
                                        },
                                        child: Text('Get')),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    height: 30,
                                   // width: 55,
                                    child: ElevatedButton(
                                        onPressed: //_port == null
                                            //? null
                                            () {
                                          // _progress = 0.0;
                                          // _startTask(16);
                                          // getpop_loader(context);
                                          // Future.delayed(Duration(seconds: 18), () {
                                          //   Navigator.pop(context); //pop dialog
                                          // });

                                          // Set_position_range();
                                        },
                                        child: Text('Set')),
                                  ),
                                )
                              ]),
                              Row(children: [
                                Padding(
                                  padding: const EdgeInsets.all(9.0),
                                  child: Text(
                                    'Range :',
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 80,
                                  child: TextField(
                                    enabled: false,
                                    //controller: position_Range_Max_controller,
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 45, 51, 74)),
                                  ),
                                ),
                                Text('Max')
                              ]),
                              Row(children: [
                                Padding(
                                  padding: const EdgeInsets.all(9.0),
                                  child: Text(
                                    'Raw Count:',
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 80,
                                  child: TextField(
                                    //controller: position_Raw_Min_controller,
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 45, 51, 74)),
                                  ),
                                ),
                                Text('Min'),
                              ]),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(children: [
                                  Text(
                                    'Raw Count:',
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      //controller: position_Raw_Max_controller,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          color: Color.fromARGB(
                                              255, 45, 51, 74)),
                                    ),
                                  ),
                                  Text('Max'),
                                ]),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ExpandableTile(
                        title: Text(
                          'Position Sensor 5'.toUpperCase(),
                          softWrap: true,
                        ),
                        body: Card(
                          elevation: 10,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Row(children: [
                                Padding(
                                  padding: const EdgeInsets.all(9.0),
                                  child: Text(
                                    'Actual Value :',
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 80,
                                  child: TextField(
                                    //controller: position_value__controller,
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 45, 51, 74)),
                                  ),
                                ),
                                // SizedBox(width: 5),
                                Text('mA'),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    height: 30,
                                   // width: 55,
                                    child: ElevatedButton(
                                        onPressed: //_port == null
                                            //? null
                                            () {
                                          // _progress = 0.0;
                                          // _startTask(16);
                                          // getpop_loader(context);
                                          // Future.delayed(Duration(seconds: 18), () {
                                          //   Navigator.pop(context); //pop dialog
                                          // });

                                          // get_position_actual_val();
                                        },
                                        child: Text('Get')),
                                  ),
                                ),
                              ]),
                              Row(children: [
                                Padding(
                                  padding: const EdgeInsets.all(9.0),
                                  child: Text(
                                    'Actual Count :',
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 80,
                                  child: TextField(
                                    //controller: postion_actual_count_controller,
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 45, 51, 74)),
                                  ),
                                ),
                              ]),
                              Row(children: [
                                Padding(
                                  padding: const EdgeInsets.all(9.0),
                                  child: Text(
                                    'Range :',
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 80,
                                  child: TextField(
                                    enabled: false,
                                    //controller: position_Range_Min_controller,
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 45, 51, 74)),
                                  ),
                                ),
                                Text('Min'),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    height: 30,
                                   // width: 55,
                                    child: ElevatedButton(
                                        onPressed: //_port == null
                                            //? null
                                            () {
                                          // _progress = 0.0;
                                          // _startTask(16);
                                          // getpop_loader(context);
                                          // Future.delayed(Duration(seconds: 18), () {
                                          //   Navigator.pop(context); //pop dialog
                                          // });

                                          // get_position_range();
                                        },
                                        child: Text('Get')),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    height: 30,
                                   // width: 55,
                                    child: ElevatedButton(
                                        onPressed: //_port == null
                                            //? null
                                            () {
                                          // _progress = 0.0;
                                          // _startTask(16);
                                          // getpop_loader(context);
                                          // Future.delayed(Duration(seconds: 18), () {
                                          //   Navigator.pop(context); //pop dialog
                                          // });

                                          // Set_position_range();
                                        },
                                        child: Text('Set')),
                                  ),
                                )
                              ]),
                              Row(children: [
                                Padding(
                                  padding: const EdgeInsets.all(9.0),
                                  child: Text(
                                    'Range :',
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 80,
                                  child: TextField(
                                    enabled: false,
                                    //controller: position_Range_Max_controller,
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 45, 51, 74)),
                                  ),
                                ),
                                Text('Max')
                              ]),
                              Row(children: [
                                Padding(
                                  padding: const EdgeInsets.all(9.0),
                                  child: Text(
                                    'Raw Count:',
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 80,
                                  child: TextField(
                                    //controller: position_Raw_Min_controller,
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 45, 51, 74)),
                                  ),
                                ),
                                Text('Min'),
                              ]),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(children: [
                                  Text(
                                    'Raw Count:',
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      //controller: position_Raw_Max_controller,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          color: Color.fromARGB(
                                              255, 45, 51, 74)),
                                    ),
                                  ),
                                  Text('Max'),
                                ]),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ExpandableTile(
                        title: Text(
                          'Position Sensor 6'.toUpperCase(),
                          softWrap: true,
                        ),
                        body: Card(
                          elevation: 10,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Row(children: [
                                Padding(
                                  padding: const EdgeInsets.all(9.0),
                                  child: Text(
                                    'Actual Value :',
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 80,
                                  child: TextField(
                                    //controller: position_value__controller,
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 45, 51, 74)),
                                  ),
                                ),
                                // SizedBox(width: 5),
                                Text('mA'),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    height: 30,
                                   // width: 55,
                                    child: ElevatedButton(
                                        onPressed: //_port == null
                                            //? null
                                            () {
                                          // _progress = 0.0;
                                          // _startTask(16);
                                          // getpop_loader(context);
                                          // Future.delayed(Duration(seconds: 18), () {
                                          //   Navigator.pop(context); //pop dialog
                                          // });

                                          // get_position_actual_val();
                                        },
                                        child: Text('Get')),
                                  ),
                                ),
                              ]),
                              Row(children: [
                                Padding(
                                  padding: const EdgeInsets.all(9.0),
                                  child: Text(
                                    'Actual Count :',
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 80,
                                  child: TextField(
                                    //controller: postion_actual_count_controller,
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 45, 51, 74)),
                                  ),
                                ),
                              ]),
                              Row(children: [
                                Padding(
                                  padding: const EdgeInsets.all(9.0),
                                  child: Text(
                                    'Range :',
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 80,
                                  child: TextField(
                                    enabled: false,
                                    //controller: position_Range_Min_controller,
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 45, 51, 74)),
                                  ),
                                ),
                                Text('Min'),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    height: 30,
                                   // width: 55,
                                    child: ElevatedButton(
                                        onPressed: //_port == null
                                            //? null
                                            () {
                                          // _progress = 0.0;
                                          // _startTask(16);
                                          // getpop_loader(context);
                                          // Future.delayed(Duration(seconds: 18), () {
                                          //   Navigator.pop(context); //pop dialog
                                          // });

                                          // get_position_range();
                                        },
                                        child: Text('Get')),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    height: 30,
                                   // width: 55,
                                    child: ElevatedButton(
                                        onPressed: //_port == null
                                            //? null
                                            () {
                                          // _progress = 0.0;
                                          // _startTask(16);
                                          // getpop_loader(context);
                                          // Future.delayed(Duration(seconds: 18), () {
                                          //   Navigator.pop(context); //pop dialog
                                          // });

                                          // Set_position_range();
                                        },
                                        child: Text('Set')),
                                  ),
                                )
                              ]),
                              Row(children: [
                                Padding(
                                  padding: const EdgeInsets.all(9.0),
                                  child: Text(
                                    'Range :',
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 80,
                                  child: TextField(
                                    enabled: false,
                                    //controller: position_Range_Max_controller,
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 45, 51, 74)),
                                  ),
                                ),
                                Text('Max')
                              ]),
                              Row(children: [
                                Padding(
                                  padding: const EdgeInsets.all(9.0),
                                  child: Text(
                                    'Raw Count:',
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 80,
                                  child: TextField(
                                    //controller: position_Raw_Min_controller,
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 45, 51, 74)),
                                  ),
                                ),
                                Text('Min'),
                              ]),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(children: [
                                  Text(
                                    'Raw Count:',
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 80,
                                    child: TextField(
                                      //controller: position_Raw_Max_controller,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          color: Color.fromARGB(
                                              255, 45, 51, 74)),
                                    ),
                                  ),
                                  Text('Max'),
                                ]),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  */
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      } else {
        // return Card(child: Center(child: CircularProgressIndicator()));
        return Container();
      }
    } catch (_, ex) {
      return Container();
    }
  }

// inlet pt before
  get_Inlet_pt_before_actual_val() async {
    try {
      String data = 'AI 1'.toUpperCase() + "\r\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 14)).whenComplete(
        () {
          print(_response);
          String res = _response.join('');
          int i = res.indexOf("AI");

          var aisData = res.substring(i + 5);
          List<String> position_range = aisData.split(' ');
          _inlet_actual_value_before_controller.text = position_range[0];
          _inlet_actual_count_before_controller.text =
              position_range[1].replaceAll('>', '');
          print(_inlet_actual_value_before_controller.text.toString());
          print(_inlet_actual_count_before_controller.text.toString());
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
                        get_Inlet_pt_before_actual_val();
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

  Set_Inlet_pt_before_actual_val() async {
    try {
      String data = ('AI 1' +
                  _inlet_actual_value_before_controller.text +
                  _inlet_actual_count_before_controller.text)
              .toUpperCase() +
          "\r\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 14)).whenComplete(
        () {
          print(_response);
          String res = _response.join('');
          int i = res.indexOf("AI");

          var aisData = res.substring(i + 5);
          List<String> position_range = aisData.split(' ');
          _inlet_actual_value_before_controller.text = position_range[0];
          _inlet_actual_count_before_controller.text =
              position_range[1].replaceAll('>', '');
          print(_inlet_actual_value_before_controller.text.toString());
          print(_inlet_actual_count_before_controller.text.toString());
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
                        Set_Inlet_pt_before_actual_val();
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

  get_Inlet_before_range() async {
    try {
      String data = 'AIS 1'.toUpperCase() + "\r\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 14)).whenComplete(
        () {
          print(_response);
          String res = _response.join('');
          int i = res.indexOf("AI");
          var aisData = res.substring(i + 6);
          List<String> position_range = aisData.split(' ');
          inlet_before_Range_Min_controller.text = position_range[0];
          inlet_before_Range_Max_controller.text = position_range[1];
          inlet_before_Raw_Min_controller.text = position_range[2];
          inlet_before_Raw_Max_controller.text =
              position_range[3].substring(0, 4);
          print(res.substring(i + 3, i + 20));
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
                        get_Inlet_before_range();
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

  Set_Inlet_before_range() async {
    try {
      String data = ('AIS 1' +
                  ' ' +
                  inlet_before_Range_Min_controller.text +
                  ' ' +
                  inlet_before_Range_Max_controller.text +
                  ' ' +
                  '20000' +
                  ' ' +
                  '4000')
              .toUpperCase() +
          "\r\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 14)).whenComplete(
        () {
          print(_response);
          String res = _response.join('');
          int i = res.indexOf("AI");
          var aisData = res.substring(i + 6);
          List<String> position_range = aisData.split(' ');
          inlet_before_Range_Min_controller.text = position_range[0];

          before_inlet_range_min = position_range[0];

          before_inlet_range_max = position_range[1];

          inlet_before_Range_Max_controller.text = position_range[1];

          inlet_before_Raw_Min_controller.text = position_range[2];
          inlet_before_Raw_Max_controller.text =
              position_range[3].substring(0, 4);
          print(res.substring(i + 3, i + 20));
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
                        Set_Inlet_before_range();
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

// inlet pt after
  get_Inlet_pt_after_actual_val() async {
    try {
      String data = 'AI 2'.toUpperCase() + "\r\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 14)).whenComplete(
        () {
          print(_response);
          String res = _response.join('');
          int i = res.indexOf("AI");

          var aisData = res.substring(i + 5);
          List<String> position_range = aisData.split(' ');
          print(position_range);

          _inlet_actual_value_after_controller.text = position_range[0];
          _inlet_actual_count_after_controller.text =
              position_range[1].replaceAll('>', '');
          print(_inlet_actual_value_after_controller.text.toString());
          print(_inlet_actual_count_after_controller.text.toString());
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
                        get_Inlet_pt_after_actual_val();
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

  get_Inlet_after_range() async {
    try {
      String data = 'AIS 2'.toUpperCase() + "\r\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 14)).whenComplete(
        () {
          print(_response);
          String res = _response.join('');
          int i = res.indexOf("AI");
          var aisData = res.substring(i + 6);
          List<String> position_range = aisData.split(' ');
          print(position_range);
          print(position_range[3].substring(0, 4));

          inlet_after_Range_Min_controller.text = position_range[0];
          after_inlet_range_min = position_range[0];
          after_inlet_range_max = position_range[1];
          inlet_after_Range_Max_controller.text = position_range[1];
          inlet_after_Raw_Min_controller.text = position_range[2];
          inlet_after_Raw_Max_controller.text =
              position_range[3].substring(0, 4);
          print(res.substring(i + 3, i + 20));
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
                        get_Inlet_after_range();
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

  Set_Inlet_after_range() async {
    try {
      String data = ('AIS 2' +
                  ' ' +
                  inlet_after_Range_Min_controller.text +
                  ' ' +
                  inlet_after_Range_Max_controller.text +
                  ' ' +
                  '20000' +
                  ' ' +
                  '4000')
              .toUpperCase() +
          "\r\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 14)).whenComplete(
        () {
          print(_response);
          String res = _response.join('');
          int i = res.indexOf("AI");
          var aisData = res.substring(i + 6);
          List<String> position_range = aisData.split(' ');
          inlet_before_Range_Min_controller.text = position_range[0];
          inlet_before_Range_Max_controller.text = position_range[1];
          inlet_before_Raw_Min_controller.text = position_range[2];
          inlet_before_Raw_Max_controller.text =
              position_range[3].substring(0, 4);
          print(res.substring(i + 3, i + 20));
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
                        Set_Inlet_after_range();
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

// oulet pt
  get_outlet_pt_actual_val() async {
    try {
      String data = 'AI 3'.toUpperCase() + "\r\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 14)).whenComplete(
        () {
          print(_response);
          String res = _response.join('');
          int i = res.indexOf("AI");

          var aisData = res.substring(i + 5);
          List<String> position_range = aisData.split(' ');
          print(position_range);

          outlet_value_after_controller.text = position_range[0];
          outlet_actual_count_after_controller.text =
              position_range[1].replaceAll('>', '');
          print(outlet_value_after_controller.text.toString());
          print(outlet_actual_count_after_controller.text.toString());
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
                        get_outlet_pt_actual_val();
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

  get_outlet_range() async {
    try {
      String data = 'AIS 3'.toUpperCase() + "\r\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 14)).whenComplete(
        () {
          print(_response);
          String res = _response.join('');
          int i = res.indexOf("AI");
          var aisData = res.substring(i + 6);
          List<String> position_range = aisData.split(' ');
          print(position_range);
          print(position_range[3].substring(0, 4));

          outlet_Range_Min_controller.text = position_range[0];
          before_outlet_range_min = position_range[0];
          before_outlet_range_max = position_range[1];
          oultet_Range_Max_controller.text = position_range[1];
          outlet_Raw_Min_controller.text = position_range[2];
          outlet_Raw_Max_controller.text = position_range[3].substring(0, 4);
          print(res.substring(i + 3, i + 20));
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
                        get_outlet_range();
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

  Set_outlet_range() async {
    try {
      String data = ('AIS 3' +
                  ' ' +
                  outlet_Range_Min_controller.text +
                  ' ' +
                  oultet_Range_Max_controller.text +
                  ' ' +
                  '20000' +
                  ' ' +
                  '4000')
              .toUpperCase() +
          "\r\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 14)).whenComplete(
        () {
          print(_response);
          String res = _response.join('');
          int i = res.indexOf("AI");
          var aisData = res.substring(i + 6);
          List<String> position_range = aisData.split(' ');
          inlet_before_Range_Min_controller.text = position_range[0];
          inlet_before_Range_Max_controller.text = position_range[1];
          inlet_before_Raw_Min_controller.text = position_range[2];
          inlet_before_Raw_Max_controller.text =
              position_range[3].substring(0, 4);
          print(res.substring(i + 3, i + 20));
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
                        Set_outlet_range();
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

  // position sensor
  get_position_actual_val() async {
    try {
      String data = 'AI 9'.toUpperCase() + "\r\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 14)).whenComplete(
        () {
          print(_response);
          String res = _response.join('');
          int i = res.indexOf("AI");

          var aisData = res.substring(i + 5);
          List<String> position_range = aisData.split(' ');
          print(position_range);

          position_value__controller.text = position_range[0];
          postion_actual_count_controller.text =
              position_range[1].replaceAll('>', '');
          print(position_value__controller.text.toString());
          print(postion_actual_count_controller.text.toString());
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
                        get_position_actual_val();
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

  get_position_range() async {
    try {
      String data = 'AIS 9'.toUpperCase() + "\r\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 14)).whenComplete(
        () {
          print(_response);
          String res = _response.join('');
          int i = res.indexOf("AI");
          var aisData = res.substring(i + 6);
          List<String> position_range = aisData.split(' ');
          print(position_range);
          print(position_range[3].replaceAll('>', ''));

          position_Range_Min_controller.text = position_range[0];
          before_pos_raw_min = position_range[2];
          before_pos_raw_max = position_range[3].replaceAll('>', '');
          position_Range_Max_controller.text = position_range[1];
          position_Raw_Min_controller.text = position_range[2];
          position_Raw_Max_controller.text =
              position_range[3].replaceAll('>', '');
          print(res.substring(i + 6, i + 20));
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
                        get_position_range();
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

  Set_position_range() async {
    try {
      String data = ('AIS 9' +
                  ' ' +
                  '0' +
                  ' ' +
                  '100' +
                  ' ' +
                  position_Raw_Min_controller.text +
                  ' ' +
                  position_Raw_Max_controller.text)
              .toUpperCase() +
          "\r\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 14)).whenComplete(
        () {
          print(_response);
          String res = _response.join('');
          int i = res.indexOf("AI");
          var aisData = res.substring(i + 6);
          List<String> position_range = aisData.split(' ');
          inlet_before_Range_Min_controller.text = position_range[0];
          inlet_before_Range_Max_controller.text = position_range[1];
          inlet_before_Raw_Min_controller.text = position_range[2];
          inlet_before_Raw_Max_controller.text =
              position_range[3].substring(0, 4);
          print(res.substring(i + 3, i + 20));
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
                        Set_position_range();
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

//inlet pt 1

  get_Inlet_pt_1_actual_val() async {
    try {
      String data = 'AI 1'.toUpperCase() + "\r\n";
      _data.clear();
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 14)).whenComplete(
        () {
          print(_data);
          String res = _data.join('');
          int i = res.indexOf("AI");

          var aisData = res.substring(i + 5);
          List<String> position_range = aisData.split(' ');
          _inlet_1_actual_value_controller.text = position_range[0];
          _inlet__1_actual_count_controller.text =
              position_range[1].trim().split('>').first;
          String value1 = position_range[1].trim().split('>').first;
          print(value1);
/*
          print(_inlet_1_actual_value_controller.text.toString());
          print(_inlet__1_actual_count_controller.text.toString());*/
        },
      );
      _data = [];
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
                        get_Inlet_pt_1_actual_val();
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

  get_Inlet_1_range() async {
    try {
      String data = 'AIS 1'.toUpperCase() + "\r\n";
      _data.clear();
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 14)).whenComplete(
        () {
          print(_data);
          String res = _data.join('');
          int i = res.indexOf("AI");
          var aisData = res.substring(i + 6);
          List<String> position_range = aisData.split(' ');
          inlet_1_Range_Min_controller.text = position_range[0];
          inlet_1_Range_Max_controller.text = position_range[1];
          inlet_1_Raw_Min_controller.text = position_range[2];
          inlet_1_Raw_Max_controller.text = position_range[3].substring(0, 4);
          print(res.substring(i + 3, i + 20));
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
                        get_Inlet_1_range();
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

  Set_Inlet_1_range() async {
    try {
      String data = ('AIS 1' +
                  ' ' +
                  inlet_1_Range_Min_controller.text +
                  ' ' +
                  inlet_1_Range_Max_controller.text +
                  ' ' +
                  '20000' +
                  ' ' +
                  '4000')
              .toUpperCase() +
          "\r\n";
      _data.clear();
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 14)).whenComplete(
        () {
          print(_data);
          String res = _data.join('');
          int i = res.indexOf("AI");
          var aisData = res.substring(i + 6);
          List<String> position_range = aisData.split(' ');
          inlet_1_Range_Min_controller.text = position_range[0];

          // inlet_1_range_min = position_range[0];

          // inlet_1_range_max = position_range[1];

          inlet_1_Range_Max_controller.text = position_range[1];

          inlet_1_Raw_Min_controller.text = position_range[2];
          inlet_1_Raw_Max_controller.text = position_range[3].substring(0, 4);
          print(res.substring(i + 3, i + 20));
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
                        Set_Inlet_1_range();
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
  //inlet pt 2

  get_Inlet_pt_2_actual_val() async {
    try {
      String data = 'AI 2'.toUpperCase() + "\r\n";
      _data.clear();
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 14)).whenComplete(
        () {
          print(_data);
          String res = _data.join('');
          int i = res.indexOf("AI");

          var aisData = res.substring(i + 5);
          List<String> position_range = aisData.split(' ');
          _inlet_2_actual_value_controller.text = position_range[0];
          _inlet__2_actual_count_controller.text =
              position_range[1].trim().split('>').first;
          String value1 = position_range[1].trim().split('>').first;
          print(value1);
/*
          print(_inlet_1_actual_value_controller.text.toString());
          print(_inlet__1_actual_count_controller.text.toString());*/
        },
      );
      _data = [];
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
                        get_Inlet_pt_2_actual_val();
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

  get_Inlet_2_range() async {
    try {
      String data = 'AIS 2'.toUpperCase() + "\r\n";
      _data.clear();
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 14)).whenComplete(
        () {
          print(_data);
          String res = _data.join('');
          int i = res.indexOf("AI");
          var aisData = res.substring(i + 6);
          List<String> position_range = aisData.split(' ');
          inlet_2_Range_Min_controller.text = position_range[0];
          inlet_2_Range_Max_controller.text = position_range[1];
          inlet_2_Raw_Min_controller.text = position_range[2];
          inlet_2_Raw_Max_controller.text = position_range[3].substring(0, 4);
          print(res.substring(i + 3, i + 20));
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
                        get_Inlet_2_range();
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

  Set_Inlet_2_range() async {
    try {
      String data = ('AIS 2' +
                  ' ' +
                  inlet_2_Range_Min_controller.text +
                  ' ' +
                  inlet_2_Range_Max_controller.text +
                  ' ' +
                  '20000' +
                  ' ' +
                  '4000')
              .toUpperCase() +
          "\r\n";
      _data.clear();
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 14)).whenComplete(
        () {
          print(_data);
          String res = _data.join('');
          int i = res.indexOf("AI");
          var aisData = res.substring(i + 6);
          List<String> position_range = aisData.split(' ');
          inlet_2_Range_Min_controller.text = position_range[0];

          // inlet_1_range_min = position_range[0];

          // inlet_1_range_max = position_range[1];

          inlet_2_Range_Max_controller.text = position_range[1];

          inlet_2_Raw_Min_controller.text = position_range[2];
          inlet_2_Raw_Max_controller.text = position_range[3].substring(0, 4);
          print(res.substring(i + 3, i + 20));
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
                        Set_Inlet_2_range();
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

  // oulet pt 1
  get_outlet_pt_1_actual_val() async {
    try {
      String data = 'AI 3'.toUpperCase() + "\r\n";
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

          outlet_1_value_controller.text = position_range[0];
          outlet_1_actual_count_controller.text =
              position_range[1].trim().split('>').first;
          print(outlet_1_value_controller.text.toString());
          print(outlet_1_actual_count_controller.text.toString());
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

      _serialData.add('Please Try Again...');
    }
  }

  get_outlet_1_range() async {
    try {
      String data = 'AIS 3'.toUpperCase() + "\r\n";
      _data.clear();
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 10)).whenComplete(
        () {
          print(_data);
          String res = _data.join('');
          int i = res.indexOf("AI");
          var aisData = res.substring(i + 6);
          List<String> position_range = aisData.split(' ');
          print(position_range);
          print(position_range[3].substring(0, 4));

          outlet_1_Range_Min_controller.text = position_range[0];

          oultet_1_Range_Max_controller.text = position_range[1];
          outlet_1_Raw_Min_controller.text = position_range[2];
          outlet_1_Raw_Max_controller.text = position_range[3].substring(0, 4);
          print(res.substring(i + 3, i + 20));
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
                        get_outlet_1_range();
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

  Set_outlet_1_range() async {
    try {
      String data = ('AIS 3' +
                  ' ' +
                  outlet_1_Range_Min_controller.text +
                  ' ' +
                  oultet_1_Range_Max_controller.text +
                  ' ' +
                  '20000' +
                  ' ' +
                  '4000')
              .toUpperCase() +
          "\r\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 14)).whenComplete(
        () {
          print(_response);
          String res = _response.join('');
          int i = res.indexOf("AI");
          var aisData = res.substring(i + 6);
          List<String> position_range = aisData.split(' ');
          outlet_1_Range_Min_controller.text = position_range[0];
          oultet_1_Range_Max_controller.text = position_range[1];
          outlet_1_Raw_Min_controller.text = position_range[2];
          outlet_1_Raw_Max_controller.text = position_range[3].substring(0, 4);
          print(res.substring(i + 3, i + 20));
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
                        Set_outlet_1_range();
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

// oulet pt 2
  get_outlet_pt_2_actual_val() async {
    try {
      String data = 'AI 4'.toUpperCase() + "\r\n";
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

          outlet_2_value_after_controller.text = position_range[0];
          outlet_2_actual_count_after_controller.text =
              position_range[1].trim().split('>').first;
          print(outlet_2_value_after_controller.text.toString());
          print(outlet_2_actual_count_after_controller.text.toString());
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

      _serialData.add('Please Try Again...');
    }
  }

  get_outlet_2_range() async {
    try {
      String data = 'AIS 4'.toUpperCase() + "\r\n";
      _data.clear();
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 10)).whenComplete(
        () {
          print(_data);
          String res = _data.join('');
          int i = res.indexOf("AI");
          var aisData = res.substring(i + 6);
          List<String> position_range = aisData.split(' ');
          print(position_range);
          print(position_range[3].substring(0, 4));

          outlet_2_Range_Min_controller.text = position_range[0];

          oultet_2_Range_Max_controller.text = position_range[1];
          outlet_2_Raw_Min_controller.text = position_range[2];
          outlet_2_Raw_Max_controller.text = position_range[3].substring(0, 4);
          print(res.substring(i + 3, i + 20));
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
                        get_outlet_2_range();
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

  Set_outlet_2_range() async {
    try {
      String data = ('AIS 4' +
                  ' ' +
                  outlet_2_Range_Min_controller.text +
                  ' ' +
                  oultet_2_Range_Max_controller.text +
                  ' ' +
                  '20000' +
                  ' ' +
                  '4000')
              .toUpperCase() +
          "\r\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 14)).whenComplete(
        () {
          print(_response);
          String res = _response.join('');
          int i = res.indexOf("AI");
          var aisData = res.substring(i + 6);
          List<String> position_range = aisData.split(' ');
          outlet_1_Range_Min_controller.text = position_range[0];
          oultet_1_Range_Max_controller.text = position_range[1];
          outlet_1_Raw_Min_controller.text = position_range[2];
          outlet_1_Raw_Max_controller.text = position_range[3].substring(0, 4);
          print(res.substring(i + 3, i + 20));
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
                        Set_outlet_2_range();
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

// oulet pt 3
  get_outlet_pt_3_actual_val() async {
    try {
      String data = 'AI 5'.toUpperCase() + "\r\n";
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

          outlet_3_value_controller.text = position_range[0];
          outlet_3_actual_count_controller.text =
              position_range[1].trim().split('>').first;
          print(outlet_3_value_controller.text.toString());
          print(outlet_3_actual_count_controller.text.toString());
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

      _serialData.add('Please Try Again...');
    }
  }

  get_outlet_3_range() async {
    try {
      String data = 'AIS 5'.toUpperCase() + "\r\n";
      _data.clear();
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 10)).whenComplete(
        () {
          print(_data);
          String res = _data.join('');
          int i = res.indexOf("AI");
          var aisData = res.substring(i + 6);
          List<String> position_range = aisData.split(' ');
          print(position_range);
          print(position_range[3].substring(0, 4));

          outlet_3_Range_Min_controller.text = position_range[0];

          oultet_3_Range_Max_controller.text = position_range[1];
          outlet_3_Raw_Min_controller.text = position_range[2];
          outlet_3_Raw_Max_controller.text = position_range[3].substring(0, 4);
          print(res.substring(i + 3, i + 20));
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
                        get_outlet_3_range();
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

  Set_outlet_3_range() async {
    try {
      String data = ('AIS 5' +
                  ' ' +
                  outlet_3_Range_Min_controller.text +
                  ' ' +
                  oultet_3_Range_Max_controller.text +
                  ' ' +
                  '20000' +
                  ' ' +
                  '4000')
              .toUpperCase() +
          "\r\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 14)).whenComplete(
        () {
          print(_response);
          String res = _response.join('');
          int i = res.indexOf("AI");
          var aisData = res.substring(i + 6);
          List<String> position_range = aisData.split(' ');
          outlet_3_Range_Min_controller.text = position_range[0];
          oultet_3_Range_Max_controller.text = position_range[1];
          outlet_3_Raw_Min_controller.text = position_range[2];
          outlet_3_Raw_Max_controller.text = position_range[3].substring(0, 4);
          print(res.substring(i + 3, i + 20));
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
                        Set_outlet_3_range();
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

// oulet pt 4
  get_outlet_pt_4_actual_val() async {
    try {
      String data = 'AI 6'.toUpperCase() + "\r\n";
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

          outlet_4_value_controller.text = position_range[0];
          outlet_4_actual_count_controller.text =
              position_range[1].trim().split('>').first;
          print(outlet_4_value_controller.text.toString());
          print(outlet_4_actual_count_controller.text.toString());
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

      _serialData.add('Please Try Again...');
    }
  }

  get_outlet_4_range() async {
    try {
      String data = 'AIS 6'.toUpperCase() + "\r\n";
      _data.clear();
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 10)).whenComplete(
        () {
          print(_data);
          String res = _data.join('');
          int i = res.indexOf("AI");
          var aisData = res.substring(i + 6);
          List<String> position_range = aisData.split(' ');
          print(position_range);
          print(position_range[3].substring(0, 4));

          outlet_4_Range_Min_controller.text = position_range[0];

          oultet_4_Range_Max_controller.text = position_range[1];
          outlet_4_Raw_Min_controller.text = position_range[2];
          outlet_4_Raw_Max_controller.text = position_range[3].substring(0, 4);
          print(res.substring(i + 3, i + 20));
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
                        get_outlet_4_range();
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

  Set_outlet_4_range() async {
    try {
      String data = ('AIS 6' +
                  ' ' +
                  outlet_4_Range_Min_controller.text +
                  ' ' +
                  oultet_4_Range_Max_controller.text +
                  ' ' +
                  '20000' +
                  ' ' +
                  '4000')
              .toUpperCase() +
          "\r\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 14)).whenComplete(
        () {
          print(_response);
          String res = _response.join('');
          int i = res.indexOf("AI");
          var aisData = res.substring(i + 6);
          List<String> position_range = aisData.split(' ');
          outlet_4_Range_Min_controller.text = position_range[0];
          oultet_4_Range_Max_controller.text = position_range[1];
          outlet_4_Raw_Min_controller.text = position_range[2];
          outlet_4_Raw_Max_controller.text = position_range[3].substring(0, 4);
          print(res.substring(i + 3, i + 20));
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
                        Set_outlet_4_range();
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

// oulet pt 5
  get_outlet_pt_5_actual_val() async {
    try {
      String data = 'AI 7'.toUpperCase() + "\r\n";
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

          outlet_5_value_controller.text = position_range[0];
          outlet_5_actual_count_controller.text =
              position_range[1].trim().split('>').first;
          print(outlet_5_value_controller.text.toString());
          print(outlet_5_actual_count_controller.text.toString());
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

  get_outlet_5_range() async {
    try {
      String data = 'AIS 7'.toUpperCase() + "\r\n";
      _data.clear();
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 10)).whenComplete(
        () {
          print(_data);
          String res = _data.join('');
          int i = res.indexOf("AI");
          var aisData = res.substring(i + 6);
          List<String> position_range = aisData.split(' ');
          print(position_range);
          print(position_range[3].substring(0, 4));

          outlet_5_Range_Min_controller.text = position_range[0];

          oultet_5_Range_Max_controller.text = position_range[1];
          outlet_5_Raw_Min_controller.text = position_range[2];
          outlet_5_Raw_Max_controller.text = position_range[3].substring(0, 4);
          print(res.substring(i + 3, i + 20));
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
                        get_outlet_5_range();
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

  Set_outlet_5_range() async {
    try {
      String data = ('AIS 7' +
                  ' ' +
                  outlet_5_Range_Min_controller.text +
                  ' ' +
                  oultet_5_Range_Max_controller.text +
                  ' ' +
                  '20000' +
                  ' ' +
                  '4000')
              .toUpperCase() +
          "\r\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 14)).whenComplete(
        () {
          print(_response);
          String res = _response.join('');
          int i = res.indexOf("AI");
          var aisData = res.substring(i + 6);
          List<String> position_range = aisData.split(' ');
          outlet_5_Range_Min_controller.text = position_range[0];
          oultet_5_Range_Max_controller.text = position_range[1];
          outlet_5_Raw_Min_controller.text = position_range[2];
          outlet_5_Raw_Max_controller.text = position_range[3].substring(0, 4);
          print(res.substring(i + 3, i + 20));
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
                        Set_outlet_5_range();
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

// oulet pt 6
  get_outlet_pt_6_actual_val() async {
    try {
      String data = 'AI 8'.toUpperCase() + "\r\n";
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

          outlet_6_value_controller.text = position_range[0];
          outlet_6_actual_count_controller.text =
              position_range[1].trim().split('>').first;
          print(outlet_6_value_controller.text.toString());
          print(outlet_6_actual_count_controller.text.toString());
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

  get_outlet_6_range() async {
    try {
      String data = 'AIS 8'.toUpperCase() + "\r\n";
      _data.clear();
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 10)).whenComplete(
        () {
          print(_data);
          String res = _data.join('');
          int i = res.indexOf("AI");
          var aisData = res.substring(i + 6);
          List<String> position_range = aisData.split(' ');
          print(position_range);
          print(position_range[3].substring(0, 4));

          outlet_6_Range_Min_controller.text = position_range[0];

          oultet_6_Range_Max_controller.text = position_range[1];
          outlet_6_Raw_Min_controller.text = position_range[2];
          outlet_6_Raw_Max_controller.text = position_range[3].substring(0, 4);
          print(res.substring(i + 3, i + 20));
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
                        get_outlet_6_range();
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

  Set_outlet_6_range() async {
    try {
      String data = ('AIS 8' +
                  ' ' +
                  outlet_6_Range_Min_controller.text +
                  ' ' +
                  oultet_6_Range_Max_controller.text +
                  ' ' +
                  '20000' +
                  ' ' +
                  '4000')
              .toUpperCase() +
          "\r\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 14)).whenComplete(
        () {
          print(_response);
          String res = _response.join('');
          int i = res.indexOf("AI");
          var aisData = res.substring(i + 6);
          List<String> position_range = aisData.split(' ');
          outlet_5_Range_Min_controller.text = position_range[0];
          oultet_5_Range_Max_controller.text = position_range[1];
          outlet_5_Raw_Min_controller.text = position_range[2];
          outlet_5_Raw_Max_controller.text = position_range[3].substring(0, 4);
          print(res.substring(i + 3, i + 20));
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
                        Set_outlet_6_range();
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

  // // position sensor pfcmd6 pos 1
  get_position_pt_1_actual_val() async {
    try {
      String data = 'AI 9'.toUpperCase() + "\r\n";
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

          position_value_1_controller.text = position_range[0];
          postion_actual_1_count_controller.text =
              position_range[1].trim().split('>').first;
          print(outlet_6_value_controller.text.toString());
          print(outlet_6_actual_count_controller.text.toString());
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
                        get_position_pt_1_actual_val();
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

  get_position_1_range() async {
    try {
      String data = 'AIS 9'.toUpperCase() + "\r\n";
      _data.clear();
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 10)).whenComplete(
        () {
          print(_data);
          String res = _data.join('');
          int i = res.indexOf("AI");
          var aisData = res.substring(i + 6);
          List<String> position_range = aisData.split(' ');
          print(position_range);
          print(position_range[3].substring(0, 4));

          position_1_Range_Min_controller.text = position_range[0];

          position_1_Range_Max_controller.text = position_range[1];
          position_1_Raw_Min_controller.text = position_range[2];
          position_1_Raw_Max_controller.text =
              position_range[3].substring(0, 4);
          print(res.substring(i + 3, i + 20));
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
                        get_position_1_range();
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

  set_position_1_range() async {
    try {
      String data = ('AIS 9' +
                  ' ' +
                  position_1_Range_Min_controller.text +
                  ' ' +
                  position_1_Range_Max_controller.text +
                  ' ' +
                  '20000' +
                  ' ' +
                  '4000')
              .toUpperCase() +
          "\r\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 14)).whenComplete(
        () {
          print(_response);
          String res = _response.join('');
          int i = res.indexOf("AI");
          var aisData = res.substring(i + 6);
          List<String> position_range = aisData.split(' ');
          position_1_Range_Min_controller.text = position_range[0];
          position_1_Range_Max_controller.text = position_range[1];
          position_1_Raw_Min_controller.text = position_range[2];
          position_1_Raw_Max_controller.text =
              position_range[3].substring(0, 4);
          print(res.substring(i + 3, i + 20));
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
                        set_position_1_range();
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

  // // position sensor pfcmd6 pos 2
  get_position_pt_2_actual_val() async {
    try {
      String data = 'AI 10'.toUpperCase() + "\r\n";
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

          position_value_2_controller.text = position_range[1];
          postion_actual_2_count_controller.text =
              position_range[2].trim().split('>').first;
          print(outlet_6_value_controller.text.toString());
          print(outlet_6_actual_count_controller.text.toString());
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
                        get_position_pt_2_actual_val();
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

  get_position_2_range() async {
    try {
      String data = 'AIS 10'.toUpperCase() + "\r\n";
      _data.clear();
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 10)).whenComplete(
        () {
          print(_data);
          String res = _data.join('');
          int i = res.indexOf("AI");
          var aisData = res.substring(i + 6);
          List<String> position_range = aisData.split(' ');
          print(position_range);
          print(position_range[3].substring(0, 4));

          position_2_Range_Min_controller.text = position_range[1];

          position_2_Range_Max_controller.text = position_range[2];
          position_2_Raw_Min_controller.text = position_range[3];
          position_2_Raw_Max_controller.text =
              position_range[4].substring(0, 4);
          print(res.substring(i + 3, i + 20));
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
                        get_position_2_range();
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

  set_position_2_range() async {
    try {
      String data = ('AIS 10' +
                  ' ' +
                  position_2_Range_Min_controller.text +
                  ' ' +
                  position_2_Range_Max_controller.text +
                  ' ' +
                  '20000' +
                  ' ' +
                  '4000')
              .toUpperCase() +
          "\r\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 14)).whenComplete(
        () {
          print(_response);
          String res = _response.join('');
          int i = res.indexOf("AI");
          var aisData = res.substring(i + 6);
          List<String> position_range = aisData.split(' ');
          position_2_Range_Min_controller.text = position_range[1];
          position_2_Range_Max_controller.text = position_range[2];
          position_2_Raw_Min_controller.text = position_range[3];
          position_2_Raw_Max_controller.text =
              position_range[4].substring(0, 4);
          print(res.substring(i + 3, i + 20));
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
                        set_position_2_range();
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

  // // position sensor pfcmd6 pos 3
  get_position_pt_3_actual_val() async {
    try {
      String data = 'AI 11'.toUpperCase() + "\r\n";
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

          position_value_3_controller.text = position_range[1];
          postion_actual_3_count_controller.text =
              position_range[2].trim().split('>').first;
          print(position_value_3_controller.text.toString());
          print(postion_actual_3_count_controller.text.toString());
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
                        get_position_pt_3_actual_val();
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

  get_position_3_range() async {
    try {
      String data = 'AIS 11'.toUpperCase() + "\r\n";
      _data.clear();
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 10)).whenComplete(
        () {
          print(_data);
          String res = _data.join('');
          int i = res.indexOf("AI");
          var aisData = res.substring(i + 6);
          List<String> position_range = aisData.split(' ');
          print(position_range);
          print(position_range[3].substring(0, 4));

          position_3_Range_Min_controller.text = position_range[1];

          position_3_Range_Max_controller.text = position_range[2];
          position_3_Raw_Min_controller.text = position_range[3];
          position_3_Raw_Max_controller.text =
              position_range[4].substring(0, 4);
          print(res.substring(i + 3, i + 20));
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
                        get_position_3_range();
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

  set_position_3_range() async {
    try {
      String data = ('AIS 11' +
                  ' ' +
                  position_3_Range_Min_controller.text +
                  ' ' +
                  position_3_Range_Max_controller.text +
                  ' ' +
                  '20000' +
                  ' ' +
                  '4000')
              .toUpperCase() +
          "\r\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 14)).whenComplete(
        () {
          print(_response);
          String res = _response.join('');
          int i = res.indexOf("AI");
          var aisData = res.substring(i + 6);
          List<String> position_range = aisData.split(' ');
          position_3_Range_Min_controller.text = position_range[0];
          position_3_Range_Max_controller.text = position_range[1];
          position_3_Raw_Min_controller.text = position_range[2];
          position_3_Raw_Max_controller.text =
              position_range[3].substring(0, 4);
          print(res.substring(i + 3, i + 20));
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
                        set_position_3_range();
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

  // // position sensor pfcmd6 pos 4
  get_position_pt_4_actual_val() async {
    try {
      String data = 'AI 12'.toUpperCase() + "\r\n";
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

          position_value_4_controller.text = position_range[1];
          postion_actual_4_count_controller.text =
              position_range[2].trim().split('>').first;
          print(position_value_4_controller.text.toString());
          print(postion_actual_4_count_controller.text.toString());
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
                        get_position_pt_4_actual_val();
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

  get_position_4_range() async {
    try {
      String data = 'AIS 12'.toUpperCase() + "\r\n";
      _data.clear();
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 10)).whenComplete(
        () {
          print("AIS 12" + _data.join().toString());
          String res = _data.join('');
          int i = res.indexOf("AI");
          var aisData = res.substring(i + 6);
          List<String> position_range = aisData.split(' ');
          print(position_range);
          print(position_range[3].substring(0, 4));

          position_4_Range_Min_controller.text = position_range[1];

          position_4_Range_Max_controller.text = position_range[2];
          position_4_Raw_Min_controller.text = position_range[3];
          position_4_Raw_Max_controller.text =
              position_range[4].substring(0, 4);
          print(res.substring(i + 3, i + 20));
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
                        get_position_4_range();
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

  set_position_4_range() async {
    try {
      String data = ('AIS 12' +
                  ' ' +
                  position_4_Range_Min_controller.text +
                  ' ' +
                  position_4_Range_Max_controller.text +
                  ' ' +
                  '20000' +
                  ' ' +
                  '4000')
              .toUpperCase() +
          "\r\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 14)).whenComplete(
        () {
          print(_response);
          String res = _response.join('');
          int i = res.indexOf("AI");
          var aisData = res.substring(i + 6);
          List<String> position_range = aisData.split(' ');
          position_4_Range_Min_controller.text = position_range[0];
          position_4_Range_Max_controller.text = position_range[1];
          position_4_Raw_Min_controller.text = position_range[2];
          position_4_Raw_Max_controller.text =
              position_range[3].substring(0, 4);
          print(res.substring(i + 3, i + 20));
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
                        set_position_4_range();
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

  // // position sensor pfcmd6 pos 5
  get_position_pt_5_actual_val() async {
    try {
      String data = 'AI 13'.toUpperCase() + "\r\n";
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

          position_value_5_controller.text = position_range[1];
          postion_actual_5_count_controller.text =
              position_range[2].trim().split('>').first;
          print(position_value_5_controller.text.toString());
          print(postion_actual_5_count_controller.text.toString());
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
                        get_position_pt_5_actual_val();
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

  get_position_5_range() async {
    try {
      String data = 'AIS 13'.toUpperCase() + "\r\n";
      _data.clear();
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 10)).whenComplete(
        () {
          print(_data);
          String res = _data.join('');
          int i = res.indexOf("AI");
          var aisData = res.substring(i + 6);
          List<String> position_range = aisData.split(' ');
          print(position_range);
          print(position_range[3].substring(0, 4));

          position_5_Range_Min_controller.text = position_range[1];

          position_5_Range_Max_controller.text = position_range[2];
          position_5_Raw_Min_controller.text = position_range[3];
          position_5_Raw_Max_controller.text =
              position_range[4].substring(0, 4);
          print(res.substring(i + 3, i + 20));
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
                        get_position_5_range();
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

  set_position_5_range() async {
    try {
      String data = ('AIS 13' +
                  ' ' +
                  position_5_Range_Min_controller.text +
                  ' ' +
                  position_5_Range_Max_controller.text +
                  ' ' +
                  '20000' +
                  ' ' +
                  '4000')
              .toUpperCase() +
          "\r\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 14)).whenComplete(
        () {
          print(_response);
          String res = _response.join('');
          int i = res.indexOf("AI");
          var aisData = res.substring(i + 6);
          List<String> position_range = aisData.split(' ');
          position_5_Range_Min_controller.text = position_range[0];
          position_5_Range_Max_controller.text = position_range[1];
          position_5_Raw_Min_controller.text = position_range[2];
          position_5_Raw_Max_controller.text =
              position_range[3].substring(0, 4);
          print(res.substring(i + 3, i + 20));
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
                        set_position_5_range();
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

  // // position sensor pfcmd6 pos 5
  get_position_pt_6_actual_val() async {
    try {
      String data = 'AI 14'.toUpperCase() + "\r\n";
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

          position_value_6_controller.text = position_range[1];
          postion_actual_6_count_controller.text =
              position_range[2].trim().split('>').first;
          print(position_value_6_controller.text.toString());
          print(postion_actual_6_count_controller.text.toString());
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
                        get_position_pt_6_actual_val();
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

  get_position_6_range() async {
    try {
      String data = 'AIS 14'.toUpperCase() + "\r\n";
      _data.clear();
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 10)).whenComplete(
        () {
          print(_data);
          String res = _data.join('');
          int i = res.indexOf("AI");
          var aisData = res.substring(i + 6);
          List<String> position_range = aisData.split(' ');
          print(position_range);
          print(position_range[3].substring(0, 4));

          position_6_Range_Min_controller.text = position_range[1];

          position_6_Range_Max_controller.text = position_range[2];
          position_6_Raw_Min_controller.text = position_range[3];
          position_6_Raw_Max_controller.text =
              position_range[4].substring(0, 4);
          print(res.substring(i + 3, i + 20));
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
                        get_position_6_range();
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

  set_position_6_range() async {
    try {
      String data = ('AIS 14' +
                  ' ' +
                  position_6_Range_Min_controller.text +
                  ' ' +
                  position_6_Range_Max_controller.text +
                  ' ' +
                  '20000' +
                  ' ' +
                  '4000')
              .toUpperCase() +
          "\r\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 14)).whenComplete(
        () {
          print(_response);
          String res = _response.join('');
          int i = res.indexOf("AI");
          var aisData = res.substring(i + 6);
          List<String> position_range = aisData.split(' ');
          position_6_Range_Min_controller.text = position_range[0];
          position_6_Range_Max_controller.text = position_range[1];
          position_6_Raw_Min_controller.text = position_range[2];
          position_6_Raw_Max_controller.text =
              position_range[3].substring(0, 4);
          print(res.substring(i + 3, i + 20));
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
                        set_position_6_range();
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

// get all
  void getAllData() async {
    await getdoors();
    await get_Inlet_pt_before_actual_val();
    await get_Inlet_before_range();
    await get_Inlet_pt_after_actual_val();
    await get_Inlet_after_range();
    await get_outlet_pt_actual_val();
    await get_outlet_range();
    await get_position_actual_val();
    await get_position_range();
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
        () {
          String res = _data.join('');
          int i = res.indexOf("SI");
          deviceType = res.substring(i + 5, i + 13);
          if (deviceType!.toLowerCase().contains('boc')) {
            setState(() {
              deviceType = res.substring(i + 5, i + 13);
            });
            deviceType = _data.join();
            print('Controller Type :' + deviceType!);
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

  void SetAllData() async {
    if ((inlet_before_Range_Min_controller.text.isEmpty &&
            inlet_before_Range_Max_controller.text.isEmpty) ||
        (before_inlet_range_min != inlet_before_Range_Min_controller.text ||
            inlet_before_Range_Max_controller.text != before_inlet_range_max)) {
      await Set_Inlet_before_range();
    }

    if ((inlet_after_Range_Min_controller.text.isEmpty &&
            oultet_Range_Max_controller.text.isEmpty) ||
        (after_inlet_range_min != inlet_after_Range_Min_controller.text ||
            inlet_after_Range_Max_controller.text != after_inlet_range_max)) {
      await Set_Inlet_after_range();
    }

    if ((outlet_Range_Min_controller.text.isEmpty &&
            inlet_after_Range_Max_controller.text.isEmpty) ||
        (before_outlet_range_min != outlet_Range_Min_controller.text ||
            oultet_Range_Max_controller.text != before_outlet_range_max)) {
      await Set_outlet_range();
    }

    if ((position_Range_Min_controller.text.isEmpty &&
            position_Range_Max_controller.text.isEmpty) ||
        (before_pos_raw_min != position_Range_Min_controller.text ||
            position_Range_Max_controller.text != before_pos_raw_max)) {
      await Set_position_range();
    }
  }

  getdoors() async {
    try {
      String data = 'DI'.toUpperCase() + "\r\n";
      await _port!.write(Uint8List.fromList(data.codeUnits));
      await Future.delayed(Duration(seconds: 14)).whenComplete(
        () {
          print(_response);
          String res = _data.join('');
          int i = res.indexOf("DI");
          var aisData = res.substring(i + 3);
          List<String> position_range = aisData.split(' ');
          print(position_range);
          if (position_range[1] == '1') {
            door1.text = 'Open';
          } else {
            door1.text = 'Close';
          }
          String temp = position_range[3].replaceAll('>', '');
          if (temp == '1') {
            door2.text = 'Open';
          } else {
            door2.text = 'Close';
          }

          // door2.text = position_range[3].replaceAll('>', '');
          aisData = '';
          // print(res.substring(i + 6, i + 20));
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
                        getdoors();
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
