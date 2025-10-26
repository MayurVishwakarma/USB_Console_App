// // ignore_for_file: unused_field, unused_element, empty_catches, file_names

// import 'dart:async';
// import 'dart:typed_data';

// import 'package:convert/convert.dart';
// import 'package:flutter/material.dart';
// import 'package:usb_console_application/models/AutoCommission.dart';
// import 'package:usb_console_application/models/data.dart';
// import 'package:intl/intl.dart';
// import 'package:usb_serial/usb_serial.dart';

// class UsbProvider extends ChangeNotifier {
//   UsbPort? _port;
//   UsbDevice? usbDevice;

//   final String _status = "Idle";
//   List<UsbDevice> _devices = [];

//   int? _currentIndex;
//   int? get currentIndex => _currentIndex;

//   StreamSubscription<Uint8List>? _dataSubscription;
//   List<UsbDevice> _connectedDevices = [];
//   final List<String> _terminalMessage = [];
//   final List<String> _response = [];
//   final ScrollController listScrollController = ScrollController();
//   UsbPort? get port => _port;
//   List<UsbDevice>? get devices => _devices;
//   bool _isLoading = false;
//   bool get isLoading => _isLoading;
//   AutoCommissionModel autoCommissionModel = AutoCommissionModel();
//   Data _data = Data();
//   Data get data => _data;
//   String? _currentResponse;
//   String get currentResponse => _currentResponse ?? "";

//   String? _controllerType;
//   String? get controllerType => _controllerType;

//   StreamSubscription<Uint8List>? get dataSubscription => _dataSubscription;
//   List<UsbDevice> get connectedDevices => _connectedDevices;
//   List<String> get terminalMessage => _terminalMessage;

//   Future<void> getAllUSBDevice() async {
//     final devices = await UsbSerial.listDevices();
//     updateDeviceList(devices);
//   }

//   updateDeviceList(List<UsbDevice> res) {
//     _devices = res;
//     notifyListeners();
//   }

//   updateConnectedDevices(List<UsbDevice> newDevices) {
//     _connectedDevices = newDevices;
//     notifyListeners();
//   }

//   Future<bool> _connectTo(UsbDevice? device) async {
//     // _response.clear();
//     if (_port != null) {
//       await _port!.close();
//       _port = null;
//     }
//     if (device == null) {
//       // setState(() {
//       //   _status = "Disconnected";
//       //   btntxt = 'Disconnected';
//       // });
//       return true;
//     }
//     _port = await device.create();
//     if (!await _port!.open()) {
//       // setState(() {
//       //   _status = "Failed to open port";
//       // });
//       return false;
//     }
//     await _port!.setDTR(true);
//     await _port!.setRTS(true);
//     await _port!.setPortParameters(
//         115200, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);

//     _dataSubscription = _port!.inputStream!.listen((Uint8List data) {
//       // onDataReceived(data);
//     });

//     // setState(() {
//     //   _status = "Connected";
//     //   btntxt = 'Connected';
//     // });
//     return true;
//   }

//   String response = "";
//   final List<int> _dataBuffer = [];
//   String _currentCommand = "";

//   void _onDataReceived(Uint8List data) {
//     _dataBuffer.addAll(data.toList());
//     String result = String.fromCharCodes(_dataBuffer);
//     String hexData = hex.encode(_dataBuffer);
//     _response.add(hexData);
//     var index = terminalMessage.lastIndexOf(_currentCommand);
//     if (index != -1) {
//       if (terminalMessage.length == (index + 2)) {
//         _terminalMessage.last = result;
//         handleCommands(result);
//         notifyListeners();
//       } else {
//         addTerminalMessage(result);
//       }
//     } else {
//       if (terminalMessage.isNotEmpty) {
//         _terminalMessage.last = result;
//         notifyListeners();
//       }
//     }
//   }

//   addTerminalMessage(String message) {
//     _terminalMessage.add(message);
//     Future.delayed(const Duration(milliseconds: 333)).then((_) {
//       listScrollController.animateTo(
//           listScrollController.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 333),
//           curve: Curves.easeOut);
//     });
//     notifyListeners();
//   }

//   updateIsLoading(bool newLoad) {
//     _isLoading = newLoad;
//     notifyListeners();
//   }

//   updateData(Data newData) {
//     _data = newData;
//     notifyListeners();
//   }

//   updateCurrentResponse(String? newResponse) {
//     _currentResponse = newResponse;
//   }

//   updateControllerType(String? controller) {
//     _controllerType = controller;
//     notifyListeners();
//   }

//   getMid() {
//     String data = 'mid'.toUpperCase();
//     sendMessage(data);
//   }

//   Future<void> sendMessage(String text) async {
//     if (_port != null) {
//       text = text.trim();
//       _currentCommand = text;
//       updateIsLoading(true);
//       _dataBuffer.clear();
//       _terminalMessage.clear();
//       updateCurrentResponse(null);
//       addTerminalMessage(text);
//       if (text.isNotEmpty) {
//         try {
//           _port?.write(Uint8List.fromList(("$text\r\n").codeUnits));

//           // await usbDevice?.output.allSent;
//         } catch (e) {}
//       }
//     } else {}
//   }

//   String reverseString(String input) {
//     return input.split('').reversed.join('');
//   }

//   handleCommands(String result) async {
//     if (result.toLowerCase().contains("recieved_end")) {
//       updateIsLoading(false);
//     }
//     switch (_currentCommand.toUpperCase()) {
//       case "SINM":
//         if (result.contains("SINM") && result.contains("END")) {
//           int i = result.indexOf("SI");
//           var controllerName = result.substring(i + 5, i + 13);
//           updateControllerType(controllerName);
//           getMid();
//         }
//         updateIsLoading(false);
//         break;
//       case "INTG":
//         if (result.contains('BOCOM6')) {
//           var hexIntgValue =
//               reverseString(reverseString(_response.join()).substring(0, 172));
//           autoCommissionModel.updateHexIntgValue(hexIntgValue);
//           // getAllINTGPacket();
//           // getAllPTValues();
//           // for (int i = 1; i <= 6; i++) {
//           //   await getSmodevalve(i);
//           //   await getOmodevalve(i);
//           // }
//           notifyListeners();
//         }
//         updateIsLoading(false);
//         break;
//       case "DTS":
//         if (result.contains("END")) {
//           String res = result;
//           int i = res.indexOf("DT");
//           String dateTime = res.substring(i + 4, i + 21).replaceAll('>', '');
//           List<int> dateParts =
//               dateTime.split(' ').map((part) => int.parse(part)).toList();
//           int year = dateParts[0];
//           int month = dateParts[1];
//           int day = dateParts[2];
//           int hour = dateParts[3];
//           int minute = dateParts[4];
//           int second = dateParts[5];
//           final DateFormat formatter = DateFormat('yyyy/MM/dd HH:mm:ss');

//           String? deviceTime = formatter
//               .format(DateTime(year, month, day, hour, minute, second));
//           String? currTime = formatter.format(DateTime.now());
//           if (deviceTime == currTime) {
//             autoCommissionModel.updateLoraCommunication("Ok");
//             notifyListeners();
//           } else {
//             autoCommissionModel.updateLoraCommunication("Not Ok");
//             notifyListeners();
//           }
//         }
//         updateIsLoading(false);
//         break;
//       case "MID":
//         int i = result.indexOf("MI");
//         String substring = result.substring(i + 4, i + 20);
//         RegExp pattern = RegExp(r'^[0-9A-F]{16}$');
//         bool matchesPattern = pattern.hasMatch(substring);
//         if (matchesPattern) {
//           autoCommissionModel.mid = result.substring(i + 4, i + 20);
//           notifyListeners();
//         }
//         updateIsLoading(false);
//         break;

//       case "FWV":
//         int i = result.indexOf("FW");
//         int j = result.indexOf(">");
//         String substring = result.substring(i + 4, j);
//         autoCommissionModel.firmwareversion = double.tryParse(substring);
//         notifyListeners();
//         break;
//       case "BVTG":
//         int i = result.indexOf("BV");
//         int j = result.indexOf(">");
//         String substring = result.substring(i + 5, j);
//         autoCommissionModel.batteryVlt = double.tryParse(substring);
//         notifyListeners();

//         break;
//       case "SVTG":
//         int i = result.indexOf("SV");
//         int j = result.indexOf(">");
//         String substring = result.substring(i + 5, j);
//         autoCommissionModel.solarVlt = double.tryParse(substring);
//         break;
//       case "DI":
//       default:
//         //PFCMD6ONOFF
//         /*if (_currentCommand == "PFCMD6ONOFF $currentIndex 1") {
//           getValveOpenPFCMD6(result);
//         }

//         //PFCMD6ONOFF
//         if (_currentCommand == "PFCMD6ONOFF $currentIndex 0") {
//           getValveClosePFCMD6(result);
//         }*/

//         if (_currentCommand == "PFCMD6TYPE $currentIndex 2") {}

//         //PFCMD6TYPE check type
//         if (_currentCommand == "PFCMD6TYPE $currentIndex 1") {
//           if (result.toUpperCase().contains("PFCMD6TYPE $currentIndex 1") &&
//               result.toUpperCase().contains("END")) {}
//         }
//         //SMODE check smode
//         if (_currentCommand == "SMODE $currentIndex 2 1 1") {
//           if (result.toUpperCase().contains("SMODE $currentIndex 2 1 1") &&
//               result.toUpperCase().contains("END")) {}
//         }

//         if (_currentCommand == "AI ${(currentIndex ?? 0) + 8}") {
//           if (result.toUpperCase().contains('AI ${(currentIndex ?? 0) + 8}')) {
//             String res = result;
//             int i = res.indexOf("AI");
//             int lastindex = res.indexOf(">");
//             var aisData = res.substring(i + 7, lastindex);
//             List<String> positionRange = aisData.split(' ');
//             // updatePosValUsingCurrentIndex(
//             //     currentIndex ?? 0, double.tryParse(position_range[0]));
//             var poscount = double.tryParse(positionRange[1]);
//             bool isWithinRange =
//                 (poscount ?? 0) >= 3800 && (poscount ?? 0) <= 20000;
//             if (isWithinRange) {
//               // updatePosUsingCurrentIndex(currentIndex ?? 0, "OK");
//             } else {
//               // updatePosUsingCurrentIndex(currentIndex ?? 0, "Faulty");
//             }
//           }
//         }

//         break;
//     }
//   }
// }
