// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, unused_import, file_names, depend_on_referenced_packages, unnecessary_import, sort_child_properties_last, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:usb_console_application/Screens/FactorySetting/GeneralSetting.dart';
import 'package:usb_console_application/Screens/FactorySetting/IOConfiguration.dart';
import 'package:usb_console_application/Screens/FactorySetting/operationMode.dart';
import 'package:usb_console_application/Screens/HardwareConfiguation/GeneralSetting.dart';
import 'package:usb_console_application/Screens/HardwareConfiguation/IOStatus.dart';

class FactorySetting extends StatefulWidget {
  const FactorySetting({Key? key}) : super(key: key);

  @override
  _FactorySettingState createState() => _FactorySettingState();
}

class _FactorySettingState extends State<FactorySetting>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Tab> myTabs = [
    Tab(
      text: 'General \nSettings',
    ),
    Tab(text: 'IO \nConfiguration'),
    Tab(text: 'Operation \nMode'),
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
          'Factory Setting',
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: myTabs,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          GeneralFactorySetting(),
          IOConfigurationPage(),
          operation_mode()
        ],
      ),
    );
  }
}
