// ignore_for_file: must_call_super, non_constant_identifier_names, must_be_immutable, unused_local_variable, avoid_types_as_parameter_names, prefer_is_empty, prefer_const_constructors, use_key_in_widget_constructors

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:usb_console_application/Provider/UsbProvider.dart';
import 'package:usb_console_application/Provider/data_provider.dart';
import 'package:usb_console_application/core/router/router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermissionsOnStartup() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.storage,
    Permission.bluetooth,
    Permission.bluetoothConnect,
    Permission.bluetoothScan,
  ].request();

  if (statuses.values.any((status) => status.isDenied)) {
    await [
      Permission.storage,
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
    ].request();
  }

  if (statuses.values.any((status) => status.isPermanentlyDenied)) {
    openAppSettings();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await requestPermissionsOnStartup();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => DataProvider()),
        ChangeNotifierProvider(create: (context) => UsbProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        onGenerateRoute: AppRouter.onGenerateRoute,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ).copyWith(
          textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        ),
        title: 'usb_application',
      ),
    );
  }
}
