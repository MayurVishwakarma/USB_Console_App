import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';

class BluetoothController extends GetxController {
  // FlutterBluePlus flutterBlue = new FlutterBluePlus();
  BluetoothDevice? _connectedDevice;

  // Scan for available Bluetooth devices
  Future<void> scanDevices() async {
    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
    } catch (e) {
      print('Error scanning for devices: $e');
    }
  }

  // Disconnect from the currently connected device
  Future<void> disconnectDevice() async {
    if (_connectedDevice != null) {
      try {
        await _connectedDevice!.disconnect();
        print('Disconnected from ${_connectedDevice!.name}');
        _connectedDevice = null;
      } catch (e) {
        print('Error disconnecting from device: $e');
      }
    }
  }

  // Getter for the currently connected device
  BluetoothDevice? get connectedDevice => _connectedDevice;

  // Stream of available Bluetooth devices
  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;
}
