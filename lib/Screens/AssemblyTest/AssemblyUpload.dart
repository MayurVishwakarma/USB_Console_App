// ignore_for_file: avoid_print, unused_local_variable, use_build_context_synchronously, use_super_parameters, unnecessary_string_interpolations

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usb_console_application/core/app_export.dart';
import 'package:usb_console_application/core/services/api_services.dart';
import 'package:usb_console_application/models/State_list_Model.dart';

class AssemblyUpload extends StatefulWidget {
  const AssemblyUpload({
    Key? key,
  }) : super(key: key);

  @override
  State<AssemblyUpload> createState() => _AssemblyUploadState();
}

class _AssemblyUploadState extends State<AssemblyUpload> {
  List<List<String>> fileData = [];
  String? fileType;
  int? selectedProject;
  List<ProjectModel>? projects;

  @override
  void initState() {
    super.initState();
    getprojects();
  }

  getprojects() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      projects = [];
    });

    // Try to fetch data from SharedPreferences (offline storage)
    String? offlineProjectData =
        sharedPreferences.getString('offlineProjectData');
    if (offlineProjectData != null) {
      List<dynamic> jsonData = jsonDecode(offlineProjectData);
      projects = jsonData.map((e) => ProjectModel.fromJson(e)).toList();
    }

    // Fetch data from API if online, else use offline data
    try {
      List<ProjectModel> apiData =
          await ApiService().getStateAuthority(Keys.user);
      if (apiData.isNotEmpty) {
        setState(() {
          projects = apiData
              .where(
                (element) => element.id != 40053,
              )
              .toList();
        });
        // Store fetched data in SharedPreferences
        sharedPreferences.setString('offlineProjectData', jsonEncode(apiData));
      }
    } catch (e) {
      // Handle API failure - using offline data only
      debugPrint('Failed to load data from API: $e');
    }
  }

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'xlsx', 'xls'],
    );

    if (result != null && result.files.isNotEmpty) {
      final filePath = result.files.single.path;

      if (filePath != null) {
        if (filePath.endsWith('.csv')) {
          await _parseCsv(filePath);
        } else if (filePath.endsWith('.xlsx') || filePath.endsWith('.xls')) {
          await _parseExcel(filePath);
        }
      }
    }
  }

  Future<void> _parseCsv(String filePath) async {
    final file = File(filePath);
    final content = await file.readAsString();
    final rows = const CsvToListConverter().convert(content);

    setState(() {
      fileType = "CSV";
      fileData = rows
          .map((row) => row.map((cell) => cell.toString()).toList())
          .toList();
    });
  }

  Future<void> _parseExcel(String filePath) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    final excel = Excel.decodeBytes(bytes);

    List<List<String>> tempData = [];
    for (var table in excel.tables.keys) {
      var rows = excel.tables[table]?.rows ?? [];
      for (var row in rows) {
        tempData.add(row.map((cell) => cell?.value?.toString() ?? "").toList());
      }
    }

    setState(() {
      fileType = "Excel";
      fileData = tempData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assembly Test'),
      ),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (projects != null && projects!.isNotEmpty)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
                child: DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: "Select Project",
                    border: OutlineInputBorder(),
                  ),
                  initialValue: selectedProject,
                  items: projects!
                      .map((project) => DropdownMenuItem<int>(
                            value: project.id,
                            child: Text(
                                project.projectName ?? 'Project ${project.id}'),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedProject = value;
                    });
                  },
                ),
              ),
            if (fileData.isEmpty)
              InkWell(
                onTap: pickFile,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.1,
                  width: MediaQuery.of(context).size.width * 0.9,
                  padding: const EdgeInsets.all(15),
                  margin: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(15)),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.upload_file_outlined),
                      Text('Please select a CSV or Excel file to upload'),
                    ],
                  ),
                ),
              ),
            // if (fileType != null)
            //   Text(
            //     'File Type: $fileType',
            //     style:
            //         const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            //   ),

            if (fileData.isNotEmpty) Divider(),
            if (fileData.isNotEmpty)
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal, // Horizontal scroll
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical, // Vertical scroll
                    child: DataTable(
                      columns: fileData.first
                          .map((header) => DataColumn(
                              label: Text(header,
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))))
                          .toList(),
                      rows: fileData.skip(1).map((row) {
                        return DataRow(
                            cells: row
                                .map((cell) => DataCell(Text(cell)))
                                .toList());
                      }).toList(),
                    ),
                  ),
                ),
              ),
            if (fileData.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    child: Center(
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              elevation: 2,
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5))),
                          onPressed: () {
                            connect(context, fileData);
                          },
                          child: const SizedBox(
                              height: 50,
                              child: Center(
                                child: Text(
                                  "Upload",
                                  // style: TextStyle(fontSize: 10),
                                  textAlign: TextAlign.center,
                                ),
                              ))),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    child: Center(
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              elevation: 2,
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5))),
                          onPressed: pickFile,
                          child: const SizedBox(
                              height: 50,
                              child: Center(
                                child: Text(
                                  "Replace",
                                  textAlign: TextAlign.center,
                                ),
                              ))),
                    ),
                  ),
                ],
              ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> connect(BuildContext context, List<List<String>> data) async {
    try {
      if (selectedProject == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please select project first"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (data.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("The uploaded file is empty!"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // 1️⃣ Validate that the first header is 'deviceId'
      final headers = data.first.map((h) => h.trim().toLowerCase()).toList();
      if (headers.isEmpty || headers.first != "deviceid") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                "Please edit the file and add 'deviceId' as the first column!"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // 2️⃣ Validate duplicate macId
      final macIdIndex = headers.indexOf("macid");
      if (macIdIndex == -1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("'macId' column not found! Please check your file."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final macIds = <String>{};
      for (var row in data.skip(1)) {
        if (row.length <= macIdIndex) continue;
        final mac = row[macIdIndex].trim();
        if (macIds.contains(mac)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("❌ Duplicate macId found: $mac"),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        macIds.add(mac);
      }

      // ✅ File validation passed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ File validated successfully! Uploading data..."),
          backgroundColor: Colors.green,
        ),
      );

      // Proceed with uploading data
      for (var row in data.skip(1)) {
        if (row.length < 15) {
          print("Skipping row, not enough columns: $row");
          continue;
        }

        String deviceId = "${row[0]}";
        String macId = row[1];
        int batchNo = int.tryParse(row[2]) ?? 0;
        String inletPT0bar = row[3];
        String outletPT0bar = row[4];
        String pt0bar = row[5];
        String inletPT2bar = row[6];
        String outletPT2bar = row[7];
        String pt2bar = row[8];
        String positionSensor = row[9];
        String solenoid = row[10];
        int doorStatus = int.tryParse(row[11]) ?? 0;
        int rtcStatus = int.tryParse(row[12]) ?? 0;
        int flashStatus = int.tryParse(row[13]) ?? 0;
        int doneBy = int.tryParse(row[14]) ?? 0;

        // ✅ Handle date parsing
        DateTime? doneOn;
        try {
          String formattedDate = row[14].replaceAll("T", " ");
          final dateFormat = DateFormat("dd-MM-yyyy HH:mm:ss");
          doneOn = dateFormat.parse(formattedDate);
        } catch (e) {
          print("Date parsing error for row ${row[14]}: $e");
          continue;
        }

        String mysqlDate = DateFormat("yyyy-MM-dd HH:mm:ss").format(doneOn);

        Map<String, dynamic> jsondata = {
          "deviceId": deviceId,
          "macId": macId,
          "batchNo": batchNo,
          "inletPT0bar": inletPT0bar,
          "outletPT0bar": outletPT0bar,
          "pt0bar": pt0bar,
          "inletPT2bar": inletPT2bar,
          "outletPT2bar": outletPT2bar,
          "pt2bar": pt2bar,
          "positionSensor": positionSensor,
          "solenoid": solenoid,
          "doorStatus": doorStatus,
          "rtcStatus": rtcStatus,
          "flashStatus": flashStatus,
          "doneBy": doneBy,
          "doneOn": mysqlDate,
        };

        await uploadData(jsondata, selectedProject);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Data uploaded successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('MySQL Query Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Something went wrong! Probably incorrect data."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> uploadData(
      Map<String, dynamic> jsonPaylod, int? projectId) async {
    var dio = Dio();
    var response = await dio.request(
      'http://ecmv2.iotwater.in:3011/api/v1/project/production/uploadProductionReport?projectId=$projectId',
      // 'http://wmsservices.seprojects.in/api/Project/InsertProductionDetails?conString=$conString',
      options: Options(
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
      ),
      data: jsonPaylod,
    );

    if (response.statusCode == 200) {
      print(json.encode(response.data));
      return response.data;
    } else {
      print(response.statusMessage);
    }
  }
}
