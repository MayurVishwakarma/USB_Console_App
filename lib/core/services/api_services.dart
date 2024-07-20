import "dart:convert";

import "package:flutter/foundation.dart" as fd;
import "package:flutter_application_usb2/core/exception.dart";
import "package:flutter_application_usb2/models/loginmodel.dart";
import "package:http/http.dart" as http;

class ApiService {
  Future<LoginMasterModel?> login(
      {required String mobileNumber, required String password}) async {
    try {
      final response = await http.get(Uri.parse(
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
}
