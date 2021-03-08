import 'package:flutter/material.dart';
import 'package:mm_remote/models/settingArguments.dart';
import 'package:mm_remote/shared/colors.dart';

class SettingsPage extends StatefulWidget {
  static const routeName = '/settings';

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _alertDurationController = TextEditingController();
  final _apiKeyController = TextEditingController();
  List<DefaultCommand> _defaultCommands = <DefaultCommand>[];
  bool _stateInitialized = false;
  int _alertDuration;
  String _apiKey;
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    if (!_stateInitialized) {
      _stateInitialized = true;
      SettingArguments tmp;
      final Map<String, Object> currentSettings =
          ModalRoute.of(context).settings.arguments as Map;
      tmp = currentSettings["currentSettings"];
      _defaultCommands = tmp.defaultCommands;
      _alertDuration = tmp.alertDuration;
      _apiKey = tmp.apiKey;
    }
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
              _createDefaultCommandsSelector(),
              SizedBox(
                height: 30,
              ),
              Center(
                child: Text(
                  "Alert settings",
                  textScaleFactor: 1.3,
                ),
              ),
              _createAlertDurationTextField(),
              SizedBox(
                height: 30,
              ),
              Center(
                child: Text(
                  "API Key",
                  textScaleFactor: 1.3,
                ),
              ),
              _createApiKeyTextField(),
              SizedBox(height: 10),
              _createFinishButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _createDefaultCommandsSelector() {
    return Column(
      children: [
        Text(
          "Default commands",
          textScaleFactor: 1.3,
        ),
        SizedBox(
          height: 15,
        ),
        CheckboxListTile(
          title: const Text("Photo slideshow"),
          value: _defaultCommands.contains(DefaultCommand.PhotoSlideshow),
          onChanged: (bool value) {
            _changeDefaultCommand(value, DefaultCommand.PhotoSlideshow);
          },
        ),
        CheckboxListTile(
          title: const Text("Monitor brightness"),
          value: _defaultCommands.contains(DefaultCommand.MonitorBrightness),
          onChanged: (bool value) {
            _changeDefaultCommand(value, DefaultCommand.MonitorBrightness);
          },
        ),
        CheckboxListTile(
          title: const Text("Stop-watch/Timer"),
          value: _defaultCommands.contains(DefaultCommand.StopwatchTimer),
          onChanged: (bool value) {
            _changeDefaultCommand(value, DefaultCommand.StopwatchTimer);
          },
        )
      ],
    );
  }

  Widget _createAlertDurationTextField() {
    _alertDurationController.text = '$_alertDuration';
    return AccentColorOverride(
      color: primaryColor,
      child: TextField(
        keyboardType: TextInputType.number,
        controller: _alertDurationController,
        decoration: InputDecoration(
          labelText: "Alert duration (in seconds)",
        ),
      ),
    );
  }

  Widget _createApiKeyTextField() {
    _apiKeyController.text = _apiKey;
    return AccentColorOverride(
      color: primaryColor,
      child: TextField(
        controller: _apiKeyController,
        obscureText: !this._showPassword,
        decoration: InputDecoration(
          labelText: 'Current API key:',
          suffixIcon: IconButton(
            icon: Icon(
              this._showPassword ? Icons.visibility : Icons.visibility_off,
              color: this._showPassword ? Colors.blue : Colors.grey,
            ),
            onPressed: () {
              setState(() => this._showPassword = !this._showPassword);
            },
          ),
        ),
      ),
    );
  }

  Widget _createFinishButton() {
    return ButtonBar(
      children: <Widget>[
        ElevatedButton(
            child: Text(
              'FINISH',
              style: TextStyle(color: secondaryColor),
            ),
            style: ElevatedButton.styleFrom(
              primary: primaryColor,
              elevation: 5.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
              ),
            ),
            onPressed: () {
              _submitSettings();
            })
      ],
    );
  }

  void _changeDefaultCommand(bool value, DefaultCommand defaultCommand) {
    if (value) {
      if (!_defaultCommands.contains(defaultCommand)) {
        _defaultCommands.add(defaultCommand);
      }
    } else {
      if (_defaultCommands.contains(defaultCommand)) {
        _defaultCommands.remove(defaultCommand);
      }
    }
    // Update Widgets
    setState(() {});
  }

  void _submitSettings() {
    if (_alertDurationController.text.trim().compareTo("") != 0) {
      _alertDuration = int.parse(_alertDurationController.text.trim());
    }
    if (_apiKeyController.text.trim().compareTo("") != 0) {
      _apiKey = _apiKeyController.text.trim();
    }
    _apiKeyController.clear();
    _alertDurationController.clear();
    SettingArguments settings =
        new SettingArguments(_defaultCommands, _alertDuration, _apiKey);
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
