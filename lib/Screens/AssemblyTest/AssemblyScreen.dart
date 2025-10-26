// ignore_for_file: file_names, use_build_context_synchronously, unused_field, prefer_final_fields, prefer_if_null_operators, non_constant_identifier_names, unused_element
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:convert/convert.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_serial_communication/flutter_serial_communication.dart';
import 'package:flutter_serial_communication/models/device_info.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usb_console_application/core/app_export.dart';
import 'package:usb_console_application/core/constants/SaveFile.dart';
import 'package:usb_console_application/models/loginmodel.dart';
import 'package:pdf/widgets.dart' as pdfWidgets;

class AssemblyScreen extends StatefulWidget {
  const AssemblyScreen({super.key});

  @override
  State<AssemblyScreen> createState() => _AssemblyScreenState();
}

class _AssemblyScreenState extends State<AssemblyScreen> {
  final FlutterSerialCommunication _serialComm = FlutterSerialCommunication();
  String _status = "Idle";
  List<DeviceInfo> _devices = [];
  List<String> _response = [];
  List<String> _serialData = [];
  String btntxt = 'Connect';
  List<int> _dataBuffer = [];
  String _tempBuffer = '';
  bool isStart = false;
  bool isReady = false;
  bool isDoorOk = false;
  bool isRTCOk = false;
  bool isFlashOk = false;
  int noOfPfcmds = 6;
  String? macId;
  List<String> outletPT_Status_0bar = [];
  List<double> outletPT_Values_0bar = [];

  List<String> outletPT_Status_1bar = [];
  List<double> outletPT_Values_1bar = [];

  List<String>? position_status = [];
  List<double>? position_values = [];

  List<String>? solenoid_status = [];

  double? filterInlet = 0.0;
  double? filterOutlet = 0.0;
  String inletPT_0bar = '';
  String outletPT_0bar = '';

  double? filterInlet1bar = 0.0;
  double? filterOutlet1bar = 0.0;
  String inletPT_1bar = '';
  String outletPT_1bar = '';
  bool? isSaved = false;
  String? filePath = '';
  String? username;
  int? userId;
  String? Cdate;
  int? batchNo;
  bool isMessageComplete = false;

  Future<bool> _connectTo(DeviceInfo? device) async {
    // Disconnect any current connection.
    if (_status == 'Connected') {
      await _serialComm.disconnect();
    }

    if (device == null) {
      _updateStatus("Disconnected", 'Disconnected');
      _showProcessingToast(
        context,
        content: '${device?.productName ?? "Device"} disconnected successfully',
      );
      return true;
    }

    bool connectionSuccess = await _serialComm.connect(device, 115200);
    debugPrint("Connection success: $connectionSuccess");

    if (!connectionSuccess) {
      _updateStatus("Failed to open port", 'Connect');
      return false;
    }

    _updateStatus("Connected", 'Connected');
    _showProcessingToast(
      context,
      content: '${device.productName} connected successfully',
    );

    return true;
  }

  void _updateStatus(String status, String buttonText) {
    setState(() {
      _status = status;
      btntxt = buttonText;
    });
  }

  // Initialize serial data and device status listeners.
  void _initSerialListeners() {
    _serialComm.getSerialMessageListener().receiveBroadcastStream().listen(
      (event) {
        _handleData(Uint8List.fromList(event));
      },
      onError: (error) {
        debugPrint("Serial Listener Error: $error");
      },
    );

    // _deviceStatusSubscription =
    _serialComm.getDeviceConnectionListener().receiveBroadcastStream().listen((
      event,
    ) {
      setState(() {
        _status = event;
      });
    });
  }

  /*
  void _handleData(Uint8List data) {
    _dataBuffer.addAll(data);
    // Check if the buffer contains the delimiter \n (newline) or \r (carriage return)
    if (_dataBuffer.contains(10) && _dataBuffer.contains(13)) {
      String completeMessage = String.fromCharCodes(_dataBuffer);

      debugPrint("Complete Message: $completeMessage");
      String hexData = hex.encode(_dataBuffer);
      _dataBuffer.clear();
      setState(() {
        isMessageComplete = true;
        _response.add(hexData);
        _serialData.add(completeMessage);
      });
      if (isMessageComplete == true) {
        parseJsonData(completeMessage);
        isMessageComplete = false;
      }
    }
  }*/

  void _handleData(Uint8List data) {
    _dataBuffer.addAll(data);
    String message = String.fromCharCodes(_dataBuffer);
    if (message.contains('READY')) {
      setState(() {
        isReady = true;
        _serialData.add(message);
      });
    }

    // Ensure buffer has at least two elements before checking the last two values
    if (_dataBuffer.length >= 2 &&
        _dataBuffer[_dataBuffer.length - 2] == 13 &&
        _dataBuffer[_dataBuffer.length - 1] == 10) {
      isMessageComplete = true; // Set flag only if last two values are 10 & 13

      String completeMessage = String.fromCharCodes(_dataBuffer);
      debugPrint("Complete Message: $completeMessage");

      String hexData = hex.encode(_dataBuffer);
      _dataBuffer.clear();

      setState(() {
        _response.add(hexData);
        _serialData.add(completeMessage);
      });
      if (_serialData.join().contains('READY')) {
        setState(() {
          isReady = true;
        });
      }

      if (isMessageComplete) {
        parseJsonData(completeMessage);
        isMessageComplete = false; // Reset flag after parsing
      }
    }
  }

  void parseJsonData(String message) {
    for (String line in message.split('\n')) {
      line = line.trim();
      // debugPrint(line);

      //RTC Status
      if (line.contains('APP-RTC')) {
        int beginIndex = line.indexOf("{");
        int endIndex = line.lastIndexOf("}");
        if (beginIndex != -1 && endIndex != -1) {
          String rtcJson = line.substring(beginIndex, endIndex + 1);
          try {
            // Map<String, dynamic> doorValData = json.decode(doorValJson);
            setState(() {
              isRTCOk = rtcJson.contains('OK');
            });
            debugPrint("RTC Values: $rtcJson");
          } catch (e) {
            debugPrint("Error decoding APP-RTC JSON: $e");
          }
        }
      }
      //Flash Status
      if (line.contains('APP-FLASH')) {
        int beginIndex = line.indexOf("{");
        int endIndex = line.lastIndexOf("}");
        if (beginIndex != -1 && endIndex != -1) {
          String flashJson = line.substring(beginIndex, endIndex + 1);
          try {
            setState(() {
              isFlashOk = flashJson.contains('OK');
            });
            debugPrint("Flash Values: $isFlashOk");
          } catch (e) {
            debugPrint("Error decoding APP-FLASH JSON: $e");
          }
        }
      }

      //Door Status
      if (line.contains('APP-DOOR1')) {
        int beginIndex = line.indexOf("{");
        int endIndex = line.lastIndexOf("}");
        if (beginIndex != -1 && endIndex != -1) {
          String doorValJson = line.substring(beginIndex, endIndex + 1);
          try {
            Map<String, dynamic> doorValData = json.decode(doorValJson);
            setState(() {
              isDoorOk = doorValData["STATUS"] == "OK";
              // Optionally store other door values, e.g., "d2"
            });
            debugPrint("Door Values: $doorValData");
          } catch (e) {
            debugPrint("Error decoding APP-DOORVAL JSON: $e");
          }
        }
      }
      //PT values at 0 bar
      if (line.contains('APP-PTVAL - 0bar') || line.contains('PTVal - 0bar')) {
        int beginIndex = line.indexOf("{");
        int endIndex = line.lastIndexOf("}");

        if (beginIndex != -1 && endIndex != -1) {
          String ptJson = line.substring(beginIndex, endIndex + 1);

          try {
            Map<String, dynamic> ptData = json.decode(ptJson);

            setState(() {
              // Ensure outletPT_Values_0bar is large enough before modifying
              if (outletPT_Values_0bar.length < ptData.length - 2) {
                outletPT_Values_0bar = List.filled(ptData.length - 2, 0.0);
              }

              for (int i = 0; i < ptData.length; i++) {
                String key = "PT${i + 1}";
                double value =
                    double.tryParse(ptData[key]?.toString() ?? '0') ?? 0.0;

                if (i == 0) {
                  filterInlet = value;
                } else if (i == 1) {
                  filterOutlet = value;
                } else if (i - 1 < outletPT_Values_0bar.length) {
                  outletPT_Values_0bar[i - 1] = value;
                }
              }
            });

            debugPrint("Pressure Values (0bar): $ptData");
          } catch (e, stackTrace) {
            debugPrint("Error decoding APP-PT - 0bar JSON: $e\n$stackTrace");
          }
        }
      }

      /*if (line.contains('APP-PTVAL - 0bar') || line.contains('PTVal - 0bar')) {
        int beginIndex = line.indexOf("{");
        int endIndex = line.lastIndexOf("}");
        if (beginIndex != -1 && endIndex != -1) {
          String ptJson = line.substring(beginIndex, endIndex + 1);
          try {
            Map<String, dynamic> ptData = json.decode(ptJson);
            setState(() {
              for (int i = 0; i <= outletPT_Values_0bar.length + 2; i++) {
                String key = "PT${i + 1}";
                if (i == 0) {
                  filterInlet = double.parse(ptData[key] ?? '0');
                } else if (i == 1) {
                  filterOutlet = double.parse(ptData[key] ?? '0');
                } else {
                  outletPT_Values_0bar[i - 1] = double.parse(
                    ptData[key] ?? '0',
                  );
                }
              }
            });
            debugPrint("Pressure Values (0bar): $ptData");
          } catch (e) {
            debugPrint("Error decoding APP-PT - 0bar JSON: $e");
          }
        }
      }*/
      //PT Status at 0 bar
      if (line.contains('APP-PT - 0bar')) {
        int beginIndex = line.indexOf("{");
        int endIndex = line.lastIndexOf("}");
        if (beginIndex != -1 && endIndex != -1) {
          String statusJson = line.substring(beginIndex, endIndex + 1);
          try {
            Map<String, dynamic> statusData = json.decode(statusJson);
            String status = statusData["STATUS"] ?? "Unknown";

            setState(() {
              // Set the specific variables for the given barType
              outletPT_0bar = status;
              inletPT_0bar = status;
              for (int i = 0; i < outletPT_Status_0bar.length; i++) {
                outletPT_Status_0bar[i] = status;
              }
              // Add cases for other bar types as needed
            });
          } catch (e) {
            debugPrint("Error decoding APP-PT - 0bar - Status JSON: $e");
          }
        }
      }
      //PT Values at 2 bar
      if (line.contains('PT - 2bar')) {
        int beginIndex = line.indexOf('{');
        int endIndex = line.indexOf('}');
        if (beginIndex != -1 && endIndex != -1) {
          String valueJson = line.substring(beginIndex, endIndex + 1);
          try {
            Map<String, dynamic> valueData = json.decode(valueJson);
            valueData.forEach((key, value) {
              int index = int.parse(key.substring(2)) -
                  1; // Extract PT number (e.g., PT1 -> 0)
              if (index >= 0 && index < outletPT_Values_1bar.length) {
                if (index == 0) {
                  filterInlet1bar = double.parse(value.toString());
                } else if (index == 1) {
                  filterOutlet1bar = double.parse(value.toString());
                } else {
                  outletPT_Values_1bar[index] = double.parse(value.toString());
                }
                outletPT_Values_1bar[index] = double.parse(value.toString());
              }
            });
          } catch (e) {
            debugPrint("Error decoding APP-PT - 2bar JSON: $e");
          }
        }
      }
      //PT Status at 2 bar
      if (line.contains('APP-PT')) {
        final match = RegExp(r'APP-PT\d+ - 2bar - (\{.*?\})').firstMatch(line);
        if (match != null) {
          String statusJson = match.group(1) ?? '';
          try {
            // Decode the JSON to extract the "STATUS"
            Map<String, dynamic> statusData = json.decode(statusJson);
            String status = statusData["STATUS"]?.trim() ??
                "Unknown"; // Trim any extra spaces

            setState(() {
              for (int i = 0; i <= outletPT_Values_0bar.length + 2; i++) {
                if (i == 0) {
                  inletPT_1bar = status;
                } else if (i == 1) {
                  outletPT_1bar = status;
                } else {
                  outletPT_Status_1bar[i - 2] = status;
                }
              }
              // Update all elements of position_status list
              for (int i = 0; i < position_status!.length; i++) {
                position_status![i] = status;
              }
            });

            debugPrint("Position Status for APP-PT: $status");
          } catch (e) {
            debugPrint("Error decoding APP-PT JSON: $e");
          }
        }
      }
      //Position Sensor values
      if (line.contains('APP-PS - METAL')) {
        int beginIndex = line.indexOf("{");
        int endIndex = line.lastIndexOf("}");
        if (beginIndex != -1 && endIndex != -1) {
          String statusJson = line.substring(beginIndex, endIndex + 1);
          try {
            Map<String, dynamic> psData = json.decode(statusJson);
            psData.forEach((key, value) {
              // Extract the PS index and assign the value to the corresponding list
              if (key.startsWith("PS")) {
                int index =
                    int.parse(key.substring(2)) - 1; // Convert PS1 to index 0
                if (index >= 0 && index < position_values!.length) {
                  position_values![index] = double.parse(value.toString());
                }
              }
            });

            debugPrint("Position Sensor Values: $position_values");
          } catch (e) {
            debugPrint("Error decoding APP-PS - METAL JSON: $e");
          }
        }
      }
      //Position Sensor Status
      if (line.contains('APP-PS')) {
        final match = RegExp(r'APP-PS\d+ - METAL - (\{.*?\})').firstMatch(line);
        if (match != null) {
          String statusJson = match.group(1) ?? '';
          try {
            // Decode the JSON to extract the "STATUS"
            Map<String, dynamic> statusData = json.decode(statusJson);
            String status = statusData["STATUS"]?.trim() ??
                "Unknown"; // Trim any extra spaces

            setState(() {
              // Update all elements of position_status list
              for (int i = 0; i < position_status!.length; i++) {
                position_status![i] = status;
              }
            });

            debugPrint("Position Status for APP-PT: $status");
          } catch (e) {
            debugPrint("Error decoding APP-PT JSON: $e");
          }
        }
      }
      //Solenoide Status
      if (line.contains('APP-SOV')) {
        int beginIndex = line.indexOf("{");
        int endIndex = line.lastIndexOf("}");
        if (beginIndex != -1 && endIndex != -1) {
          String sovJson = line.substring(beginIndex, endIndex + 1);
          try {
            Map<String, dynamic> sovData = json.decode(sovJson);
            setState(() {
              for (int i = 1; i <= solenoid_status!.length; i++) {
                String key = "SOV$i";
                solenoid_status![i - 1] = sovData[key] ??
                    'UNKNOWN'; // Default to 'UNKNOWN' if key not found
              }
            });
            debugPrint("SOV Statuses: $sovData");
          } catch (e) {
            debugPrint("Error decoding APP-SOV JSON: $e");
          }
        }
      }
      //MacId
      if (line.contains('APP-MACID')) {
        int beginIndex = line.indexOf("{");
        int endIndex = line.lastIndexOf("}");
        if (beginIndex != -1 && endIndex != -1) {
          String macJson = line.substring(beginIndex, endIndex + 1);
          try {
            Map<String, dynamic> macAddressval = json.decode(macJson);
            setState(() {
              macId = macAddressval["MACID"];
              // Optionally store other door values, e.g., "d2"
            });

            debugPrint("MACID Values: $macJson");
          } catch (e) {
            debugPrint("Error decoding APP-MACID JSON: $e");
          }
        }
      } else {
        debugPrint("Unhandled message: $line");
      }
    }
  }

  /*void _handleData(Uint8List data) {
    print("Lenght Of Data: ${data.length}");
    _dataBuffer.addAll(data);
    String completeMessage = String.fromCharCodes(_dataBuffer);
    String hexData = hex.encode(_dataBuffer);
    _dataBuffer.clear();
    setState(() {
      _response.add(hexData);
      _serialData.add(completeMessage);
    });

    // Extract data into variables

    for (String line in completeMessage.split('\n')) {
      line = line.trim();
      debugPrint(line);

      //RTC Status
      if (line.contains('APP-RTC')) {
        int beginIndex = line.indexOf("{");
        int endIndex = line.lastIndexOf("}");
        if (beginIndex != -1 && endIndex != -1) {
          String rtcJson = line.substring(beginIndex, endIndex + 1);
          try {
            // Map<String, dynamic> doorValData = json.decode(doorValJson);
            setState(() {
              isRTCOk = rtcJson.contains('OK');
            });
            debugPrint("RTC Values: $rtcJson");
          } catch (e) {
            debugPrint("Error decoding APP-RTC JSON: $e");
          }
        }
      }
      //Door Status
      else if (line.contains('APP-DOORVAL') || line.contains('DOORVAL')) {
        int beginIndex = line.indexOf("{");
        int endIndex = line.lastIndexOf("}");
        if (beginIndex != -1 && endIndex != -1) {
          String doorValJson = line.substring(beginIndex, endIndex + 1);
          try {
            Map<String, dynamic> doorValData = json.decode(doorValJson);
            setState(() {
              isDoorOk = doorValData["d1"] == "0";
              // Optionally store other door values, e.g., "d2"
            });
            debugPrint("Door Values: $doorValData");
          } catch (e) {
            debugPrint("Error decoding APP-DOORVAL JSON: $e");
          }
        }
      } else if (line.contains('APP-DOOR1')) {
        int beginIndex = line.indexOf("{");
        int endIndex = line.lastIndexOf("}");
        if (beginIndex != -1 && endIndex != -1) {
          String doorValJson = line.substring(beginIndex, endIndex + 1);
          try {
            Map<String, dynamic> doorValData = json.decode(doorValJson);
            setState(() {
              isDoorOk = doorValData["STATUS"] == "OK";
              // Optionally store other door values, e.g., "d2"
            });
            debugPrint("Door Values: $doorValData");
          } catch (e) {
            debugPrint("Error decoding APP-DOORVAL JSON: $e");
          }
        }
      }
      //PT values at 0 bar
      else if (line.contains('APP-PTVAL - 0bar')) {
        int beginIndex = line.indexOf("{");
        int endIndex = line.lastIndexOf("}");
        if (beginIndex != -1 && endIndex != -1) {
          String ptJson = line.substring(beginIndex, endIndex + 1);
          try {
            Map<String, dynamic> ptData = json.decode(ptJson);
            setState(() {
              for (int i = 1; i <= outletPT_Values_0bar.length + 2; i++) {
                String key = "PT$i";
                if (i == 0) {
                  filterInlet = double.parse(ptData[key] ?? '0');
                } else if (i == 1) {
                  filterOutlet = double.parse(ptData[key] ?? '0');
                } else {
                  outletPT_Values_0bar[i - 1] = double.parse(
                    ptData[key] ?? '0',
                  );
                }
              }
            });
            debugPrint("Pressure Values (0bar): $ptData");
          } catch (e) {
            debugPrint("Error decoding APP-PT - 0bar JSON: $e");
          }
        }
      }
      //PT Status at 0 bar
      else if (line.contains('APP-PT - 0bar')) {
        int beginIndex = line.indexOf("{");
        int endIndex = line.lastIndexOf("}");
        if (beginIndex != -1 && endIndex != -1) {
          String statusJson = line.substring(beginIndex, endIndex + 1);
          try {
            Map<String, dynamic> statusData = json.decode(statusJson);
            String status = statusData["STATUS"] ?? "Unknown";

            setState(() {
              // Set the specific variables for the given barType
              outletPT_0bar = status;
              inletPT_0bar = status;
              for (int i = 0; i < outletPT_Status_0bar.length; i++) {
                outletPT_Status_0bar[i] = status;
              }
              // Add cases for other bar types as needed
            });
          } catch (e) {
            debugPrint("Error decoding APP-PT - 0bar - Status JSON: $e");
          }
        }
      }
      //PT Values at 2 bar
      else if (line.contains('PT - 2bar')) {
        int beginIndex = line.indexOf('{');
        int endIndex = line.indexOf('}');
        if (beginIndex != -1 && endIndex != -1) {
          String valueJson = line.substring(beginIndex, endIndex + 1);
          try {
            Map<String, dynamic> valueData = json.decode(valueJson);
            valueData.forEach((key, value) {
              int index = int.parse(key.substring(2)) -
                  1; // Extract PT number (e.g., PT1 -> 0)
              if (index >= 0 && index < outletPT_Values_1bar.length) {
                if (index == 0) {
                  filterInlet1bar = double.parse(value.toString());
                } else if (index == 1) {
                  filterOutlet1bar = double.parse(value.toString());
                } else {
                  outletPT_Values_1bar[index] = double.parse(value.toString());
                }
                outletPT_Values_1bar[index] = double.parse(value.toString());
              }
            });
          } catch (e) {
            debugPrint("Error decoding APP-PT - 2bar JSON: $e");
          }
        }
      }
      //PT Status at 2 bar
      else if (line.contains('APP-PT')) {
        final match = RegExp(r'APP-PT\d+ - 2bar - (\{.*?\})').firstMatch(line);
        if (match != null) {
          String statusJson = match.group(1) ?? '';
          try {
            // Decode the JSON to extract the "STATUS"
            Map<String, dynamic> statusData = json.decode(statusJson);
            String status = statusData["STATUS"]?.trim() ??
                "Unknown"; // Trim any extra spaces

            setState(() {
              for (int i = 0; i <= outletPT_Values_0bar.length + 2; i++) {
                if (i == 0) {
                  inletPT_1bar = status;
                } else if (i == 1) {
                  outletPT_1bar = status;
                } else {
                  outletPT_Status_1bar[i - 2] = status;
                }
              }
              // Update all elements of position_status list
              for (int i = 0; i < position_status!.length; i++) {
                position_status![i] = status;
              }
            });

            debugPrint("Position Status for APP-PT: $status");
          } catch (e) {
            debugPrint("Error decoding APP-PT JSON: $e");
          }
        }
      }
      //Position Sensor values
      else if (line.contains('APP-PS - METAL')) {
        int beginIndex = line.indexOf("{");
        int endIndex = line.lastIndexOf("}");
        if (beginIndex != -1 && endIndex != -1) {
          String statusJson = line.substring(beginIndex, endIndex + 1);
          try {
            Map<String, dynamic> psData = json.decode(statusJson);
            psData.forEach((key, value) {
              // Extract the PS index and assign the value to the corresponding list
              if (key.startsWith("PS")) {
                int index =
                    int.parse(key.substring(2)) - 1; // Convert PS1 to index 0
                if (index >= 0 && index < position_values!.length) {
                  position_values![index] = double.parse(value.toString());
                }
              }
            });

            debugPrint("Position Sensor Values: $position_values");
          } catch (e) {
            debugPrint("Error decoding APP-PS - METAL JSON: $e");
          }
        }
      }
      //Position Sensor Status
      else if (line.contains('APP-PS')) {
        final match = RegExp(r'APP-PS\d+ - METAL - (\{.*?\})').firstMatch(line);
        if (match != null) {
          String statusJson = match.group(1) ?? '';
          try {
            // Decode the JSON to extract the "STATUS"
            Map<String, dynamic> statusData = json.decode(statusJson);
            String status = statusData["STATUS"]?.trim() ??
                "Unknown"; // Trim any extra spaces

            setState(() {
              // Update all elements of position_status list
              for (int i = 0; i < position_status!.length; i++) {
                position_status![i] = status;
              }
            });

            debugPrint("Position Status for APP-PT: $status");
          } catch (e) {
            debugPrint("Error decoding APP-PT JSON: $e");
          }
        }
      }
      //Solenoide Status
      else if (line.contains('APP-SOV')) {
        int beginIndex = line.indexOf("{");
        int endIndex = line.lastIndexOf("}");
        if (beginIndex != -1 && endIndex != -1) {
          String sovJson = line.substring(beginIndex, endIndex + 1);
          try {
            Map<String, dynamic> sovData = json.decode(sovJson);
            setState(() {
              for (int i = 1; i <= solenoid_status!.length; i++) {
                String key = "SOV$i";
                solenoid_status![i - 1] = sovData[key] ??
                    'UNKNOWN'; // Default to 'UNKNOWN' if key not found
              }
            });
            debugPrint("SOV Statuses: $sovData");
          } catch (e) {
            debugPrint("Error decoding APP-SOV JSON: $e");
          }
        }
      }
      //MacId
      else if (line.contains('APP-MACID')) {
        int beginIndex = line.indexOf("{");
        int endIndex = line.lastIndexOf("}");
        if (beginIndex != -1 && endIndex != -1) {
          String macJson = line.substring(beginIndex, endIndex + 1);
          try {
            Map<String, dynamic> macAddressval = json.decode(macJson);
            setState(() {
              macId = macAddressval["MACID"];
              // Optionally store other door values, e.g., "d2"
            });

            debugPrint("MACID Values: $macJson");
          } catch (e) {
            debugPrint("Error decoding APP-MACID JSON: $e");
          }
        }
      }
      //Else, handle other messages
      else {
        debugPrint("Unhandled message: $line");
      }
    }
    if (_serialData.join().contains('READY')) {
      setState(() {
        isReady = true;
      });
    }
  }
*/

  Future<void> _logSerialData(String Message) async {
    try {
      // Get the application documents directory
      String formattedDate = await FileUtils.getFormattedDate();
      Directory directory = await FileUtils.createDirectory(
          'USB Console App', formattedDate, 'Assembly-Test');
      final file = File('${directory.path}/serial_log.txt');

      // Append data to the log file
      final logContent = Message + '\n';
      await file.writeAsString(logContent, mode: FileMode.append);

      debugPrint("Data logged to ${file.path}");
    } catch (e) {
      debugPrint("Error writing to log file: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _initSerialListeners();
    initializeLists();
    _fetchDevices();
  }

  Future<void> _fetchDevices() async {
    final devices = await _serialComm.getAvailableDevices();
    setState(() {
      _devices.clear();
      _devices.addAll(devices);
    });
  }

  void initializeLists() {
    outletPT_Status_0bar = List.filled(noOfPfcmds, '');
    outletPT_Values_0bar = List.filled(noOfPfcmds, 0.0);

    outletPT_Status_1bar = List.filled(noOfPfcmds, '');
    outletPT_Values_1bar = List.filled(noOfPfcmds, 0.0);

    position_status = List.filled(noOfPfcmds, '');
    position_values = List.filled(noOfPfcmds, 0.0);

    solenoid_status = List.filled(noOfPfcmds, '');
  }

  // Future<void> _getPorts() async {
  //   final devices = await _serialComm.getAvailableDevices();
  //   setState(() {
  //     _devices = devices;
  //   });
  // }

  clearSerialData() {
    setState(() {
      _serialData.clear();
      _response.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assembly Test')),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Clear Console',
        child: const Icon(Icons.clear_all_rounded),
        onPressed: () {
          clearSerialData();
        },
      ),
      body: Container(
        padding: const EdgeInsets.all(8.0),
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            for (final device in _devices)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.blueAccent.shade100,
                ),
                child: ListTile(
                  leading: Container(
                    decoration: BoxDecoration(
                      color: Colors.lightBlue.shade200,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(5.0),
                      child: Icon(Icons.usb),
                    ),
                  ),
                  title: Text(device.productName),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 2,
                      backgroundColor:
                          _status == 'Disconnected' ? Colors.red : Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: Text(btntxt),
                    onPressed: () {
                      if (_status == 'Disconnected') {
                        _connectTo(device);
                      } else if (_status == 'Connected') {
                        _connectTo(null);
                        setState(() {
                          isStart = false;
                        });
                      } else {
                        _connectTo(device);
                      }
                    },
                  ),
                ),
              ),
            // if (isReady)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 2,
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onPressed: _devices.isEmpty
                      ? null
                      : () async {
                          debugPrint('Start Assembly Test');
                          debugPrint('MAC ID: \$0080E1150541B9BF\$');
                          if (_devices.isEmpty) {
                            return;
                          }
                          /*if (!isStart) {*/
                          setState(() {
                            isStart = true;
                          });
                          _serialData.clear();

                          String data = "${'START'.toUpperCase()}\r\n";
                          setState(() {
                            _serialData.add(data);
                          });

                          bool isMessageSent = await _serialComm.write(
                            Uint8List.fromList(data.codeUnits),
                          );
                          debugPrint("Is Message Sent:  $isMessageSent");
                          // }
                        },
                  child: const SizedBox(
                    height: 50,
                    child: Center(
                      child: Text(
                        "Start Assembly Test",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (isReady) infoCardWidget(),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 200,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 253, 249, 249),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black),
                    ),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: _serialData.reversed // Reverse the list
                            .map(
                              (message) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 5.0,
                                ),
                                child: Text(
                                  message,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors
                                        .black, // Set the desired text color here
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget infoCardWidget() {
    try {
      return Expanded(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(5.5),
                  decoration: BoxDecoration(
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 1.5,
                        spreadRadius: 2.2,
                        offset: Offset(1.5, 2),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: const Text(
                                'Flash Status Checks',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Divider(),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.20,
                              child: const Text(
                                'Flash Status',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.15,
                              child: Text(
                                isFlashOk ? 'Ok' : 'Faulty',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                //RTC Check
                Container(
                  margin: const EdgeInsets.all(5.5),
                  decoration: BoxDecoration(
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 1.5,
                        spreadRadius: 2.2,
                        offset: Offset(1.5, 2),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: const Text(
                                'RTC Status Checks',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Divider(),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.20,
                              child: const Text(
                                'RTC Status',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.15,
                              child: Text(
                                isRTCOk ? 'Ok' : 'Faulty',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                //Door Status Check
                Container(
                  margin: const EdgeInsets.all(5.5),
                  decoration: BoxDecoration(
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 1.5,
                        spreadRadius: 2.2,
                        offset: Offset(1.5, 2),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: const Text(
                                'Door Status Checks',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Divider(),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.20,
                              child: const Text(
                                'Door Status',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.15,
                              child: Text(
                                isDoorOk ? 'Ok' : 'Faulty',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      /*
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.20,
                              child: const Text(
                                'Open Door',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.15,
                              child: const Text(
                                'OPEN',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.15,
                              child: Text(
                                '${isDoorOpen ? 'OPEN' : 'CLOSE'}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.15,
                              child: Text(
                                "${isDoorOpen ? 'Ok' : 'Faulty'}",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.20,
                              child: const Text(
                                'Close Door',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.15,
                              child: const Text(
                                'CLOSE',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.15,
                              child: Text(
                                '${isDoorClose ? 'CLOSE' : 'OPEN'}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.15,
                              child: Text(
                                "${isDoorClose ? 'OK' : 'Faulty'}",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    */
                    ],
                  ),
                ),
                //PT Valve Check at 0 bar
                Container(
                  margin: const EdgeInsets.all(5.5),
                  decoration: BoxDecoration(
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 1.5,
                        spreadRadius: 2.2,
                        offset: Offset(1.5, 2),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'PT Valve Check At 0 Bar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Divider(),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.15,
                              child: const Text(
                                'Description',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.15,
                              child: const Text(
                                'Exp. Value',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.15,
                              child: const Text(
                                'Act. Value',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.15,
                              child: const Text(
                                "Remark",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      //Inlet valve Check
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.all(8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.15,
                                    child: const Text(
                                      "Filter Inlet PT",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.15,
                                    child: const Text(
                                      '4000 mA',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.15,
                                    child: Text(
                                      '${filterInlet ?? ''} mA',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.15,
                                    child: Text(
                                      inletPT_0bar,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.all(8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.15,
                                    child: const Text(
                                      "Filter Outlet PT",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.15,
                                    child: const Text(
                                      '4000 mA',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.15,
                                    child: Text(
                                      '${filterOutlet ?? ''} mA',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.15,
                                    child: Text(
                                      outletPT_0bar,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Divider(),
                      ),

                      //Outlet valve Check
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                          itemCount: noOfPfcmds,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.all(8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.15,
                                    child: Text(
                                      'Outlet PT ${index + 1}',
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.15,
                                    child: const Text(
                                      '4000 mA',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.15,
                                    child: Text(
                                      '${outletPT_Values_0bar[index]} mA',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.15,
                                    child: Text(
                                      outletPT_Status_0bar[index],
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                //PT Valve Check at 2 bar
                Container(
                  margin: const EdgeInsets.all(5.5),
                  decoration: BoxDecoration(
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 1.5,
                        spreadRadius: 2.2,
                        offset: Offset(1.5, 2),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'PT Valve Check At 2 Bar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Divider(),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.3,
                              child: const Text(
                                'Description',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            /*SizedBox(
                              width: MediaQuery.of(context).size.width * 0.15,
                              child: const Text(
                                'Exp. Value',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),*/
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.25,
                              child: const Text(
                                'Act. Value',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.25,
                              child: const Text(
                                "Remark",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      //Inlet valve Check
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.all(8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
                                    child: const Text(
                                      "Filter Inlet PT",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  /*SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.15,
                                    child: const Text(
                                      '0.5 - 1.2 bar',
                                      textAlign: TextAlign.center,
                                      // style: TextStyle(
                                      //   fontSize: 16,
                                      //   fontWeight: FontWeight.bold,
                                      // ),
                                    ),
                                  ),*/
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.25,
                                    child: Text(
                                      '${filterInlet1bar ?? ''} mA',
                                      textAlign: TextAlign.center,
                                      // style: TextStyle(
                                      //   fontSize: 16,
                                      //   fontWeight: FontWeight.bold,
                                      // ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.25,
                                    child: Text(
                                      inletPT_1bar,
                                      textAlign: TextAlign.center,
                                      // style: TextStyle(
                                      //   fontSize: 16,
                                      //   fontWeight: FontWeight.bold,
                                      // ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.all(8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
                                    child: const Text(
                                      "Filter Outlet PT",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  /*SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.15,
                                    child: const Text(
                                      '0.5 - 1.2 bar',
                                      textAlign: TextAlign.center,
                                      // style: TextStyle(
                                      //   fontSize: 16,
                                      //   fontWeight: FontWeight.bold,
                                      // ),
                                    ),
                                  ),*/
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.25,
                                    child: Text(
                                      '${filterOutlet1bar ?? ''} mA',
                                      textAlign: TextAlign.center,
                                      // style: TextStyle(
                                      //   fontSize: 16,
                                      //   fontWeight: FontWeight.bold,
                                      // ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.25,
                                    child: Text(
                                      outletPT_1bar,
                                      textAlign: TextAlign.center,
                                      // style: TextStyle(
                                      //   fontSize: 16,
                                      //   fontWeight: FontWeight.bold,
                                      // ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Divider(),
                      ),

                      //Outlet valve Check
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: noOfPfcmds,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.all(8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
                                    child: Text(
                                      'Outlet PT ${index + 1}',
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  /*SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.15,
                                      child: const Text(
                                        '0.5 - 1.2 bar',
                                        textAlign: TextAlign.center,
                                        // style: TextStyle(
                                        //   fontSize: 16,
                                        //   fontWeight: FontWeight.bold,
                                        // ),
                                      ),
                                    ),*/
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.25,
                                    child: Text(
                                      '${outletPT_Values_1bar[index]} mA',
                                      textAlign: TextAlign.center,
                                      // style: TextStyle(
                                      //   fontSize: 16,
                                      //   fontWeight: FontWeight.bold,
                                      // ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.25,
                                    child: Text(
                                      outletPT_Status_1bar[index],
                                      textAlign: TextAlign.center,
                                      // style: TextStyle(
                                      //   fontSize: 16,
                                      //   fontWeight: FontWeight.bold,
                                      // ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                //Position Senson
                Container(
                  margin: const EdgeInsets.all(5.5),
                  decoration: BoxDecoration(
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 1.5,
                        spreadRadius: 2.2,
                        offset: Offset(1.5, 2),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Position Sensor ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Divider(),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.3,
                              child: const Text(
                                'Description',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.18,
                              child: const Text(
                                'Exp. Value',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.15,
                              child: const Text(
                                'Act. Value',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.15,
                              child: const Text(
                                "Remark",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                          itemCount: 6,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.all(8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
                                    child: Text(
                                      'Position Sensor ${index + 1}',
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.18,
                                    child: const Text(
                                      '3000 - 20000 mA',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.15,
                                    child: Text(
                                      '${position_values?[index] ?? ''} mA',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.15,
                                    child: Text(
                                      "${position_status?[index]}",
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                //Solenoid block
                Container(
                  margin: const EdgeInsets.all(5.5),
                  decoration: BoxDecoration(
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 1.5,
                        spreadRadius: 2.2,
                        offset: Offset(1.5, 2),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Solenoid Test',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Divider(),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.3,
                              child: const Text(
                                'Description',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.15,
                              child: const Text(
                                "Remark",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      //Solenoid test
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: noOfPfcmds,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.all(8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
                                    child: Text(
                                      'Solenoid ${index + 1}',
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.15,
                                    child: Text(
                                      "${solenoid_status?[index]}",
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                //MacId
                Container(
                  margin: const EdgeInsets.all(5.5),
                  decoration: BoxDecoration(
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 1.5,
                        spreadRadius: 2.2,
                        offset: Offset(1.5, 2),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.3,
                              child: const Text(
                                'MAC ID :',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "$macId",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                //Save PDF Button
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isSaved!)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Your PDF was saved successfully ${filePath?.replaceAll('/', '>')}.',
                        ) /*now please set all the solenoid to Flow Control mode.*/,
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 25),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  5,
                                ), // Set border radius to 0 for square shape
                              ),
                            ),
                            onPressed: () {
                              getusername();
                              getcurrentdate();
                              showSaveDialog(context);
                              // saveJSON();
                            },
                            child: const Text(
                              'Submit',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    } catch (ex, _) {
      return const Center(child: Text('Click On Get SINM to Find Device Type'));
    }
  }

  getusername() async {
    final sharePref = await SharedPreferences.getInstance();
    var res = sharePref.getInt('batchNo');
    var user = sharePref.getString(Keys.user.name);
    if (user != null) {
      final userJson = json.decode(user);
      var newUser = LoginMasterModel.fromJson(userJson);
      username = newUser.fName;
      userId = newUser.userid;
      batchNo = res;
    }
  }

  getcurrentdate() async {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('dd-MM-yyyyTHH:mm:ss');
    final String formatted = formatter.format(now);
    Cdate = formatted;
  }

  void _showProcessingToast(BuildContext context, {String? content}) {
    CherryToast.info(
      title: Text(
        content ?? 'Processing data...',
        style: const TextStyle(letterSpacing: 2),
      ),
      // displayTitle: true,
      // icon: Icons.hourglass_bottom,
      animationType: AnimationType.fromBottom,
      borderRadius: 20,
      toastDuration: const Duration(seconds: 2),
    ).show(context);
  }

  void _showFlashTestCode(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/tap.png', height: 90, width: 90),
                  const Text(
                    'Flash Test Code',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "Please flash the test firmware in the controller to test the unit",
                    style: TextStyle(fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 60),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 2,
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Ok'),
                  ),
                  // OutlinedButton(onPressed: () {}, child: Text('Ok'))
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void showSaveDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/pdf.png', height: 90, width: 90),
                  const Text(
                    'Save PDF',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "Please confirm that you want save the PDF.",
                    style: TextStyle(fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 60),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 2,
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        onPressed: () async {
                          _submitForm();
                          Navigator.of(context).pop();
                        },
                        child: const Text('Save'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 2,
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _submitForm() {
    final pdfWidgets.Document pdf = pdfWidgets.Document();
    //Page 1
    pdf.addPage(
      pdfWidgets.Page(
        build: (context) {
          return pdfWidgets.Container(
            child: pdfWidgets.Column(
              mainAxisAlignment: pdfWidgets.MainAxisAlignment.start,
              crossAxisAlignment: pdfWidgets.CrossAxisAlignment.start,
              children: [
                pdfWidgets.Center(
                  child: pdfWidgets.Text(
                    'Assembly Testing Report',
                    style: pdfWidgets.TextStyle(
                      fontSize: 24,
                      fontWeight: pdfWidgets.FontWeight.bold,
                    ),
                  ),
                ),
                pdfWidgets.Divider(),

                // RTC Status Check
                pdfWidgets.Padding(
                  padding: const pdfWidgets.EdgeInsets.all(8.0),
                  child: pdfWidgets.Text(
                    'RTC Status Check',
                    style: pdfWidgets.TextStyle(
                      fontSize: 14,
                      fontWeight: pdfWidgets.FontWeight.bold,
                    ),
                  ),
                ),
                pdfWidgets.Padding(
                  padding: const pdfWidgets.EdgeInsets.all(8.0),
                  child: pdfWidgets.Row(
                    mainAxisAlignment:
                        pdfWidgets.MainAxisAlignment.spaceBetween,
                    children: [
                      pdfWidgets.SizedBox(
                        child: pdfWidgets.Text(
                          'RTC Status :',
                          style: pdfWidgets.TextStyle(
                            fontWeight: pdfWidgets.FontWeight.bold,
                          ),
                        ),
                      ),
                      pdfWidgets.SizedBox(
                        child: pdfWidgets.Text(
                          isRTCOk ? 'Ok' : 'Faulty',
                          style: pdfWidgets.TextStyle(
                            fontWeight: pdfWidgets.FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                pdfWidgets.Divider(),
                // Door Status
                pdfWidgets.Padding(
                  padding: const pdfWidgets.EdgeInsets.all(8.0),
                  child: pdfWidgets.Text(
                    'Door Status Check',
                    style: pdfWidgets.TextStyle(
                      fontSize: 14,
                      fontWeight: pdfWidgets.FontWeight.bold,
                    ),
                  ),
                ),
                pdfWidgets.Padding(
                  padding: const pdfWidgets.EdgeInsets.all(8.0),
                  child: pdfWidgets.Row(
                    mainAxisAlignment:
                        pdfWidgets.MainAxisAlignment.spaceBetween,
                    children: [
                      pdfWidgets.SizedBox(
                        child: pdfWidgets.Text(
                          'Door Open :',
                          style: pdfWidgets.TextStyle(
                            fontWeight: pdfWidgets.FontWeight.bold,
                          ),
                        ),
                      ),
                      pdfWidgets.SizedBox(
                        child: pdfWidgets.Text(
                          isDoorOk ? 'Ok' : 'Faulty',
                          style: pdfWidgets.TextStyle(
                            fontWeight: pdfWidgets.FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                pdfWidgets.Divider(),

                //PT check At 0 Bar
                pdfWidgets.Padding(
                  padding: const pdfWidgets.EdgeInsets.all(8.0),
                  child: pdfWidgets.Text(
                    'PT Valve Check At 0 Bar',
                    style: pdfWidgets.TextStyle(
                      fontSize: 14,
                      fontWeight: pdfWidgets.FontWeight.bold,
                    ),
                  ),
                ),
                pdfWidgets.Padding(
                  padding: const pdfWidgets.EdgeInsets.all(8),
                  child: pdfWidgets.Table(
                    border: pdfWidgets.TableBorder.all(
                      width: 1,
                      color: PdfColors.black,
                    ),
                    children: [
                      pdfWidgets.TableRow(
                        children: [
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                'Description',
                                style: pdfWidgets.TextStyle(
                                  fontWeight: pdfWidgets.FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                'Exp. Value',
                                style: pdfWidgets.TextStyle(
                                  fontWeight: pdfWidgets.FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                'Act. Value',
                                style: pdfWidgets.TextStyle(
                                  fontWeight: pdfWidgets.FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                'Remark',
                                style: pdfWidgets.TextStyle(
                                  fontWeight: pdfWidgets.FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      pdfWidgets.TableRow(
                        children: [
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text("Filter Inlet PT"),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text('4000 mA'),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                '${filterInlet.toString()} mA',
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(inletPT_0bar),
                            ),
                          ),
                        ],
                      ),
                      pdfWidgets.TableRow(
                        children: [
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text('Flter Outlet PT'),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text("4000 mA"),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                '${filterOutlet.toString()} mA',
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(outletPT_0bar),
                            ),
                          ),
                        ],
                      ),

                      ...List.generate(noOfPfcmds, (index) {
                        return pdfWidgets.TableRow(
                          children: [
                            pdfWidgets.Expanded(
                              flex: 1,
                              child: pdfWidgets.Container(
                                height: 20,
                                alignment: pdfWidgets.Alignment.center,
                                child: pdfWidgets.Text(
                                  'Outlet PT ${index + 1}',
                                ),
                              ),
                            ),
                            pdfWidgets.Expanded(
                              flex: 1,
                              child: pdfWidgets.Container(
                                height: 20,
                                alignment: pdfWidgets.Alignment.center,
                                child: pdfWidgets.Text('4000 mA'),
                              ),
                            ),
                            pdfWidgets.Expanded(
                              flex: 1,
                              child: pdfWidgets.Container(
                                height: 20,
                                alignment: pdfWidgets.Alignment.center,
                                child: pdfWidgets.Text(
                                  '${outletPT_Values_0bar[index].toString()} mA',
                                ),
                              ),
                            ),
                            pdfWidgets.Expanded(
                              flex: 1,
                              child: pdfWidgets.Container(
                                height: 20,
                                alignment: pdfWidgets.Alignment.center,
                                child: pdfWidgets.Text(
                                  outletPT_Status_0bar[index],
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(), // Don't forget to convert the iterable into a list
                    ],
                  ),
                ),
                //PT check At 2 Bar
                pdfWidgets.Padding(
                  padding: const pdfWidgets.EdgeInsets.all(8.0),
                  child: pdfWidgets.Text(
                    'PT Valve Check At 2 Bar',
                    style: pdfWidgets.TextStyle(
                      fontSize: 14,
                      fontWeight: pdfWidgets.FontWeight.bold,
                    ),
                  ),
                ),
                pdfWidgets.Padding(
                  padding: const pdfWidgets.EdgeInsets.all(8),
                  child: pdfWidgets.Table(
                    border: pdfWidgets.TableBorder.all(
                      width: 1,
                      color: PdfColors.black,
                    ),
                    children: [
                      pdfWidgets.TableRow(
                        children: [
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                'Description',
                                style: pdfWidgets.TextStyle(
                                  fontWeight: pdfWidgets.FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          // pdfWidgets.Expanded(
                          //   flex: 1,
                          //   child: pdfWidgets.Container(
                          //     height: 20,
                          //     alignment: pdfWidgets.Alignment.center,
                          //     child: pdfWidgets.Text('Exp. Value',
                          //         style: pdfWidgets.TextStyle(
                          //             fontWeight: pdfWidgets.FontWeight.bold)),
                          //   ),
                          // ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                'Act. Value',
                                style: pdfWidgets.TextStyle(
                                  fontWeight: pdfWidgets.FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                'Remark',
                                style: pdfWidgets.TextStyle(
                                  fontWeight: pdfWidgets.FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      pdfWidgets.TableRow(
                        children: [
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text("Filter Inlet PT"),
                            ),
                          ),
                          // pdfWidgets.Expanded(
                          //   flex: 1,
                          //   child: pdfWidgets.Container(
                          //     height: 20,
                          //     alignment: pdfWidgets.Alignment.center,
                          //     child: pdfWidgets.Text('0.5 - 1.2 bar'),
                          //   ),
                          // ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                '${filterInlet1bar.toString()} mA',
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(inletPT_1bar),
                            ),
                          ),
                        ],
                      ),
                      pdfWidgets.TableRow(
                        children: [
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text('Flter Outlet PT'),
                            ),
                          ),
                          // pdfWidgets.Expanded(
                          //   flex: 1,
                          //   child: pdfWidgets.Container(
                          //     height: 20,
                          //     alignment: pdfWidgets.Alignment.center,
                          //     child: pdfWidgets.Text("0.5 - 1.2 bar"),
                          //   ),
                          // ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                '${filterOutlet1bar.toString()} mA',
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(outletPT_1bar),
                            ),
                          ),
                        ],
                      ),

                      ...List.generate(
                        noOfPfcmds,
                        (index) {
                          return pdfWidgets.TableRow(
                            children: [
                              pdfWidgets.Expanded(
                                flex: 1,
                                child: pdfWidgets.Container(
                                  height: 20,
                                  alignment: pdfWidgets.Alignment.center,
                                  child: pdfWidgets.Text(
                                    'Outlet PT ${index + 1}',
                                  ),
                                ),
                              ),
                              // pdfWidgets.Expanded(
                              //   flex: 1,
                              //   child: pdfWidgets.Container(
                              //     height: 20,
                              //     alignment: pdfWidgets.Alignment.center,
                              //     child: pdfWidgets.Text('0.5 - 1.2 bar'),
                              //   ),
                              // ),
                              pdfWidgets.Expanded(
                                flex: 1,
                                child: pdfWidgets.Container(
                                  height: 20,
                                  alignment: pdfWidgets.Alignment.center,
                                  child: pdfWidgets.Text(
                                    '${outletPT_Values_1bar[index]} mA',
                                  ),
                                ),
                              ),
                              pdfWidgets.Expanded(
                                flex: 1,
                                child: pdfWidgets.Container(
                                  height: 20,
                                  alignment: pdfWidgets.Alignment.center,
                                  child: pdfWidgets.Text(
                                    outletPT_Status_1bar[index],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ).toList(), // Don't forget to convert the iterable into a list
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
    //Page 2
    pdf.addPage(
      pdfWidgets.Page(
        build: (context) {
          return pdfWidgets.Container(
            child: pdfWidgets.Column(
              mainAxisAlignment: pdfWidgets.MainAxisAlignment.start,
              crossAxisAlignment: pdfWidgets.CrossAxisAlignment.start,
              children: [
                // Position Sensor Table
                pdfWidgets.Padding(
                  padding: const pdfWidgets.EdgeInsets.all(8.0),
                  child: pdfWidgets.Text(
                    'Position Sensor Test',
                    style: pdfWidgets.TextStyle(
                      fontSize: 14,
                      fontWeight: pdfWidgets.FontWeight.bold,
                    ),
                  ),
                ),
                pdfWidgets.Padding(
                  padding: const pdfWidgets.EdgeInsets.all(8),
                  child: pdfWidgets.Table(
                    border: pdfWidgets.TableBorder.all(
                      width: 1,
                      color: PdfColors.black,
                    ),
                    children: [
                      pdfWidgets.TableRow(
                        children: [
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                'Description',
                                style: pdfWidgets.TextStyle(
                                  fontWeight: pdfWidgets.FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                'Exp. Value',
                                style: pdfWidgets.TextStyle(
                                  fontWeight: pdfWidgets.FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                'Act. Value',
                                style: pdfWidgets.TextStyle(
                                  fontWeight: pdfWidgets.FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          pdfWidgets.Expanded(
                            flex: 1,
                            child: pdfWidgets.Container(
                              height: 20,
                              alignment: pdfWidgets.Alignment.center,
                              child: pdfWidgets.Text(
                                'Remark',
                                style: pdfWidgets.TextStyle(
                                  fontWeight: pdfWidgets.FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Loop through solenoid statuses
                      ...List.generate(noOfPfcmds, (index) {
                        return pdfWidgets.TableRow(
                          children: [
                            pdfWidgets.Expanded(
                              flex: 1,
                              child: pdfWidgets.Container(
                                height: 20,
                                alignment: pdfWidgets.Alignment.center,
                                child: pdfWidgets.Text(
                                  'Position Sensor ${index + 1}',
                                ),
                              ),
                            ),
                            pdfWidgets.Expanded(
                              flex: 1,
                              child: pdfWidgets.Container(
                                height: 20,
                                alignment: pdfWidgets.Alignment.center,
                                child: pdfWidgets.Text('3000 - 20000 mA'),
                              ),
                            ),
                            pdfWidgets.Expanded(
                              flex: 1,
                              child: pdfWidgets.Container(
                                height: 20,
                                alignment: pdfWidgets.Alignment.center,
                                child: pdfWidgets.Text(
                                  '${position_values?[index].toString()} mA',
                                ),
                              ),
                            ),
                            pdfWidgets.Expanded(
                              flex: 1,
                              child: pdfWidgets.Container(
                                height: 20,
                                alignment: pdfWidgets.Alignment.center,
                                child: pdfWidgets.Text(
                                  position_status?[index] ?? '',
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
                //Solenoid Table
                pdfWidgets.Padding(
                  padding: const pdfWidgets.EdgeInsets.all(8.0),
                  child: pdfWidgets.Text(
                    'Solenoid Testing',
                    style: pdfWidgets.TextStyle(
                      fontSize: 14,
                      fontWeight: pdfWidgets.FontWeight.bold,
                    ),
                  ),
                ),
                pdfWidgets.Padding(
                  padding: const pdfWidgets.EdgeInsets.all(8),
                  child: pdfWidgets.Table(
                    border: pdfWidgets.TableBorder.all(
                      color: PdfColors.black,
                      width: 1,
                      style: pdfWidgets.BorderStyle.solid,
                    ),
                    children: [
                      // Header row
                      pdfWidgets.TableRow(
                        children: [
                          pdfWidgets.Container(
                            height: 20,
                            alignment: pdfWidgets.Alignment.center,
                            child: pdfWidgets.Text(
                              'Solenoid',
                              style: pdfWidgets.TextStyle(
                                fontWeight: pdfWidgets.FontWeight.bold,
                              ),
                            ),
                          ),
                          pdfWidgets.Container(
                            height: 20,
                            alignment: pdfWidgets.Alignment.center,
                            child: pdfWidgets.Text(
                              'Remark',
                              style: pdfWidgets.TextStyle(
                                fontWeight: pdfWidgets.FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Loop through solenoid statuses
                      ...List.generate(
                        noOfPfcmds,
                        (index) {
                          return pdfWidgets.TableRow(
                            children: [
                              pdfWidgets.Container(
                                height: 20,
                                alignment: pdfWidgets.Alignment.center,
                                child: pdfWidgets.Text('Solenoid ${index + 1}'),
                              ),
                              pdfWidgets.Container(
                                height: 20,
                                alignment: pdfWidgets.Alignment.center,
                                child: pdfWidgets.Text(
                                  solenoid_status?[index] ?? '',
                                ),
                              ),
                            ],
                          );
                        },
                      ).toList(), // Don't forget to convert the iterable into a list
                    ],
                  ),
                ),
                //MacID
                pdfWidgets.Container(
                  child: pdfWidgets.Column(
                    children: [
                      pdfWidgets.SizedBox(height: 10),
                      pdfWidgets.Row(
                        children: [
                          pdfWidgets.Text(
                            'Mac ID :',
                            style: pdfWidgets.TextStyle(
                              fontWeight: pdfWidgets.FontWeight.bold,
                            ),
                          ),
                          pdfWidgets.SizedBox(width: 20),
                          pdfWidgets.Text(
                            macId ?? '',
                            style: pdfWidgets.TextStyle(
                              fontWeight: pdfWidgets.FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                pdfWidgets.Divider(),
                //Done By
                pdfWidgets.Row(
                  children: [
                    pdfWidgets.Text(
                      'Done By:  ',
                      style: pdfWidgets.TextStyle(
                        fontWeight: pdfWidgets.FontWeight.bold,
                      ),
                    ),
                    pdfWidgets.Text(username ?? ""),
                  ],
                ),
                pdfWidgets.SizedBox(height: 10),
                pdfWidgets.Row(
                  children: [
                    pdfWidgets.Text(
                      'Date: ',
                      style: pdfWidgets.TextStyle(
                        fontWeight: pdfWidgets.FontWeight.bold,
                      ),
                    ),
                    pdfWidgets.Text(Cdate?.replaceAll("T", " ") ?? ""),
                  ],
                ),
                pdfWidgets.Row(
                  children: [
                    pdfWidgets.Text(
                      'Application Version:  ',
                      style: pdfWidgets.TextStyle(
                        fontWeight: pdfWidgets.FontWeight.bold,
                      ),
                    ),
                    pdfWidgets.Text("v2.8.3"),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    savePDF(pdf, context, 'Assembly-Test', macId ?? 'Unknown');

    _saveToCSV({
      "MacId": macId,
      "BatchNo": batchNo,
      "InletPT0bar": {"Value": filterInlet, "Status": inletPT_0bar},
      "OutletPT0bar": {"Value": filterOutlet, "Status": outletPT_0bar},
      "PT0bar": {
        "Values": outletPT_Values_0bar,
        "Status": outletPT_Status_0bar,
      },
      "InletPT2bar": {"Value": filterInlet1bar, "Status": inletPT_1bar},
      "OutletPT2bar": {"Value": filterOutlet1bar, "Status": outletPT_1bar},
      "PT2bar": {
        "Values": outletPT_Values_1bar,
        "Status": outletPT_Status_1bar,
      },
      "PositionSensor": {"Values": position_values, "Status": position_status},
      "Solenoid": solenoid_status,
      "DoorStatus": isDoorOk ? 1 : 0,
      "RTCStatus": isRTCOk ? 1 : 0,
      "FlashStatus": isFlashOk ? 1 : 0,
      "Done By": userId,
      "Done On": Cdate,
    });
  }

  void _saveToCSV(Map<String, dynamic> formData) async {
    try {
      // Prepare a single row of data
      final List<dynamic> row = [
        formData['MacId'] ?? '',
        formData['BatchNo'] ?? '',
        formData['InletPT0bar'] ?? '',
        formData['OutletPT0bar'] ?? '',
        formData['PT0bar'] ?? '',
        formData['InletPT2bar'] ?? '',
        formData['OutletPT2bar'] ?? '',
        formData['PT2bar'] ?? '',
        formData['PositionSensor'] ?? '',
        formData['Solenoid'] ?? '',
        formData['DoorStatus'] ?? '',
        formData['RTCStatus'] ?? '',
        formData['FlashStatus'] ?? '',
        formData['Done By'] ?? '',
        formData['Done On'] ?? '',
      ];

      // Get directory to save file
      String formattedDate = await FileUtils.getFormattedDate();
      Directory directory = await FileUtils.createDirectory(
        "Assembly-Test",
        formattedDate,
        'Assembly-Test',
      );
      final file = File('${directory.path}/Assembly-test-$formattedDate.csv');

      // Check if file exists
      if (await file.exists()) {
        // Append to existing file
        final String existingData = await file.readAsString();
        final List<List<dynamic>> csvData = const CsvToListConverter().convert(
          existingData,
        );
        csvData.add(row);
        final String csvDataString = const ListToCsvConverter().convert(
          csvData,
        );
        await file.writeAsString(csvDataString);
      } else {
        // Create a new file with headers and first row
        final List<List<dynamic>> rows = [
          [
            "MacId",
            "BatchNo",
            "Inlet PT 0bar",
            "Outlet PT 0bar",
            "PT 0bar",
            "Inlet PT 2bar",
            "Outlet PT 2bar",
            "PT 2bar",
            "Position Sensor",
            "Solenoid",
            "Door Status",
            "RTC Status",
            "Flash Status",
            "Done By",
            "Done On",
          ],
          row,
        ];
        final String csvDataString = const ListToCsvConverter().convert(rows);
        await file.writeAsString(csvDataString);
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Data saved to ${file.path}')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save data: $e')));
    }
  }

  Future<void> savePDF(
    pdfWidgets.Document pdf,
    BuildContext context,
    String projectName,
    String chakNo,
  ) async {
    try {
      String formattedDate = await FileUtils.getFormattedDate();
      Directory directory = await FileUtils.createDirectory(
        "Assembly-Test",
        formattedDate,
        'Assembly-Test',
      );

      String pdfName = 'Assembly $chakNo-$projectName.pdf';
      File file = File('${directory.path}/$pdfName');

      await file.writeAsBytes(await pdf.save());
      setState(() {
        filePath = file.path.replaceAll('/storage/emulated/0/', '');
        isSaved = true;
      });

      await FileUtils.showAlertDialog(
        context,
        'PDF Saved',
        'The PDF was saved successfully.',
      );
    } catch (e) {
      debugPrint('Error saving PDF: $e');
      await FileUtils.showAlertDialog(
        context,
        'Error',
        'An error occurred while saving the PDF.',
      );
    }
  }
}
