import 'package:flutter/material.dart';
import 'package:mmremotecontrol/shared/colors.dart';


class SettingsPage extends StatefulWidget {
  static const routeName = '/settings';

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _alertDurationController = TextEditingController();
  bool _isComposingAlertDuration = false;
  String _alertDurationField = 'Alert-Duration (default 10 sec.)';
  bool _addMonitorBrightnessCard = true;
  bool _addPhotoSlideshowCard = true;
  bool _addStopwatchTimerCard = true;

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
            SizedBox(height: 30),
            Column(
             children: [
               Text("Default commands",
               textScaleFactor: 1.3,
               ),
               SizedBox(
                 height: 15,
               ),
               CheckboxListTile(
                 title: const Text("Photo slideshow"),
                 value: _addPhotoSlideshowCard,
                 onChanged: (bool value) {
                   setState(() {
                     _addPhotoSlideshowCard = value;
                   });
                 },
               ),
               CheckboxListTile(
                 title: const Text("Monitor brightness"),
                 value: _addMonitorBrightnessCard,
                 onChanged: (bool value) {
                    setState(() {
                      _addMonitorBrightnessCard = value;
                    });
                 },
               ),
                CheckboxListTile(
                  title: const Text("Stop-watch/Timer"),
                  value: _addStopwatchTimerCard,
                  onChanged: (bool value) {
                    setState(() {
                      _addStopwatchTimerCard = value;
                    });
                  },
                )
             ],
            ),
            SizedBox(
              height: 30,
            ),
            Center(
              child: Text("Alert settings",
              textScaleFactor: 1.3,
              ),
            ),
            AccentColorOverride(
              color: primaryColor,
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
                    color: secondaryColor
                  ),
                  ),
                  elevation: 8.0,
                  color: primaryColor,
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
