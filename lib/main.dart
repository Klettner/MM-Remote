import 'package:flutter/material.dart';

import 'screens/currentDevice.dart';
import 'screens/chooseDevice.dart';
import 'screens/addDevice.dart';

void main() => runApp(MirrorApp());

class MirrorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MM-Remote',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StartPage(),
      routes: {
        CurrentDevicePage.routeName: (context) => CurrentDevicePage(),
        AddDevicePage.routeName: (context) => AddDevicePage(),
        StartPage.routeName: (context) => StartPage(),
      },
    );
  }
}

