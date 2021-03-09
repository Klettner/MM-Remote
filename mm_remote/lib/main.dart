import 'package:flutter/material.dart';
import 'package:mm_remote/screens/help.dart';
import 'package:mm_remote/screens/settings.dart';
import 'package:mm_remote/shared/styles.dart';
import 'package:provider/provider.dart';

import 'models/darkThemeProvider.dart';
import 'screens/addDevice.dart';
import 'screens/chooseDevice.dart';
import 'screens/currentDevice/cdMain.dart';

void main() => runApp(MirrorApp());

class MirrorApp extends StatefulWidget {
  @override
  _MirrorAppState createState() => _MirrorAppState();
}

class _MirrorAppState extends State<MirrorApp> {
  DarkThemeProvider themeChangeProvider = new DarkThemeProvider();

  @override
  void initState() {
    super.initState();
    getCurrentAppTheme();
  }

  void getCurrentAppTheme() async {
    themeChangeProvider.darkTheme =
        await themeChangeProvider.darkThemePreference.getTheme();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        return themeChangeProvider;
      },
      child: Consumer<DarkThemeProvider>(
        builder: (BuildContext context, value, Widget child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'MM-Remote',
            theme: Styles.themeData(themeChangeProvider.darkTheme, context),
            home: StartPage(),
            routes: <String, WidgetBuilder>{
              CurrentDevicePage.routeName: (context) => CurrentDevicePage(),
              AddDevicePage.routeName: (context) => AddDevicePage(),
              StartPage.routeName: (context) => StartPage(),
              HelpPage.routeName: (context) => HelpPage(),
              SettingsPage.routeName: (context) => SettingsPage(),
            },
          );
        },
      ),
    );
  }
}