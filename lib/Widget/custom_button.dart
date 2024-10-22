import 'package:flutter/material.dart';
import 'package:usb_console_application/core/utils/appColors..dart';

class CustomButton extends StatelessWidget {
  const CustomButton(
      {super.key,
      required this.onPressed,
      this.title = "",
      this.bcolor = Colors.indigo});
  final VoidCallback onPressed;
  final String title;
  final MaterialColor bcolor;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 50,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            foregroundColor: AppColors.white,
            backgroundColor: bcolor,
          ),
          onPressed: onPressed,
          child: Text(
            title,
            style: const TextStyle(letterSpacing: 2),
          )),
    );
  }
}
