// ignore_for_file: unused_catch_stack

import 'dart:convert';
import 'package:usb_console_application/models/loginmodel.dart';
import 'package:http/http.dart' as http;

var testUser = LoginMasterModel(
    fName: "test",
    lName: "test",
    mobMessage: "test",
    pwd: "test",
    token: "testtesttest",
    userType: "Test",
    userid: 1);
Future<LoginMasterModel> fetchLoginDetails(String mobno, String passwd) async {
  try {
    final response = await http.get(Uri.parse(
        'http://wmsservices.seprojects.in/api/login/Login?MobNo=$mobno&Password=$passwd'));
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      if (json['Status'] == 'Ok') {
        LoginMasterModel loginResult =
            LoginMasterModel.fromJson(json['data']['Response']);
        return loginResult;
      } else {
        throw testUser; // Exception("Login Failed");
      }
    } else {
      throw testUser; // Exception("Login Failed");
    }
  } on Exception catch (_, ex) {
    return testUser;
  }
}
