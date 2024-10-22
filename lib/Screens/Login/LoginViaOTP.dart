// ignore_for_file: use_build_context_synchronously

import 'dart:ui';

import 'package:flutter/material.dart';
// import 'package:usb_console_application/Provider/data_provider.dart';
import 'package:usb_console_application/Screens/Login/LoginScreen.dart';
import 'package:usb_console_application/Widget/custom_button.dart';
import 'package:usb_console_application/core/exception.dart';
import 'package:usb_console_application/core/services/api_services.dart';
import 'package:usb_console_application/core/utils/utils.dart';
import 'package:usb_console_application/models/OTPMasterModel.dart';
// import 'package:provider/provider.dart';

class LoginviaOTP extends StatefulWidget {
  static const routeName = "/loginviaOTP";
  const LoginviaOTP({super.key});

  @override
  State<LoginviaOTP> createState() => _LoginviaOTPState();
}

class _LoginviaOTPState extends State<LoginviaOTP> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child: SizedBox(
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
                    const Image(
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
                    const LoginFormWidget(),
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
  final _passwordFocusNode = FocusNode();
  var sizedbox = const SizedBox(
    height: 15,
  );
  bool valuefirst = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            sizedbox,
            _buildPhoneField(context),
            // const SizedBox(height: 16),
            // _buildPasswordField(context),
            const SizedBox(height: 16),
            _buildOTPButton(context),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(
                    context, LoginPageScreen.routeName);
              },
              child: const Text('Back to Login'),
            ),
            sizedbox,
          ],
        ),
      ),
    );
  }

  // _passwordValidation(String value) {
  //   if (value.isEmpty) {
  //     return "Please enter password";
  //   } else {
  //     return null;
  //   }
  // }

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
              contentPadding: const EdgeInsets.all(8),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              prefixIcon: const Icon(Icons.person),
              labelStyle: const TextStyle(color: Colors.black),
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

  // Widget _buildPasswordField(BuildContext context) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
  //     child: TextFormField(
  //       controller: passwordController,
  //       keyboardType: TextInputType.text,
  //       textInputAction: TextInputAction.next,
  //       onFieldSubmitted: (_) {
  //         FocusScope.of(context).requestFocus(_emailFocusNode);
  //       },
  //       validator: (value) => _passwordValidation(value.toString()),
  //       obscureText: _isPasswordVisible,
  //       decoration: InputDecoration(
  //         border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
  //         prefixIcon: Icon(Icons.lock),
  //         labelText: "Password",
  //         // hintText: "",
  //         labelStyle: TextStyle(color: Colors.black),
  //         alignLabelWithHint: true,
  //         contentPadding: EdgeInsets.all(8),
  //         suffixIcon: IconButton(
  //             icon: Icon(
  //               _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
  //               color: Colors.black,
  //             ),
  //             onPressed: () {
  //               setState(() {
  //                 _isPasswordVisible = !_isPasswordVisible;
  //               });
  //             }),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildOTPButton(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        child: CustomButton(
            title: "GET OTP",
            bcolor: Colors.blue,
            onPressed: () async {
              try {
                if (_formKey.currentState!.validate()) {
                  OTPMasterModel? user = await ApiService()
                      .getOTP(mobileNumber: UsernameController.text);
                  if (user != null) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          child: Container(
                            height: 90,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Center(child: Text(user.code ?? '')),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Copy OTP'))
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                    // Provider.of<DataProvider>(context, listen: false)
                    //     .storeDataInSharedPreference(user.toJson());
                    // getpop(context, user);
                    // Navigator.pushReplacementNamed(
                    //     context, DashboardScreen.routeName);
                  }
                }
              } on ServerException catch (e) {
                Utils.showsnackBar(context, e.message);
              }
            }));
  }
}
