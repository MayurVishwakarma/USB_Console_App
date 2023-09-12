// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, unused_import, file_names, depend_on_referenced_packages, unnecessary_import, sort_child_properties_last
library flutter_blue;

import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';

import 'dart:async';
import 'package:collection/collection.dart';
import 'package:convert/convert.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_usb2/core/app_export.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:file_picker/file_picker.dart';

class UpdateScreen extends StatefulWidget {
  const UpdateScreen({Key? key}) : super(key: key);

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  @override
  Widget build(BuildContext context) {
    var result;
    var file;
    return Scaffold(
      appBar: AppBar(
          title: Text('FIRMWARE UPDATE'),
          ),
      body: Container(
        color: Color.fromARGB(255, 174, 205, 236),
        child: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
              decoration: BoxDecoration(
                  color: Color.fromARGB(255, 223, 235, 247),
                  borderRadius: BorderRadius.circular(20)),
              height: MediaQuery.of(context).size.height * 0.80,
              width: MediaQuery.of(context).size.width * 0.85,
              child: Column(
                children: [
                  Container(
                    child: Center(
                        child: Text(
                      "Mac ID:-",
                      textScaleFactor: 1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: ColorConstant.whiteA700,
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    )),
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20))),
                    width: MediaQuery.of(context).size.width,
                    height: 45,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 100.0),
                    child: InkWell(
                      onTap: () async {
                        result = await FilePicker.platform
                            .pickFiles(allowMultiple: true);
                        file = result.files.first;
                      },
                      child: Container(
                        height: 100,
                        width: 100,
                        child: Icon(
                          Icons.add_outlined,
                          color: Colors.white,
                          size: 50,
                        ),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(500),
                            color: Colors.blue),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Add Your File',
                      softWrap: true,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (result != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        file.toString(),
                        softWrap: true,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: ElevatedButton(
                      child: Text('Firmware Upload',style: TextStyle(color: Colors.white),),
                      onPressed: () {},
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.blue)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50))),
                              height: 50,
                              width: 50,
                              child: Icon(Icons.upload_file),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Run BackUp'),
                            )
                          ],
                        ),
                        Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50))),
                              child: Icon(
                                Icons.arrow_right_rounded,
                                size: 50,
                              ),
                              height: 50,
                              width: 50,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Go To Application'),
                            )
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
