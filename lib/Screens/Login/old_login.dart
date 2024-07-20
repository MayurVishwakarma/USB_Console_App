// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace, use_keyColor_in_widget_constructors, prefer_final_fields, unused_field, prefer_const_literals_to_create_immutables, unused_element, file_names, use_build_context_synchronously, avoid_print, non_constant_identifier_names, unnecessary_new, unused_catch_stack, unused_local_variable, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:flutter_application_usb2/Provider/data_provider.dart';
import 'package:flutter_application_usb2/Screens/Login/Dashboard.dart';
import 'package:flutter_application_usb2/Widget/custom_button.dart';
import 'package:flutter_application_usb2/Widget/simple_button.dart';
import 'package:flutter_application_usb2/core/exception.dart';
import 'package:flutter_application_usb2/core/services/api_services.dart';
import 'package:flutter_application_usb2/core/utils/appColors..dart';
import 'package:flutter_application_usb2/core/utils/color_constant.dart';
import 'package:flutter_application_usb2/core/utils/math_utils.dart';
import 'package:flutter_application_usb2/core/utils/utils.dart';
import 'package:flutter_application_usb2/models/loginmodel.dart';
import 'package:provider/provider.dart';

class LoginPageScreen extends StatefulWidget {
  static const routeName = "/loginScreen";

  const LoginPageScreen({super.key});
  @override
  State<StatefulWidget> createState() {
    return _LoginPageScreenState();
  }
}

class _LoginPageScreenState extends State<LoginPageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height,
                  width: double.infinity,
                  // decoration:
                  //     BoxDecoration(color: Color.fromARGB(255, 174, 215, 247)),
                ),
                Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                        padding: EdgeInsets.only(top: 125),
                        child: Column(
                          children: [
                            Image(
                              image: AssetImage("assets/images/SeLogo.png"),
                              height: 150,
                              // width: 400,
                            ),
                            Text(
                              "Welcome Back!",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Sign in to your account",
                              style: TextStyle(fontSize: 16),
                            )
                          ],
                        ))),
                Positioned(
                  top: MediaQuery.of(context).size.height / 2 - 100,
                  left: 0.1,
                  right: 0.1,
                  child: LoginFormWidget(),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LoginFormWidget extends StatefulWidget {
  const LoginFormWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return _LoginFormWidgetState();
  }
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  final _formKey = GlobalKey<FormState>();
  var UsernameController = TextEditingController();
  var passwordController = TextEditingController();
  var _emailFocusNode = FocusNode();
  var _passwordFocusNode = FocusNode();
  bool _isPasswordVisible = true;
  bool _autoValidate = false;
  var sizedbox = SizedBox(
    height: 15,
  );
  bool valuefirst = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            sizedbox,
            _buildPhoneField(context),
            const SizedBox(height: 16),
            _buildPasswordField(context),
            const SizedBox(height: 16),
            // _buildForgotPassword(context),
            _buildLogInButton(context),

            sizedbox,
            // _buildCreateNewAccount(context)
          ],
        ),
      ),
    );
  }

  // _userNameValidation(String value) {
  //   if (value.isEmpty) {
  //     return "Please enter valid phone number";
  //   } else {
  //     return null;
  //   }
  // }

  _passwordValidation(String value) {
    if (value.isEmpty) {
      return "Please enter password";
    } else {
      return null;
    }
  }

  Widget _buildPhoneField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
      child: TextFormField(
          controller: UsernameController,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) {
            FocusScope.of(context).requestFocus(_passwordFocusNode);
          },
          validator: (value) => _phoneValidation(value.toString()),
          decoration: InputDecoration(
              // isDense: true,
              contentPadding: EdgeInsets.all(8),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              prefixIcon: Icon(Icons.person),
              labelStyle: TextStyle(color: Colors.black),
              // hintText: 'hello@rgmail.com',
              labelText: 'Mobile No.')),
    );
  }

  _phoneValidation(String value) {
    bool emailValid = RegExp(r'(^(?:[+0]9)?[0-9]{10,12}$)').hasMatch(value);
    if (!emailValid) {
      return "Enter valid Mobile";
    } else {
      return null;
    }
  }

  Widget _buildPasswordField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
      child: TextFormField(
        controller: passwordController,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.next,
        onFieldSubmitted: (_) {
          FocusScope.of(context).requestFocus(_emailFocusNode);
        },
        validator: (value) => _passwordValidation(value.toString()),
        obscureText: _isPasswordVisible,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          prefixIcon: Icon(Icons.lock),
          labelText: "Password",
          // hintText: "",
          labelStyle: TextStyle(color: Colors.black),
          alignLabelWithHint: true,
          contentPadding: EdgeInsets.all(8),
          suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                color: Colors.black,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              }),
        ),
      ),
    );
  }

  Widget _buildLogInButton(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        child: CustomButton(
            title: "Login",
            onPressed: () async {
              try {
                if (_formKey.currentState!.validate()) {
                  LoginMasterModel? user = await ApiService().login(
                      mobileNumber: UsernameController.text,
                      password: passwordController.text);
                  if (user != null) {
                    Provider.of<DataProvider>(context, listen: false)
                        .storeDataInSharedPreference(user.toJson());
                    Navigator.pushReplacementNamed(
                        context, DashboardScreen.routeName);
                  }
                }
              } on ServerException catch (e) {
                Utils.showsnackBar(context, e.message);
              }
            }));
  }

  getpop(context, LoginMasterModel? data) {
    return showDialog(
      barrierDismissible: false,
      useSafeArea: false,
      context: context,
      builder: (ctx) => Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Container(
            decoration: BoxDecoration(
                gradient: ColorConstant.appBarGradient,
                borderRadius: BorderRadius.circular(10)),
            width: 300, //size.width * 0.75,
            height: 350, //size.height * 0.45,
            child: Column(
              children: [
                ///image
                Column(
                  children: [
                    Image(
                      image: AssetImage("assets/images/SeLogo.png"),
                      height: size.height * 0.15,
                      width: size.width * 0.30,
                    ),
                    Text(
                      "BOC Mobile Application",
                      style: TextStyle(
                          color: ColorConstant.green900,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
                // Welcome Text
                Container(
                  height: MediaQuery.of(context).size.height * 0.15,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          "Welcome",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          data!.fName.toString(),
                          style: TextStyle(
                              color: ColorConstant.whiteA700,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          data.userType.toString(),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w400),
                        ),
                      ]),
                ),

                ///Button
                Container(
                  width: 80,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: Text("OK",
                          textScaleFactor: 1,
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                      onPressed: () async {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DashboardScreen()),
                          (Route<dynamic> route) => false,
                        );
                      }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
