import 'package:flutter/material.dart';
import 'package:mm_remote/screens/help.dart';
import 'package:mm_remote/screens/settings.dart';
import 'package:mm_remote/shared/colors.dart';

import 'screens/addDevice.dart';
import 'screens/chooseDevice.dart';
import 'screens/currentDevice/cdMain.dart';

void main() => runApp(MirrorApp());

class MirrorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MM-Remote',
      theme: ThemeData(
        primaryColor: primaryColor,
        hintColor: tertiaryColorDark,
        cardColor: cardBackgroundColor,
        focusColor: accentColor,
        backgroundColor: backgroundColor,
        dividerColor: highlightColor,
        dialogBackgroundColor: backgroundColor,
      ),
      home: StartPage(),
      routes: {
        CurrentDevicePage.routeName: (context) => CurrentDevicePage(),
        AddDevicePage.routeName: (context) => AddDevicePage(),
        StartPage.routeName: (context) => StartPage(),
        HelpPage.routeName: (context) => HelpPage(),
        SettingsPage.routeName: (context) => SettingsPage(),
      },
    );
  }
}
