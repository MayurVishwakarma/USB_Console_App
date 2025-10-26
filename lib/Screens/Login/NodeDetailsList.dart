// ignore_for_file: must_be_immutable, unused_field, unnecessary_null_comparison, non_constant_identifier_names, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_serial_communication/flutter_serial_communication.dart';
import 'package:flutter_serial_communication/models/device_info.dart';
import 'package:usb_console_application/Screens/AutoCommisitoning/AutoCommission_2PT.dart';
import 'package:usb_console_application/Screens/AutoCommisitoning/AutoCommistoning.dart';
import 'package:usb_console_application/Screens/AutoCommisitoning/OnePFCMDROMS_screen.dart';
import 'package:usb_console_application/Screens/AutoCommisitoning/OnePFCMD_DryComm.dart';
import 'package:usb_console_application/Widget/dialog.dart';
import 'package:usb_console_application/core/db_helper/node_helper.dart';
import 'package:usb_console_application/models/EngineerModel.dart';
import 'package:usb_console_application/models/NodeDetailsModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:usb_console_application/models/State_list_Model.dart';

class Nodedetailslist extends StatefulWidget {
  ProjectModel? projectName;
  Nodedetailslist(ProjectModel project, {super.key}) {
    projectName = project;
  }

  @override
  State<Nodedetailslist> createState() => _NodedetailslistState();
}

class _NodedetailslistState extends State<Nodedetailslist> {
  final FlutterSerialCommunication _serialComm = FlutterSerialCommunication();
  List<DeviceInfo> _devices = [];
  List<String> deviceTypes = [];
  String? selectedDeviceType = 'OMS';

  /*  Future<bool> _connectTo(UsbDevice? device) async {
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
  } */

  Future<void> _getPorts() async {
    final devices = await _serialComm.getAvailableDevices();
    setState(() {
      _devices = devices;
    });
  }

  @override
  void initState() {
    super.initState();
    updateDeviceTypes(widget.projectName!.eCString ?? '');
    getProjectDetails();
    _getPorts();
    searchController = TextEditingController();
    _serialComm
        .getSerialMessageListener()
        .receiveBroadcastStream()
        .listen((event) {
      debugPrint("Received From Native:  $event");
    });

    _serialComm
        .getDeviceConnectionListener()
        .receiveBroadcastStream()
        .listen((event) {});
  }

  getProjectDetails() async {
    await getUserId().whenComplete(() {
      _firstLoad();
    });
    try {
      await DatabaseHelper().createProjectTable(
          widget.projectName?.projectName?.replaceAll(' ', '_') ?? '');
      await DatabaseHelper().deleteOldRecords(
          widget.projectName?.projectName?.replaceAll(' ', '_') ?? '');
      _loadFromDatabase();
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
    _serialComm.disconnect();
  }

  void updateDeviceTypes(String eCString) {
    deviceTypes = [];
    if (eCString[0] == '1') deviceTypes.add('OMS');
    if (eCString[1] == '1') deviceTypes.add('AMS');
    if (eCString[2] == '1') deviceTypes.add('RMS');
    if (eCString[3] == '1') deviceTypes.add('Lora');
    selectedDeviceType = deviceTypes.first;
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

    if ([
      'kundalia lbc',
      'kundalia rbc',
      'pachore',
      'jamuniya',
      'kundaliarbc_exe',
      'mohanpura r2'
    ].contains(projectName)) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => AutoCommistioningScreen(
            _filteredList![index],
            widget.projectName?.projectName ?? '',
          ),
        ),
        (Route<dynamic> route) => true,
      ).whenComplete(() {
        _firstLoad();
      });
    } else if ([
      'bansujara',
      'garoth',
      'alirajpur',
      'alirajpur demo',
      'chhegaon makhan',
      'chhegaon makhan d',
      'hanuman jugaidevi'
    ].contains(projectName)) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => OnePFCMDScreen(
            _filteredList![index],
            widget.projectName?.projectName ?? '',
          ),
        ),
        (Route<dynamic> route) => true,
      );
    } else if (['shamgarh', 'mohanpurarbc_exe', 'berkheda']
        .contains(projectName)) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => AutoCommission2PTScreen(
            _filteredList![index],
            widget.projectName?.projectName ?? '',
          ),
        ),
        (Route<dynamic> route) => true,
      ).whenComplete(() {
        _firstLoad();
      });
    } else if (['bistan'].contains(projectName)) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => OnePFCMDROMSScreen(
            _filteredList![index],
            widget.projectName?.projectName ?? '',
          ),
        ),
        (Route<dynamic> route) => true,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => AutoCommistioningScreen(
            _filteredList![index],
            widget.projectName?.projectName ?? '',
          ),
        ),
        (Route<dynamic> route) => true,
      ).whenComplete(() {
        _firstLoad();
      });
      // firmwareNotFound(context);
    }
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
                              /* final firmwareVersion = double.tryParse(
                                      _filteredList?[index]
                                              .firmwareVersion
                                              ?.toString() ??
                                          '0.0')
                                  ?.toStringAsFixed(1);

                              switch (firmwareVersion) {
                                case '5.8':
                                case '6.2':
                                case '6.5':
                                  // Check the project name for specific cases
                                  if (widget.projectName?.toLowerCase() ==
                                          'shamgarh' ||
                                      widget.projectName?.toLowerCase() ==
                                          'mohanpurarbc_exe') {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AutoCommission2PTScreen(
                                          _filteredList![index],
                                          widget.projectName!,
                                        ),
                                      ),
                                      (Route<dynamic> route) => true,
                                    ).whenComplete(() {
                                      _firstLoad();
                                    });
                                  } else {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AutoCommistioningScreen(
                                          _filteredList![index],
                                          widget.projectName!,
                                        ),
                                      ),
                                      (Route<dynamic> route) => true,
                                    ).whenComplete(() {
                                      _firstLoad();
                                    });
                                  }
                                  break;

                                case '2.5':
                                  // Specific case for firmware version 2.5
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OnePFCMDScreen(
                                        _filteredList![index],
                                        widget.projectName!,
                                      ),
                                    ),
                                    (Route<dynamic> route) => true,
                                  );
                                  break;

                                default:
                                  // Handle unknown firmware versions
                                  firmwareNotFound(context);
                                  break;
                              }*/
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

  Widget buildDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required void Function(T?) onChanged,
    required String Function(T) itemText,
  }) {
    return SizedBox(
      height: 80,
      width: 200,
      child: DropdownButtonFormField<T>(
        isExpanded: true,
        isDense: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        value: value,
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(itemText(item)),
          );
        }).toList(),
        onChanged: onChanged,
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
          'http://wmsservices.seprojects.in/api/PMS/ECMReportStatusByUserId?userId=$userId&Source=$selectedDeviceType&conString=$conString'));
      print(
          'http://wmsservices.seprojects.in/api/PMS/ECMReportStatusByUserId?userId=$userId&Source=$selectedDeviceType&conString=$conString');
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
