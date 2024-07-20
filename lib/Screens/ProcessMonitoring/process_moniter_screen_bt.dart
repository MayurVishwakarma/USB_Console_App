import 'package:flutter/material.dart';
import 'package:flutter_application_usb2/Provider/data_provider.dart';
import 'package:flutter_application_usb2/Widget/nested_row.dart';
import 'package:flutter_application_usb2/Widget/simple_button.dart';
import 'package:flutter_application_usb2/Widget/table.dart';
import 'package:flutter_application_usb2/core/utils/appColors..dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ProcessMoniterScreenBT extends StatefulWidget {
  const ProcessMoniterScreenBT({super.key});

  static const routeName = "/processctMoniter";

  @override
  State<ProcessMoniterScreenBT> createState() => _ProcessMoniterScreenBTState();
}

class _ProcessMoniterScreenBTState extends State<ProcessMoniterScreenBT> {
  @override
  Widget build(BuildContext context) {
    final dt = Provider.of<DataProvider>(context);
    double width = 0;
    if (MediaQuery.of(context).size.width > 600) {
      width = (MediaQuery.of(context).size.width / 7).toDouble();
    } else {
      width = (MediaQuery.of(context).size.width / 8.2).toDouble();
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Process Monitering",
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (dt.connectedDevices.isNotEmpty)
                        Container(
                            padding: const EdgeInsets.all(8),
                            alignment: Alignment.centerLeft,
                            width: MediaQuery.of(context).size.width,
                            height: 50,
                            decoration:
                                BoxDecoration(color: AppColors.primaryColor),
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
                                                dt.connectBTDevice(context, e);
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
                      Column(
                        children: [
                          Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width,
                            // height: 30,
                            decoration:
                                BoxDecoration(color: AppColors.primaryColor),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Mac ID ${dt.autoCommissionModel.mid ?? ''}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                          color: AppColors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                ),
                                ElevatedButton(
                                    onPressed: () {
                                      dt.clearResponse();
                                      dt.sendMessage("SINM");
                                    },
                                    child: const Text('Check')),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(left: 8.0),
                            alignment: Alignment.centerLeft,
                            child: SimpleButton(
                              onPressed: () {
                                dt.sendINTGMessage();
                              },
                              title: "Get Data",
                            ),
                          ),
                          NestedRow(
                            title1: "Door",
                            title2: "FW Version",
                            value1:
                                dt.autoCommissionModel.door1 ?? "Not Check Yet",
                            value2:
                                '${dt.autoCommissionModel.firmwareversion ?? "Not Check Yet"}',
                            color1: Colors.green,
                            color2: Colors.red,
                          ),
                          NestedRow(
                            title1: "Solar Voltage",
                            title2: "Battery Voltage",
                            value1:
                                '${dt.autoCommissionModel.solarVlt ?? "Not Check Yet"}',
                            value2:
                                '${dt.autoCommissionModel.batteryVlt ?? "Not Check Yet"}',
                            color1: Colors.green,
                            color2: Colors.red,
                          ),
                          NestedRow(
                            title1: "Inlet Press",
                            title2: "Outlet Press",
                            value1: '${dt.data.filterInlet ?? "Not Check Yet"}',
                            value2:
                                '${dt.data.filterOutlet ?? "Not Check Yet"}',
                            color1: Colors.green,
                            color2: Colors.red,
                          ),
                          Stack(
                            children: [
                              SizedBox(
                                height: 300,
                                width: MediaQuery.of(context).size.width,
                              ),
                              Positioned(
                                top: 80,
                                right: 0,
                                height: 20,
                                width: MediaQuery.of(context).size.width * 1,
                                child: const ShadeContainer(),
                              ),
                              Positioned(
                                left: -50,
                                top: 30,
                                height: 200,
                                child: Image.asset("assets/images/val.png"),
                              ),
                              Positioned(
                                height: 10,
                                width: 10,
                                left: 45,
                                top: 80,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: width - width,
                                top: 47,
                                child: Transform.scale(
                                  scale: 0.6,
                                  child: PFCMDContainer(
                                    title: "PFCMD 6",
                                    flowMode: dt.data.pt6Smode,
                                    manualAutoTest: dt.data.pt6Omode,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: width,
                                top: 47,
                                child: Transform.scale(
                                  scale: 0.6,
                                  child: PFCMDContainer(
                                    title: "PFCMD 5",
                                    flowMode: dt.data.pt5Smode,
                                    manualAutoTest: dt.data.pt5Omode,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: width * 2,
                                top: 47,
                                child: Transform.scale(
                                  scale: 0.6,
                                  child: PFCMDContainer(
                                    title: "PFCMD 4",
                                    flowMode: dt.data.pt4Smode,
                                    manualAutoTest: dt.data.pt4Omode,
                                    isGreen: true,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: width * 3,
                                top: 47,
                                child: Transform.scale(
                                  scale: 0.6,
                                  child: PFCMDContainer(
                                    title: "PFCMD 3",
                                    flowMode: dt.data.pt3Smode,
                                    manualAutoTest: dt.data.pt3Omode,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: width * 4,
                                top: 47,
                                child: Transform.scale(
                                  scale: 0.6,
                                  child: PFCMDContainer(
                                    title: "PFCMD 2",
                                    flowMode: dt.data.pt2Smode,
                                    manualAutoTest: dt.data.pt2Omode,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: width * 5,
                                top: 47,
                                child: Transform.scale(
                                  scale: 0.6,
                                  child: PFCMDContainer(
                                    title: "PFCMD 1",
                                    flowMode: dt.data.pt1Smode,
                                    manualAutoTest: dt.data.pt1Omode,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Device Date"),
                                Text(
                                  DateFormat("dd MM yyyy").format(
                                    DateTime.now(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const MyTable()
                        ],
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
  }
}

class PFCMDContainer extends StatelessWidget {
  final String? title;
  final Color? color;
  final bool? isGreen;
  final String? flowMode;
  final String? manualAutoTest;
  const PFCMDContainer({
    this.title,
    this.isGreen = true,
    this.flowMode,
    this.manualAutoTest,
    this.color = Colors.green,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10), color: Colors.grey),
              child: Text(
                flowMode ?? "N",
                style: TextStyle(),
              ),
            ),
            Text(manualAutoTest ?? "N")
          ],
        ),
        Column(
          children: [
            const SizedBox(
              height: 40,
              width: 25,
              child: VerticalShadeContainer(),
            ),
            const SizedBox(
              width: 45,
              height: 15,
              child: GreyContainer(),
            ),
            const SizedBox(
              width: 60,
              height: 15,
              child: GreyContainer(),
            ),
            Container(
              height: 100,
              width: 40,
              decoration: BoxDecoration(
                gradient: (isGreen == true)
                    ? const LinearGradient(colors: [
                        Colors.green,
                        Colors.greenAccent,
                        Colors.green
                      ])
                    : LinearGradient(
                        colors: [Colors.red, Colors.red.shade200, Colors.red]),
              ),
            ),
            const SizedBox(
              width: 60,
              height: 15,
              child: GreyContainer(),
            ),
            const SizedBox(
              width: 45,
              height: 15,
              child: GreyContainer(),
            ),
            const SizedBox(
              height: 40,
              width: 25,
              child: VerticalShadeContainer(),
            ),
            Text(
              title ?? "",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            )
          ],
        ),
      ],
    );
  }
}

class GreyContainer extends StatelessWidget {
  const GreyContainer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [
            Colors.black,
            Colors.grey,
            Colors.white,
            Colors.grey,
            Colors.black
          ]),
          color: Colors.grey.shade500,
          borderRadius: BorderRadius.circular(5)),
    );
  }
}

class ShadeContainer extends StatelessWidget {
  const ShadeContainer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
        Colors.grey.shade800,
        Colors.white,
        Colors.grey.shade800,
      ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
    );
  }
}

class VerticalShadeContainer extends StatelessWidget {
  const VerticalShadeContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
        Colors.grey.shade800,
        Colors.white,
        Colors.grey.shade800,
      ])),
    );
  }
}
