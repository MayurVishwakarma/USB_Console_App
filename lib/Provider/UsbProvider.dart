import 'package:flutter/material.dart';
import 'package:usb_serial/usb_serial.dart';

class UsbProvider extends ChangeNotifier {
  UsbPort? _port;
  String _status = "Idle";
  List<UsbDevice> _devices = [];

  UsbPort? get port => _port;
  List<UsbDevice>? get devices => _devices;
}
