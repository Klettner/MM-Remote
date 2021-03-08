import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mm_remote/shared/colors.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HelpPage extends StatefulWidget {
  static const routeName = '/helpPage';

  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: secondaryColor),
          title: Text(
            'HELP',
            style: TextStyle(color: secondaryColor),
          ),
          backgroundColor: primaryColor,
        ),
        body: Container(
          child: WebView(
            initialUrl: 'https://klettner.github.io/MM-Remote_App.html',
          ),
        ));
  }
}
