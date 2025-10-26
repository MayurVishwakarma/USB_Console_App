// ignore_for_file: deprecated_member_use

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usb_console_application/Screens/AssemblyTest/AssemblyScreen.dart';
import 'package:usb_console_application/Screens/AssemblyTest/AssemblyUpload.dart';
import 'package:usb_console_application/Screens/Login/LoginScreen.dart';
import 'package:usb_console_application/Screens/Login/ProjectListScreen.dart';
import 'package:usb_console_application/core/app_export.dart';
import 'package:usb_console_application/models/loginmodel.dart';

class MyDrawerScreen extends StatefulWidget {
  @override
  State<MyDrawerScreen> createState() => _MyDrawerScreenState();
}

class _MyDrawerScreenState extends State<MyDrawerScreen> {
  String? userType = 'Engineer';
  String? userName = '';

  @override
  void initState() {
    super.initState();
    getusername();
  }

  Future<void> getusername() async {
    final sharePref = await SharedPreferences.getInstance();
    var user = sharePref.getString(Keys.user.name);
    if (user != null) {
      final userJson = json.decode(user);
      var newUser = LoginMasterModel.fromJson(userJson);
      setState(() {
        // return newUser;
        userName = newUser.fName;
        userType = newUser.userType;
      });
    }
  }

  void _navigateTo(
    BuildContext context,
    Widget screen, {
    bool clearStack = false,
  }) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => screen),
      (route) => !clearStack,
    );
  }

  Widget _buildDrawerHeader() {
    return DrawerHeader(
      padding: const EdgeInsets.all(10.0),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Colors.blueGrey, Colors.blue],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('assets/images/SeLogo.png'),
          ),
          const SizedBox(height: 10),
          Text(
            userName ?? 'Guest',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(
    String title,
    String iconPath,
    Widget screen, {
    bool clearStack = true,
  }) {
    return ListTile(
      leading: ImageIcon(AssetImage(iconPath)),
      title: Text(title, textScaleFactor: 1),
      onTap: () => _navigateTo(context, screen, clearStack: clearStack),
    );
  }

  Widget _buildAppInfo() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
          child: Text(
            "Auto Dry Commissioning Application",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(10.0, 3.0, 0.0, 0.0),
          child: Text(
            'Saisanket Automation Pvt Ltd',
            style: TextStyle(fontSize: 14),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(10.0, 3.0, 0.0, 10.0),
          child: Text('App Version-v2.8.3', style: TextStyle(fontSize: 10)),
        ),
      ],
    );
  }

  Future<void> _logout() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
    _navigateTo(context, LoginPageScreen(), clearStack: true);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(),
          _buildAppInfo(),
          _buildListTile(
            'Project List',
            'assets/icons/home.png',
            ProjectListScreen(),
          ),
          if (userType!.toLowerCase().contains('manufacturer') ||
              userType!.toLowerCase().contains('manager'))
            _buildListTile(
              'Assembly Test',
              'assets/images/production.png',
              const AssemblyScreen(),
              clearStack: false,
            ),
          if (userType!.toLowerCase().contains('manufacturer') ||
              userType!.toLowerCase().contains('manager'))
            _buildListTile(
              'Assembly Upload',
              'assets/images/upload.png',
              const AssemblyUpload(),
              clearStack: false,
            ),
          ListTile(
            leading: const ImageIcon(AssetImage("assets/icons/log-out.png")),
            title: const Text('Logout', textScaleFactor: 1),
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}
