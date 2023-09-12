// import 'package:flutter/material.dart';
// import 'package:flutter_application_usb2/contrrollers/bluetooth_controller.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:get/get.dart';

// class ScanScreen extends StatefulWidget {
//   const ScanScreen({super.key});

//   @override
//   State<ScanScreen> createState() => _ScanScreenState();
// }

// class _ScanScreenState extends State<ScanScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<BluetoothController>(
//       init: BluetoothController(),
//       builder: (controller) {
//         return SingleChildScrollView(
//           child: Column(
//             children: [
//               SizedBox(
//                 height: 10,
//               ),
//               Center(
//                 child: ElevatedButton(
//                   onPressed: controller.scanDevices,
//                   style: ElevatedButton.styleFrom(
//                     foregroundColor: Colors.white,
//                     backgroundColor: Colors.blue,
//                     minimumSize: const Size(350, 55),
//                     shape: const RoundedRectangleBorder(
//                       borderRadius: BorderRadius.all(
//                         Radius.circular(5),
//                       ),
//                     ),
//                   ),
//                   child: const Text(
//                     "Scan",
//                     style: TextStyle(fontSize: 18),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               StreamBuilder<List<ScanResult>>(
//                 stream: controller.scanResults,
//                 builder: (context, snapshot) {
//                   if (snapshot.hasData) {
//                     return ListView.builder(
//                       shrinkWrap: true,
//                       physics: NeverScrollableScrollPhysics(),
//                       itemCount: snapshot.data!.length,
//                       itemBuilder: (context, index) {
//                         final data = snapshot.data![index];
//                         return Card(
//                           elevation: 2,
//                           child: ListTile(
//                             title: Text(data.device.name),
//                             subtitle: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text(data.device.id.id),
//                                 Text(data.rssi.toString()),
//                               ],
//                             ),
//                             trailing: ElevatedButton(
//                               child: const Text('Connect'),
//                               onPressed: () async {
//                                 snapshot.data![index].device
//                                     .connect()
//                                     .whenComplete(() => showDialog(
//                                           context: context,
//                                           builder: (BuildContext context) {
//                                             return AlertDialog(
//                                               title: const Text(
//                                                   'Device Connected'),
//                                               content: Column(
//                                                 mainAxisSize: MainAxisSize.min,
//                                                 crossAxisAlignment:
//                                                     CrossAxisAlignment.start,
//                                                 children: [
//                                                   Text(
//                                                       'Name: ${snapshot.data![index].device.name}'),
//                                                   Text(
//                                                       'ID: ${snapshot.data![index].device.id}'),
//                                                   Text(
//                                                       'Type: ${snapshot.data![index].device.type}'),
//                                                 ],
//                                               ),
//                                               actions: [
//                                                 TextButton(
//                                                   onPressed: () =>
//                                                       Navigator.pop(context),
//                                                   child: const Text('OK'),
//                                                 ),
//                                               ],
//                                             );
//                                           },
//                                         ));
//                               },
//                             ),
//                           ),
//                         );
//                       },
//                     );
//                   } else {
//                     return const Center(
//                       child: Text("No Devices Found"),
//                     );
//                   }
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
