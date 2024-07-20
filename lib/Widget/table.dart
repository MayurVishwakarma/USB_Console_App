import 'package:flutter/material.dart';
import 'package:flutter_application_usb2/Provider/data_provider.dart';
import 'package:flutter_application_usb2/core/utils/appColors..dart';
import 'package:provider/provider.dart';

class MyTable extends StatelessWidget {
  const MyTable({super.key});

  @override
  Widget build(BuildContext context) {
    final dt = Provider.of<DataProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10))),
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1),
                4: FlexColumnWidth(1),
                5: FlexColumnWidth(1),
              },
              children: [
                TableRow(children: [
                  Text(
                    "VALVE DETAILS",
                    style: TextStyle(color: AppColors.white),
                  ),
                  Text(
                    'PFCMD1',
                    style: TextStyle(color: AppColors.white),
                  ),
                  Text(
                    'PFCMD2',
                    style: TextStyle(color: AppColors.white),
                  ),
                  Text(
                    'PFCMD3',
                    style: TextStyle(color: AppColors.white),
                  ),
                  Text(
                    'PFCMD4',
                    style: TextStyle(color: AppColors.white),
                  ),
                  Text(
                    'PFCMD5',
                    style: TextStyle(color: AppColors.white),
                  ),
                  Text(
                    'PFCMD6',
                    style: TextStyle(color: AppColors.white),
                  )
                ])
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: AppColors.lighBlue,
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10))),
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1),
                4: FlexColumnWidth(1),
                5: FlexColumnWidth(1),
              },
              children: [
                TableRow(children: [
                  const Text('PT(m)'),
                  Text(
                    dt.getOutletbar().toString(),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    dt.getOutletbar_pfcmd_2().toString(),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    dt.getOutletbar_pfcmd_3().toString(),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    dt.getOutletbar_pfcmd_4().toString(),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    dt.getOutletbar_pfcmd_5().toString(),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    dt.getOutletbar_pfcmd_6().toString(),
                    textAlign: TextAlign.center,
                  ),
                ]),
                TableRow(children: [
                  const Text('Position(%)'),
                  Text(
                    dt.getPostion().toString(),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    dt.getPostion_pfcmd_2().toString(),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    dt.getPostion_pfcmd_3().toString(),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    dt.getPostion_pfcmd_4().toString(),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    dt.getPostion_pfcmd_5().toString(),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    dt.getPostion_pfcmd_6().toString(),
                    textAlign: TextAlign.center,
                  ),
                ]),
                TableRow(children: [
                  const Text('Flow(LPS)'),
                  Text(
                    dt.getflowvalue().toString(),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    dt.getflowvalue_pfcmd_2().toString(),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    dt.getflowvalue_pfcmd_3().toString(),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    dt.getflowvalue_pfcmd_4().toString(),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    dt.getflowvalue_pfcmd_5().toString(),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    dt.getflowvalue_pfcmd_6().toString(),
                    textAlign: TextAlign.center,
                  ),
                ]),
                TableRow(children: [
                  const Text('Vol(m³)'),
                  Text(
                    dt.getDailyvol().toString(),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    dt.getDailyvol_pfcmd_2().toString(),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    dt.getDailyvol_pfcmd_3().toString(),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    dt.getDailyvol_pfcmd_4().toString(),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    dt.getDailyvol_pfcmd_5().toString(),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    dt.getDailyvol_pfcmd_6().toString(),
                    textAlign: TextAlign.center,
                  )
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
