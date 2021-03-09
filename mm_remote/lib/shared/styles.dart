import 'package:flutter/material.dart';

import 'colors.dart';

class Styles {
  static ThemeData themeData(bool isDarkTheme, BuildContext context) {
    isDarkTheme ? setDarkMode() : setLightMode();
    return ThemeData(
      primaryColor: primaryColor,
      hintColor: tertiaryColorDark,
      cardColor: cardBackgroundColor,
      focusColor: accentColor,
      backgroundColor: backgroundColor,
      dividerColor: highlightColor,
      dialogBackgroundColor: secondaryBackgroundColor,
    );
  }
}
