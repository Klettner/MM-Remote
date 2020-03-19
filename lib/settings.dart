import 'package:flutter/material.dart';


class SettingsPage extends StatefulWidget {
  static const routeName = '/addCommand';

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _alertDurationController = TextEditingController();
  bool _isComposingAlertDuration = false;
  String _alertDurationField = 'Alert-Duration (default 10)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        elevation: 10.0,
        titleSpacing: 0.0,
        title: Text('Settings'),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          children: <Widget>[
            SizedBox(height: 75),
            AccentColorOverride(
              color: Colors.blue,
              child: TextField(
                keyboardType: TextInputType.number,
                controller: _alertDurationController,
                decoration: InputDecoration(
                  labelText: _alertDurationField,
                ),
                onChanged: (String text) {
                  setState(() {
                    _isComposingAlertDuration = text.trim().length > 0;
                  });
                },
              ),
            ),
            SizedBox(height: 10),
            ButtonBar(
              children: <Widget>[
                FlatButton(
                  child: Text('CLEAR'),
                  shape: BeveledRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(7.0)),
                  ),
                  onPressed: () {
                    _alertDurationController.clear();
                    setState(() {
                      _isComposingAlertDuration = false;
                    });
                  },
                ),
                RaisedButton(
                  child: Text('Apply',
                  style: TextStyle(
                    color: Colors.white
                  ),
                  ),
                  elevation: 8.0,
                  color: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                  onPressed: (_isComposingAlertDuration)
                      ? () => _setAlertDuration(_alertDurationController.text)
                      : null,
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  void _setAlertDuration(
      String alertDuration) {
    _alertDurationController.clear();
    setState(() {
      _isComposingAlertDuration = false;
    });
      Navigator.pop(
        context,
        alertDuration
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
