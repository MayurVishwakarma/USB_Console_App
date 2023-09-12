// ignore_for_file: unused_catch_stack

import 'dart:convert';
import 'package:flutter_application_usb2/models/loginmodel.dart';
import 'package:http/http.dart' as http;

Future<LoginMasterModel?> fetchLoginDetails(
    String mobno, String passwd) async {
  try {
    final response = await http.get(Uri.parse(
        'http://wmsservices.seprojects.in/api/login/Login?MobNo=$mobno&Password=$passwd'));
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      if (json['Status'] == 'Ok') {
        LoginMasterModel loginResult =
            LoginMasterModel.fromJson(json['data']['Response']);
        return loginResult;
      } else
        throw Exception("Login Failed");
    } else {
      throw Exception("Login Failed");
    }
  } on Exception catch (_, ex) {
    return null;
  }
}
