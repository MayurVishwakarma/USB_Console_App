// ignore_for_file: non_constant_identifier_names

import 'package:usb_console_application/models/CheckListMode.dart';

class DeviceData {
  String? controllerType;
  double? batteryVoltage;
  double? batteryVoltageAftet;
  double? firmwareVersion;
  double? solarVoltage;
  String? deviceTime;
  String? isBatteryOk;
  bool isSolarOk;
  bool isDoorOpen;
  bool isDoorClose;
  bool isLoraOK;
  String macId;
  List<String> outletPT_Status_0bar;
  List<double> outletPT_Values_0bar;
  List<String> outletPT_Status_1bar;
  List<double> outletPT_Values_1bar;
  List<String>? outletPT_Status_3bar;
  List<double>? outletPT_Values_3bar;
  List<String>? positionStatus;
  List<double>? positionValues;
  List<String>? solenoidStatus;
  double? filterInlet;
  double? filterOutlet;
  String inletButton;
  String outletButton;
  double? filterInlet3bar;
  double? filterOutlet3bar;
  String inletPT_3bar;
  String outletPT_3bar;
  String inletPT_1bar;
  String outletPT_1bar;
  double? filterInlet1bar;
  double? filterOutlet1bar;
  String? doneBy;
  String? doneOn;

  DeviceData(
      {this.controllerType,
      this.batteryVoltage,
      this.batteryVoltageAftet,
      this.firmwareVersion,
      this.solarVoltage,
      this.deviceTime,
      this.isBatteryOk,
      this.isSolarOk = true,
      this.isDoorOpen = true,
      this.isDoorClose = true,
      this.isLoraOK = true,
      this.macId = '',
      List<String>? outletPT_Status_0bar,
      List<double>? outletPT_Values_0bar,
      List<String>? outletPT_Status_1bar,
      List<double>? outletPT_Values_1bar,
      List<String>? outletPT_Status_3bar,
      List<double>? outletPT_Values_3bar,
      List<String>? positionStatus,
      List<double>? positionValues,
      List<String>? solenoidStatus,
      this.filterInlet,
      this.filterOutlet,
      this.inletButton = '',
      this.outletButton = '',
      this.filterInlet3bar,
      this.filterOutlet3bar,
      this.inletPT_3bar = '',
      this.outletPT_3bar = '',
      this.inletPT_1bar = '',
      this.outletPT_1bar = '',
      this.filterInlet1bar,
      this.filterOutlet1bar,
      List<CheckListItem>? items,
      this.doneOn = '',
      this.doneBy = ''})
      : outletPT_Status_0bar = outletPT_Status_0bar ?? List.filled(6, ''),
        outletPT_Values_0bar = outletPT_Values_0bar ?? List.filled(6, 0.0),
        outletPT_Status_1bar = outletPT_Status_1bar ?? List.filled(6, ''),
        outletPT_Values_1bar = outletPT_Values_1bar ?? List.filled(6, 0.0),
        outletPT_Status_3bar = outletPT_Status_3bar ?? List.filled(6, ''),
        outletPT_Values_3bar = outletPT_Values_3bar ?? List.filled(6, 0.0),
        positionStatus = positionStatus ?? List.filled(6, ''),
        positionValues = positionValues ?? List.filled(6, 0.0),
        solenoidStatus = solenoidStatus ?? List.filled(6, '');

  Map<String, dynamic> toJson() {
    return {
      'controllerType': controllerType,
      'batteryVoltage': batteryVoltage,
      'batteryVoltageAftet': batteryVoltageAftet,
      'firmwareVersion': firmwareVersion,
      'solarVoltage': solarVoltage,
      'deviceTime': deviceTime,
      'isBatteryOk': isBatteryOk,
      'isSolarOk': isSolarOk,
      'isDoorOpen': isDoorOpen,
      'isDoorClose': isDoorClose,
      'isLoraOK': isLoraOK,
      'macId': macId,
      'outletPT_Status_0bar': outletPT_Status_0bar,
      'outletPT_Values_0bar': outletPT_Values_0bar,
      'outletPT_Status_1bar': outletPT_Status_1bar,
      'outletPT_Values_1bar': outletPT_Values_1bar,
      'outletPT_Status_3bar': outletPT_Status_3bar,
      'outletPT_Values_3bar': outletPT_Values_3bar,
      'positionStatus': positionStatus,
      'positionValues': positionValues,
      'solenoidStatus': solenoidStatus,
      'filterInlet': filterInlet,
      'filterOutlet': filterOutlet,
      'inletButton': inletButton,
      'outletButton': outletButton,
      'filterInlet3bar': filterInlet3bar,
      'filterOutlet3bar': filterOutlet3bar,
      'inletPT_3bar': inletPT_3bar,
      'outletPT_3bar': outletPT_3bar,
      'inletPT_1bar': inletPT_1bar,
      'outletPT_1bar': outletPT_1bar,
      'filterInlet1bar': filterInlet1bar,
      'filterOutlet1bar': filterOutlet1bar,
      'doneBy': doneBy,
      'doneOn': doneOn,
    };
  }
}
