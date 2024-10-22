// // ignore_for_file: use_build_context_synchronously, avoid_print

// import 'dart:convert';
// import 'dart:io';
// import 'dart:typed_data';

// import 'package:convert/convert.dart';
// import 'package:flutter/material.dart';
// import 'package:usb_console_application/Screens/Login/Dashboard.dart';
// import 'package:usb_console_application/Screens/Login/LoginScreen.dart';
// import 'package:usb_console_application/core/utils/appColors..dart';
// import 'package:usb_console_application/core/utils/utils.dart';
// import 'package:usb_console_application/models/AutoCommission.dart';
// import 'package:usb_console_application/models/data.dart';
// import 'package:usb_console_application/models/loginmodel.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
// import 'package:flutter_bluetooth_serial_ble/flutter_bluetooth_serial_ble.dart';
// import 'package:intl/intl.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:pdf/pdf.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:pdf/widgets.dart' as pdfWidgets;

// enum Keys { user }

// enum Methods { getSINM }

// class DataProvider extends ChangeNotifier {
//   BluetoothConnection? bluetoothConnection;
//   List<fbp.BluetoothDevice> _bondedDevices = [];
//   List<fbp.BluetoothDevice> get bondedDevices => _bondedDevices;

//   final ScrollController listScrollController = ScrollController();

//   List<fbp.BluetoothDevice> _connectedDevices = [];
//   List<fbp.BluetoothDevice> get connectedDevices => _connectedDevices;

//   String? _controllerType;
//   String? get controllerType => _controllerType;

//   final List<String> _terminalMessage = [];
//   List<String> get terminalMessage => _terminalMessage;

//   String? _currentResponse;
//   String get currentResponse => _currentResponse ?? "";

//   int? _currentIndex;
//   int? get currentIndex => _currentIndex;

//   AutoCommissionModel autoCommissionModel = AutoCommissionModel();
//   Data _data = Data();
//   Data get data => _data;

//   LoginMasterModel? user;

//   bool _isLoading = false;
//   bool get isLoading => _isLoading;
//   double? _ptSetPoint = 2.5;
//   double? get ptSetpoint => _ptSetPoint;
//   double? upperLimit = 2.5 * 0.9;
//   double? lowerLimit = 2.5 * 1.1;

//   updateSetPoint(double newSetPoint) {
//     _ptSetPoint = newSetPoint;
//     lowerLimit = newSetPoint * 0.9;
//     upperLimit = newSetPoint * 1.1;
//   }

//   bool showSovFlowControlMode = false;

//   final List<String> _response = [];
//   String pdfSavedPath = "";

//   updateFlowControlMode(bool? val) {
//     showSovFlowControlMode = val ?? false;
//     notifyListeners();
//   }

//   updateIsLoading(bool newLoad) {
//     _isLoading = newLoad;
//     notifyListeners();
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

//   updateData(Data newData) {
//     _data = newData;
//     notifyListeners();
//   }

//   updateCurrentResponse(String? newResponse) {
//     _currentResponse = newResponse;
//     print("[Current Res] $currentResponse");
//   }

//   updateControllerType(String? controller) {
//     _controllerType = controller;
//     notifyListeners();
//   }

//   updateBondedDevices(List<fbp.BluetoothDevice> newDevices) {
//     _bondedDevices = newDevices;
//     notifyListeners();
//   }

//   updateConnectedDevices(List<fbp.BluetoothDevice> newDevices) {
//     _connectedDevices = newDevices;
//     notifyListeners();
//   }

//   Future<LoginMasterModel?> getDataFromSharedPreference(Keys key) async {
//     final sharePref = await SharedPreferences.getInstance();
//     var user = sharePref.getString(key.name);
//     if (user != null) {
//       final userJson = json.decode(user);
//       var newUser = LoginMasterModel.fromJson(userJson);
//       return newUser;
//     }
//     return null;
//   }

//   getCurrentUser() async {
//     var newUser = await getDataFromSharedPreference(Keys.user);
//     user = newUser;
//   }

//   Future<bool> storeDataInSharedPreference(Map<String, dynamic> json) async {
//     final sharePref = await SharedPreferences.getInstance();
//     final res = await sharePref.setString(Keys.user.name, jsonEncode(json));
//     return res;
//   }

//   Future<bool> clearSharedPreference() async {
//     final sharePref = await SharedPreferences.getInstance();
//     return await sharePref.clear();
//   }

//   splashScreenInit(BuildContext context) async {
//     var res = await getDataFromSharedPreference(Keys.user);
//     if (res != null) {
//       Navigator.pushReplacementNamed(context, DashboardScreen.routeName);
//     } else {
//       Navigator.pushReplacementNamed(context, LoginPageScreen.routeName);
//     }
//   }

//   Future<void> connectBTDevice(
//       BuildContext context, fbp.BluetoothDevice device) async {
//     try {
//       bluetoothConnection =
//           await BluetoothConnection.toAddress(device.remoteId.toString());
//       print('Connected to the device');
//       updateConnectedDevices([device]);
//       if (bluetoothConnection?.isConnected == true) {
//         Utils.showsnackBar(context, "Bluetooth Device Connected Successfully",
//             color: Colors.green);
//       } else if (bluetoothConnection?.isConnected == false) {
//         Utils.showsnackBar(context, "Bluetooth Device Disconnected",
//             color: Colors.red);
//       }
//       bluetoothConnection?.input?.listen(_onDataReceived).onDone(() {
//         print('Disconnected by remote requesret');
//       });
//     } catch (exception) {
//       connectedDevices.clear();
//       notifyListeners();
//       print('Cannot connect, exception occured');
//     }
//   }

//   clearMessages() {
//     print(terminalMessage);
//     terminalMessage.clear();
//     updateIsLoading(false);
//     notifyListeners();
//   }

//   String response = "";
//   final List<int> _dataBuffer = [];
//   String _currentCommand = "";

//   void _onDataReceived(Uint8List data) {
//     print(data);
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

//   String getSovCommand(int currentIndex) {
//     return "PFCMD6ONOFF $currentIndex 1";
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
//           print(controllerName);
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
//           print(hexIntgValue);
//           getAllINTGPacket();
//           getAllPTValues();
//           for (int i = 1; i <= 6; i++) {
//             await getSmodevalve(i);
//             await getOmodevalve(i);
//           }
//           getAllPositionSensorValue();
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
//           print("DeviceTime: $deviceTime Curr Time: $currTime");
//           if (deviceTime == currTime) {
//             autoCommissionModel.updateLoraCommunication("Ok");
//             notifyListeners();
//           } else {
//             autoCommissionModel.updateLoraCommunication("Not Ok");
//             notifyListeners();
//           }
//           print(autoCommissionModel.loraCommunication);
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

//       default:
//         //PFCMD6ONOFF
//         if (_currentCommand == "PFCMD6ONOFF $currentIndex 1") {
//           getValveOpenPFCMD6(result);
//         }

//         //PFCMD6ONOFF
//         if (_currentCommand == "PFCMD6ONOFF $currentIndex 0") {
//           getValveClosePFCMD6(result);
//         }

//         if (_currentCommand == "PFCMD6TYPE $currentIndex 2") {
//           print("SOV $currentIndex set to Flow mode");
//         }

//         //PFCMD6TYPE check type
//         if (_currentCommand == "PFCMD6TYPE $currentIndex 1") {
//           if (result.toUpperCase().contains("PFCMD6TYPE $currentIndex 1") &&
//               result.toUpperCase().contains("END")) {
//             print("SOV $currentIndex set to Open/Close mode");
//           }
//         }
//         //SMODE check smode
//         if (_currentCommand == "SMODE $currentIndex 2 1 1") {
//           if (result.toUpperCase().contains("SMODE $currentIndex 2 1 1") &&
//               result.toUpperCase().contains("END")) {
//             print("SOV $currentIndex set to Open/Close mode");
//           }
//         }

//         break;
//     }
//   }

//   void getValveOpenPFCMD6(String result) {
//     if (result.toLowerCase().contains("pfcmd$currentIndex on") &&
//         result.toUpperCase().contains("END")) {
//       print("PFCMD $currentIndex is OPEN now");
//       switch (currentIndex) {
//         case 1:
//           data.openvalpos1 = true;
//           break;
//         case 2:
//           data.openvalpos2 = true;
//           break;
//         case 3:
//           data.openvalpos3 = true;
//           break;
//         case 4:
//           data.openvalpos4 = true;
//           break;
//         case 5:
//           data.openvalpos5 = true;
//           break;
//         case 6:
//           data.openvalpos6 = true;
//           break;
//         default:
//           print('open');
//       }
//       updateIsLoading(false);
//     }
//   }

//   bool? getSovValONIndex(int index) {
//     switch (index) {
//       case 1:
//         return (data.sov1 == "OK");
//       case 2:
//         return (data.sov2 == "OK");
//       case 3:
//         return (data.sov3 == "OK");
//       case 4:
//         return (data.sov4 == "OK");
//       case 5:
//         return (data.sov5 == "OK");
//       case 6:
//         return (data.sov6 == "OK");
//       default:
//         return null;
//     }
//   }

//   String getSovValText(int index) {
//     switch (index) {
//       case 1:
//         return data.sov1 ?? "Not Check yet";
//       case 2:
//         return data.sov2 ?? "Not Check yet";
//       case 3:
//         return data.sov3 ?? "Not Check yet";
//       case 4:
//         return data.sov4 ?? "Not Check yet";
//       case 5:
//         return data.sov5 ?? "Not Check yet";
//       case 6:
//         return data.sov6 ?? "Not Check yet";
//       default:
//         return "wrong index";
//     }
//   }

//   toggleSovValText(int index, String value) {
//     switch (index) {
//       case 1:
//         data.sov1 = value;
//         break;
//       case 2:
//         data.sov2 = value;
//         break;
//       case 3:
//         data.sov3 = value;
//         break;
//       case 4:
//         data.sov4 = value;
//         break;
//       case 5:
//         data.sov5 = value;
//         break;
//       case 6:
//         data.sov6 = value;
//         break;
//       default:
//         return "wrong index";
//     }
//     notifyListeners();
//   }

//   setSovFlowControl(int index) async {
//     String data = 'PFCMD6TYPE $index 2'.toUpperCase();
//     updateCurrentIndex(index);
//     sendMessage(data);
//   }

//   void getValveClosePFCMD6(String result) {
//     if (result.toLowerCase().contains("pfcmd$currentIndex off") &&
//         result.toUpperCase().contains("END")) {
//       print("PFCMD $currentIndex is CLOSE now");
//       switch (currentIndex) {
//         case 1:
//           data.closevalpos1 = true;
//           data.sov1 =
//               ((data.openvalpos1 ?? false) && (data.closevalpos1 ?? false))
//                   ? "OK"
//                   : "Faulty";
//           break;
//         case 2:
//           data.closevalpos2 = true;
//           data.sov2 =
//               ((data.openvalpos2 ?? false) && (data.closevalpos2 ?? false))
//                   ? "OK"
//                   : "Faulty";
//           break;
//         case 3:
//           data.closevalpos3 = true;
//           data.sov3 =
//               ((data.openvalpos3 ?? false) && (data.closevalpos3 ?? false))
//                   ? "OK"
//                   : "Faulty";
//           break;
//         case 4:
//           data.closevalpos4 = true;
//           data.sov4 =
//               ((data.openvalpos4 ?? false) && (data.closevalpos4 ?? false))
//                   ? "OK"
//                   : "Faulty";

//           break;
//         case 5:
//           data.closevalpos5 = true;
//           data.sov5 =
//               ((data.openvalpos5 ?? false) && (data.closevalpos5 ?? false))
//                   ? "OK"
//                   : "Faulty";

//           break;
//         case 6:
//           data.closevalpos6 = true;
//           data.sov5 =
//               ((data.openvalpos6 ?? false) && (data.closevalpos6 ?? false))
//                   ? "OK"
//                   : "Faulty";
//           break;
//         default:
//           print('');
//       }
//       updateIsLoading(false);
//     }
//   }

//   String reverseString(String input) {
//     return input.split('').reversed.join('');
//   }

//   getAllINTGPacket() {
//     getFirmwareVersion();
//     getBatterVoltage();
//     getSOLARVoltage();
//     getAlarms();
//   }

//   getAI1() {
//     String? subString3;
//     double ai1;
//     try {
//       subString3 = autoCommissionModel.hexIntgValue?.substring(20, 24);
//       int decimal = int.parse(subString3 ?? "", radix: 16);
//       ai1 = (decimal / 100);
//     } catch (_) {
//       ai1 = 0.0;
//     }
//     return ai1;
//   }

//   String convertm3hrToLps(double data) {
//     double res = 0.0;
//     try {
//       res = (data / 3.6);
//     } catch (_) {}
//     return res.toStringAsFixed(2);
//   }

//   getAI2() {
//     String? subString3;
//     double ai2;
//     try {
//       subString3 = autoCommissionModel.hexIntgValue?.substring(24, 28);
//       int decimal = int.parse(subString3 ?? "", radix: 16);
//       ai2 = (decimal / 100);
//     } catch (_) {
//       ai2 = 0.0;
//     }
//     return ai2;
//   }

//   void getTemprature() {
//     String? subString2;
//     double temp;
//     try {
//       subString2 = autoCommissionModel.hexIntgValue?.substring(8, 12);
//       int decimal = int.parse(subString2 ?? "", radix: 16);
//       temp = (decimal / 100);
//       autoCommissionModel.updateTemp(temp);
//     } catch (ex) {
//       temp = 0;
//       autoCommissionModel.updateTemp(temp);
//     }
//   }

//   getOmodevalve(int mode) async {
//     try {
//       switch (mode) {
//         case 1:
//           // var subString3;
//           String binaryNumber;
//           List<String> openclose = [];
//           try {
//             var subString3 =
//                 autoCommissionModel.hexIntgValue?.substring(158, 160);
//             int decimalNumber = int.parse(subString3 ?? "", radix: 16);
//             // binaryNumber = decimalNumber.toRadixString(2);
//             binaryNumber = decimalNumber.toRadixString(2).padLeft(8, '0');
//           } catch (_) {
//             binaryNumber = '0.0';
//           }

//           if (binaryNumber.length >= 5) {
//             openclose.add(binaryNumber[1]);
//             openclose.add(binaryNumber[2]);
//             openclose.add(binaryNumber[3]);
//           }
//           if (int.parse(openclose[2]) == 1) {
//             data.pt1Omode = 'O';
//           } else if (int.parse(openclose[1]) == 1) {
//             data.pt1Omode = 'F';
//           } else if (int.parse(openclose[0]) == 1) {
//             data.pt1Omode = 'P';
//           } else {
//             data.pt1Omode = 'N';
//           }
//           break;
//         case 2:
//           String binaryNumber;
//           List<String> openclose = [];
//           try {
//             var subString3 =
//                 autoCommissionModel.hexIntgValue?.substring(160, 162);
//             int decimalNumber = int.parse(subString3 ?? "", radix: 16);
//             binaryNumber = decimalNumber.toRadixString(2).padLeft(8, '0');
//             // binaryNumber = decimalNumber.toRadixString(2);
//           } catch (_) {
//             binaryNumber = '0.0';
//           }

//           if (binaryNumber.length >= 5) {
//             openclose.add(binaryNumber[1]);
//             openclose.add(binaryNumber[2]);
//             openclose.add(binaryNumber[3]);
//           }
//           if (openclose[2] == '1') {
//             data.pt1Omode = 'O';
//           } else if (openclose[1] == '1') {
//             data.pt1Omode = 'F';
//           } else if (openclose[0] == '1') {
//             data.pt1Omode = 'P';
//           } else {
//             data.pt1Omode = 'N';
//           }

//           break;
//         case 3:
//           String binaryNumber;
//           List<String> openclose = [];
//           try {
//             var subString3 =
//                 autoCommissionModel.hexIntgValue?.substring(162, 164);
//             int decimalNumber = int.parse(subString3 ?? "", radix: 16);
//             // binaryNumber = decimalNumber.toRadixString(2);
//             binaryNumber = decimalNumber.toRadixString(2).padLeft(8, '0');
//           } catch (_) {
//             binaryNumber = '0.0';
//           }

//           if (binaryNumber.length >= 5) {
//             openclose.add(binaryNumber[1]);
//             openclose.add(binaryNumber[2]);
//             openclose.add(binaryNumber[3]);
//           }
//           if (openclose[2] == '1') {
//             data.pt1Omode = 'O';
//           } else if (openclose[1] == '1') {
//             data.pt1Omode = 'F';
//           } else if (openclose[0] == '1') {
//             data.pt1Omode = 'P';
//           } else {
//             data.pt1Omode = 'N';
//           }

//           break;
//         case 4:
//           String binaryNumber;
//           List<String> openclose = [];
//           try {
//             var subString3 =
//                 autoCommissionModel.hexIntgValue?.substring(164, 166);
//             int decimalNumber = int.parse(subString3 ?? "", radix: 16);
//             // binaryNumber = decimalNumber.toRadixString(2);
//             binaryNumber = decimalNumber.toRadixString(2).padLeft(8, '0');
//           } catch (_) {
//             binaryNumber = '0.0';
//           }

//           if (binaryNumber.length >= 5) {
//             openclose.add(binaryNumber[1]);
//             openclose.add(binaryNumber[2]);
//             openclose.add(binaryNumber[3]);
//           }
//           if (openclose[2] == '1') {
//             data.pt1Omode = 'O';
//           } else if (openclose[1] == '1') {
//             data.pt1Omode = 'F';
//           } else if (openclose[0] == '1') {
//             data.pt1Omode = 'P';
//           } else {
//             data.pt1Omode = 'N';
//           }
//           break;
//         case 5:
//           String binaryNumber;
//           List<String> openclose = [];
//           try {
//             var subString3 =
//                 autoCommissionModel.hexIntgValue?.substring(166, 168);
//             int decimalNumber = int.parse(subString3 ?? "", radix: 16);
//             // binaryNumber = decimalNumber.toRadixString(2);
//             binaryNumber = decimalNumber.toRadixString(2).padLeft(8, '0');
//           } catch (_) {
//             binaryNumber = '0.0';
//           }

//           if (binaryNumber.length >= 5) {
//             openclose.add(binaryNumber[1]);
//             openclose.add(binaryNumber[2]);
//             openclose.add(binaryNumber[3]);
//           }
//           if (openclose[2] == '1') {
//             data.pt1Omode = 'O';
//           } else if (openclose[1] == '1') {
//             data.pt1Omode = 'F';
//           } else if (openclose[0] == '1') {
//             data.pt1Omode = 'P';
//           } else {
//             data.pt1Omode = 'N';
//           }
//           break;
//         case 6:
//           String binaryNumber;
//           List<String> openclose = [];
//           try {
//             var subString3 =
//                 autoCommissionModel.hexIntgValue?.substring(168, 170);
//             int decimalNumber = int.parse(subString3 ?? "", radix: 16);
//             // binaryNumber = decimalNumber.toRadixString(2);

//             binaryNumber = decimalNumber.toRadixString(2).padLeft(8, '0');
//           } catch (_) {
//             binaryNumber = '0.0';
//           }

//           if (binaryNumber.length >= 5) {
//             openclose.add(binaryNumber[1]);
//             openclose.add(binaryNumber[2]);
//             openclose.add(binaryNumber[3]);
//           }
//           if (openclose[2] == '1') {
//             data.pt1Omode = 'O';
//           } else if (openclose[1] == '1') {
//             data.pt1Omode = 'F';
//           } else if (openclose[0] == '1') {
//             data.pt1Omode = 'P';
//           } else {
//             data.pt1Omode = 'N';
//           }
//           break;
//       }
//     } catch (e) {
//       print(e);
//     }
//   }

//   getPFCMDContainerColor(double model, int index) {
//     double posValve = 0.0, flowValve = 0.0;
//     switch (index) {
//       case 1:
//         posValve = (model);
//         flowValve = (model);
//         break;
//       case 2:
//         posValve = (model);
//         flowValve = (model);
//         break;
//       case 3:
//         posValve = (model);
//         flowValve = (model);
//         break;
//       case 4:
//         posValve = (model);
//         flowValve = (model);
//         break;
//       case 5:
//         posValve = (model);
//         flowValve = (model);
//         break;
//       case 6:
//         posValve = model;
//         flowValve = model;
//         break;
//     }
//     if (posValve < 2) {
//       return Colors.red[900];
//     } else if (posValve >= 2 && flowValve == 0) {
//       return Colors.yellow;
//     } else if (posValve >= 2 && flowValve > 0) {
//       return Colors.green;
//     } else {
//       return Colors.grey;
//     }
//   }

//   getDateTime() {
//     String subString3 =
//         (autoCommissionModel.hexIntgValue ?? "").substring(0, 8);
//     int date = int.parse(subString3, radix: 16);
//     var dateTime = DateTime.fromMillisecondsSinceEpoch(date * 1000);
//     var formatter = DateFormat('dd-MM-yyyy');
//     var formattedDate = formatter.format(dateTime);

//     return formattedDate;
//   }

//   getSmodevalve(int mode) async {
//     try {
//       switch (mode) {
//         case 1:
//           String binaryNumber;
//           List<String> autom = [];
//           try {
//             var subString3 =
//                 autoCommissionModel.hexIntgValue?.substring(158, 160);
//             int decimalNumber = int.parse(subString3 ?? "", radix: 16);
//             // binaryNumber = decimalNumber.toRadixString(2);
//             binaryNumber = decimalNumber.toRadixString(2).padLeft(8, '0');
//           } catch (_) {
//             binaryNumber = '0.0';
//           }

//           if (binaryNumber.length >= 5) {
//             autom.add(binaryNumber[4]);
//             autom.add(binaryNumber[5]);
//             autom.add(binaryNumber[6]);
//           }
//           if (autom[0] == "1") {
//             data.pt1Smode = "T";
//           } else if (autom[1] == "1") {
//             data.pt1Smode = "M";
//           } else if (autom[2] == "1") {
//             data.pt1Smode = "A";
//           } else {
//             data.pt1Smode = "N";
//           }
//           break;

//         case 2:
//           String binaryNumber;
//           List<String> autom = [];
//           try {
//             var subString3 =
//                 autoCommissionModel.hexIntgValue?.substring(160, 162);
//             int decimalNumber = int.parse(subString3 ?? "", radix: 16);
//             // binaryNumber = decimalNumber.toRadixString(2);
//             binaryNumber = decimalNumber.toRadixString(2).padLeft(8, '0');
//           } catch (_) {
//             binaryNumber = '0.0';
//           }

//           if (binaryNumber.length >= 5) {
//             autom.add(binaryNumber[4]);
//             autom.add(binaryNumber[5]);
//             autom.add(binaryNumber[6]);
//             // autom.add(binaryNumber[6]);
//           }
//           if (int.parse(autom[0]) == 1) {
//             data.pt2Smode = "T";
//           } else if (int.parse(autom[1]) == 1) {
//             data.pt2Smode = "M";
//           } else if (int.parse(autom[2]) == 1) {
//             data.pt2Smode = "A";
//           } else {
//             data.pt2Smode = "N";
//           }
//           break;
//         case 3:
//           String binaryNumber;
//           List<String> autom = [];
//           try {
//             var subString3 =
//                 autoCommissionModel.hexIntgValue?.substring(162, 164);
//             int decimalNumber = int.parse(subString3 ?? "", radix: 16);
//             // binaryNumber = decimalNumber.toRadixString(2);
//             binaryNumber = decimalNumber.toRadixString(2).padLeft(8, '0');
//           } catch (_) {
//             binaryNumber = '0.0';
//           }

//           if (binaryNumber.length >= 5) {
//             autom.add(binaryNumber[4]);
//             autom.add(binaryNumber[5]);
//             autom.add(binaryNumber[6]);
//           }
//           if (int.parse(autom[0]) == 1) {
//             data.pt3Smode = 'T';
//           } else if (int.parse(autom[1]) == 1) {
//             data.pt3Smode = 'M';
//           } else if (int.parse(autom[2]) == 1) {
//             data.pt3Smode = 'A';
//           } else {
//             data.pt3Smode = "N";
//           }
//           break;
//         case 4:
//           String binaryNumber;
//           List<String> autom = [];
//           try {
//             var subString3 =
//                 autoCommissionModel.hexIntgValue?.substring(164, 166);
//             int decimalNumber = int.parse(subString3 ?? "", radix: 16);
//             // binaryNumber = decimalNumber.toRadixString(2);
//             binaryNumber = decimalNumber.toRadixString(2).padLeft(8, '0');
//           } catch (_) {
//             binaryNumber = '0.0';
//           }

//           if (binaryNumber.length >= 5) {
//             autom.add(binaryNumber[4]);
//             autom.add(binaryNumber[5]);
//             autom.add(binaryNumber[6]);
//           }
//           if (int.parse(autom[0]) == 1) {
//             data.pt4Smode = 'T';
//           } else if (int.parse(autom[1]) == 1) {
//             data.pt4Smode = 'M';
//           } else if (int.parse(autom[2]) == 1) {
//             data.pt4Smode = 'A';
//           } else {
//             data.pt4Smode = 'N';
//           }
//           break;
//         case 5:
//           String binaryNumber;
//           List<String> autom = [];
//           try {
//             var subString3 =
//                 autoCommissionModel.hexIntgValue?.substring(166, 168);
//             int decimalNumber = int.parse(subString3 ?? "", radix: 16);
//             // binaryNumber = decimalNumber.toRadixString(2);
//             binaryNumber = decimalNumber.toRadixString(2).padLeft(8, '0');
//           } catch (_) {
//             binaryNumber = '0.0';
//           }

//           if (binaryNumber.length >= 5) {
//             autom.add(binaryNumber[4]);
//             autom.add(binaryNumber[5]);
//             autom.add(binaryNumber[6]);
//           }
//           if (int.parse(autom[0]) == 1) {
//             data.pt5Smode = 'T';
//           } else if (int.parse(autom[1]) == 1) {
//             data.pt5Smode = 'M';
//           } else if (int.parse(autom[2]) == 1) {
//             data.pt5Smode = 'A';
//           } else {
//             data.pt5Smode = 'N';
//           }
//           break;
//         case 6:
//           String binaryNumber;
//           List<String> autom = [];
//           try {
//             var subString3 =
//                 autoCommissionModel.hexIntgValue?.substring(168, 170);
//             int decimalNumber = int.parse(subString3 ?? "", radix: 16);
//             // binaryNumber = decimalNumber.toRadixString(2);
//             binaryNumber = decimalNumber.toRadixString(2).padLeft(8, '0');
//           } catch (_) {
//             binaryNumber = '0.0';
//           }

//           if (binaryNumber.length >= 5) {
//             autom.add(binaryNumber[4]);
//             autom.add(binaryNumber[5]);
//             autom.add(binaryNumber[6]);
//           }
//           if (int.parse(autom[0]) == 1) {
//             data.pt6Smode = 'T';
//           } else if (int.parse(autom[1]) == 1) {
//             data.pt6Smode = 'M';
//           } else if (int.parse(autom[2]) == 1) {
//             data.pt6Smode = 'A';
//           } else {
//             data.pt6Smode = 'N';
//           }
//           break;
//       }
//     } catch (e) {
//       print(e);
//     }
//   }

//   String getOutletbar_pfcmd_2() {
//     String subString3;
//     String outletbar;
//     try {
//       subString3 = (autoCommissionModel.hexIntgValue ?? "").substring(58, 62);
//       int decimal = int.parse(subString3, radix: 16);
//       outletbar = (decimal / 100).toString();
//     } catch (ex) {
//       outletbar = '0.0';
//     }
//     return outletbar;
//   }

//   String getPostion_pfcmd_2() {
//     String? subString3;
//     String postionvalue;
//     try {
//       subString3 = autoCommissionModel.hexIntgValue?.substring(62, 66);
//       int decimal = int.parse(subString3, radix: 16);
//       postionvalue = (decimal / 100).toString();
//     } catch (ex) {
//       postionvalue = '0.0';
//     }
//     return postionvalue;
//   }

//   String getflowvalue_pfcmd_2() {
//     String? subString3;
//     String flowvalue;
//     try {
//       subString3 = autoCommissionModel.hexIntgValue?.substring(66, 70);
//       int decimal = int.parse(subString3, radix: 16);
//       flowvalue = (decimal / 100).toString();
//     } catch (ex) {
//       flowvalue = '0.0';
//     }
//     return flowvalue;
//   }

//   String getDailyvol_pfcmd_2() {
//     String? subString3;
//     String dailyvol;
//     try {
//       subString3 = autoCommissionModel.hexIntgValue?.substring(70, 74);
//       int decimal = int.parse(subString3, radix: 16);
//       dailyvol = (decimal / 100).toString();
//     } catch (ex) {
//       dailyvol = '0.0';
//     }
//     return dailyvol;
//   }

// // pfcmd 3 data

//   String getOutletbar_pfcmd_3() {
//     String? subString3;
//     String outletbar;
//     try {
//       subString3 = autoCommissionModel.hexIntgValue?.substring(78, 82);
//       int decimal = int.parse(subString3, radix: 16);
//       outletbar = (decimal / 100).toString();
//     } catch (ex) {
//       outletbar = '0.0';
//     }
//     return outletbar;
//   }

//   String getPostion_pfcmd_3() {
//     String? subString3;
//     String postionvalue;
//     try {
//       subString3 = autoCommissionModel.hexIntgValue?.substring(82, 86);
//       int decimal = int.parse(subString3, radix: 16);
//       postionvalue = (decimal / 100).toString();
//     } catch (ex) {
//       postionvalue = '0.0';
//     }
//     return postionvalue;
//   }

//   String getflowvalue_pfcmd_3() {
//     String? subString3;
//     String flowvalue;
//     try {
//       subString3 = autoCommissionModel.hexIntgValue?.substring(86, 90);
//       int decimal = int.parse(subString3, radix: 16);
//       flowvalue = (decimal / 100).toString();
//     } catch (ex) {
//       flowvalue = '0.0';
//     }
//     return flowvalue;
//   }

//   String getDailyvol_pfcmd_3() {
//     String? subString3;
//     String dailyvol;
//     try {
//       subString3 = autoCommissionModel.hexIntgValue?.substring(90, 94);
//       int decimal = int.parse(subString3, radix: 16);
//       dailyvol = (decimal / 100).toString();
//     } catch (ex) {
//       dailyvol = '0.0';
//     }
//     return dailyvol;
//   }

// // pfcmd 4 data

//   String getOutletbar_pfcmd_4() {
//     String? subString3;
//     String outletbar;
//     try {
//       subString3 = autoCommissionModel.hexIntgValue?.substring(98, 102);
//       int decimal = int.parse(subString3, radix: 16);
//       outletbar = (decimal / 100).toString();
//     } catch (ex) {
//       outletbar = '0.0';
//     }
//     return outletbar;
//   }

//   String getPostion_pfcmd_4() {
//     String? subString3;
//     String postionvalue;
//     try {
//       subString3 = autoCommissionModel.hexIntgValue?.substring(108, 106);
//       int decimal = int.parse(subString3 ?? '', radix: 16);
//       postionvalue = (decimal / 100).toString();
//     } catch (ex) {
//       postionvalue = '0.0';
//     }
//     return postionvalue;
//   }

//   String getflowvalue_pfcmd_4() {
//     String? subString3;
//     String flowvalue;
//     try {
//       subString3 = autoCommissionModel.hexIntgValue?.substring(106, 110);
//       int decimal = int.parse(subString3 ?? '', radix: 16);
//       flowvalue = (decimal / 100).toString();
//     } catch (ex) {
//       flowvalue = '0.0';
//     }
//     return flowvalue;
//   }

//   String getDailyvol_pfcmd_4() {
//     String? subString3;
//     String dailyvol;
//     try {
//       subString3 = autoCommissionModel.hexIntgValue?.substring(110, 114);
//       int decimal = int.parse(subString3 ?? '', radix: 16);
//       dailyvol = (decimal / 100).toString();
//     } catch (_) {
//       dailyvol = '0.0';
//     }
//     return dailyvol;
//   }

//   // pfcmd 5 data

//   String getOutletbar_pfcmd_5() {
//     String? subString3;
//     String outletbar;
//     try {
//       subString3 = autoCommissionModel.hexIntgValue?.substring(118, 122);
//       int decimal = int.parse(subString3 ?? '', radix: 16);
//       outletbar = (decimal / 100).toString();
//     } catch (ex) {
//       outletbar = '0.0';
//     }
//     return outletbar;
//   }

//   String getPostion_pfcmd_5() {
//     String? subString3;
//     String postionvalue;
//     try {
//       subString3 = autoCommissionModel.hexIntgValue?.substring(122, 126);
//       int decimal = int.parse(subString3 ?? '', radix: 16);
//       postionvalue = (decimal / 100).toString();
//     } catch (ex) {
//       postionvalue = '0.0';
//     }
//     return postionvalue;
//   }

//   String getflowvalue_pfcmd_5() {
//     String? subString3;
//     String flowvalue;
//     try {
//       subString3 = autoCommissionModel.hexIntgValue?.substring(126, 130);
//       int decimal = int.parse(subString3 ?? '', radix: 16);
//       flowvalue = (decimal / 100).toString();
//     } catch (ex) {
//       flowvalue = '0.0';
//     }
//     return flowvalue;
//   }

//   String getDailyvol_pfcmd_5() {
//     String? subString3;
//     String dailyvol;
//     try {
//       subString3 = autoCommissionModel.hexIntgValue?.substring(130, 134);
//       int decimal = int.parse(subString3 ?? '', radix: 16);
//       dailyvol = (decimal / 100).toString();
//     } catch (_) {
//       dailyvol = '0.0';
//     }
//     return dailyvol;
//   }

// // 6 pfcnd data

//   String getOutletbar_pfcmd_6() {
//     String? subString3;
//     String outletbar;
//     try {
//       subString3 = autoCommissionModel.hexIntgValue?.substring(138, 142);
//       int decimal = int.parse(subString3 ?? '', radix: 16);
//       outletbar = (decimal / 100).toString();
//     } catch (ex) {
//       outletbar = '0.0';
//     }
//     return outletbar;
//   }

//   String getPostion_pfcmd_6() {
//     String? subString3;
//     String postionvalue;
//     try {
//       subString3 = autoCommissionModel.hexIntgValue?.substring(142, 146);
//       int decimal = int.parse(subString3 ?? '', radix: 16);
//       postionvalue = (decimal / 100).toString();
//     } catch (ex) {
//       postionvalue = '0.0';
//     }
//     return postionvalue;
//   }

//   String getflowvalue_pfcmd_6() {
//     String? subString3;
//     String flowvalue;
//     try {
//       subString3 = autoCommissionModel.hexIntgValue?.substring(146, 150);
//       int decimal = int.parse(subString3 ?? '', radix: 16);
//       flowvalue = (decimal / 100).toString();
//     } catch (_) {
//       flowvalue = '0.0';
//     }
//     return flowvalue;
//   }

//   String getDailyvol_pfcmd_6() {
//     String? subString3;
//     String dailyvol;
//     try {
//       subString3 = autoCommissionModel.hexIntgValue?.substring(150, 154);
//       int decimal = int.parse(subString3 ?? '', radix: 16);
//       dailyvol = (decimal / 100).toString();
//     } catch (_) {
//       dailyvol = '0.0';
//     }
//     return dailyvol;
//   }

//   void getFirmwareVersion() {
//     String? subString3;
//     double firmwareversion;
//     try {
//       subString3 = autoCommissionModel.hexIntgValue?.substring(28, 30);
//       int decimal = int.parse(subString3 ?? "", radix: 16);
//       firmwareversion = (decimal / 10);
//     } catch (_) {
//       firmwareversion = 0.0;
//     }
//     autoCommissionModel.updateFirmwareVersion(firmwareversion);
//     notifyListeners();
//   }

//   void getSOLARVoltage() {
//     String? subString3;
//     double solarVoltage;
//     try {
//       subString3 = autoCommissionModel.hexIntgValue?.substring(16, 20);
//       int decimal = int.parse(subString3 ?? "", radix: 16);
//       solarVoltage = (decimal / 100).toDouble();
//     } catch (_) {
//       solarVoltage = 0.0;
//     }
//     autoCommissionModel.updateSolarVlt(solarVoltage);
//     notifyListeners();
//   }

//   void getBatterVoltage() {
//     String? subString2;
//     double batteryVoltage;
//     try {
//       subString2 = autoCommissionModel.hexIntgValue?.substring(12, 16);
//       int decimal = int.parse(subString2 ?? "", radix: 16);
//       batteryVoltage = (decimal / 100);
//     } catch (_) {
//       batteryVoltage = 0.0;
//     }
//     autoCommissionModel.updateBatteryVlt(batteryVoltage);
//     notifyListeners();
//   }

//   void getAlarms() {
//     String? hexvalue;
//     String binaryNumber;
//     List<String> binaryValues = [];

//     try {
//       hexvalue = autoCommissionModel.hexIntgValue?.substring(30, 34);
//       int decimalNumber = int.parse(hexvalue ?? "", radix: 16);
//       binaryNumber = decimalNumber.toRadixString(2).padLeft(16, '0');
//     } catch (_) {
//       binaryNumber = '0.0';
//     }

//     if (binaryNumber.length >= 16) {
//       binaryValues.add(binaryNumber[15]);
//       binaryValues.add(binaryNumber[14]);
//     }
//     autoCommissionModel.updateDoor1(binaryNumber[15] == '0' ? 'OPEN' : 'CLOSE');
//     autoCommissionModel.updateDoor2(binaryNumber[14] == '0' ? 'OPEN' : 'CLOSE');
//     notifyListeners();
//   }

//   getSolarColor(double? levelStatus) {
//     if (levelStatus == null) {
//       return Colors.red;
//     } else if (levelStatus <= 0) {
//       return Colors.red;
//     } else if (levelStatus > 0 && levelStatus < 21) {
//       return Colors.green;
//     } else {
//       return Colors.red;
//     }
//   }

//   setDatetime() async {
//     try {
//       String data = "${('dts 0000 00 00 00 00 00').toUpperCase()}\r\n";
//       await sendMessage(data);
//       await Future.delayed(const Duration(seconds: 5)).whenComplete(() async {
//         String rebootData = "${'RBT'.toUpperCase()}\r\n";
//         await sendMessage(rebootData);
//         await Future.delayed(const Duration(seconds: 16))
//             .whenComplete(() async {
//           getDatetime();
//         });
//       });
//     } catch (_) {
//       addTerminalMessage('Please Try Again...');
//     }
//   }

//   getDatetime() async {
//     try {
//       String data = "${'dts'.toUpperCase()}\r\n";
//       sendMessage(data);
//     } catch (e) {
//       debugPrint(e.toString());
//     }
//   }

//   void clearResponse() {
//     response = "";
//   }

//   sendINTGMessage() async {
//     String data = 'INTG';
//     await sendMessage(data);
//     autoCommissionModel.updateHexIntgValue(null);
//   }

//   Future<void> sendMessage(String text) async {
//     if (bluetoothConnection?.isConnected == true) {
//       text = text.trim();
//       _currentCommand = text;
//       updateIsLoading(true);
//       _dataBuffer.clear();
//       _terminalMessage.clear();
//       updateCurrentResponse(null);
//       addTerminalMessage(text);
//       if (text.isNotEmpty) {
//         try {
//           bluetoothConnection?.output
//               .add(Uint8List.fromList(("$text\r\n").codeUnits));
//           await bluetoothConnection?.output.allSent;
//         } catch (e) {
//           print(e);
//         }
//       }
//     } else {
//       print("bleutooth device is not connected");
//     }
//   }

//   disconnectBTConnection(BuildContext context) {
//     bluetoothConnection?.finish().whenComplete(() {
//       Utils.showsnackBar(context, "Bluetooth Device Disconnected",
//           color: Colors.red);
//     });
//     notifyListeners();
//   }

//   getAllBtDevices() async {
//     var list = await fbp.FlutterBluePlus.bondedDevices;
//     updateBondedDevices(list);
//   }

//   updateCurrentIndex(int newIndex) {
//     _currentIndex = newIndex;
//   }

//   String getBtStatusText(fbp.BluetoothDevice device) {
//     if (connectedDevices.contains(device)) {
//       if (bluetoothConnection?.isConnected == true) {
//         return "Connected";
//       } else {
//         return "Disconnected";
//       }
//     } else {
//       return "Connect";
//     }
//   }

//   Color getBtStatusColor(fbp.BluetoothDevice device) {
//     if (connectedDevices.contains(device)) {
//       if (bluetoothConnection?.isConnected == true) {
//         return AppColors.green;
//       } else {
//         return AppColors.red;
//       }
//     } else {
//       return AppColors.primaryColor;
//     }
//   }

//   getAllPTModeData() {
//     getPT1modeData();
//   }

//   getPT1modeData() {
//     var ptmodeData = autoCommissionModel.hexIntgValue?.substring(158, 160);
//     print(autoCommissionModel.hexIntgValue);
//     print(ptmodeData);
//   }

//   //get all pt values from 1 to 6
//   getAllPTValues() {
//     getFilterInlet();
//     getFilterOutlet();
//     getPT1value();
//     getPT2value();
//     getPT3value();
//     getPT4value();
//     getPT5value();
//     getPT6value();
//   }

//   //get all position values from 1 to 6
//   getAllPositionSensorValue() {
//     getPostion1Value();
//     getPostion2Value();
//     getPostion3Value();
//     getPostion4Value();
//     getPostion5Value();
//     getPostion6Value();
//   }

//   getFilterInlet() {
//     try {
//       var filterinlethex = autoCommissionModel.hexIntgValue?.substring(20, 24);
//       int decimal = int.parse(filterinlethex!, radix: 16);
//       double ai1 = (decimal / 100);
//       bool isWithinRange = ai1 >= lowerLimit! && ai1 <= upperLimit!;
//       // bool isWithinRange = ai1 >= 2.25 && ai1 <= 2.75;
//       print(
//           'Filter Inlet: ${ai1.toStringAsFixed(3)}'); // Format to 3 decimal places
//       print(
//           'Is filterInlet between $lowerLimit and $upperLimit? $isWithinRange');
//       data.filterInlet = ai1;
//       data.InletButton = (isWithinRange) ? "OK" : "Faulty";
//       notifyListeners(); //update ui
//     } catch (_, ex) {
//       print(ex);
//     }
//   }

//   getFilterOutlet() {
//     try {
//       var filteroutlethex = autoCommissionModel.hexIntgValue?.substring(24, 28);
//       int decimal = int.parse(filteroutlethex!, radix: 16);
//       double ai2 = (decimal / 100);
//       print('Filter Outlet PT $ai2');
//       bool isWithinRange = ai2 >= lowerLimit! && ai2 <= upperLimit!;
//       // bool isWithinRange = ai2 >= 2.25 && ai2 <= 2.75;
//       print(
//           'Is filterOutlet between $lowerLimit and $upperLimit? $isWithinRange');
//       data.filterOutlet = ai2;
//       data.OutletButton = (isWithinRange) ? "OK" : "Faulty";
//       notifyListeners(); //update ui
//     } catch (_, ex) {
//       print(ex);
//     }
//   }

//   getPT1value() {
//     try {
//       var outletPt1hex = autoCommissionModel.hexIntgValue?.substring(38, 42);
//       int decimal = int.parse(outletPt1hex!, radix: 16);
//       var outletpt1 = (decimal / 100);
//       bool isWithinRange = outletpt1 >= lowerLimit! && outletpt1 <= upperLimit!;
//       // bool isWithinRange = outletpt1 >= 2.25 && outletpt1 <= 2.75;
//       print(
//           'Is OutletPT-1 between $lowerLimit and $upperLimit? $isWithinRange');
//       data.outlet_1_actual_count_controller = outletpt1;
//       data.PFCMD1 = (isWithinRange) ? "OK" : "Faulty";
//       notifyListeners(); //update ui
//     } catch (_, ex) {
//       print(ex);
//     }
//   }

//   double getflowvalue() {
//     String? subString3;
//     double flowvalue;
//     try {
//       subString3 = autoCommissionModel.hexIntgValue?.substring(46, 50);
//       int decimal = int.parse(subString3, radix: 16);
//       flowvalue = (decimal / 100);
//     } catch (_) {
//       flowvalue = 0.0;
//     }
//     return flowvalue;
//   }

//   String getDailyvol() {
//     String? subString3;
//     String dailyvol;
//     try {
//       subString3 = autoCommissionModel.hexIntgValue?.substring(50, 54);
//       int decimal = int.parse(subString3, radix: 16);
//       dailyvol = (decimal / 100).toString();
//     } catch (_) {
//       dailyvol = '0.0';
//     }
//     return dailyvol;
//   }

//   String getruntime() {
//     String? subString3;
//     String runtime;
//     try {
//       subString3 = autoCommissionModel.hexIntgValue?.substring(54, 58);
//       int decimal = int.parse(subString3, radix: 16);
//       runtime = (decimal / 100).toString();
//     } catch (_) {
//       runtime = '0.0';
//     }
//     return runtime;
//   }

//   getPT2value() {
//     try {
//       var outletPt2hex = autoCommissionModel.hexIntgValue?.substring(58, 62);
//       int decimal = int.parse(outletPt2hex!, radix: 16);
//       var outletpt2 = (decimal / 100);
//       print(outletpt2.toString());
//       bool isWithinRange = outletpt2 >= lowerLimit! && outletpt2 <= upperLimit!;
//       // bool isWithinRange = outletpt2 >= 2.25 && outletpt2 <= 2.75;
//       print(
//           'Is OutletPt-2 between $lowerLimit and $upperLimit? $isWithinRange');
//       data.outlet_2_actual_count_controller = outletpt2;
//       data.PFCMD2 = (isWithinRange) ? "OK" : "Faulty";
//       notifyListeners(); //update ui
//     } catch (_, ex) {
//       print(ex);
//     }
//   }

//   String getPocketIndication() {
//     String? subString3;
//     String binaryNumber;
//     String returnvalue = '';
//     try {
//       subString3 = autoCommissionModel.hexIntgValue?.substring(34, 36);
//       int decimalNumber = int.parse(subString3!, radix: 16);
//       binaryNumber = decimalNumber.toRadixString(2).padLeft(8, '0');
//       if (binaryNumber[5] == '1') {
//         returnvalue = 'Alarm';
//       } else if (binaryNumber[6] == '1') {
//         returnvalue = 'INTG';
//       } else if (binaryNumber[7] == '1') {
//         returnvalue = 'IRT';
//       }
//     } catch (_) {
//       returnvalue = '';
//     }
//     return returnvalue;
//   }

//   String getEmergencystrop() {
//     String? subString3;
//     String binaryNumber;
//     String returnvalue = '';
//     try {
//       subString3 = autoCommissionModel.hexIntgValue?.substring(36, 38);
//       int decimalNumber = int.parse(subString3!, radix: 16);
//       binaryNumber = decimalNumber.toRadixString(2).padLeft(8, '0');
//       if (binaryNumber[6] == '0') {
//         returnvalue = 'Emergency Stop';
//       } else if (binaryNumber[7] == '1') {
//         returnvalue = 'Stop Irrigation';
//       }
//     } catch (_) {
//       returnvalue = '';
//     }
//     return returnvalue;
// /*
//     if (binaryNumber.length >= 7) {
//       binaryValues.add(binaryNumber[6]);
//       binaryValues.add(binaryNumber[7]);
//     }

//     if (index >= 0 && index < binaryValues.length) {
//       return binaryValues[index];
//     } else {
//       return '';
//     }*/
//   }

//   String getOutletbar() {
//     String? subString3;
//     String outletbar;
//     try {
//       subString3 = autoCommissionModel.hexIntgValue?.substring(38, 42);
//       int decimal = int.parse(subString3 ?? '', radix: 16);
//       outletbar = (decimal / 100).toString();
//     } catch (_) {
//       outletbar = '0.0';
//     }
//     return outletbar;
//   }

//   double getPostion() {
//     String? subString3;
//     double postionvalue;
//     try {
//       subString3 = autoCommissionModel.hexIntgValue?.substring(42, 46);
//       int decimal = int.parse(subString3, radix: 16);
//       postionvalue = (decimal / 100);
//     } catch (_) {
//       postionvalue = 0.0;
//     }
//     return postionvalue;
//   }

//   getpfcmdcolor(var valpos, var flow) {
//     try {
//       if (valpos < 2) {
//         return Colors.red;
//       } else if (valpos > 2 && flow == 0) {
//         return Colors.yellow;
//       } else if (valpos > 2 && flow > 0) {
//         return Colors.green;
//       }
//     } catch (ex) {
//       return Colors.red;
//     }
//   }

//   String getOperationMode() {
//     String? data;
//     String mode;
//     String binaryNumber;
//     try {
//       data = autoCommissionModel.hexIntgValue?.substring(58, 60);
//       int decimalNumber = int.parse(data, radix: 16);
//       binaryNumber = decimalNumber.toRadixString(2).padLeft(8, '0');
//       if (binaryNumber[4] == '1') {
//         mode = 'Test';
//       } else if (binaryNumber[5] == '1') {
//         mode = 'Manual';
//       } else if (binaryNumber[6] == '1') {
//         mode = 'Auto';
//       } else {
//         mode = '';
//       }
//     } catch (_) {
//       mode = '';
//     }
//     return mode;
//   }

//   String getControllMode() {
//     String? data;
//     String mode;
//     String binaryNumber;
//     try {
//       data = autoCommissionModel.hexIntgValue?.substring(58, 60);
//       int decimalNumber = int.parse(data, radix: 16);
//       binaryNumber = decimalNumber.toRadixString(2).padLeft(8, '0');
//       if (binaryNumber[1] == '1') {
//         mode = 'Position Control';
//       } else if (binaryNumber[2] == '1') {
//         mode = 'Flow Control';
//       } else if (binaryNumber[3] == '1') {
//         mode = 'Open/Close';
//       } else {
//         mode = '';
//       }
//     } catch (_) {
//       mode = '';
//     }
//     return mode;
//   }

//   Flowmeter_Flow() {
//     String? subString3;
//     double BatteryVoltage;
//     try {
//       subString3 = autoCommissionModel.hexIntgValue?.substring(60, 64);
//       int decimal = int.parse(subString3, radix: 16);
//       BatteryVoltage = (decimal / 100).toDouble();
//     } catch (_) {
//       BatteryVoltage = 0.0;
//     }
//     return BatteryVoltage;
//   }

//   Flowmeter_Volume() {
//     String? subString3;
//     double BatteryVoltage;
//     try {
//       subString3 = autoCommissionModel.hexIntgValue?.substring(64, 68);
//       int decimal = int.parse(subString3, radix: 16);
//       BatteryVoltage = (decimal / 100).toDouble();
//     } catch (_) {
//       BatteryVoltage = 0.0;
//     }
//     return BatteryVoltage;
//   }

//   getPT3value() {
//     try {
//       var outletPt3hex = autoCommissionModel.hexIntgValue?.substring(78, 82);
//       int decimal = int.parse(outletPt3hex!, radix: 16);
//       double outletpt3 = (decimal / 100);
//       print(outletpt3.toString());
//       bool isWithinRange = outletpt3 >= lowerLimit! && outletpt3 <= upperLimit!;
//       // bool isWithinRange = outletpt3 >= 2.25 && outletpt3 <= 2.75;/
//       print(
//           'Is OutletPt-3 between $lowerLimit and $upperLimit? $isWithinRange');
//       data.outlet_3_actual_count_controller = outletpt3;
//       data.PFCMD3 = (isWithinRange) ? "OK" : "Faulty";
//       notifyListeners(); //update ui
//     } catch (_, ex) {
//       print(ex);
//     }
//   }

//   getPT4value() {
//     try {
//       var outletPt4hex =
//           autoCommissionModel.hexIntgValue?.substring(98, 102) ?? "";
//       int decimal = int.parse(outletPt4hex, radix: 16);
//       double outletpt4 = (decimal / 100);
//       data.outlet_4_actual_count_controller = outletpt4;
//       bool isWithinRange = outletpt4 >= lowerLimit! && outletpt4 <= upperLimit!;
//       // bool isWithinRange = outletpt4 >= 2.25 && outletpt4 <= 2.75;
//       print(
//           'Is OutletPt-4 between $lowerLimit and $upperLimit? $isWithinRange');
//       data.PFCMD4 = (isWithinRange) ? "OK" : "Faulty";
//       notifyListeners(); //update ui;
//     } catch (_, ex) {
//       print(ex);
//     }
//   }

//   getPT5value() {
//     try {
//       var outletPt5hex =
//           autoCommissionModel.hexIntgValue?.substring(118, 122) ?? "";
//       int decimal = int.parse(outletPt5hex, radix: 16);
//       double outletpt5 = (decimal / 100);
//       data.outlet_5_actual_count_controller = outletpt5;
//       bool isWithinRange = outletpt5 >= lowerLimit! && outletpt5 <= upperLimit!;
//       // bool isWithinRange = outletpt5 >= 2.25 && outletpt5 <= 2.75;
//       print(
//           'Is OutletPt-5 between $lowerLimit and $upperLimit? $isWithinRange');
//       data.PFCMD5 = (isWithinRange) ? "OK" : "Faulty";
//       notifyListeners(); //update ui
//     } catch (_) {}
//   }

//   getPT6value() {
//     try {
//       var outletPt6hex = autoCommissionModel.hexIntgValue?.substring(138, 142);
//       int decimal = int.parse(outletPt6hex!, radix: 16);
//       double outletpt6 = (decimal / 100);
//       data.outlet_6_actual_count_controller = outletpt6;
//       bool isWithinRange = outletpt6 >= lowerLimit! && outletpt6 <= upperLimit!;
//       // bool isWithinRange = outletpt6 >= 2.25 && outletpt6 <= 2.75;
//       print(
//           'Is OutletPt-6 between $lowerLimit and $upperLimit? $isWithinRange');
//       data.PFCMD6 = (isWithinRange) ? "OK" : "Faulty";
//       notifyListeners(); //update ui
//     } catch (_) {}
//   }

//   getPostion1Value() {
//     try {
//       var pos1hex = autoCommissionModel.hexIntgValue?.substring(42, 46);
//       int decimal = int.parse(pos1hex!, radix: 16);
//       double position1value = (decimal / 100);
//       bool isWithinRange = position1value >= 0 && position1value <= 100;
//       print('Is filterOutlet between 4000 and 20000? $isWithinRange');
//       data.posval1 = position1value;
//       data.pos1 = isWithinRange ? "OK" : "Faulty";
//       notifyListeners(); //update ui
//     } catch (_, ex) {
//       print(ex);
//     }
//   }

//   getPostion2Value() {
//     try {
//       var pos2hex = autoCommissionModel.hexIntgValue?.substring(62, 66);
//       int decimal = int.parse(pos2hex!, radix: 16);
//       double position2value = (decimal / 100);
//       bool isWithinRange = position2value >= 0 && position2value <= 100;
//       print('Is filterOutlet between 4000 and 20000? $isWithinRange');
//       data.posval2 = position2value;
//       data.pos2 = isWithinRange ? "OK" : "Faulty";
//       notifyListeners(); //update ui
//     } catch (_, ex) {
//       print(ex);
//     }
//   }

//   getPostion3Value() {
//     try {
//       var pos3hex = autoCommissionModel.hexIntgValue?.substring(82, 86);
//       int decimal = int.parse(pos3hex!, radix: 16);
//       double position3value = (decimal / 100);
//       bool isWithinRange = position3value >= 0 && position3value <= 100;
//       print('Is filterOutlet between 4000 and 20000? $isWithinRange');
//       data.posval3 = position3value;
//       data.pos3 = isWithinRange ? "OK" : "Faulty";
//       notifyListeners(); //update ui
//     } catch (_, ex) {
//       print(ex);
//     }
//   }

//   getPostion4Value() {
//     try {
//       var pos4hex = autoCommissionModel.hexIntgValue?.substring(103, 106);
//       int decimal = int.parse(pos4hex!, radix: 16);
//       double position4value = (decimal / 100);
//       bool isWithinRange = position4value >= 0 && position4value <= 100;
//       print('Is filterOutlet between 4000 and 20000? $isWithinRange');
//       data.posval4 = position4value;
//       data.pos4 = isWithinRange ? "OK" : "Faulty";
//       notifyListeners(); //update ui
//     } catch (_, ex) {
//       print(ex);
//     }
//   }

//   getPostion5Value() {
//     try {
//       var pos5hex = autoCommissionModel.hexIntgValue?.substring(122, 126);

//       int decimal = int.parse(pos5hex!, radix: 16);
//       double position5value = (decimal / 100);
//       bool isWithinRange = position5value >= 0 && position5value <= 100;
//       print('Is filterOutlet between 4000 and 20000? $isWithinRange');
//       data.posval5 = position5value;
//       data.pos5 = isWithinRange ? "OK" : "Faulty";
//       notifyListeners(); //update ui
//     } catch (_, ex) {
//       print(ex);
//     }
//   }

//   getPostion6Value() {
//     try {
//       var pos6hex = autoCommissionModel.hexIntgValue?.substring(142, 146);
//       int decimal = int.parse(pos6hex!, radix: 16);
//       double position6value = (decimal / 100);
//       bool isWithinRange = position6value >= 0 && position6value <= 100;
//       print('Is filterOutlet between 4000 and 20000? $isWithinRange');
//       data.posval6 = position6value;
//       data.pos6 = isWithinRange ? "OK" : "Faulty";
//       notifyListeners(); //update ui
//     } catch (_, ex) {
//       print(ex);
//     }
//   }

//   setSovOpneclose(int index) {
//     try {
//       String message = 'PFCMD6TYPE $index 1'.toUpperCase();
//       updateCurrentIndex(index);
//       sendMessage(message);
//     } catch (e) {
//       print(e);
//     }
//   }

//   setSovSMode(int index) {
//     try {
//       String data = 'SMODE $index 2 1 1'.toUpperCase();
//       updateCurrentIndex(index);
//       sendMessage(data);
//     } catch (e) {
//       print(e);
//     }
//   }

//   getMid() {
//     String data = 'mid'.toUpperCase();
//     sendMessage(data);
//   }

//   setValveOpenPFCMD6(int index) {
//     String data = ('PFCMD6ONOFF $index 1').toUpperCase();
//     updateCurrentIndex(index);
//     sendMessage(data);
//   }

//   setValveClosePFCMD6(int index) {
//     String data = ('PFCMD6ONOFF $index 0').toUpperCase();
//     updateCurrentIndex(index);
//     sendMessage(data);
//   }

//   void showSaveDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Enter Details'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 decoration: const InputDecoration(
//                   labelText: 'Project Name',
//                 ),
//                 onChanged: (value) {
//                   autoCommissionModel.siteName = value;
//                 },
//               ),
//               TextField(
//                 decoration: const InputDecoration(
//                   labelText: 'Node No',
//                 ),
//                 onChanged: (value) {
//                   autoCommissionModel.nodeNo = value;
//                 },
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               child: const Text('Cancel'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//             TextButton(
//               child: const Text('Submit'),
//               onPressed: () {
//                 if ((autoCommissionModel.siteName ?? "").isEmpty ||
//                     (autoCommissionModel.nodeNo ?? "").isEmpty) {
//                   // Display an error message if any field is empty
//                   showDialog(
//                     context: context,
//                     builder: (BuildContext context) {
//                       return AlertDialog(
//                         title: const Text('Error'),
//                         content: const Text('Please fill in all fields.'),
//                         actions: [
//                           TextButton(
//                             child: const Text('OK'),
//                             onPressed: () {
//                               Navigator.of(context).pop();
//                             },
//                           ),
//                         ],
//                       );
//                     },
//                   );
//                 } else {
//                   _submitForm(context);
//                   Navigator.of(context).pop();
//                 }
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   updateSavePath(String newPath) {
//     pdfSavedPath = newPath.replaceAll('/storage/emulated/0/', '');
//     notifyListeners();
//   }

//   void _submitForm(BuildContext context) {
//     final pdfWidgets.Document pdf = pdfWidgets.Document();
//     pdf.addPage(pdfWidgets.Page(build: (context) {
//       return pdfWidgets.Container(
//         child: pdfWidgets.Column(
//             mainAxisAlignment: pdfWidgets.MainAxisAlignment.start,
//             crossAxisAlignment: pdfWidgets.CrossAxisAlignment.start,
//             children: [
//               pdfWidgets.Center(
//                 child: pdfWidgets.Text(
//                   'Auto Dry Commissinning Report',
//                   style: pdfWidgets.TextStyle(
//                       fontSize: 24, fontWeight: pdfWidgets.FontWeight.bold),
//                 ),
//               ),
//               pdfWidgets.Divider(),
//               pdfWidgets.Container(
//                 child: pdfWidgets.Column(
//                   children: [
//                     pdfWidgets.SizedBox(height: 10),
//                     pdfWidgets.Row(
//                       children: [
//                         pdfWidgets.Text('Site Name :',
//                             style: pdfWidgets.TextStyle(
//                                 fontWeight: pdfWidgets.FontWeight.bold)),
//                         pdfWidgets.SizedBox(width: 20),
//                         pdfWidgets.Text(
//                             autoCommissionModel.siteName ?? 'Not Check Yet')
//                       ],
//                     ),
//                     pdfWidgets.SizedBox(height: 10),
//                     pdfWidgets.Row(
//                       children: [
//                         pdfWidgets.Text('Node No :',
//                             style: pdfWidgets.TextStyle(
//                                 fontWeight: pdfWidgets.FontWeight.bold)),
//                         pdfWidgets.SizedBox(width: 20),
//                         pdfWidgets.Text(
//                             autoCommissionModel.nodeNo ?? 'Not Check Yet')
//                       ],
//                     ),
//                     pdfWidgets.SizedBox(height: 5),
//                   ],
//                 ),
//               ),
//               pdfWidgets.Divider(),
//               pdfWidgets.Container(
//                 width: 200,
//                 child: pdfWidgets.Column(
//                   mainAxisAlignment: pdfWidgets.MainAxisAlignment.start,
//                   crossAxisAlignment: pdfWidgets.CrossAxisAlignment.start,
//                   children: [
//                     pdfWidgets.Padding(
//                       padding: const pdfWidgets.EdgeInsets.all(8.0),
//                       child: pdfWidgets.Row(
//                         mainAxisAlignment:
//                             pdfWidgets.MainAxisAlignment.spaceBetween,
//                         children: [
//                           pdfWidgets.SizedBox(
//                             child: pdfWidgets.Text(
//                               'General Checks ',
//                               style: pdfWidgets.TextStyle(
//                                 fontSize: 22,
//                                 fontWeight: pdfWidgets.FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     pdfWidgets.Padding(
//                       padding: const pdfWidgets.EdgeInsets.all(8.0),
//                       child: pdfWidgets.Row(
//                         mainAxisAlignment:
//                             pdfWidgets.MainAxisAlignment.spaceBetween,
//                         children: [
//                           pdfWidgets.SizedBox(
//                             child: pdfWidgets.Text(
//                               'Firmware Version :',
//                               style: pdfWidgets.TextStyle(
//                                 fontWeight: pdfWidgets.FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                           // Replace with your actual battery percentage

//                           pdfWidgets.SizedBox(
//                             child: pdfWidgets.Text(
//                               '${autoCommissionModel.firmwareversion ?? "Not Check Yet"}',
//                               style: pdfWidgets.TextStyle(
//                                 fontWeight: pdfWidgets.FontWeight.normal,
//                               ),
//                             ),
//                           )
//                         ],
//                       ),
//                     ),
//                     pdfWidgets.Padding(
//                       padding: const pdfWidgets.EdgeInsets.all(8.0),
//                       child: pdfWidgets.Row(
//                         mainAxisAlignment:
//                             pdfWidgets.MainAxisAlignment.spaceBetween,
//                         children: [
//                           pdfWidgets.SizedBox(
//                             child: pdfWidgets.Text(
//                               'Mac ID :',
//                               style: pdfWidgets.TextStyle(
//                                 fontWeight: pdfWidgets.FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                           // Replace with your actual battery percentage

//                           pdfWidgets.SizedBox(
//                             child: pdfWidgets.Text(
//                               autoCommissionModel.mid ?? 'Not Check Yet',
//                               style: pdfWidgets.TextStyle(
//                                 fontWeight: pdfWidgets.FontWeight.normal,
//                               ),
//                             ),
//                           )
//                         ],
//                       ),
//                     ),
//                     pdfWidgets.Padding(
//                       padding: const pdfWidgets.EdgeInsets.all(8.0),
//                       child: pdfWidgets.Row(
//                         mainAxisAlignment:
//                             pdfWidgets.MainAxisAlignment.spaceBetween,
//                         children: [
//                           pdfWidgets.SizedBox(
//                             child: pdfWidgets.Text(
//                               'Battery Voltage :',
//                               style: pdfWidgets.TextStyle(
//                                 fontWeight: pdfWidgets.FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                           // Replace with your actual battery percentage

//                           pdfWidgets.SizedBox(
//                             child: pdfWidgets.Text(
//                               '${autoCommissionModel.batteryVlt ?? 'Not Check Yet'} V',
//                               style: pdfWidgets.TextStyle(
//                                 fontWeight: pdfWidgets.FontWeight.normal,
//                               ),
//                             ),
//                           )
//                         ],
//                       ),
//                     ),
//                     pdfWidgets.Padding(
//                       padding: const pdfWidgets.EdgeInsets.all(8.0),
//                       child: pdfWidgets.Row(
//                         mainAxisAlignment:
//                             pdfWidgets.MainAxisAlignment.spaceBetween,
//                         children: [
//                           pdfWidgets.SizedBox(
//                             child: pdfWidgets.Text(
//                               'Solar Voltage :',
//                               style: pdfWidgets.TextStyle(
//                                 fontWeight: pdfWidgets.FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                           // Replace with your actual battery percentage

//                           pdfWidgets.SizedBox(
//                             child: pdfWidgets.Text(
//                               '${autoCommissionModel.solarVlt ?? 'Not Check Yet'} V',
//                               style: pdfWidgets.TextStyle(
//                                 fontWeight: pdfWidgets.FontWeight.normal,
//                               ),
//                             ),
//                           )
//                         ],
//                       ),
//                     ),
//                     pdfWidgets.Padding(
//                       padding: const pdfWidgets.EdgeInsets.all(8.0),
//                       child: pdfWidgets.Row(
//                         mainAxisAlignment:
//                             pdfWidgets.MainAxisAlignment.spaceBetween,
//                         children: [
//                           pdfWidgets.SizedBox(
//                             // color: Colors.blue,
//                             child: pdfWidgets.Text(
//                               'Door 1 :',
//                               style: pdfWidgets.TextStyle(
//                                 fontWeight: pdfWidgets.FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                           pdfWidgets.SizedBox(
//                             child: pdfWidgets.Text(
//                               autoCommissionModel.door1 ?? 'Not Check Yet',
//                               style: pdfWidgets.TextStyle(
//                                 fontWeight: pdfWidgets.FontWeight.normal,
//                               ),
//                             ),
//                           )
//                         ],
//                       ),
//                     ),
//                     pdfWidgets.Padding(
//                       padding: const pdfWidgets.EdgeInsets.all(8.0),
//                       child: pdfWidgets.Row(
//                         mainAxisAlignment:
//                             pdfWidgets.MainAxisAlignment.spaceBetween,
//                         children: [
//                           pdfWidgets.SizedBox(
//                             // color: Colors.blue,
//                             child: pdfWidgets.Text(
//                               'Door 2 :',
//                               style: pdfWidgets.TextStyle(
//                                 fontWeight: pdfWidgets.FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                           pdfWidgets.SizedBox(
//                             child: pdfWidgets.Text(
//                               autoCommissionModel.door2 ?? 'Not Check Yet',
//                               style: pdfWidgets.TextStyle(
//                                 fontWeight: pdfWidgets.FontWeight.normal,
//                               ),
//                             ),
//                           )
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               pdfWidgets.Container(
//                 width: 200,
//                 child: pdfWidgets.Column(
//                   mainAxisAlignment: pdfWidgets.MainAxisAlignment.start,
//                   crossAxisAlignment: pdfWidgets.CrossAxisAlignment.start,
//                   children: [
//                     pdfWidgets.Padding(
//                       padding: const pdfWidgets.EdgeInsets.all(8.0),
//                       child: pdfWidgets.Row(
//                         mainAxisAlignment:
//                             pdfWidgets.MainAxisAlignment.spaceBetween,
//                         children: [
//                           pdfWidgets.SizedBox(
//                             child: pdfWidgets.Text(
//                               'Lora Communication Check',
//                               style: pdfWidgets.TextStyle(
//                                 fontSize: 22,
//                                 fontWeight: pdfWidgets.FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     pdfWidgets.Padding(
//                       padding: const pdfWidgets.EdgeInsets.all(8.0),
//                       child: pdfWidgets.Row(
//                         mainAxisAlignment:
//                             pdfWidgets.MainAxisAlignment.spaceBetween,
//                         children: [
//                           pdfWidgets.SizedBox(
//                             child: pdfWidgets.Text(
//                               'Lora Communication :',
//                               style: pdfWidgets.TextStyle(
//                                 fontWeight: pdfWidgets.FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                           pdfWidgets.SizedBox(
//                             child: pdfWidgets.Text(
//                               autoCommissionModel.loraCommunication ??
//                                   'Not Check Yet',
//                               style: pdfWidgets.TextStyle(
//                                 fontWeight: pdfWidgets.FontWeight.normal,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               pdfWidgets.Padding(
//                 padding: const pdfWidgets.EdgeInsets.all(8.0),
//                 child: pdfWidgets.Container(
//                   decoration: pdfWidgets.BoxDecoration(
//                       borderRadius: pdfWidgets.BorderRadius.circular(5)),
//                   width: double.infinity,
//                   child: pdfWidgets.Padding(
//                     padding: const pdfWidgets.EdgeInsets.all(8.0),
//                     child: pdfWidgets.Text(
//                       'Inlet PT Valve Test',
//                       style: pdfWidgets.TextStyle(
//                         fontSize: 22,
//                         fontWeight: pdfWidgets.FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               pdfWidgets.Padding(
//                 padding: const pdfWidgets.EdgeInsets.all(8),
//                 child: pdfWidgets.Table(
//                   border: pdfWidgets.TableBorder.all(
//                       width: 1, color: PdfColors.black),
//                   children: [
//                     pdfWidgets.TableRow(
//                       children: [
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Container(
//                             height: 20,
//                             alignment: pdfWidgets.Alignment.center,
//                             child: pdfWidgets.Text('PT Name',
//                                 style: pdfWidgets.TextStyle(
//                                     fontWeight: pdfWidgets.FontWeight.bold)),
//                           ),
//                         ),
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Container(
//                             height: 20,
//                             alignment: pdfWidgets.Alignment.center,
//                             child: pdfWidgets.Text('Pressure',
//                                 style: pdfWidgets.TextStyle(
//                                     fontWeight: pdfWidgets.FontWeight.bold)),
//                           ),
//                         ),
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Container(
//                             height: 20,
//                             alignment: pdfWidgets.Alignment.center,
//                             child: pdfWidgets.Text('Technician Remark',
//                                 style: pdfWidgets.TextStyle(
//                                     fontWeight: pdfWidgets.FontWeight.bold)),
//                           ),
//                         ),
//                       ],
//                     ),
//                     pdfWidgets.TableRow(
//                       children: [
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Container(
//                             height: 20,
//                             alignment: pdfWidgets.Alignment.center,
//                             child: pdfWidgets.Text('Filter Inlet PT'),
//                           ),
//                         ),
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Container(
//                             height: 20,
//                             alignment: pdfWidgets.Alignment.center,
//                             child: pdfWidgets.Text(
//                               '${data.filterInlet ?? "Not Check Yet"} bar',
//                             ),
//                           ),
//                         ),
//                         /*pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Container(
//                             height: 20,
//                             alignment: pdfWidgets.Alignment.center,
//                             child: pdfWidgets.Text(
//                               '${aibarvalue.toString()} bar',
//                             ),
//                           ),
//                         ),*/
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Container(
//                             height: 20,
//                             alignment: pdfWidgets.Alignment.center,
//                             child: pdfWidgets.Text(
//                                 data.InletButton ?? "Not Check Yet"),
//                           ),
//                         ),
//                       ],
//                     ),
//                     pdfWidgets.TableRow(
//                       children: [
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Container(
//                             height: 20,
//                             alignment: pdfWidgets.Alignment.center,
//                             child: pdfWidgets.Text('Flter Outlet PT'),
//                           ),
//                         ),
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Container(
//                             height: 20,
//                             alignment: pdfWidgets.Alignment.center,
//                             child: pdfWidgets.Text(
//                               '${data.filterOutlet ?? 'Not Check Yet'} bar',
//                             ),
//                           ),
//                         ),
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Container(
//                             height: 20,
//                             alignment: pdfWidgets.Alignment.center,
//                             child: pdfWidgets.Text(
//                                 data.OutletButton ?? 'Not Check Yet'),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ]),
//       );
//     }));
//     pdf.addPage(pdfWidgets.Page(build: (context) {
//       return pdfWidgets.Container(
//         child: pdfWidgets.Column(
//             mainAxisAlignment: pdfWidgets.MainAxisAlignment.start,
//             crossAxisAlignment: pdfWidgets.CrossAxisAlignment.start,
//             children: [
//               pdfWidgets.Padding(
//                 padding: const pdfWidgets.EdgeInsets.all(8.0),
//                 child: pdfWidgets.Container(
//                   decoration: pdfWidgets.BoxDecoration(
//                       borderRadius: pdfWidgets.BorderRadius.circular(5)),
//                   width: double.infinity,
//                   child: pdfWidgets.Padding(
//                     padding: const pdfWidgets.EdgeInsets.all(8.0),
//                     child: pdfWidgets.Text(
//                       'Outlet PT Valve Test',
//                       style: pdfWidgets.TextStyle(
//                         fontSize: 22,
//                         fontWeight: pdfWidgets.FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               pdfWidgets.Padding(
//                 padding: const pdfWidgets.EdgeInsets.all(8),
//                 child: pdfWidgets.Table(
//                   border: pdfWidgets.TableBorder.all(
//                       width: 1, color: PdfColors.black),
//                   children: [
//                     pdfWidgets.TableRow(
//                       children: [
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Container(
//                             height: 20,
//                             alignment: pdfWidgets.Alignment.center,
//                             child: pdfWidgets.Text('PT Name',
//                                 style: pdfWidgets.TextStyle(
//                                     fontWeight: pdfWidgets.FontWeight.bold)),
//                           ),
//                         ),
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Container(
//                             height: 20,
//                             alignment: pdfWidgets.Alignment.center,
//                             child: pdfWidgets.Text('Pressure',
//                                 style: pdfWidgets.TextStyle(
//                                     fontWeight: pdfWidgets.FontWeight.bold)),
//                           ),
//                         ),
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Container(
//                             height: 20,
//                             alignment: pdfWidgets.Alignment.center,
//                             child: pdfWidgets.Text('Technician Remark',
//                                 style: pdfWidgets.TextStyle(
//                                     fontWeight: pdfWidgets.FontWeight.bold)),
//                           ),
//                         ),
//                       ],
//                     ),
//                     pdfWidgets.TableRow(
//                       children: [
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Container(
//                             height: 20,
//                             alignment: pdfWidgets.Alignment.center,
//                             child: pdfWidgets.Text('Outlet PT 1'),
//                           ),
//                         ),
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Container(
//                             height: 20,
//                             alignment: pdfWidgets.Alignment.center,
//                             child: pdfWidgets.Text(
//                               '${data.outlet_1_actual_count_controller ?? 'Not Check Yet'} bar',
//                             ),
//                           ),
//                         ),
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Container(
//                             height: 20,
//                             alignment: pdfWidgets.Alignment.center,
//                             child:
//                                 pdfWidgets.Text(data.PFCMD1 ?? 'Not Check Yet'),
//                           ),
//                         ),
//                       ],
//                     ),
//                     pdfWidgets.TableRow(
//                       children: [
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Container(
//                             height: 20,
//                             alignment: pdfWidgets.Alignment.center,
//                             child: pdfWidgets.Text('Outlet PT 2'),
//                           ),
//                         ),
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Container(
//                             height: 20,
//                             alignment: pdfWidgets.Alignment.center,
//                             child: pdfWidgets.Text(
//                               '${data.outlet_2_actual_count_controller?.toString() ?? 'Not Check Yet'} bar',
//                             ),
//                           ),
//                         ),
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Container(
//                             height: 20,
//                             alignment: pdfWidgets.Alignment.center,
//                             child:
//                                 pdfWidgets.Text(data.PFCMD2 ?? 'Not Check Yet'),
//                           ),
//                         ),
//                       ],
//                     ),
//                     pdfWidgets.TableRow(
//                       children: [
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Container(
//                             height: 20,
//                             alignment: pdfWidgets.Alignment.center,
//                             child: pdfWidgets.Text('Outlet PT 3'),
//                           ),
//                         ),
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Container(
//                             height: 20,
//                             alignment: pdfWidgets.Alignment.center,
//                             child: pdfWidgets.Text(
//                               '${data.outlet_3_actual_count_controller?.toString() ?? 'Not Check Yet'} bar',
//                             ),
//                           ),
//                         ),
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Container(
//                             height: 20,
//                             alignment: pdfWidgets.Alignment.center,
//                             child:
//                                 pdfWidgets.Text(data.PFCMD3 ?? 'Not Check Yet'),
//                           ),
//                         ),
//                       ],
//                     ),
//                     pdfWidgets.TableRow(
//                       children: [
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Container(
//                             height: 20,
//                             alignment: pdfWidgets.Alignment.center,
//                             child: pdfWidgets.Text('Outlet PT 4'),
//                           ),
//                         ),
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Container(
//                             height: 20,
//                             alignment: pdfWidgets.Alignment.center,
//                             child: pdfWidgets.Text(
//                               '${data.outlet_4_actual_count_controller?.toString() ?? 'Not Check Yet'} bar',
//                             ),
//                           ),
//                         ),
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Container(
//                             height: 20,
//                             alignment: pdfWidgets.Alignment.center,
//                             child:
//                                 pdfWidgets.Text(data.PFCMD4 ?? 'Not Check Yet'),
//                           ),
//                         ),
//                       ],
//                     ),
//                     pdfWidgets.TableRow(
//                       children: [
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Container(
//                             height: 20,
//                             alignment: pdfWidgets.Alignment.center,
//                             child: pdfWidgets.Text('Outlet PT 5'),
//                           ),
//                         ),
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Container(
//                             height: 20,
//                             alignment: pdfWidgets.Alignment.center,
//                             child: pdfWidgets.Text(
//                               '${data.outlet_5_actual_count_controller?.toString() ?? 'Not Check Yet'} bar',
//                             ),
//                           ),
//                         ),
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Container(
//                             height: 20,
//                             alignment: pdfWidgets.Alignment.center,
//                             child:
//                                 pdfWidgets.Text(data.PFCMD5 ?? 'Not Check Yet'),
//                           ),
//                         ),
//                       ],
//                     ),
//                     pdfWidgets.TableRow(
//                       children: [
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Container(
//                             height: 20,
//                             alignment: pdfWidgets.Alignment.center,
//                             child: pdfWidgets.Text('Outlet PT 6'),
//                           ),
//                         ),
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Container(
//                             height: 20,
//                             alignment: pdfWidgets.Alignment.center,
//                             child: pdfWidgets.Text(
//                               '${data.outlet_6_actual_count_controller ?? 'Not Check Yet'} bar',
//                             ),
//                           ),
//                         ),
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Container(
//                             height: 20,
//                             alignment: pdfWidgets.Alignment.center,
//                             child:
//                                 pdfWidgets.Text(data.PFCMD6 ?? 'Not Check Yet'),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               pdfWidgets.Padding(
//                 padding: const pdfWidgets.EdgeInsets.all(8.0),
//                 child: pdfWidgets.Container(
//                   decoration: pdfWidgets.BoxDecoration(
//                       borderRadius: pdfWidgets.BorderRadius.circular(5)),
//                   width: double.infinity,
//                   child: pdfWidgets.Padding(
//                     padding: const pdfWidgets.EdgeInsets.all(8.0),
//                     child: pdfWidgets.Text(
//                       'Position Sensor Test',
//                       style: pdfWidgets.TextStyle(
//                         fontSize: 22,
//                         fontWeight: pdfWidgets.FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               pdfWidgets.Padding(
//                 padding: const pdfWidgets.EdgeInsets.all(8),
//                 child: pdfWidgets.Table(
//                   border: pdfWidgets.TableBorder.all(
//                       width: 1, color: PdfColors.black),
//                   children: [
//                     pdfWidgets.TableRow(
//                       children: [
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Container(
//                             height: 20,
//                             alignment: pdfWidgets.Alignment.center,
//                             child: pdfWidgets.Text('Position Sensor',
//                                 style: pdfWidgets.TextStyle(
//                                     fontWeight: pdfWidgets.FontWeight.bold)),
//                           ),
//                         ),
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Container(
//                             height: 20,
//                             alignment: pdfWidgets.Alignment.center,
//                             child: pdfWidgets.Text('Value',
//                                 style: pdfWidgets.TextStyle(
//                                     fontWeight: pdfWidgets.FontWeight.bold)),
//                           ),
//                         ),
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Container(
//                             height: 20,
//                             alignment: pdfWidgets.Alignment.center,
//                             child: pdfWidgets.Text('Remark',
//                                 style: pdfWidgets.TextStyle(
//                                     fontWeight: pdfWidgets.FontWeight.bold)),
//                           ),
//                         ),
//                       ],
//                     ),
//                     pdfWidgets.TableRow(
//                       children: [
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Container(
//                             height: 20,
//                             alignment: pdfWidgets.Alignment.center,
//                             child: pdfWidgets.Text('Position Sensor 1'),
//                           ),
//                         ),
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Container(
//                             height: 20,
//                             alignment: pdfWidgets.Alignment.center,
//                             child: pdfWidgets.Text(
//                               '${data.posval1 ?? 'Not Check Yet'} %',
//                             ),
//                           ),
//                         ),
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Container(
//                             height: 20,
//                             alignment: pdfWidgets.Alignment.center,
//                             child:
//                                 pdfWidgets.Text(data.pos1 ?? 'Not Check Yet'),
//                           ),
//                         ),
//                       ],
//                     ),
//                     pdfWidgets.TableRow(
//                       children: [
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Container(
//                             height: 20,
//                             alignment: pdfWidgets.Alignment.center,
//                             child: pdfWidgets.Text('Position Sensor 2'),
//                           ),
//                         ),
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Container(
//                             height: 20,
//                             alignment: pdfWidgets.Alignment.center,
//                             child: pdfWidgets.Text(
//                               '${data.posval2 ?? 'Not Check Yet'} %',
//                             ),
//                           ),
//                         ),
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Container(
//                             height: 20,
//                             alignment: pdfWidgets.Alignment.center,
//                             child:
//                                 pdfWidgets.Text(data.pos2 ?? 'Not Check Yet'),
//                           ),
//                         ),
//                       ],
//                     ),
//                     pdfWidgets.TableRow(
//                       children: [
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Container(
//                             height: 20,
//                             alignment: pdfWidgets.Alignment.center,
//                             child: pdfWidgets.Text('Position Sensor 3'),
//                           ),
//                         ),
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Container(
//                             height: 20,
//                             alignment: pdfWidgets.Alignment.center,
//                             child: pdfWidgets.Text(
//                               '${data.posval3 ?? 'Not Check Yet'} %',
//                             ),
//                           ),
//                         ),
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Container(
//                             height: 20,
//                             alignment: pdfWidgets.Alignment.center,
//                             child:
//                                 pdfWidgets.Text(data.pos3 ?? 'Not Check Yet'),
//                           ),
//                         ),
//                       ],
//                     ),
//                     pdfWidgets.TableRow(
//                       children: [
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Container(
//                             height: 20,
//                             alignment: pdfWidgets.Alignment.center,
//                             child: pdfWidgets.Text('Position Sensor 4'),
//                           ),
//                         ),
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Container(
//                             height: 20,
//                             alignment: pdfWidgets.Alignment.center,
//                             child: pdfWidgets.Text(
//                               '${data.posval4 ?? 'Not Check Yet'} %',
//                             ),
//                           ),
//                         ),
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Container(
//                             height: 20,
//                             alignment: pdfWidgets.Alignment.center,
//                             child:
//                                 pdfWidgets.Text(data.pos4 ?? 'Not Check Yet'),
//                           ),
//                         ),
//                       ],
//                     ),
//                     pdfWidgets.TableRow(
//                       children: [
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Container(
//                             height: 20,
//                             alignment: pdfWidgets.Alignment.center,
//                             child: pdfWidgets.Text('Position Sensor 5'),
//                           ),
//                         ),
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Container(
//                             height: 20,
//                             alignment: pdfWidgets.Alignment.center,
//                             child: pdfWidgets.Text(
//                               '${data.posval5?.toString() ?? 'Not Check Yet'} %',
//                             ),
//                           ),
//                         ),
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Container(
//                             height: 20,
//                             alignment: pdfWidgets.Alignment.center,
//                             child:
//                                 pdfWidgets.Text(data.pos5 ?? 'Not Check Yet'),
//                           ),
//                         ),
//                       ],
//                     ),
//                     pdfWidgets.TableRow(
//                       children: [
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Container(
//                             height: 20,
//                             alignment: pdfWidgets.Alignment.center,
//                             child: pdfWidgets.Text('Position Sensor 6'),
//                           ),
//                         ),
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Container(
//                             height: 20,
//                             alignment: pdfWidgets.Alignment.center,
//                             child: pdfWidgets.Text(
//                               '${data.posval6?.toString() ?? 'Not Check Yet'} %',
//                             ),
//                           ),
//                         ),
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Container(
//                             height: 20,
//                             alignment: pdfWidgets.Alignment.center,
//                             child:
//                                 pdfWidgets.Text(data.pos6 ?? 'Not Check Yet'),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               pdfWidgets.Padding(
//                 padding: const pdfWidgets.EdgeInsets.all(8.0),
//                 child: pdfWidgets.Container(
//                   width: double.infinity,
//                   child: pdfWidgets.Padding(
//                     padding: const pdfWidgets.EdgeInsets.all(8.0),
//                     child: pdfWidgets.Text(
//                       'Solenoid Testing',
//                       style: pdfWidgets.TextStyle(
//                         fontSize: 22,
//                         fontWeight: pdfWidgets.FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               pdfWidgets.Padding(
//                 padding: const pdfWidgets.EdgeInsets.all(8),
//                 child: pdfWidgets.Table(
//                   border: pdfWidgets.TableBorder.all(
//                     color: PdfColors.black,
//                     width: 1,
//                     style: pdfWidgets.BorderStyle.solid,
//                   ),
//                   children: [
//                     pdfWidgets.TableRow(
//                       children: [
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Container(
//                             height: 20,
//                             alignment: pdfWidgets.Alignment.center,
//                             child: pdfWidgets.Text('Solenoid',
//                                 style: pdfWidgets.TextStyle(
//                                     fontWeight: pdfWidgets.FontWeight.bold)),
//                           ),
//                         ),
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Container(
//                             height: 20,
//                             alignment: pdfWidgets.Alignment.center,
//                             child: pdfWidgets.Text('Technician Remark',
//                                 style: pdfWidgets.TextStyle(
//                                     fontWeight: pdfWidgets.FontWeight.bold)),
//                           ),
//                         ),
//                       ],
//                     ),
//                     //PFCMD 1
//                     pdfWidgets.TableRow(
//                       children: [
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Container(
//                             height: 20,
//                             child: pdfWidgets.Center(
//                               child: pdfWidgets.Text(
//                                 'SOV 1',
//                               ),
//                             ),
//                           ),
//                         ),
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Row(
//                             mainAxisAlignment:
//                                 pdfWidgets.MainAxisAlignment.center,
//                             children: [
//                               pdfWidgets.Container(
//                                 height: 20,
//                                 //
//                                 child: pdfWidgets.Center(
//                                     child: pdfWidgets.Text(
//                                         data.sov1 ?? 'Not Check Yet')),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                     pdfWidgets.TableRow(
//                       children: [
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Container(
//                             height: 20,
//                             //
//                             child: pdfWidgets.Center(
//                               child: pdfWidgets.Text(
//                                 'SOV 2',
//                               ),
//                             ),
//                           ),
//                         ),
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Row(
//                             mainAxisAlignment:
//                                 pdfWidgets.MainAxisAlignment.center,
//                             children: [
//                               pdfWidgets.Container(
//                                 height: 20,
//                                 //
//                                 child: pdfWidgets.Center(
//                                     child: pdfWidgets.Text(
//                                         data.sov2 ?? 'Not Check Yet')),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),

//                     // PFCMD 3
//                     pdfWidgets.TableRow(
//                       children: [
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Container(
//                             height: 20,
//                             child: pdfWidgets.Center(
//                               child: pdfWidgets.Text(
//                                 'SOV 3',
//                               ),
//                             ),
//                           ),
//                         ),
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Row(
//                             mainAxisAlignment:
//                                 pdfWidgets.MainAxisAlignment.center,
//                             children: [
//                               pdfWidgets.Container(
//                                 height: 20,
//                                 //
//                                 child: pdfWidgets.Center(
//                                     child: pdfWidgets.Text(
//                                         data.sov3 ?? 'Not Check Yet')),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                     pdfWidgets.TableRow(
//                       children: [
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Container(
//                             height: 20,
//                             child: pdfWidgets.Center(
//                               child: pdfWidgets.Text(
//                                 'SOV 4',
//                               ),
//                             ),
//                           ),
//                         ),
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Row(
//                             mainAxisAlignment:
//                                 pdfWidgets.MainAxisAlignment.center,
//                             children: [
//                               pdfWidgets.Container(
//                                 height: 20,
//                                 //
//                                 child: pdfWidgets.Center(
//                                     child: pdfWidgets.Text(
//                                         data.sov4 ?? 'Not Check Yet')),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                     pdfWidgets.TableRow(
//                       children: [
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Container(
//                             height: 20,
//                             child: pdfWidgets.Center(
//                               child: pdfWidgets.Text(
//                                 'SOV 5',
//                               ),
//                             ),
//                           ),
//                         ),
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Row(
//                             mainAxisAlignment:
//                                 pdfWidgets.MainAxisAlignment.center,
//                             children: [
//                               pdfWidgets.Container(
//                                 height: 20,
//                                 child: pdfWidgets.Center(
//                                     child: pdfWidgets.Text(
//                                         data.sov5 ?? 'Not Check Yet')),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                     pdfWidgets.TableRow(
//                       children: [
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Container(
//                             height: 20,
//                             child: pdfWidgets.Center(
//                               child: pdfWidgets.Text(
//                                 'SOV 6',
//                               ),
//                             ),
//                           ),
//                         ),
//                         pdfWidgets.Expanded(
//                           flex: 1,
//                           child: pdfWidgets.Row(
//                             mainAxisAlignment:
//                                 pdfWidgets.MainAxisAlignment.center,
//                             children: [
//                               pdfWidgets.Container(
//                                 height: 20,
//                                 child: pdfWidgets.Center(
//                                     child: pdfWidgets.Text(
//                                         data.sov6 ?? 'Not Check Yet')),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               pdfWidgets.Divider(),
//               pdfWidgets.Row(
//                 children: [
//                   pdfWidgets.Text('Done By:  ',
//                       style: pdfWidgets.TextStyle(
//                           fontWeight: pdfWidgets.FontWeight.bold)),
//                   pdfWidgets.Text(user?.fName ?? 'Not Check Yet')
//                 ],
//               ),
//               pdfWidgets.SizedBox(height: 10),
//               pdfWidgets.Row(
//                 children: [
//                   pdfWidgets.Text('Date: ',
//                       style: pdfWidgets.TextStyle(
//                           fontWeight: pdfWidgets.FontWeight.bold)),
//                   pdfWidgets.Text(getcurrentdate())
//                 ],
//               ),
//             ]),
//       );
//     }));
//     savePDF(pdf, context);
//     updateFlowControlMode(true);
//   }

//   void savePDF(pdfWidgets.Document pdf, BuildContext context) async {
//     // String downloadPath = '/storage/emulated/0/Download';
//     final Directory? downloadPath = await getDownloadsDirectory();
//     String pdfName =
//         'AutoDry ${autoCommissionModel.nodeNo}-${autoCommissionModel.siteName}.pdf';
//     File file = File('${downloadPath?.path}/$pdfName');
//     try {
//       await file.writeAsBytes(await pdf.save());
//       print('PDF saved successfully');
//       updateSavePath(downloadPath?.path ?? "");
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: const Text('PDF Saved'),
//             content: const Text('The PDF was saved successfully.'),
//             actions: <Widget>[
//               TextButton(
//                 child: const Text('OK'),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//               ),
//             ],
//           );
//         },
//       );
//     } catch (e) {
//       print('Error saving PDF: $e');
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: const Text('Error'),
//             content: const Text('An error occurred while saving the PDF.'),
//             actions: <Widget>[
//               TextButton(
//                 child: const Text('OK'),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//               ),
//             ],
//           );
//         },
//       );
//     }
//   }

//   String getcurrentdate() {
//     final DateTime now = DateTime.now();
//     final DateFormat formatter = DateFormat('d-MMM-y H:m:s');
//     final String formatted = formatter.format(now);
//     // Cdate = formatted;
//     return formatted;
//   }
// }
