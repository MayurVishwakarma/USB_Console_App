import 'package:flutter/material.dart';
import 'package:flutter_application_usb2/Screens/AutoCommisitoning/auto_commission_screen_bluetooth.dart';
import 'package:flutter_application_usb2/Screens/Bluetooth/bluetooth_screen.dart';
import 'package:flutter_application_usb2/Screens/Login/Dashboard.dart';
import 'package:flutter_application_usb2/Screens/Login/LoginScreen.dart';
import 'package:flutter_application_usb2/Screens/Login/splash_screen.dart';
import 'package:flutter_application_usb2/Screens/ProcessMonitoring/process_moniter_screen_bt.dart';
import 'package:flutter_application_usb2/Screens/rms/rms_bluetooth.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => SplashScreen(),
        );
      case LoginPageScreen.routeName:
        return MaterialPageRoute(
          builder: (_) => LoginPageScreen(),
        );
      case AutoDryCommissionScreenBluetooth.routeName:
        return MaterialPageRoute(
          builder: (_) => const AutoDryCommissionScreenBluetooth(),
        );
      case ProcessMoniterScreenBT.routeName:
        return MaterialPageRoute(
          builder: (_) => const ProcessMoniterScreenBT(),
        );
      case DashboardScreen.routeName:
        return MaterialPageRoute(
          builder: (_) => DashboardScreen(),
        );
      case BluetoothScreen.routeName:
        return MaterialPageRoute(
          builder: (_) => const BluetoothScreen(),
        );
      case RMSAutoDryCommissionScreenBluetooth.routeName:
        return MaterialPageRoute(
            builder: (context) => const RMSAutoDryCommissionScreenBluetooth());
      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Center(
                      child: Text('No route defined for ${settings.name}')),
                ));
    }
  }
}
