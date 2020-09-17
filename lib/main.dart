import 'package:flutter/material.dart';
import 'package:mmremotecontrol/screens/help.dart';
import 'package:mmremotecontrol/screens/settings.dart';

import 'screens/currentDevice.dart';
import 'screens/chooseDevice.dart';
import 'screens/addDevice.dart';
import 'package:mmremotecontrol/shared/colors.dart';

void main() => runApp(MirrorApp());

class MirrorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MM-Remote',
      theme: ThemeData(
        primarySwatch: primaryColor,
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

