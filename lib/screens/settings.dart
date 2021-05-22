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
  bool _showApiKey = false;

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
      backgroundColor: backgroundColor,
      appBar: AppBar(
        iconTheme: IconThemeData(color: secondaryColor),
        brightness: Brightness.light,
        elevation: 10.0,
        titleSpacing: 0.0,
        title: Text(
          'Settings',
          style: TextStyle(
            color: secondaryColor,
          ),
        ),
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
                  style: TextStyle(
                    color: tertiaryColorDark,
                  ),
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
                  style: TextStyle(
                    color: tertiaryColorDark,
                  ),
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
          style: TextStyle(
            color: tertiaryColorDark,
          ),
        ),
        SizedBox(
          height: 15,
        ),
        _createCheckboxListTile(
            DefaultCommand.PhotoSlideshow, "Photo slideshow"),
        _createCheckboxListTile(
            DefaultCommand.MonitorBrightness, "Monitor brightness"),
        _createCheckboxListTile(
            DefaultCommand.StopwatchTimer, "Stopwatch/Timer"),
        _createCheckboxListTile(DefaultCommand.Volume, "Volume"),
      ],
    );
  }

  Widget _createCheckboxListTile(DefaultCommand defaultCommand, String title) {
    return Theme(
      data: ThemeData(unselectedWidgetColor: tertiaryColorDark),
      child: CheckboxListTile(
        title: Text(
          title,
          style: TextStyle(
            color: tertiaryColorDark,
          ),
        ),
        activeColor: accentColor,
        checkColor: secondaryColor,
        value: _isDefaultCommandEnabled(defaultCommand),
        secondary: _isDefaultCommandEnabled(defaultCommand)
            ? _getNumberWidget(_getIndex(defaultCommand))
            : Icon(
                Icons.indeterminate_check_box,
                color: tertiaryColorDark,
              ),
        onChanged: (bool value) {
          _changeDefaultCommand(value, defaultCommand);
        },
      ),
    );
  }

  bool _isDefaultCommandEnabled(DefaultCommand defaultCommand) {
    return _defaultCommands.contains(defaultCommand);
  }

  int _getIndex(DefaultCommand defaultCommand) {
    return _defaultCommands.indexOf(defaultCommand);
  }

  Widget _getNumberWidget(int index) {
    var icon;
    switch (index + 1) {
      case 1:
        icon = Icons.looks_one;
        break;
      case 2:
        icon = Icons.looks_two;
        break;
      case 3:
        icon = Icons.looks_3;
        break;
      case 4:
        icon = Icons.looks_4;
        break;
      case 5:
        icon = Icons.looks_5;
        break;
      case 6:
        icon = Icons.looks_6;
        break;
      default:
        icon = Icons.indeterminate_check_box;
    }
    return Icon(
      icon,
      color: accentColor,
    );
  }

  Widget _createAlertDurationTextField() {
    _alertDurationController.text = '$_alertDuration';
    return AccentColorOverride(
      color: accentColor,
      child: TextField(
        style: TextStyle(color: tertiaryColorDark),
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
      color: accentColor,
      child: TextField(
        style: TextStyle(color: tertiaryColorDark),
        controller: _apiKeyController,
        obscureText: !this._showApiKey,
        decoration: InputDecoration(
          labelText: 'Current API key:',
          suffixIcon: IconButton(
            icon: Icon(
              this._showApiKey ? Icons.visibility : Icons.visibility_off,
              color: this._showApiKey ? accentColor : tertiaryColorLight,
            ),
            onPressed: () {
              setState(() => this._showApiKey = !this._showApiKey);
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
              primary: accentColor,
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
