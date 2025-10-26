// ignore_for_file: must_be_immutable, unused_field, unnecessary_null_comparison, non_constant_identifier_names, use_build_context_synchronously, avoid_print

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_serial_communication/flutter_serial_communication.dart';
import 'package:flutter_serial_communication/models/device_info.dart';
import 'package:usb_console_application/Widget/dialog.dart';
import 'package:usb_console_application/core/db_helper/node_helper.dart';
import 'package:usb_console_application/models/EngineerModel.dart';
import 'package:usb_console_application/models/NodeDetailsModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:usb_console_application/models/State_list_Model.dart';

class NodedetailslistRMS extends StatefulWidget {
  ProjectModel? projectName;
  NodedetailslistRMS(ProjectModel project, {super.key}) {
    projectName = project;
  }

  @override
  State<NodedetailslistRMS> createState() => _NodedetailslistRMSState();
}

class _NodedetailslistRMSState extends State<NodedetailslistRMS> {
  final FlutterSerialCommunication _serialComm = FlutterSerialCommunication();

  List<DeviceInfo> _devices = [];

  Future<void> _getPorts() async {
    final devices = await _serialComm.getAvailableDevices();
    setState(() {
      _devices = devices;
    });
  }

  @override
  void initState() {
    super.initState();
    getProjectDetails();
    searchController = TextEditingController();
    _serialComm
        .getDeviceConnectionListener()
        .receiveBroadcastStream()
        .listen((isConnected) {
      _getPorts();
    });
    _getPorts();
  }

  getProjectDetails() async {
    await getUserId().whenComplete(() {
      _firstLoad();
    });
    await DatabaseHelper().createProjectTable(
        widget.projectName?.projectName?.replaceAll(' ', '_') ?? '');
    await DatabaseHelper().deleteOldRecords(
        widget.projectName?.projectName?.replaceAll(' ', '_') ?? '');
    _loadFromDatabase();
  }

  @override
  void dispose() {
    super.dispose();
    _serialComm.disconnect();
  }

  late TextEditingController searchController;
  String query = '';

  List<NodeDetailsModel>? _DisplayList = [];
  List<NodeDetailsModel>? _filteredList = [];

  void navigateBasedOnProjectName(int index) {
    final projectName = widget.projectName?.projectName?.toLowerCase();

    if (projectName == null) {
      firmwareNotFound(context);
      return;
    }

    /*Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => RMSAutoCommScreen(
          _filteredList![index],
          widget.projectName?.projectName ?? '',
        ),
      ),
      (Route<dynamic> route) => true,
    ).whenComplete(() {
      _firstLoad();
    });*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.projectName?.projectName?.toUpperCase()}'),
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
                      onTap: _devices.isEmpty
                          ? () => deviceNotConnectedDialog(context)
                          : () {
                              navigateBasedOnProjectName(index);
                            },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          elevation: 4,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5)),
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
                                        _DisplayList![index].rmsNo.toString(),
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
    List<NodeDetailsModel> storedData = await dbHelper.getAllNodeDetails(
        widget.projectName?.projectName?.replaceAll(' ', '_'));
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
          'http://wmsservices.seprojects.in/api/PMS/ECMReportStatusByUserId?userId=$userId&Source=RMS&conString=$conString'));
      debugPrint(
          'http://wmsservices.seprojects.in/api/PMS/ECMReportStatusByUserId?userId=$userId&Source=RMS&conString=$conString');
      if (res.statusCode == 200) {
        var json = jsonDecode(res.body);
        List<NodeDetailsModel> fetchedData = <NodeDetailsModel>[];

        DatabaseHelper dbHelper = DatabaseHelper();

        for (var e in json['data']['Response']) {
          NodeDetailsModel nodeDetail = NodeDetailsModel.fromJson(e);
          fetchedData.add(nodeDetail);

          // Insert each node detail into the database
          await dbHelper.insertNodeDetails(
              (widget.projectName?.projectName ?? '').replaceAll(' ', '_'),
              nodeDetail);
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
