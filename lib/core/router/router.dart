import 'package:flutter/material.dart';
import 'package:usb_console_application/Screens/AutoCommisitoning/auto_commission_screen_bluetooth.dart';
import 'package:usb_console_application/Screens/Bluetooth/bluetooth_screen.dart';
import 'package:usb_console_application/Screens/Login/LoginScreen.dart';
import 'package:usb_console_application/Screens/Login/LoginViaOTP.dart';
import 'package:usb_console_application/Screens/Login/ProjectListScreen.dart';
import 'package:usb_console_application/Screens/Login/splash_screen.dart';
// import 'package:usb_console_application/Screens/ProcessMonitoring/process_moniter_screen_bt.dart';
import 'package:usb_console_application/Screens/rms/rms_bluetooth.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );
      case LoginPageScreen.routeName:
        return MaterialPageRoute(
          builder: (_) => const LoginPageScreen(),
        );
      // case AutoDryCommissionScreenBluetooth.routeName:
      //   return MaterialPageRoute(
      //     builder: (_) => const AutoDryCommissionScreenBluetooth(),
      //   );
      // case ProcessMoniterScreenBT.routeName:
      //   return MaterialPageRoute(
      //     builder: (_) => const ProcessMoniterScreenBT(),
      //   );
      // case DashboardScreen.routeName:
      //   return MaterialPageRoute(
      //     builder: (_) => DashboardScreen(),
      //   );
      case ProjectListScreen.routeName:
        return MaterialPageRoute(
          builder: (_) => const ProjectListScreen(),
        );
      // case BluetoothScreen.routeName:
      //   return MaterialPageRoute(
      //     builder: (_) => const BluetoothScreen(),
      //   );
      // case NodeDetailsOffline.routeName:
      //   return MaterialPageRoute(
      //     builder: (_) =>  NodeDetailsOffline(),
      //   );
      // case RMSAutoDryCommissionScreenBluetooth.routeName:
      //   return MaterialPageRoute(
      //       builder: (context) => const RMSAutoDryCommissionScreenBluetooth());
      case LoginviaOTP.routeName:
        return MaterialPageRoute(builder: (context) => const LoginviaOTP());
      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Center(
                      child: Text('No route defined for ${settings.name}')),
                ));
    }
  }
}
