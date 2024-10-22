/*
import 'package:flutter/material.dart';
import 'package:usb_console_application/Screens/Login/MyDrawerScreen.dart';
import 'package:usb_console_application/contrrollers/bluetooth_controller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';

class ProjectsCategoryScreen extends StatefulWidget {
  const ProjectsCategoryScreen({super.key});

  @override
  State<ProjectsCategoryScreen> createState() => _ProjectsCategoryScreenState();
}

class _ProjectsCategoryScreenState extends State<ProjectsCategoryScreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
     theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ).copyWith(
          textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)),
      home: DefaultTabController(
          length: 2,
          child: Scaffold(
              appBar: AppBar(
                bottom: const TabBar(tabs: [
                  Tab(
                    icon: Icon(Icons.bluetooth_searching),
                    text: 'Bluetooth Scan',
                  ),
                  Tab(
                    icon: Icon(Icons.bluetooth_connected),
                    text: 'Bluetooth Connected',
                  )
                ]),
                centerTitle: true,
                title: const Text(
                  'BLUETOOTH PAIRING',
                ),
                backgroundColor: Color.fromARGB(255, 33, 150, 243),
              ),
              drawer: MyDrawerScreen(),
              body: TabBarView(
                children: [ScanScreen(), ConnectedDevices()],
              ))),
    );
  }
}*/
// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, unused_import, file_names, depend_on_referenced_packages, unnecessary_import, sort_child_properties_last, prefer_const_literals_to_create_immutables



// current use
// import 'package:flutter/material.dart';
// import 'package:usb_console_application/Screens/Bluetooth/ConnectedDevices.dart';
// import 'package:usb_console_application/Screens/Bluetooth/ScanDevice.dart';
// import 'package:usb_console_application/Screens/HardwareConfiguation/GeneralSetting.dart';
// import 'package:usb_console_application/Screens/HardwareConfiguation/IOStatus.dart';
// import 'package:usb_console_application/Screens/Login/MyDrawerScreen.dart';

// class ProjectsCategoryScreen extends StatefulWidget {
//   const ProjectsCategoryScreen({Key? key}) : super(key: key);

//   @override
//   _ProjectsCategoryScreenState createState() => _ProjectsCategoryScreenState();
// }

// class _ProjectsCategoryScreenState extends State<ProjectsCategoryScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   final List<Tab> myTabs = [
//     Tab(text: 'Bluetooth Scan'),
//     Tab(text: 'Connected Devices'),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: myTabs.length, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       drawer: MyDrawerScreen(),
//       appBar: AppBar(
//         title: Text(
//           'BLUETOOTH PAIRING',
//         ),
//         bottom: TabBar(
//           controller: _tabController,
//           tabs: myTabs,
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [ScanScreen() /*, ConnectedDevices()*/],
//       ),
//     );
//   }
// }
