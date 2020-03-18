import 'home.dart';
import 'start.dart';
import 'addDevice.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

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
            MyHomePage.routeName: (context) => MyHomePage(settingsStorage: SettingsStorage()),
            AddDevicePage.routeName: (context) => AddDevicePage(),
            StartPage.routeName: (context) => StartPage(),
          },
        );
  }
}

class SettingsStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/settings.txt');
  }

  Future<String> readSettings() async {
    try {
      final file = await _localFile;

      // Read the file
      String contents = await file.readAsString();

      return contents;
    } catch (e) {
      // If encountering an error, return 0
      return '';
    }
  }

  Future<File> writeSettings(String settings) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString('$settings');
  }
}

