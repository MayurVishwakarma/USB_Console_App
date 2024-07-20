import 'package:flutter/material.dart';
import 'package:flutter_application_usb2/core/utils/appColors..dart';

class CustomButton extends StatelessWidget {
  const CustomButton({super.key, required this.onPressed, this.title = ""});
  final VoidCallback onPressed;
  final String title;
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
            backgroundColor: const Color.fromARGB(255, 104, 103, 243),
          ),
          onPressed: onPressed,
          child: Text(
            title,
            style: const TextStyle(letterSpacing: 2),
          )),
    );
  }
}
