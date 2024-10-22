import 'package:flutter/material.dart';
import 'package:usb_console_application/core/utils/appColors..dart';

class SimpleButton extends StatelessWidget {
  const SimpleButton(
      {super.key, required this.onPressed, this.title = "", this.color});
  final VoidCallback? onPressed;
  final String title;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            foregroundColor: (color != null) ? Colors.white : Colors.white,
            backgroundColor: color ?? AppColors.primaryColor,
          ),
          onPressed: onPressed,
          child: Text(
            title,
            style: const TextStyle(),
          )),
    );
  }
}

class MyTextButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String title;
  const MyTextButton({super.key, required this.title, this.onPressed});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
        child: Text(
          title,
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
