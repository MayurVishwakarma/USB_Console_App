// ignore_for_file: avoid_print

import "dart:convert";

import "package:flutter/foundation.dart" as fd;
import "package:flutter/material.dart";
import "package:usb_console_application/core/app_export.dart";
import "package:usb_console_application/core/constants/Url_constants.dart";
import "package:usb_console_application/core/exception.dart";
import "package:usb_console_application/models/OTPMasterModel.dart";
import "package:usb_console_application/models/State_list_Model.dart";
import "package:usb_console_application/models/loginmodel.dart";
import "package:http/http.dart" as http;
import "package:connectivity_plus/connectivity_plus.dart";
import "package:shared_preferences/shared_preferences.dart";
import 'package:dio/dio.dart';

class ApiService {
  final dio = Dio(
    BaseOptions(
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 15),
      contentType: Headers.jsonContentType,
    ),
  );

  var headers = {'Content-Type': 'application/json'};

  Future<LoginMasterModel> userLogin(String? loginId, String? password) async {
    try {
      final response = await dio.post(
        GetHttpRequest(loginPrefix, 'login'),
        data: {'mobileNo': loginId, 'password': password},
      );

      if (response.statusCode == 200 && response.data != null) {
        debugPrint("Login successful: ${response.data}");
        return LoginMasterModel.fromJson(response.data['data']['Response'][0]);
      } else {
        throw Exception("Failed with status: ${response.statusCode}");
      }
    } on DioException catch (dioError) {
      print("DioException: ${dioError.message}");
      throw Exception("Network error occurred");
    } catch (e) {
      print("Unexpected error: $e");
      throw Exception("An error occurred while logging in");
    }
  }

/*  Future<LoginMasterModel?> login(
      {required String mobileNumber, required String password}) async {
    try {
      final response = await http.get(Uri.parse(
          'http://ecmv2.iotwater.in:3011/api/v1/'
          'http://wmsservices.seprojects.in/api/login/Login?MobNo=$mobileNumber&Password=$password'));
      if (fd.kDebugMode) {
        print(response.body);
      }
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        if (json['Status'] == 'Ok') {
          LoginMasterModel loginResult =
              LoginMasterModel.fromJson(json['data']['Response']);
          if (loginResult.mobMessage?.toLowerCase() == "exists" &&
              loginResult.pwd == password) {
            return loginResult;
          } else {
            throw ServerException(message: "User Not Registered");
          }
        } else {
          throw ServerException(message: "Login Failed");
        }
      } else {
        throw ServerException(message: "Login Failed");
      }
    } on ServerException catch (ex) {
      throw ServerException(message: ex.message);
    }
  }
*/
  Future<OTPMasterModel?> getOTP({required String mobileNumber}) async {
    try {
      final response = await http.get(Uri.parse(
          'http://wmsservices.seprojects.in/api/login/MobileNumberVerify?MobNum=$mobileNumber'));
      if (fd.kDebugMode) {
        print(response.body);
      }
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        if (json['Status'] == 'Ok') {
          OTPMasterModel loginResult =
              OTPMasterModel.fromJson(json['data']['Response']);
          if (loginResult.mobMessage?.toLowerCase() == "exists") {
            return loginResult;
          } else {
            throw ServerException(message: "User Not Registered");
          }
        } else {
          throw ServerException(message: "Login Failed");
        }
      } else {
        throw ServerException(message: "Login Failed");
      }
    } on ServerException catch (ex) {
      throw ServerException(message: ex.message);
    }
  }

  Future<List<ProjectModel>> getStateAuthority(Keys key) async {
    try {
      // Check the network connection
      var connectivityResult = await (Connectivity().checkConnectivity());

      final sharePref = await SharedPreferences.getInstance();
      var user = sharePref.getString(key.name);

      if (user == null) throw Exception('No user data in SharedPreferences');

      final userJson = json.decode(user);
      var newUser = LoginMasterModel.fromJson(userJson);

      // If connected to the internet, fetch data from the API
      if (connectivityResult != ConnectivityResult.none) {
        final response = await http.get(Uri.parse(
          GetHttpRequest(loginPrefix, 'projects/${newUser.userid}/all'),
        ));

        if (response.statusCode == 200) {
          var json = jsonDecode(response.body);
          List<ProjectModel> fetchedData = <ProjectModel>[];
          json['data']['Response']
              .forEach((e) => fetchedData.add(ProjectModel.fromJson(e)));

          // Store the fetched data in SharedPreferences for offline use
          await sharePref.setString(
              'offlineProjectData', jsonEncode(fetchedData));

          return fetchedData;
        } else {
          throw Exception('Failed to load API');
        }
      } else {
        // If no internet connection, retrieve data from SharedPreferences
        var offlineData = sharePref.getString('offlineProjectData');
        if (offlineData != null) {
          List<dynamic> offlineJson = jsonDecode(offlineData);
          List<ProjectModel> offlineProjects =
              offlineJson.map((e) => ProjectModel.fromJson(e)).toList();

          return offlineProjects;
        } else {
          throw Exception('No offline data available');
        }
      }
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }
}
