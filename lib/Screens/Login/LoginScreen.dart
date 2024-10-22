// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace, use_keyColor_in_widget_constructors, prefer_final_fields, unused_field, prefer_const_literals_to_create_immutables, unused_element, file_names, use_build_context_synchronously, avoid_print, non_constant_identifier_names, unnecessary_new, unused_catch_stack, unused_local_variable, sort_child_properties_last

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:usb_console_application/Provider/data_provider.dart';
import 'package:usb_console_application/Screens/Login/ProjectListScreen.dart';
import 'package:usb_console_application/Widget/custom_button.dart';
import 'package:usb_console_application/core/exception.dart';
import 'package:usb_console_application/core/services/api_services.dart';
import 'package:usb_console_application/core/utils/color_constant.dart';
import 'package:usb_console_application/core/utils/math_utils.dart';
import 'package:usb_console_application/core/utils/utils.dart';
import 'package:usb_console_application/models/loginmodel.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      // backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: [
                const BackgroundDecorations(),
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 100.0, sigmaY: 100.0),
                  child: Container(
                    decoration: const BoxDecoration(color: Colors.transparent),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image(
                      image: AssetImage("assets/images/SeLogo.png"),
                      height: 150,
                      // width: 400,
                    ),
                    Text(
                      'Saisanket Auto-Commissioning App',
                      style: TextStyle(
                          color: Colors.green.shade800,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    LoginFormWidget(),
                  ],
                ),
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
      margin: EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            sizedbox,
            _buildPhoneField(context),
            const SizedBox(height: 16),
            _buildPasswordField(context),
            const SizedBox(height: 16),
            _buildLogInButton(context),
            // TextButton(
            //   onPressed: () {
            //     Navigator.pushReplacementNamed(context, LoginviaOTP.routeName);
            //   },
            //   child: Text('Login via OTP'),
            // ),
            sizedbox,
          ],
        ),
      ),
    );
  }

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
            bcolor: Colors.green,
            onPressed: () async {
              try {
                if (_formKey.currentState!.validate()) {
                  LoginMasterModel? user = await ApiService().login(
                      mobileNumber: UsernameController.text,
                      password: passwordController.text);
                  if (user != null) {
                    SharedPreferences preferences =
                        await SharedPreferences.getInstance();
                    preferences.setString('mobileno', UsernameController.text);
                    Provider.of<DataProvider>(context, listen: false)
                        .storeDataInSharedPreference(user.toJson());
                    getpop(context, user);
                    // Navigator.pushReplacementNamed(
                    //     context, DashboardScreen.routeName);
                  }
                }
              } on ServerException catch (e) {
                Utils.showsnackBar(context, e.message);
              }
            }));
  }

  getpop(context, LoginMasterModel? data) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
              decoration: BoxDecoration(
                  gradient: ColorConstant.appBarGradient,
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      children: [
                        ///image
                        Image(
                          image: AssetImage("assets/images/SeLogo.png"),
                          height: size.height * 0.15,
                          width: size.width * 0.30,
                        ),
                        // Welcome Text
                        Column(
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

                        ///Button
                        Container(
                          width: 80,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  elevation: 2,
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15))),
                              child: Text("OK",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16)),
                              onPressed: () async {
                                Provider.of<DataProvider>(context,
                                        listen: false)
                                    .storeDataInSharedPreference(data.toJson());
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  ProjectListScreen.routeName,
                                  (Route<dynamic> route) => false,
                                );
                              }),
                        ),
                      ],
                    )
                  ],
                ),
              )),
        );
      },
    );
    /*return showDialog(
      // barrierDismissible: false,
      // useSafeArea: false,
      context: context,
      builder: (ctx) => Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Container(
            decoration: BoxDecoration(
                gradient: ColorConstant.appBarGradient,
                borderRadius: BorderRadius.circular(10)),
            width: size.width * 0.75,
            height: size.height * 0.45,
            child: Column(
              children: [
                ///image
                Image(
                  image: AssetImage("assets/images/SeLogo.png"),
                  height: size.height * 0.15,
                  width: size.width * 0.30,
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
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                      onPressed: () async {
                        Provider.of<DataProvider>(context, listen: false)
                            .storeDataInSharedPreference(data.toJson());
                        Navigator.pushReplacementNamed(
                            context, DashboardScreen.routeName);
                      }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  */
  }
}

class BackgroundDecorations extends StatelessWidget {
  const BackgroundDecorations({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: const AlignmentDirectional(-2, -0.9),
          child: Container(
            height: 300,
            width: 400,
            decoration:
                const BoxDecoration(color: Colors.cyan, shape: BoxShape.circle),
          ),
        ),
        Align(
          alignment: const AlignmentDirectional(2, 0.1),
          child: Container(
            height: 300,
            width: 300,
            decoration:
                const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
          ),
        ),
        Align(
          alignment: const AlignmentDirectional(-1, 0.9),
          child: Container(
            height: 300,
            width: 300,
            decoration: const BoxDecoration(
                color: Colors.greenAccent, shape: BoxShape.circle),
          ),
        ),
        // Align(
        //   alignment: const AlignmentDirectional(-1, 0.9),
        //   child: ClipPath(
        //     clipper: OctagonClipper(),
        //     child: Container(
        //       height: 300,
        //       width: 300,
        //       decoration: const BoxDecoration(color: Colors.green),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
