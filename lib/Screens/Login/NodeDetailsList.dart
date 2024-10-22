// ignore_for_file: must_be_immutable, unused_field, unnecessary_null_comparison, non_constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:usb_console_application/Screens/AutoCommisitoning/AutoCommistoning.dart';
import 'package:usb_console_application/Widget/dialog.dart';
import 'package:usb_console_application/core/db_helper/node_helper.dart';
import 'package:usb_console_application/models/EngineerModel.dart';
import 'package:usb_console_application/models/NodeDetailsModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:usb_serial/transaction.dart';
import 'package:usb_serial/usb_serial.dart';

class Nodedetailslist extends StatefulWidget {
  String? projectName;
  Nodedetailslist(String project, {super.key}) {
    projectName = project;
  }

  @override
  State<Nodedetailslist> createState() => _NodedetailslistState();
}

class _NodedetailslistState extends State<Nodedetailslist> {
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
    getProjectDetails();
    searchController = TextEditingController();
    UsbSerial.usbEventStream?.listen((UsbEvent event) {
      _getPorts();
    });
    _getPorts();
  }

  getProjectDetails() async {
    await getUserId().whenComplete(() {
      _firstLoad();
    });
    await DatabaseHelper()
        .createProjectTable(widget.projectName?.replaceAll(' ', '_') ?? '');
    _loadFromDatabase();
  }

  @override
  void dispose() {
    super.dispose();
    _connectTo(null);
  }

  late TextEditingController searchController;
  String query = '';

  List<NodeDetailsModel>? _DisplayList = [];
  List<NodeDetailsModel>? _filteredList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.projectName?.toUpperCase()}'),
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.all(8.0),
        //     child: GestureDetector(
        //       child: const Image(
        //         image: AssetImage('assets/images/menu-bar.png'),
        //         height: 25,
        //       ),
        //       onTap: () async {
        //         Navigator.pushAndRemoveUntil(
        //           context,
        //           MaterialPageRoute(
        //               builder: (context) =>
        //                   NodeDetailsOffline(widget.projectName!)),
        //           (Route<dynamic> route) => true,
        //         );
        //       },
        //     ),
        //   )
        // ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: searchController,
                onChanged: (value) => _filterChakNo(value),
                decoration: const InputDecoration(
                  labelText: 'Search by Chak No.',
                  isDense: true,
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)),
                  suffixIcon: Icon(
                    Icons.search,
                    size: 30,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            if (_DisplayList!.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _filteredList?.length ?? 0,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: _port == null
                          ? () => deviceNotConnectedDialog(context)
                          : () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        AutoCommistioningScreen(
                                            _filteredList![index],
                                            widget.projectName!)),
                                (Route<dynamic> route) => true,
                              ).whenComplete(() {
                                _firstLoad();
                              });
                            },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          elevation: 4,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          child: Container(
                            // height: 50,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5)),
                            // padding: const EdgeInsets.only(
                            //     left: 0, right: 0, bottom: 15, top: 0),
                            child: Column(
                              children: [
                                Container(
                                  decoration: const BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(5),
                                          topRight: Radius.circular(5))),
                                  child: Center(
                                      child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _DisplayList![index].chakNo.toString(),
                                        style: const TextStyle(
                                            fontSize: 14, color: Colors.white),
                                      ),
                                      Text(
                                        '( ${(_DisplayList![index].areaName ?? '').trim()} - ${(_DisplayList![index].description ?? '').trim()} )',
                                        softWrap: true,
                                        style: const TextStyle(
                                            color: Colors.white),
                                      )
                                    ],
                                  )),
                                ),
                                // Divider(),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      const Text('Dry Commission'),
                                      Image(
                                        image: AssetImage(
                                          getProcessStatus(int.tryParse(
                                              _filteredList?[index]
                                                      .dryCommissioning ??
                                                  '0')),
                                        ),
                                        height: 15,
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            if (_DisplayList!.isEmpty)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
          ],
        ),
      ),
    );
  }

  getProcessStatus(int? proStatus) {
    String? imagepath;
    if (proStatus == 1) {
      imagepath = 'assets/images/Completed.png';
    } else if (proStatus == 2) {
      imagepath = 'assets/images/fullydone.png';
    } else if (proStatus == 3) {
      imagepath = 'assets/images/Commented.png';
    } else {
      imagepath = 'assets/images/notcompletted.png';
    }
    return imagepath;
  }

  void _filterChakNo(String searchQuery) {
    setState(() {
      query = searchQuery.toLowerCase();
      _filteredList = _DisplayList?.where((node) {
        return node.chakNo != null &&
            node.chakNo!.toLowerCase().contains(query);
      }).toList();
    });
  }

  // This function will load data from the local database
  void _loadFromDatabase() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    List<NodeDetailsModel> storedData = await dbHelper
        .getAllNodeDetails(widget.projectName?.replaceAll(' ', '_'));
    setState(() {
      _DisplayList = storedData;
      _filteredList = _DisplayList;
    });
  }

  // This function will be called when the app launches (see the initState function)
  void _firstLoad() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? conString = preferences.getString('ConString');
      int? userId = preferences.getInt('ProUserId');

      final res = await http.get(Uri.parse(
          'http://wmsservices.seprojects.in/api/PMS/ECMReportStatusByUserId?userId=$userId&Source=oms&conString=$conString'));
      print(
          'http://wmsservices.seprojects.in/api/PMS/ECMReportStatusByUserId?userId=$userId&Source=oms&conString=$conString');
      if (res.statusCode == 200) {
        var json = jsonDecode(res.body);
        List<NodeDetailsModel> fetchedData = <NodeDetailsModel>[];

        DatabaseHelper dbHelper = DatabaseHelper();

        for (var e in json['data']['Response']) {
          NodeDetailsModel nodeDetail = NodeDetailsModel.fromJson(e);
          fetchedData.add(nodeDetail);

          // Insert each node detail into the database
          await dbHelper.insertNodeDetails(
              widget.projectName!.replaceAll(' ', '_'), nodeDetail);
        }

        setState(() {
          _DisplayList = fetchedData;
          _filteredList = _DisplayList;
        });
      } else {
        // Handle the case where the response is not OK
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load data: ${res.statusCode}')),
        );
      }
    } catch (err) {
      throw Exception('Failed to load API');
    }
  }

  getUserId() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? conString = preferences.getString('ConString');
      String? mobileNo = preferences.getString('mobileno');

      final res = await http.get(Uri.parse(
          'http://wmsservices.seprojects.in/api/login/GetUserDetailsByMobile?mobile=$mobileNo&userid=0&conString=$conString'));

      if (res.statusCode == 200) {
        var json = jsonDecode(res.body);
        if (json['Status'] == 'Ok') {
          EngineerNameModel loginResult =
              EngineerNameModel.fromJson(json['data']['Response']);
          preferences.setInt('ProUserId', loginResult.userid!);
          preferences.setBool(
              'isAllowed', loginResult.userid! != null ? true : false);
          return loginResult.firstname.toString();
        } else {
          return '';
        }
      } else {
        return '';
      }
    } catch (err) {
      return '';
    }
  }
}
