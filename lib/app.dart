import 'home.dart';
import 'chooseDevice.dart';
import 'createDevice.dart';
import 'package:flutter/material.dart';

class MirrorApp extends StatefulWidget {
  @override
  _MirrorAppState createState() => _MirrorAppState();
}

class _MirrorAppState extends State<MirrorApp> {

  @override
  Widget build(BuildContext context) {
        return  MaterialApp(
          title: 'MM-Remote',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: StartPage(),
          routes: {
            MyHomePage.routeName: (context) => MyHomePage(),
            AddDevicePage.routeName: (context) => AddDevicePage(),
            StartPage.routeName: (context) => StartPage(),
          },
        );
  }
}
