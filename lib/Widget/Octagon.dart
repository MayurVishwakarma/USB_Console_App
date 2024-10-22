// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'dart:math';

class OctagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final width = size.width;
    final height = size.height;
    const factor = 0.25;

    path.moveTo(width * factor, 0);
    path.lineTo(width * (1 - factor), 0);
    path.lineTo(width, height * factor);
    path.lineTo(width, height * (1 - factor));
    path.lineTo(width * (1 - factor), height);
    path.lineTo(width * factor, height);
    path.lineTo(0, height * (1 - factor));
    path.lineTo(0, height * factor);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
