import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mm_remote/models/deviceArguments.dart';
import 'package:mm_remote/shared/colors.dart';

class AddDevicePage extends StatefulWidget {
  static const routeName = '/addDevice';

  @override
  _AddDevicePageState createState() => _AddDevicePageState();
}

class _AddDevicePageState extends State<AddDevicePage> {
  final _titleController = TextEditingController();
  final _ipController = TextEditingController();
  final _apiKeyController = TextEditingController();
  bool _isComposingTitle = false;
  bool _isComposingIp = false;
  bool _isComposingApiKey = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        iconTheme: IconThemeData(color: secondaryColor),
        brightness: Brightness.light,
        elevation: 10.0,
        titleSpacing: 0.0,
        title: Text(
          'Add Device',
          style: TextStyle(color: secondaryColor),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          children: <Widget>[
            SizedBox(height: 75),
            AccentColorOverride(
              color: accentColor,
              child: TextField(
                controller: _titleController,
                style: TextStyle(color: tertiaryColorDark),
                decoration: InputDecoration(
                  labelText: 'Device name',
                ),
                onChanged: (String text) {
                  setState(() {
                    _isComposingTitle = text.trim().length > 0;
                  });
                },
              ),
            ),
            SizedBox(height: 12.0),
            AccentColorOverride(
              color: accentColor,
              child: TextField(
                controller: _ipController,
                style: TextStyle(color: tertiaryColorDark),
                decoration: InputDecoration(
                  labelText: 'IP-Address',
                ),
                onChanged: (String text) {
                  setState(() {
                    _isComposingIp = text.trim().length > 0;
                  });
                },
              ),
            ),
            SizedBox(height: 12.0),
            AccentColorOverride(
              color: accentColor,
              child: TextField(
                controller: _apiKeyController,
                style: TextStyle(color: tertiaryColorDark),
                decoration: InputDecoration(
                  labelText: 'API Key',
                ),
                onChanged: (String text) {
                  setState(() {
                    _isComposingApiKey = text.trim().length > 0;
                  });
                },
              ),
            ),
            ButtonBar(
              children: <Widget>[
                TextButton(
                  child: Text(
                    'CLEAR',
                    style: TextStyle(color: inverseHighlightColor),
                  ),
                  onPressed: () {
                    _titleController.clear();
                    _ipController.clear();
                    _apiKeyController.clear();
                    setState(() {
                      _isComposingTitle = false;
                      _isComposingIp = false;
                      _isComposingApiKey = false;
                    });
                  },
                ),
                ElevatedButton(
                  child: Text(
                    'CREATE',
                    style: TextStyle(color: secondaryColor),
                  ),
                  style: ElevatedButton.styleFrom(
                      primary: accentColor,
                      elevation: 5.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15.0)),
                      )),
                  onPressed: (_isComposingTitle &&
                      _isComposingIp &&
                      _isComposingApiKey)
                      ? () => _handleSubmitted(_titleController.text,
                      _ipController.text, _apiKeyController.text)
                      : null,
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  void _handleSubmitted(String title, String ip, String apiKey) {
    _titleController.clear();
    _ipController.clear();
    _apiKeyController.clear();
    setState(() {
      _isComposingTitle = false;
      _isComposingIp = false;
      _isComposingApiKey = false;
    });
    Navigator.pop(
      context,
      DeviceArguments(
        title.trim(),
        ip.trim(),
        apiKey.trim(),
      ),
    );
  }
}

class AccentColorOverride extends StatelessWidget {
  const AccentColorOverride({Key key, this.color, this.child})
      : super(key: key);

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      child: child,
      data: Theme.of(context).copyWith(
        accentColor: color,
        brightness: Brightness.dark,
      ),
    );
  }
}
