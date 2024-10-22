// import 'package:flutter/material.dart';
// import 'package:flutter_application_usb2/core/db_helper/node_helper.dart';
// import 'package:flutter_application_usb2/models/NodeDetailsModel.dart';

// class NodeDetailsOffline extends StatefulWidget {
//   static const routeName =
//       '/nodeDetailsOffline';
//   const NodeDetailsOffline({Key? key}) : super(key: key);

//   @override
//   _NodeDetailsOfflineState createState() => _NodeDetailsOfflineState();
// }

// class _NodeDetailsOfflineState extends State<NodeDetailsOffline> {
//   List<NodeDetailsModel> _nodeDetailsList = [];
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadNodeDetails();
//   }

//   Future<void> _loadNodeDetails() async {
//     setState(() {
//       _isLoading = true; // Show loading indicator while data is being fetched
//     });

//     DatabaseHelper dbHelper = DatabaseHelper();
//     List<NodeDetailsModel> storedData = await dbHelper.getAllNodeDetails();

//     print('Fetched Node Details: $storedData');

//     setState(() {
//       _nodeDetailsList = storedData;
//       _isLoading = false; // Hide loading indicator after data is fetched
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Node Details Offline'),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: ElevatedButton(
//               onPressed: _loadNodeDetails,
//               child: Text('Fetch Node Details'),
//             ),
//           ),
//           _isLoading
//               ? Center(child: CircularProgressIndicator())
//               : Expanded(
//                   child: _nodeDetailsList.isEmpty
//                       ? Center(child: Text('No data available.'))
//                       : ListView.builder(
//                           itemCount: _nodeDetailsList.length,
//                           itemBuilder: (context, index) {
//                             final nodeDetail = _nodeDetailsList[index];
//                             return Card(
//                               margin: EdgeInsets.all(8.0),
//                               child: Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       'OmsId: ${nodeDetail.omsId ?? 'N/A'}',
//                                       style: TextStyle(
//                                           fontWeight: FontWeight.bold),
//                                     ),
//                                     Text('ChakNo: ${nodeDetail.chakNo ?? 'N/A'}'),
//                                     Text('AmsId: ${nodeDetail.amsId ?? 'N/A'}'),
//                                     Text('AmsNo: ${nodeDetail.amsNo ?? 'N/A'}'),
//                                     Text('RmsId: ${nodeDetail.rmsId ?? 'N/A'}'),
//                                     Text('RmsNo: ${nodeDetail.rmsNo ?? 'N/A'}'),
//                                     Text('IsChecking: ${nodeDetail.isChecking ?? 'N/A'}'),
//                                     Text('GateWayId: ${nodeDetail.gateWayId ?? 'N/A'}'),
//                                     Text('GatewayNo: ${nodeDetail.gatewayNo ?? 'N/A'}'),
//                                     Text('GatewayName: ${nodeDetail.gatewayName ?? 'N/A'}'),
//                                     Text('Process1: ${nodeDetail.process1 ?? 'N/A'}'),
//                                     Text('Process2: ${nodeDetail.process2 ?? 'N/A'}'),
//                                     Text('Process3: ${nodeDetail.process3 ?? 'N/A'}'),
//                                     Text('Process4: ${nodeDetail.process4 ?? 'N/A'}'),
//                                     Text('Process5: ${nodeDetail.process5 ?? 'N/A'}'),
//                                     Text('Process6: ${nodeDetail.process6 ?? 'N/A'}'),
//                                     Text('AreaName: ${nodeDetail.areaName ?? 'N/A'}'),
//                                     Text('Description: ${nodeDetail.description ?? 'N/A'}'),
//                                     Text('Mechanical: ${nodeDetail.mechanical ?? 'N/A'}'),
//                                     Text('Erection: ${nodeDetail.erection ?? 'N/A'}'),
//                                     Text('Dry Commissioning: ${nodeDetail.dryCommissioning ?? 'N/A'}'),
//                                     Text('Wet Commissioning: ${nodeDetail.wetCommissioning ?? 'N/A'}'),
//                                     Text('Trenching: ${nodeDetail.trenching ?? 'N/A'}'),
//                                     Text('Pipe Installation: ${nodeDetail.pipeInatallation ?? 'N/A'}'),
//                                     Text('Auto Dry Commissioning: ${nodeDetail.autoDryCommissioning ?? 'N/A'}'),
//                                     Text('Auto Wet Commissioning: ${nodeDetail.autoWetCommissioning ?? 'N/A'}'),
//                                     Text('Chainage: ${nodeDetail.chainage ?? 'N/A'}'),
//                                     Text('Coordinates: ${nodeDetail.coordinates ?? 'N/A'}'),
//                                     Text('Network Type: ${nodeDetail.networkType ?? 'N/A'}'),
//                                     Text('Device Type: ${nodeDetail.deviceType ?? 'N/A'}'),
//                                     Text('DeviceId: ${nodeDetail.deviceId ?? 'N/A'}'),
//                                     Text('DeviceNo: ${nodeDetail.deviceNo ?? 'N/A'}'),
//                                     Text('DeviceName: ${nodeDetail.deviceName ?? 'N/A'}'),
//                                     Text('Firmware Version: ${nodeDetail.firmwareVersion ?? 'N/A'}'),
//                                     Text('SubChakQty: ${nodeDetail.subChakQty ?? 'N/A'}'),
//                                     Text('MAC Address: ${nodeDetail.macAddress ?? 'N/A'}'),
//                                   ],
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                 ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:usb_console_application/Screens/AutoCommisitoning/AutoCommistoning.dart';
import 'package:usb_console_application/Widget/dialog.dart';
import 'package:usb_console_application/core/db_helper/node_helper.dart';
import 'package:usb_console_application/models/NodeDetailsModel.dart';
import 'package:usb_serial/transaction.dart';
import 'package:usb_serial/usb_serial.dart';

class NodeDetailsOffline extends StatefulWidget {
  String? projectName;
  NodeDetailsOffline(String project, {super.key}) {
    projectName = project;
  }

  @override
  _NodeDetailsOfflineState createState() => _NodeDetailsOfflineState();
}

class _NodeDetailsOfflineState extends State<NodeDetailsOffline> {
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

  List<NodeDetailsModel> _nodeDetailsList = [];
  List<NodeDetailsModel>? _filteredList;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNodeDetails();
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

  Future<void> _loadNodeDetails() async {
    setState(() {
      _isLoading = true; // Show loading indicator while data is being fetched
    });

    DatabaseHelper dbHelper = DatabaseHelper();
    List<NodeDetailsModel> storedData =
        await dbHelper.getAllNodeDetails(widget.projectName);

    print('Fetched Node Details: $storedData');

    setState(() {
      _nodeDetailsList = storedData;
      _filteredList = _nodeDetailsList; // Initially, no filter applied
      _isLoading = false; // Hide loading indicator after data is fetched
    });
  }

  void _filterChakNo(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredList = _nodeDetailsList;
      });
    } else {
      setState(() {
        _filteredList = _nodeDetailsList
            .where((node) =>
                node.chakNo?.toLowerCase().contains(query.toLowerCase()) ??
                false)
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Node Details Offline'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
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
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _filteredList?.length ?? 0,
                      itemBuilder: (context, index) {
                        return _buildNodeCard(_filteredList![index]);
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildNodeCard(NodeDetailsModel nodeDetail) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: _port == null
            ? () => deviceNotConnectedDialog(context)
            : () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AutoCommistioningScreen(
                          nodeDetail, widget.projectName!)),
                  (Route<dynamic> route) => true,
                );
              },
        child: Card(
          elevation: 4,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
            ),
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
                        nodeDetail.chakNo ?? 'N/A',
                        style:
                            const TextStyle(fontSize: 14, color: Colors.white),
                      ),
                      Text(
                        '( ${nodeDetail.areaName?.trim() ?? ''} - ${nodeDetail.description?.trim() ?? ''} )',
                        softWrap: true,
                        style: const TextStyle(color: Colors.white),
                      )
                    ],
                  )),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Text('Dry Commission'),
                      Image(
                        image: AssetImage(
                          getProcessStatus(
                              int.tryParse(nodeDetail.dryCommissioning ?? '0')),
                        ),
                        height: 15,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  String getProcessStatus(int? proStatus) {
    if (proStatus == 1) {
      return 'assets/images/Completed.png';
    } else if (proStatus == 2) {
      return 'assets/images/fullydone.png';
    } else if (proStatus == 3) {
      return 'assets/images/Commented.png';
    } else {
      return 'assets/images/notcompletted.png';
    }
  }
}
