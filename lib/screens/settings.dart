import 'package:flutter/material.dart';
import 'package:mmremotecontrol/models/settingArguments.dart';
import 'package:mmremotecontrol/shared/colors.dart';


class SettingsPage extends StatefulWidget {
  static const routeName = '/settings';

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _alertDurationController = TextEditingController();
  String _alertDurationField = 'Alert-Duration (default 10 sec.)';
  List<DefaultCommand> defaultCommands = new List<DefaultCommand>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        elevation: 10.0,
        titleSpacing: 0.0,
        title: Text('Settings'),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: SafeArea(
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
                   value: defaultCommands.contains(DefaultCommand.PhotoSlideshow),
                   onChanged: (bool value) {
                    _changeDefaultCommand(value, DefaultCommand.PhotoSlideshow);
                   },
                 ),
                 CheckboxListTile(
                   title: const Text("Monitor brightness"),
                   value: defaultCommands.contains(DefaultCommand.MonitorBrightness),
                   onChanged: (bool value) {
                     _changeDefaultCommand(value, DefaultCommand.MonitorBrightness);
                   },
                 ),
                  CheckboxListTile(
                    title: const Text("Stop-watch/Timer"),
                    value: defaultCommands.contains(DefaultCommand.StopwatchTimer),
                    onChanged: (bool value) {
                      _changeDefaultCommand(value, DefaultCommand.StopwatchTimer);
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
                ),
              ),
              SizedBox(height: 10),
              ButtonBar(
                children: <Widget>[
                  RaisedButton(
                    child: Text('FINISH',
                    style: TextStyle(
                      color: secondaryColor
                    ),
                    ),
                    elevation: 8.0,
                    color: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    ),
                    onPressed: () {
                      _submitSettings();
                    }
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _changeDefaultCommand(bool value, DefaultCommand defaultCommand) {
    if(value) {
      if(!defaultCommands.contains(defaultCommand)){
        defaultCommands.add(defaultCommand);
      }
    } else {
      if(defaultCommands.contains(defaultCommand)){
        defaultCommands.remove(defaultCommand);
      }
    }
    // Update Widgets
    setState(() {
    });
  }

  void _submitSettings() {
    int alertDuration = -1;
    if(_alertDurationController.text.trim().compareTo("") != 0) {
      alertDuration = int.parse(_alertDurationController.text.trim());
    }
    _alertDurationController.clear();
    SettingArguments settings = new SettingArguments(defaultCommands, alertDuration);
      Navigator.pop(
        context,
        settings,
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
