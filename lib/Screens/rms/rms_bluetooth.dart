import 'package:flutter/material.dart';
import 'package:flutter_application_usb2/Provider/data_provider.dart';
import 'package:flutter_application_usb2/Widget/simple_button.dart';
import 'package:flutter_application_usb2/core/utils/appColors..dart';
import 'package:provider/provider.dart';

import '../../Widget/custom_button.dart';

class RMSAutoDryCommissionScreenBluetooth extends StatefulWidget {
  static const routeName = "/rmsautoDryCommission";
  const RMSAutoDryCommissionScreenBluetooth({super.key});

  @override
  State<RMSAutoDryCommissionScreenBluetooth> createState() =>
      _RMSAutoDryCommissionScreenBluetoothState();
}

class _RMSAutoDryCommissionScreenBluetoothState
    extends State<RMSAutoDryCommissionScreenBluetooth> {
  @override
  void initState() {
    final dt = Provider.of<DataProvider>(context, listen: false);
    dt.getCurrentUser();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      dt.updateFlowControlMode(false);
      dt.updateSavePath("");
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, dt, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              "RMS Auto Dry Commission",
              style: TextStyle(fontSize: 16),
            ),
          ),
          floatingActionButton: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  foregroundColor: AppColors.white,
                  backgroundColor: AppColors.green),
              onPressed: () {
                dt.clearMessages();
              },
              child: const Text("Clear")),
          body: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (dt.connectedDevices.isNotEmpty)
                            Container(
                                padding: const EdgeInsets.all(8),
                                alignment: Alignment.centerLeft,
                                width: MediaQuery.of(context).size.width,
                                height: 50,
                                decoration: BoxDecoration(
                                    color: AppColors.primaryColor),
                                child: const Text(
                                  "Connected Devices",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                )),
                          if (dt.connectedDevices.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                  children: dt.connectedDevices
                                      .map((e) => Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Image.asset(
                                                    "assets/images/bluetooth.png",
                                                    height: 30,
                                                  ),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  Text(e.platformName),
                                                ],
                                              ),
                                              SimpleButton(
                                                onPressed: () {
                                                  if (dt.bluetoothConnection
                                                          ?.isConnected ==
                                                      true) {
                                                    dt.disconnectBTConnection(
                                                        context);
                                                  } else {
                                                    dt.connectBTDevice(
                                                        context, e);
                                                  }
                                                },
                                                title: (dt.bluetoothConnection
                                                            ?.isConnected ==
                                                        true)
                                                    ? "Connected"
                                                    : "Disconnected",
                                                color: (dt.bluetoothConnection
                                                            ?.isConnected ==
                                                        true)
                                                    ? AppColors.green
                                                    : AppColors.red,
                                              ),
                                            ],
                                          ))
                                      .toList()),
                            ),
                          if (dt.connectedDevices.isNotEmpty) const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SimpleButton(
                                  onPressed: () {
                                    dt.clearResponse();
                                    dt.sendMessage("SINM");
                                    // void _addMessage(String message) {
                                    //   _listKey.currentState?.insertItem(0,
                                    //       duration: const Duration(milliseconds: 300));
                                    // }
                                  },
                                  title: "SINM",
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(dt.controllerType ?? "No Device"),
                              )
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              "Click On Get SINM to Find Device Type",
                              style: TextStyle(),
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width,
                            // height: ,
                            decoration:
                                BoxDecoration(color: AppColors.primaryColor),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Lora Communication Check",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(2),
                                    child: ElevatedButton(
                                        onPressed: () {
                                          dt.setDatetime();
                                        },
                                        child: const Text("Check")),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Lora Communication"),
                                Text(dt.autoCommissionModel.loraCommunication ??
                                    "Not Check Yet"),
                              ],
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width,
                            // height: ,
                            decoration:
                                BoxDecoration(color: AppColors.primaryColor),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "General Check",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(2),
                                    child: ElevatedButton(
                                        onPressed: () {
                                          dt.sendINTGMessage();
                                        },
                                        child: const Text("Check")),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Table(
                              children: [
                                TableRow(children: [
                                  const Text("Firmware Version:"),
                                  Text(
                                      '${dt.autoCommissionModel.firmwareversion ?? "Not Check Yet"}')
                                ]),
                                TableRow(children: [
                                  const Text("MAC ID:"),
                                  Text(dt.autoCommissionModel.mid ??
                                      "Not Check Yet"),
                                ]),
                                TableRow(children: [
                                  const Text("Battery Voltage:"),
                                  Text(
                                      "${dt.autoCommissionModel.batteryVlt ?? 'Not check Yet'}")
                                ]),
                                TableRow(children: [
                                  const Text("Solar Voltage:"),
                                  Text(
                                      "${dt.autoCommissionModel.solarVlt ?? 'Not check Yet'}")
                                ]),
                                TableRow(children: [
                                  const Text("Door 1:"),
                                  Text(dt.autoCommissionModel.door1 ??
                                      'Not check Yet')
                                ]),
                                TableRow(children: [
                                  const Text("Door 2:"),
                                  Text(dt.autoCommissionModel.door2 ??
                                      'Not check Yet')
                                ])
                              ],
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width,
                            // height: ,
                            decoration:
                                BoxDecoration(color: AppColors.primaryColor),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "PT Valve Check",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(2),
                                    child: ElevatedButton(
                                        onPressed: () {
                                          dt.sendINTGMessage();
                                        },
                                        child: const Text("Check")),
                                  )
                                ],
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Connect external pressure kit, Set pressure set point and When pressure generated in pipe line press Check PT values",
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 5,
                                horizontal:
                                    (MediaQuery.of(context).size.width > 600)
                                        ? 30
                                        : 8),
                            child: Table(
                              columnWidths: const {
                                0: FlexColumnWidth(5),
                                2: FlexColumnWidth(5)
                              },
                              defaultVerticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              children: [
                                TableRow(children: [
                                  const Text(
                                    "Inlet PT",
                                  ),
                                  Text("${dt.data.filterInlet ?? ''} bar"),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Radio<String>(
                                        value: 'OK',
                                        groupValue: dt.data.InletButton,
                                        onChanged: (value) {},
                                      ),
                                      const Text('OK'),
                                      Radio<String>(
                                        value: 'Faulty',
                                        groupValue: dt.data.InletButton,
                                        onChanged: (value) {},
                                      ),
                                      const Text('Faulty'),
                                    ],
                                  ),
                                  // Checkbox(
                                  //     value: (dt.data.InletButton == "OK"),
                                  //     onChanged: (va) {}),
                                  // Text(dt.data.InletButton ?? "Not Check Yet")
                                ]),
                                TableRow(children: [
                                  const Text(
                                    "Outlet PT",
                                  ),
                                  Text("${dt.data.filterOutlet ?? ''} bar"),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Radio<String>(
                                        value: 'OK',
                                        groupValue: dt.data.OutletButton,
                                        onChanged: (value) {},
                                      ),
                                      const Text('OK'),
                                      Radio<String>(
                                        value: 'Faulty',
                                        groupValue: dt.data.OutletButton,
                                        onChanged: (value) {},
                                      ),
                                      const Text('Faulty'),
                                    ],
                                  ),
                                ]),
                                /*
                                TableRow(children: [
                                  const Text(
                                    "Outlet PT 1",
                                  ),
                                  Text(
                                      "${dt.data.outlet_1_actual_count_controller ?? ''} bar"),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Radio<String>(
                                        value: 'OK',
                                        groupValue: dt.data.PFCMD1,
                                        onChanged: (value) {},
                                      ),
                                      const Text('OK'),
                                      Radio<String>(
                                        value: 'Faulty',
                                        groupValue: dt.data.PFCMD1,
                                        onChanged: (value) {},
                                      ),
                                      const Text('Faulty'),
                                    ],
                                  ),
                                ]),
                                TableRow(children: [
                                  const Text(
                                    "Outlet PT 2",
                                  ),
                                  Text(
                                      "${dt.data.outlet_2_actual_count_controller ?? ''} bar"),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Radio<String>(
                                        value: 'OK',
                                        groupValue: dt.data.PFCMD2,
                                        onChanged: (value) {},
                                      ),
                                      const Text('OK'),
                                      Radio<String>(
                                        value: 'Faulty',
                                        groupValue: dt.data.PFCMD2,
                                        onChanged: (value) {},
                                      ),
                                      const Text('Faulty'),
                                    ],
                                  ),
                                ]),
                                TableRow(children: [
                                  const Text(
                                    "Outlet PT 3",
                                  ),
                                  Text(
                                      "${dt.data.outlet_3_actual_count_controller ?? ''} bar"),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Radio<String>(
                                        value: 'OK',
                                        groupValue: dt.data.PFCMD3,
                                        onChanged: (value) {},
                                      ),
                                      const Text('OK'),
                                      Radio<String>(
                                        value: 'Faulty',
                                        groupValue: dt.data.PFCMD3,
                                        onChanged: (value) {},
                                      ),
                                      const Text('Faulty'),
                                    ],
                                  ),
                                ]),
                                TableRow(children: [
                                  const Text(
                                    "Outlet PT 4",
                                  ),
                                  Text(
                                      "${dt.data.outlet_4_actual_count_controller ?? ''} bar"),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Radio<String>(
                                        value: 'OK',
                                        groupValue: dt.data.PFCMD4,
                                        onChanged: (value) {},
                                      ),
                                      const Text('OK'),
                                      Radio<String>(
                                        value: 'Faulty',
                                        groupValue: dt.data.PFCMD4,
                                        onChanged: (value) {},
                                      ),
                                      const Text('Faulty'),
                                    ],
                                  ),
                                ]),
                                TableRow(children: [
                                  const Text(
                                    "Outlet PT 5",
                                  ),
                                  Text(
                                      "${dt.data.outlet_5_actual_count_controller ?? ''} bar"),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Radio<String>(
                                        value: 'OK',
                                        groupValue: dt.data.PFCMD5,
                                        onChanged: (value) {},
                                      ),
                                      const Text('OK'),
                                      Radio<String>(
                                        value: 'Faulty',
                                        groupValue: dt.data.PFCMD5,
                                        onChanged: (value) {},
                                      ),
                                      const Text('Faulty'),
                                    ],
                                  ),
                                ]),
                                TableRow(children: [
                                  const Text(
                                    "Outlet PT 6",
                                  ),
                                  Text(
                                      "${dt.data.outlet_6_actual_count_controller ?? ''} bar"),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Radio<String>(
                                        value: 'OK',
                                        groupValue: dt.data.PFCMD6,
                                        onChanged: (value) {},
                                      ),
                                      const Text('OK'),
                                      Radio<String>(
                                        value: 'Faulty',
                                        groupValue: dt.data.PFCMD6,
                                        onChanged: (value) {},
                                      ),
                                      const Text('Faulty'),
                                    ],
                                  ),
                                ]),
                              */
                              ],
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width,
                            decoration:
                                BoxDecoration(color: AppColors.primaryColor),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Position Sensor Check",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(2),
                                    child: ElevatedButton(
                                        onPressed: () {
                                          dt.sendINTGMessage();
                                        },
                                        child: const Text("Check")),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    (MediaQuery.of(context).size.width > 600)
                                        ? 30
                                        : 8),
                            child: Table(
                                columnWidths: const {
                                  0: FlexColumnWidth(5),
                                  2: FlexColumnWidth(5)
                                },
                                defaultVerticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                children: [
                                  TableRow(children: [
                                    const Text(
                                      "Position Sensor 1",
                                    ),
                                    Text("${dt.data.posval1 ?? ''} %"),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Radio<String>(
                                          value: 'OK',
                                          groupValue: dt.data.pos1,
                                          onChanged: (value) {},
                                        ),
                                        const Text('OK'),
                                        Radio<String>(
                                          value: 'Faulty',
                                          groupValue: dt.data.pos1,
                                          onChanged: (value) {},
                                        ),
                                        const Text('Faulty'),
                                      ],
                                    ),
                                  ]), /*
                                  TableRow(children: [
                                    const Text("Position Sensor 2"),
                                    Text("${dt.data.posval2 ?? ''} %"),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Radio<String>(
                                          value: 'OK',
                                          groupValue: dt.data.pos2,
                                          onChanged: (value) {},
                                        ),
                                        const Text('OK'),
                                        Radio<String>(
                                          value: 'Faulty',
                                          groupValue: dt.data.pos2,
                                          onChanged: (value) {},
                                        ),
                                        const Text('Faulty'),
                                      ],
                                    ),
                                  ]),
                                  TableRow(children: [
                                    const Text("Position Sensor 3"),
                                    Text("${dt.data.posval3 ?? ''} %"),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Radio<String>(
                                          value: 'OK',
                                          groupValue: dt.data.pos3,
                                          onChanged: (value) {},
                                        ),
                                        const Text('OK'),
                                        Radio<String>(
                                          value: 'Faulty',
                                          groupValue: dt.data.pos3,
                                          onChanged: (value) {},
                                        ),
                                        const Text('Faulty'),
                                      ],
                                    ),
                                  ]),
                                  TableRow(children: [
                                    const Text(
                                      "Position Sensor 4",
                                    ),
                                    Text("${dt.data.posval4 ?? ''} %"),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Radio<String>(
                                          value: 'OK',
                                          groupValue: dt.data.pos4,
                                          onChanged: (value) {},
                                        ),
                                        const Text('OK'),
                                        Radio<String>(
                                          value: 'Faulty',
                                          groupValue: dt.data.pos4,
                                          onChanged: (value) {},
                                        ),
                                        const Text('Faulty'),
                                      ],
                                    ),
                                  ]),
                                  TableRow(children: [
                                    const Text(
                                      "Position Sensor 5",
                                    ),
                                    Text("${dt.data.posval5 ?? ''} %"),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Radio<String>(
                                          value: 'OK',
                                          groupValue: dt.data.pos5,
                                          onChanged: (value) {},
                                        ),
                                        const Text('OK'),
                                        Radio<String>(
                                          value: 'Faulty',
                                          groupValue: dt.data.pos5,
                                          onChanged: (value) {},
                                        ),
                                        const Text('Faulty'),
                                      ],
                                    ),
                                  ]),
                                  TableRow(children: [
                                    const Text(
                                      "Position Sensor 6",
                                    ),
                                    Text("${dt.data.posval6 ?? ''} %"),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Radio<String>(
                                          value: 'OK',
                                          groupValue: dt.data.pos6,
                                          onChanged: (value) {},
                                        ),
                                        const Text('OK'),
                                        Radio<String>(
                                          value: 'Faulty',
                                          groupValue: dt.data.pos6,
                                          onChanged: (value) {},
                                        ),
                                        const Text('Faulty'),
                                      ],
                                    ),
                                  ]),
                               */
                                ]),
                          ),
                          Container(
                            height: 50,
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width,
                            decoration:
                                BoxDecoration(color: AppColors.primaryColor),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                children: [
                                  Text(
                                    "Solenoid Check",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                                "Observe opening & closing of solenoid valve and click on Ok / Faluty"),
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                                children: [1].map(
                              (index) {
                                return Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal:
                                                    (MediaQuery.of(context)
                                                                .size
                                                                .width >
                                                            600)
                                                        ? 30
                                                        : 8),
                                            child: Text(
                                              'SOV $index',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                // height: 30,
                                                width: 120,
                                                child: MyTextButton(
                                                  onPressed: () async {
                                                    dt.setRMSSovOpneclose(
                                                        index);
                                                  },
                                                  title: '1.Mode',
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              SizedBox(
                                                // height: 30,
                                                width: 120,
                                                child: MyTextButton(
                                                  onPressed: () {
                                                    dt.setRMSSovSMode(index);
                                                  },
                                                  title: '2. S-Mode',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              SizedBox(
                                                width: 100,
                                                child: MyTextButton(
                                                  onPressed: () {
                                                    dt.setRMSValveOpenPFCMD6(
                                                        index);
                                                  },
                                                  title: '3.Open',
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              SizedBox(
                                                width: 100,
                                                child: MyTextButton(
                                                  onPressed: () {
                                                    dt.setRMSValveClosePFCMD6(
                                                        index);
                                                  },
                                                  title: '4.Close',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Row(
                                                children: [
                                                  Radio<String>(
                                                    value: 'OK',
                                                    groupValue:
                                                        dt.getSovValText(index),
                                                    onChanged: (value) {
                                                      dt.toggleSovValText(
                                                          index, value ?? "");
                                                    },
                                                  ),
                                                  const Text('OK'),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Radio<String>(
                                                    value: 'Faulty',
                                                    groupValue:
                                                        dt.getSovValText(index),
                                                    onChanged: (value) {
                                                      dt.toggleSovValText(
                                                          index, value ?? "");
                                                    },
                                                  ),
                                                  const Text('Faulty'),
                                                ],
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                    const Divider(),
                                  ],
                                );
                              },
                            ).toList()),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                                "Make sure all the test came out successfully and then click the button below."),
                          ),
                          Container(
                            alignment: Alignment.center,
                            // width: MediaQuery.of(context).size.width / 2,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 35, vertical: 15),
                            child: CustomButton(
                              onPressed: () {
                                dt.showSaveDialog(context);
                              },
                              title: "Submit",
                            ),
                          ),
                          if (dt.pdfSavedPath.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                  "Your PDF was saved successfully ${dt.pdfSavedPath} now please set all the solenoid to Flow Control mode."),
                            ),
                          if (dt.showSovFlowControlMode)
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                  'Your PDF was saved successfully now please set all the solenoid to Flow Control mode.'),
                            ),
                          if (dt.showSovFlowControlMode)
                            SizedBox(
                              height: 50,
                              // padding: const EdgeInsets.all(8.0),
                              child: ListView(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                children: [1, 2, 3, 4, 5, 6]
                                    .map((e) => Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: SimpleButton(
                                            title: "Sov $e",
                                            onPressed: () {
                                              dt.setSovFlowControl(e);
                                            },
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8)),
                    height: 150,
                    padding: const EdgeInsets.all(5),
                    margin: const EdgeInsets.all(8),

                    // width: MediaQuery.of(context).size.width - 30,
                    child: (dt.terminalMessage.isNotEmpty)
                        ? ListView.builder(
                            controller: dt.listScrollController,
                            itemCount: dt.terminalMessage.length,
                            itemBuilder: (context, index) {
                              return Text(
                                dt.terminalMessage[index],
                                style: const TextStyle(color: Colors.green),
                              );
                            },
                          )
                        : null,
                  ),
                ],
              ),
              if (dt.isLoading)
                Center(
                  child: Container(
                      height: 100,
                      width: 100,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.all(20),
                      child: const Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(
                            height: 5,
                          ),
                          FittedBox(
                            child: Text("Receiving..."),
                          ),
                        ],
                      )),
                ),
            ],
          ),
        );
      },
    );
  }
}
