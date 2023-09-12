// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';

// class ConnectedDevices extends StatefulWidget {
//   const ConnectedDevices({super.key});

//   @override
//   State<ConnectedDevices> createState() => _ConnectedDevicesState();
// }

// class _ConnectedDevicesState extends State<ConnectedDevices> {
//   @override
//   Widget build(BuildContext context) {
//     return RefreshIndicator(
//       onRefresh: () =>
//           FlutterBluePlus.startScan(timeout: Duration(seconds: 60)),
//       child: SingleChildScrollView(
//         child: Column(
//           children: <Widget>[
//             StreamBuilder<List<BluetoothDevice>>(
//               stream: Stream.periodic(const Duration(seconds: 2))
//                   .asyncMap((_) => FlutterBluePlus.connectedDevices),
//               initialData: const [],
//               builder: (c, snapshot) => Column(
//                 children: snapshot.data!
//                     .map((d) => ListTile(
//                           title: Text(d.name),
//                           subtitle: Text(d.id.toString()),
//                           trailing: StreamBuilder<BluetoothDeviceState>(
//                             stream: d.state,
//                             initialData: BluetoothDeviceState.disconnected,
//                             builder: (c, snapshot) {
//                               if (snapshot.data ==
//                                   BluetoothDeviceState.connected) {
//                                 return ElevatedButton(
//                                   child: const Text('Disconnect'),
//                                   onPressed: () async {
//                                     await d.disconnect();
//                                   },
//                                 );
//                               } else if (snapshot.data ==
//                                   BluetoothDeviceState.disconnected) {
//                                 return ElevatedButton(
//                                   child: const Text('Connect'),
//                                   onPressed: () async {
//                                     await d.connect();
//                                   },
//                                 );
//                               } else
//                                 return Text(snapshot.data.toString());
//                             },
//                           ),
//                         ))
//                     .toList(),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
