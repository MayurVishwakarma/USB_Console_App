import 'package:flutter/material.dart';

class Utils {
  static showsnackBar(BuildContext ctx, String message, {Color? color}) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: color,
    ));
  }
}
