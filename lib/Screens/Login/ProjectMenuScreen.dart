// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:usb_console_application/Screens/Login/NodeDetailsList.dart';
import 'package:usb_console_application/Screens/Login/NodeDetailsList_RMS.dart';
import 'package:usb_console_application/models/State_list_Model.dart';

class ProjectMenuScreen extends StatefulWidget {
  ProjectModel? projectName;
  ProjectMenuScreen(ProjectModel project, {super.key}) {
    projectName = project;
  }

  @override
  State<ProjectMenuScreen> createState() => _ProjectMenuScreenState();
}

class _ProjectMenuScreenState extends State<ProjectMenuScreen> {
  List<String> deviceTypes = [];
  @override
  void initState() {
    updateDeviceTypes(widget.projectName!.eCString ?? '');
    super.initState();
  }

  void updateDeviceTypes(String eCString) {
    deviceTypes = [];
    if (eCString[0] == '1') deviceTypes.add('OMS');
    if (eCString[1] == '1') deviceTypes.add('AMS');
    if (eCString[2] == '1') deviceTypes.add('RMS');
    if (eCString[3] == '1') deviceTypes.add('Lora');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.projectName!.projectName!),
      ),
      body: ListView(
        children: [
          if (deviceTypes.contains('OMS'))
            InkWell(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Nodedetailslist(widget.projectName!),
                  ),
                  (Route<dynamic> route) => true,
                );
              },
              child: Container(
                margin: const EdgeInsets.all(15),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: const [
                    BoxShadow(
                        offset: Offset(1, 1.8),
                        blurRadius: 3.0,
                        spreadRadius: 0.8)
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "OMS",
                      style: TextStyle(color: Colors.blue),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.blue,
                    )
                  ],
                ),
              ),
            ),
          // if (deviceTypes.contains('AMS'))
          //   ListTile(
          //     title: Text('AMS'),
          //   ),
          if (deviceTypes.contains('RMS'))
            InkWell(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        NodedetailslistRMS(widget.projectName!),
                  ),
                  (Route<dynamic> route) => true,
                );
              },
              child: Container(
                margin: const EdgeInsets.all(15),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: const [
                    BoxShadow(
                        offset: Offset(1, 1.8),
                        blurRadius: 3.0,
                        spreadRadius: 0.8)
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "RMS",
                      style: TextStyle(color: Colors.blue),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.blue,
                    )
                  ],
                ),
              ),
            )
          // if (deviceTypes.contains('Lora'))
          //   ListTile(
          //     title: Text('Lora'),
          //   ),
        ],
      ),
    );
  }
}
