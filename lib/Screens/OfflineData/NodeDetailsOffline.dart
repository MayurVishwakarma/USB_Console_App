// // ignore_for_file: must_be_immutable, unused_field, library_private_types_in_public_api, file_names

// import 'dart:async';
// import 'dart:typed_data';

// import 'package:flutter/material.dart';
// import 'package:usb_console_application/Screens/AutoCommisitoning/AutoCommistoning.dart';
// import 'package:usb_console_application/Widget/dialog.dart';
// import 'package:usb_console_application/core/db_helper/node_helper.dart';
// import 'package:usb_console_application/models/NodeDetailsModel.dart';
// import 'package:usb_serial/transaction.dart';
// import 'package:usb_serial/usb_serial.dart';

// class NodeDetailsOffline extends StatefulWidget {
//   String? projectName;
//   NodeDetailsOffline(String project, {super.key}) {
//     projectName = project;
//   }

//   @override
//   _NodeDetailsOfflineState createState() => _NodeDetailsOfflineState();
// }

// class _NodeDetailsOfflineState extends State<NodeDetailsOffline> {
//   UsbPort? _port;
//   String _status = "Idle";
//   List<UsbDevice> _devices = [];
//   StreamSubscription<String>? _subscription;
//   Transaction<String>? _transaction;
//   Future<bool> _connectTo(UsbDevice? device) async {
//     if (_port != null) {
//       await _port!.close();
//       _port = null;
//     }

//     if (device == null) {
//       setState(() {
//         _status = "Disconnected";
//       });
//       return true;
//     }

//     _port = await device.create();
//     if (!await _port!.open()) {
//       setState(() {
//         _status = "Failed to open port";
//       });
//       return false;
//     }

//     await _port!.setDTR(true);
//     await _port!.setRTS(true);

//     _transaction = Transaction.stringTerminated(
//       _port!.inputStream as Stream<Uint8List>,
//       Uint8List.fromList([13, 10]),
//     );

//     _subscription = _transaction!.stream.listen((String line) {});

//     setState(() {
//       _status = "Connected";
//     });
//     return true;
//   }

//   Future<void> _getPorts() async {
//     final devices = await UsbSerial.listDevices();
//     setState(() {
//       _devices = devices;
//     });
//     _connectTo(devices.first);
//   }

//   List<NodeDetailsModel> _nodeDetailsList = [];
//   List<NodeDetailsModel>? _filteredList;
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadNodeDetails();
//     UsbSerial.usbEventStream?.listen((UsbEvent event) {
//       _getPorts();
//     });
//     _getPorts();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     _connectTo(null);
//   }

//   Future<void> _loadNodeDetails() async {
//     setState(() {
//       _isLoading = true; // Show loading indicator while data is being fetched
//     });

//     DatabaseHelper dbHelper = DatabaseHelper();
//     List<NodeDetailsModel> storedData =
//         await dbHelper.getAllNodeDetails(widget.projectName);

//     setState(() {
//       _nodeDetailsList = storedData;
//       _filteredList = _nodeDetailsList; // Initially, no filter applied
//       _isLoading = false; // Hide loading indicator after data is fetched
//     });
//   }

//   void _filterChakNo(String query) {
//     if (query.isEmpty) {
//       setState(() {
//         _filteredList = _nodeDetailsList;
//       });
//     } else {
//       setState(() {
//         _filteredList = _nodeDetailsList
//             .where((node) =>
//                 node.chakNo?.toLowerCase().contains(query.toLowerCase()) ??
//                 false)
//             .toList();
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Node Details Offline'),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),
//       body: GestureDetector(
//         onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: TextFormField(
//                 onChanged: (value) => _filterChakNo(value),
//                 decoration: const InputDecoration(
//                   labelText: 'Search by Chak No.',
//                   isDense: true,
//                   enabledBorder: OutlineInputBorder(
//                       borderSide: BorderSide(color: Colors.black)),
//                   focusedBorder: OutlineInputBorder(
//                       borderSide: BorderSide(color: Colors.black)),
//                   suffixIcon: Icon(
//                     Icons.search,
//                     size: 30,
//                     color: Colors.black,
//                   ),
//                 ),
//               ),
//             ),
//             _isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : Expanded(
//                     child: ListView.builder(
//                       shrinkWrap: true,
//                       itemCount: _filteredList?.length ?? 0,
//                       itemBuilder: (context, index) {
//                         return _buildNodeCard(_filteredList![index]);
//                       },
//                     ),
//                   ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildNodeCard(NodeDetailsModel nodeDetail) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: InkWell(
//         onTap: _port == null
//             ? () => deviceNotConnectedDialog(context)
//             : () {
//                 Navigator.pushAndRemoveUntil(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => AutoCommistioningScreen(
//                           nodeDetail, widget.projectName!)),
//                   (Route<dynamic> route) => true,
//                 );
//               },
//         child: Card(
//           elevation: 4,
//           shape: const RoundedRectangleBorder(
//             borderRadius: BorderRadius.all(Radius.circular(8)),
//           ),
//           child: Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(5),
//             ),
//             child: Column(
//               children: [
//                 Container(
//                   decoration: const BoxDecoration(
//                       color: Colors.blue,
//                       borderRadius: BorderRadius.only(
//                           topLeft: Radius.circular(5),
//                           topRight: Radius.circular(5))),
//                   child: Center(
//                       child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         nodeDetail.chakNo ?? 'N/A',
//                         style:
//                             const TextStyle(fontSize: 14, color: Colors.white),
//                       ),
//                       Text(
//                         '( ${nodeDetail.areaName?.trim() ?? ''} - ${nodeDetail.description?.trim() ?? ''} )',
//                         softWrap: true,
//                         style: const TextStyle(color: Colors.white),
//                       )
//                     ],
//                   )),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       const Text('Dry Commission'),
//                       Image(
//                         image: AssetImage(
//                           getProcessStatus(
//                               int.tryParse(nodeDetail.dryCommissioning ?? '0')),
//                         ),
//                         height: 15,
//                       ),
//                     ],
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   String getProcessStatus(int? proStatus) {
//     if (proStatus == 1) {
//       return 'assets/images/Completed.png';
//     } else if (proStatus == 2) {
//       return 'assets/images/fullydone.png';
//     } else if (proStatus == 3) {
//       return 'assets/images/Commented.png';
//     } else {
//       return 'assets/images/notcompletted.png';
//     }
//   }
// }
