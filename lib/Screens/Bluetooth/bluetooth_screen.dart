import 'package:flutter/material.dart';
import 'package:flutter_application_usb2/Provider/data_provider.dart';
import 'package:flutter_application_usb2/Widget/simple_button.dart';
import 'package:flutter_application_usb2/core/utils/appColors..dart';
import 'package:provider/provider.dart';

class BluetoothScreen extends StatefulWidget {
  static const routeName = "/bluetoothScreen";

  const BluetoothScreen({super.key});

  @override
  State<BluetoothScreen> createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  @override
  void initState() {
    final dt = Provider.of<DataProvider>(context, listen: false);
    dt.getAllBtDevices();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final dt = Provider.of<DataProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Bluetooth",
          style: TextStyle(fontSize: 16),
        ),
      ),
      body: Column(
        children: [
          Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              height: 30,
              decoration: BoxDecoration(color: AppColors.primaryColor),
              child: const Text(
                "Connected Devices",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              )),
          Container(
            padding: const EdgeInsets.all(10),
            child: Column(
                children: dt.connectedDevices
                    .map((e) => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                if (dt.bluetoothConnection?.isConnected ==
                                    true) {
                                  dt.disconnectBTConnection(context);
                                } else {
                                  dt.connectBTDevice(context, e);
                                }
                              },
                              title:
                                  (dt.bluetoothConnection?.isConnected == true)
                                      ? "Connected"
                                      : "Disconnected",
                              color:
                                  (dt.bluetoothConnection?.isConnected == true)
                                      ? AppColors.green
                                      : AppColors.red,
                            ),
                          ],
                        ))
                    .toList()),
          ),
          Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              height: 30,
              decoration: BoxDecoration(color: AppColors.primaryColor),
              child: const Text(
                "Bluetooth Devices",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              )),
          Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: dt.bondedDevices
                  .map((e) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset(
                            "assets/images/bluetooth.png",
                            height: 30,
                          ),
                          Text(e.platformName),
                          SimpleButton(
                            onPressed: () {
                              // if (dt.connectedDevices.contains(e)) {
                              //   if (dt.bluetoothConnection?.isConnected ==
                              //       true) {
                              //     dt.disconnectBTConnection();
                              //   } else {
                              //     dt.connectBTDevice(e);
                              //   }
                              // } else {
                              dt.connectBTDevice(context, e);
                              // }
                            },
                            color: dt.getBtStatusColor(e),
                            title: dt.getBtStatusText(e),
                          )
                        ],
                      ))
                  .toList(),
            ),
          )
        ],
      ),
    );
  }
}
