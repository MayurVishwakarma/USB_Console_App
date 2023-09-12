// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, unused_import, file_names, depend_on_referenced_packages, unnecessary_import, sort_child_properties_last, prefer_const_literals_to_create_immutables, library_private_types_in_public_api, camel_case_types

import 'package:flutter/material.dart';
import 'package:flutter_application_usb2/Screens/HardwareConfiguation/GeneralSetting.dart';
import 'package:flutter_application_usb2/Screens/HardwareConfiguation/IOStatus.dart';

class Hardware_configration extends StatefulWidget {
  const Hardware_configration({Key? key}) : super(key: key);

  @override
  _Hardware_configrationState createState() => _Hardware_configrationState();
}

class _Hardware_configrationState extends State<Hardware_configration>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Tab> myTabs = [
    Tab(text: 'General Settings'),
    Tab(text: 'IO STATUS'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: myTabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'HARDWARE CONFIGURATION',
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: myTabs,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [GeneralSetting(), IOStatusScreen()],
      ),
    );
  }
}
