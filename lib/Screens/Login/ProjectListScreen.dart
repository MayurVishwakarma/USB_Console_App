// ignore_for_file: file_names, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usb_console_application/Screens/Login/AppDrawer.dart';
import 'package:usb_console_application/Screens/Login/ProjectMenuScreen.dart';
import 'package:usb_console_application/core/app_export.dart';
import 'package:usb_console_application/core/services/api_services.dart';
import 'package:usb_console_application/models/State_list_Model.dart';

class ProjectListScreen extends StatefulWidget {
  static const routeName = "/projectList";
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    getProjectList();
  }

  List<ProjectModel> projectList = [];
  late TextEditingController searchController;
  String query = '';

  getProjectList() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      projectList = [];
    });

    // Try to fetch data from SharedPreferences (offline storage)
    String? offlineProjectData =
        sharedPreferences.getString('offlineProjectData');
    if (offlineProjectData != null) {
      List<dynamic> jsonData = jsonDecode(offlineProjectData);
      projectList = jsonData.map((e) => ProjectModel.fromJson(e)).toList();
    }

    // Fetch data from API if online, else use offline data
    try {
      List<ProjectModel> apiData =
          await ApiService().getStateAuthority(Keys.user);
      if (apiData.isNotEmpty) {
        setState(() {
          projectList = apiData
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        drawer: MyDrawerScreen(),
        appBar: AppBar(
          title: Text('Project List'.toUpperCase()),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await getProjectList();
          },
          child: GestureDetector(
            onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: searchController,
                      onChanged: (value) {
                        setState(() {
                          query = value.toLowerCase();
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Search by Project or State',
                        isDense: true,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        suffixIcon: Icon(
                          Icons.search,
                          size: 30,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: projectList.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            itemCount: query.isEmpty
                                ? projectList.length
                                : projectList
                                    .where((element) {
                                      return element.projectName!
                                              .toLowerCase()
                                              .contains(query) ||
                                          element.state!
                                              .toLowerCase()
                                              .contains(query);
                                    })
                                    .toList()
                                    .length,
                            itemBuilder: (context, index) {
                              var data = query.isEmpty
                                  ? projectList
                                  : projectList.where((element) {
                                      return element.projectName!
                                              .toLowerCase()
                                              .contains(query) ||
                                          element.state!
                                              .toLowerCase()
                                              .contains(query);
                                    }).toList();
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 5),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                        255, 201, 222, 240),
                                    boxShadow: const [
                                      BoxShadow(
                                          offset: Offset(1, 1.5),
                                          blurRadius: 1.0,
                                          spreadRadius: 0.4)
                                    ],
                                    borderRadius: BorderRadius.circular(3.5),
                                  ),
                                  child: ListTile(
                                    onTap: () async {
                                      setVaribales(data[index]);

                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ProjectMenuScreen(data[index]),
                                        ),
                                        (Route<dynamic> route) => true,
                                      );
                                      /*
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              Nodedetailslist(data[index]),
                                        ),
                                        (Route<dynamic> route) => true,
                                      );
                                      */
                                    },
                                    leading: SizedBox(
                                      height: 80,
                                      child: Image.asset(getStateImage(
                                          (data[index].state ?? '')
                                              .toLowerCase())!),
                                    ),
                                    title: Text(
                                      data[index].projectName ?? '',
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (data[index].description != 'NA')
                                          Text(
                                            '${data[index].description}',
                                            style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12),
                                          ),
                                        Text(
                                          "${data[index].state} (CCA:${data[index].totalArea ?? '0'})",
                                          style: const TextStyle(
                                              color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void setVaribales(ProjectModel data) async {
    var hostip = data.hostIp;
    var projectName = data.project;
    var userName = data.userName;
    var pswd = data.password;
    String conString =
        'Data Source=$hostip;Initial Catalog=$projectName;User ID=$userName;Password=$pswd;';
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.setString('ConString', conString);
      preferences.setString('ProjectName', data.projectName!);
    });
  }

  String? getStateImage(String state) {
    String? imagePath;
    switch (state) {
      case 'madhya pradesh':
        imagePath = 'assets/images/MPlogo.png';
        break;
      case 'odisha':
        imagePath = 'assets/images/odishalogo.png';
        break;
      case 'maharashtra':
        imagePath = 'assets/images/maharastraLogo.png';
        break;
      default:
        imagePath = 'assets/images/Logo.png';
    }
    return imagePath;
  }
}
