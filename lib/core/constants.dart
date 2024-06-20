import 'package:flutter/material.dart';

class Constants {
  static const String loadingScreen = '/loadingScreen';
  static const String searchScreen = '/searchScreen';
  static const String favoriteScreen = '/favoriteScreen';
}

class IconConstants {
  static String images = 'assets/images';

  static String back = '$images/back.png';
  static String close = '$images/close.png';
  static String favorites = '$images/favorites.png';
  static String noresult = '$images/noresult.png';
  static String search = '$images/search.png';
  static String searchOnBack = '$images/searchOnBack.png';
}

class AppTextStyles {
  static const TextStyle primarySemibold = TextStyle(
    fontFamily: 'Sora',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const TextStyle primaryRegular = TextStyle(
    fontFamily: 'Sora',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.2,
  );

  static const TextStyle secondaryRegular = TextStyle(
    fontFamily: 'Sora',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );
}

class AppColors {
  static Map<String, Color> colors = {
    'background': colorFromHex('#FAFAFC'),
    'accent': colorFromHex('#0CC509'),
    'Layer1': colorFromHexWithOpacity('#FFFFFF', 0.26),
    'Layer2': colorFromHex('#F1F2F6'),
    'Layer3': colorFromHexWithOpacity('#0CC509', 0.05),
    'Layer4': colorFromHex('#F2F2F2'),
    'textPrimary': colorFromHex('#1C2027'),
    'secondaryRegular': colorFromHex('#BFBFBF'),
    'error': colorFromHex('#EA1A1A'),
    'icon': colorFromHex('#1C2027'),
  };

  static Color colorFromHex(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  static Color colorFromHexWithOpacity(String hexColor, double opacity) {
    final hexCode = hexColor.replaceAll('#', '');
    return Color.fromRGBO(
      int.parse(hexCode.substring(0, 2), radix: 16),
      int.parse(hexCode.substring(2, 4), radix: 16),
      int.parse(hexCode.substring(4, 6), radix: 16),
      opacity,
    );
  }
}
