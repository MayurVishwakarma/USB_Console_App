import 'package:flutter/material.dart';

class ColorConstant {
  static Color black900 = fromHex('#000000');

  static Color lightBlue700 = fromHex('#148fbd');

  static Color blue100 = fromHex('#c7e3f2');

  static Color whiteA700 = fromHex('#ffffff');

  static Color gray600 = fromHex('#737070');

  static Color cyan300 = fromHex('#45c7e0');

  static Color bluegray10040 = fromHex('#40cccccc');

  static Color green900 = fromHex('#176938');

  static Color black900B2 = fromHex('#b2000000');

  static Color gray800 = fromHex('#424242');

  static Color gray801 = fromHex('#4d4d4d');

  static Color cyan301 = fromHex('#3dbfde');

  static Color black90026 = fromHex('#26000000');

  static Color lightGreen900 = fromHex('#1f9400');

  static Color redA700 = fromHex('#ff0000');

  static Color yellowA400 = fromHex('#ffe814');

  static Color gray700 = fromHex('#666666');

  static Color amber500 = fromHex('#f7c412');

  static Color amber501 = fromHex('#f5c412');

  static Color lightBlue600 = fromHex('#149ed1');

  static Color lightBlue701 = fromHex('#0d99cc');

  static Color lightBlue800 = fromHex('#0d70ba');

  static Color bluegray400 = fromHex('#878787');

  static Color cyan302 = fromHex('#3dbfde');

  static Color gray900 = fromHex('#262626');

  static Color lightGreenA700 = fromHex('#63ff3d');

  static Color redA701 = fromHex('#ff0000');

  static Color gray400 = fromHex('#c2c2c2');

  static Color lightBlue50 = fromHex('#e0f7ff');

  static Color gray300 = fromHex('#e3e3e3');

  static Color bluegray100 = fromHex('#d9d9d9');

  static Color yellowA600 = fromHex('#c6ba4d');
  static const Color primaryColor = Color(0xffEC9F05);
  static const Color accentColor = Color(0xffFF4E00);
  static const Color orangeGradientEnd = Color(0xfffc4a1a);
  static const Color orangeGradientStart = Color(0xfff7b733);
  static const Color themeGradientStart = Color.fromARGB(255, 98, 159, 183);
  static const Color themeGradientEnd = Color.fromARGB(255, 151, 217, 222);

  static const LinearGradient appBarGradient =
      LinearGradient(colors: [themeGradientStart, themeGradientEnd]);

  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
