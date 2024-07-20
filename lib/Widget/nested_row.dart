import 'package:flutter/material.dart';

class NestedRow extends StatelessWidget {
  final String? title1;
  final String? title2;
  final String? value1;
  final String? value2;
  final Color? color1;
  final Color? color2;
  const NestedRow({
    this.title1,
    this.title2,
    this.value1,
    this.value2,
    this.color1,
    this.color2,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(1),
          2: FlexColumnWidth(2),
          3: FlexColumnWidth(1)
        },
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TableRow(children: [
            Text(
              title1 ?? "",
            ),
            Text(
              value1 ?? "",
              style: TextStyle(color: color1, fontWeight: FontWeight.bold),
            ),
            Text(title2 ?? ""),
            Text(
              value2 ?? "",
              style: TextStyle(color: color2, fontWeight: FontWeight.bold),
            )
          ])
          // Row(
          //   children: [
          //     Text(title1 ?? ""),
          //     SizedBox(width: 5),
          //     Text(
          //       value1 ?? "",
          //       style: TextStyle(color: color1),
          //     )
          //   ],
          // ),
          // Row(
          //   children: [
          //     Text(title2 ?? ""),
          //     SizedBox(width: 5),
          //     Text(
          //       value2 ?? "",
          //       style: TextStyle(color: color2),
          //     )
          //   ],
          // ),
        ],
      ),
    );
  }
}
