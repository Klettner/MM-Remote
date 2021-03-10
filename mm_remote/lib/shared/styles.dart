import 'package:flutter/material.dart';

import 'colors.dart';

class Styles {
  static ThemeData themeData(bool isDarkTheme, BuildContext context) {
    isDarkTheme ? setDarkMode() : setLightMode();
    return ThemeData(
        brightness: isDarkTheme ? Brightness.dark : Brightness.light,
        primaryColor: primaryColor,
        hintColor: tertiaryColorDark,
        cardColor: cardBackgroundColor,
        focusColor: accentColor,
        backgroundColor: backgroundColor,
        dividerColor: highlightColor,
        dialogBackgroundColor: secondaryBackgroundColor,
        iconTheme: IconThemeData(color: tertiaryColorMedium),
        floatingActionButtonTheme:
            FloatingActionButtonThemeData(foregroundColor: Colors.white),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            primary: tertiaryColorDark,
          ),
        ),
        textSelectionTheme: TextSelectionThemeData(
          selectionHandleColor: Colors.blue[400],
        ));
  }
}
