import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mmremotecontrol/app.dart';
import 'package:mmremotecontrol/start.dart';
import 'start.dart';
import 'dart:io';

class MyHomePage extends StatefulWidget {
  static const routeName = '/homePage';
  final SettingsStorage settingsStorage;

  MyHomePage({Key key, @required this.settingsStorage}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String lastRequest = "send alert";
  bool _isComposing = false;
  final TextEditingController _textController = new TextEditingController();
  String ip;
  String port;
  Color _monitorToggleColor = Colors.white;
  int _brightnessValue = 200;
  int _alertDuration = 10;
  String _settings = 'BRIGHTNESS:200|ALERTDURATION:10|Monitor:ON|;';
  bool _stateInitialized = false;

  @override
  Widget build(BuildContext context) {
    var _deviceOrientation = MediaQuery.of(context).orientation;
    final ScreenArguments args = ModalRoute.of(context).settings.arguments;
    this.ip = args.ip;
    this.port = args.port;

    //Only after start of the App
    if(!_stateInitialized) {
      _initializeSettings(args.title);
    }

    var appBar = AppBar(
      brightness: Brightness.light,
      elevation: 0.0,
      titleSpacing: 0.0,
      title: Text(
        args.title,
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.tv,
            color: _monitorToggleColor,
            semanticLabel: 'toggleMonitor',
          ),
          tooltip: 'switch monitor on/off',
          onPressed: _toggleMonitor,
        ),
        IconButton(
          icon: Icon(
            Icons.refresh,
            semanticLabel: 'reboot',
          ),
          tooltip: 'reboot mirror',
          onPressed: _rebootPi,
        ),
        IconButton(
          icon: Icon(
            Icons.power_settings_new,
            semanticLabel: 'shutdown',
          ),
          tooltip: 'shutdown mirror',
          onPressed: _shutdownPi,
        ),
      ],
    );

    return Scaffold(
      appBar: appBar,
      body: new Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: GridView.count(
                crossAxisCount:
                    _deviceOrientation == Orientation.portrait ? 1 : 2,
                padding: EdgeInsets.all(16.0),
                childAspectRatio: _deviceOrientation == Orientation.portrait
                    ? 8.0 / 3.0
                    : 8.0 / 3.5,
                children: <Widget>[
                  Card(
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 0.0),
                      child: new Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                new Container(
                                  margin:
                                      new EdgeInsets.symmetric(horizontal: 6.0),
                                  child: new Text(
                                    'BackgroundSlideShow:',
                                    textScaleFactor: 1.3,
                                  ),
                                ),
                              ],
                            ),
                            new Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                new SizedBox(
                                  width: 5.0,
                                ),
                                new Container(
                                  child: new IconButton(
                                      icon: Icon(Icons.stop,
                                          semanticLabel: 'stop slideshow'),
                                      tooltip: 'stop slideshow',
                                      color: Colors.black54,
                                      iconSize: 35.0,
                                      onPressed: _backgroundSlideShowStop),
                                ),
                                new Container(
                                  child: new IconButton(
                                      icon: Icon(Icons.play_arrow,
                                          semanticLabel: 'start slideshow'),
                                      tooltip: 'start slideshow',
                                      color: Colors.black54,
                                      iconSize: 35.0,
                                      onPressed: _backgroundSlideShowPlay),
                                ),
                                new Container(
                                  child: new IconButton(
                                      icon: Icon(Icons.fast_forward,
                                          semanticLabel: 'next picture'),
                                      tooltip: 'next picture',
                                      color: Colors.black54,
                                      iconSize: 35.0,
                                      onPressed: _backgroundSlideShowNext),
                                ),
                                new SizedBox(
                                  width: 5.0,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Card(
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 0.0),
                      child: new Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                new Container(
                                  margin:
                                      new EdgeInsets.symmetric(horizontal: 6.0),
                                  child: new Text(
                                    'BrightnessSlider:',
                                    textScaleFactor: 1.3,
                                  ),
                                ),
                              ],
                            ),
                            new Slider(
                              value: _brightnessValue.toDouble(),
                              min: 0.0,
                              max: 200.0,
                              divisions: 20,
                              activeColor: Colors.blue,
                              inactiveColor: Colors.black54,
                              label: 'change Brightness',
                              semanticFormatterCallback: (double newValue) {
                                return '${newValue.round()}/200 brightness';
                              },
                              onChanged: (double newValue) {
                                setState(() {
                                  _brightnessValue = newValue.round();
                                  _setBrightness(_brightnessValue, true);
                                });
                              },
                              onChangeEnd: (double newValue) {
                                _persistBrightnessSetting(newValue.round());
                              },
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            new Container(
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  new Divider(height: 5.0),
                  new Row(
                    children: <Widget>[
                      new Flexible(
                        child: new TextField(
                          controller: _textController,
                          onChanged: (String text) {
                            setState(() {
                              _isComposing = text.length > 0;
                            });
                          },
                          onSubmitted: _evaluateAlert,
                          decoration: new InputDecoration.collapsed(
                            hintText: "  " + lastRequest,
                          ),
                        ),
                      ),
                      new Container(
                        margin: new EdgeInsets.symmetric(horizontal: 4.0),
                        child: new IconButton(
                          icon:
                              new Icon(Icons.send, semanticLabel: 'send alert'),
                          color: Colors.black54,
                          disabledColor: Colors.black26,
                          tooltip:
                              'send an alert or send "AlertDuration: int" to set the display-time of an alert',
                          onPressed: _isComposing
                              ? () => _evaluateAlert(_textController.text)
                              : null,
                        ),
                      ),
                    ],
                  ),
                  //new Divider(height: 5.0),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 55.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            //new Divider(height: 5.0),
            new Container(
              child: new Container(
                color: Colors.blue,
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    new Container(
                      margin: new EdgeInsets.symmetric(horizontal: 4.0),
                      padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 5.0),
                      child: new IconButton(
                          icon: new Icon(Icons.arrow_back,
                              size: 35.0,
                              color: Colors.white,
                              semanticLabel: 'previous page'),
                          tooltip: 'previous mirror-page',
                          onPressed: _decrementPage),
                    ),
                    new SizedBox(
                      width: 150.0,
                    ),
                    new Container(
                        margin: new EdgeInsets.symmetric(horizontal: 4.0),
                        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 5.0),
                        child: new IconButton(
                          icon: new Icon(Icons.arrow_forward,
                              size: 35.0,
                              color: Colors.white,
                              semanticLabel: 'next page'),
                          tooltip: 'next mirror-page',
                          onPressed: _incrementPage,
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _initializeSettings(String title) {
      _stateInitialized = true;
      widget.settingsStorage.readSettings().then((String value) {
        if (value.compareTo('') != 0) {
          _settings = value;

          String _tempBrightness =
              _settings.substring(0, _settings.indexOf('|') + 1);
          String _tempAlertDuration = _settings.replaceAll(_tempBrightness, '');
          _tempAlertDuration = _tempAlertDuration.substring(
              0, _tempAlertDuration.indexOf('|') + 1);
          String _tempMonitorToggle =
              _settings.replaceAll(_tempBrightness + _tempAlertDuration, '');

          setState(() {
            _brightnessValue = int.parse(_extractValue(_tempBrightness));
            _alertDuration = int.parse(_extractValue(_tempAlertDuration));
            if (_extractValue(_tempMonitorToggle).compareTo('ON') == 0) {
              _monitorToggleColor = Colors.white;
            } else {
              _monitorToggleColor = Colors.black45;
            }
          });
        }
      });
      print('homePage: initialState: ');
      print('_settings: ' + _settings);
      print('_brightnessValue: $_brightnessValue');
      print('_alertDuration: $_alertDuration');
      if (_monitorToggleColor == Colors.white) {
        print('Monitor: ON');
      } else {
        print('Monitor: OFF');
      }
  }

  String _extractValue(String setting) {
    print('initial setting: ' + setting);
    setting = setting.substring(setting.indexOf(':') + 1, setting.indexOf('|'));
    print('resulting setting: ' + setting);
    return setting;
  }

  Future<File> _persistBrightnessSetting(int newValue) {
    //make sure that everything is in a unified format
    _settings = _settings.toUpperCase().trim().replaceAll(' ', '');

    _settings = _replaceValue(_settings, '$newValue');

    return widget.settingsStorage.writeSettings(_settings);
  }

  Future<File> _persistAlertDurationSetting(int newValue) {
    //make sure that everything is in a unified format
    _settings = _settings.toUpperCase().trim().replaceAll(' ', '');

    String _tempBrightness = _settings.substring(0, _settings.indexOf('|') + 1);
    String _tempAlertDuration = _settings.replaceAll(_tempBrightness, '');
    _tempAlertDuration = _replaceValue(_tempAlertDuration, '$newValue');

    _settings = _tempBrightness + _tempAlertDuration;
    return widget.settingsStorage.writeSettings(_settings);
  }

  Future<File> _persistMonitorSetting(String newValue) {
    //make sure that everything is in a unified format
    _settings = _settings.toUpperCase().trim().replaceAll(' ', '');

    String _tempBrightness = _settings.substring(0, _settings.indexOf('|') + 1);
    String _tempAlertDuration = _settings.replaceAll(_tempBrightness, '');
    _tempAlertDuration =
        _tempAlertDuration.substring(0, _tempAlertDuration.indexOf('|') + 1);
    String _tempMonitorToggle =
        _settings.replaceAll(_tempBrightness + _tempAlertDuration, '');
    print('_tempBrightness: ' + _tempBrightness);
    print('_tempalertDuration: ' + _tempAlertDuration);
    print('_tempMonitorToggle: ' + _tempMonitorToggle);
    _tempMonitorToggle = _replaceValue(_tempMonitorToggle, newValue);

    _settings = _tempBrightness + _tempAlertDuration + _tempMonitorToggle;
    return widget.settingsStorage.writeSettings(_settings);
  }

  String _replaceValue(String setting, String newValue) {
    print('replacementSetting: ' + setting);
    print('repalcementValue: ' + newValue);
    return setting.replaceRange(
        setting.indexOf(':') + 1, setting.indexOf('|'), newValue);
  }

  void _setBrightness(int value, bool message) {
    http.get("http://" +
        ip +
        ":" +
        port +
        "/remote?action=BRIGHTNESS&value=" +
        '$value');
    print("Brightness changed to " + '$value');
    if (message) {
      setState(() {
        lastRequest = "Brightness changed to " + '$value';
      });
    }
  }

  void _evaluateAlert(String text) {
    _textController.clear();
    setState(() {
      _isComposing = false;
    });
    String _temptext = text.toUpperCase().trim().replaceAll(' ', '');
    print(_temptext);
    //Check if ALERTDURATION: Command was send
    if (_temptext
            .substring(0, _temptext.indexOf(':') + 1)
            .compareTo('ALERTDURATION:') ==
        0) {
      _setAlertDuration(_temptext);
    } else {
      _sendAlert(text);
    }
  }

  void _setAlertDuration(String text) {
    String _amount = text.substring(text.indexOf(':') + 1);

    if (int.tryParse(_amount) != null) {
      _alertDuration = int.tryParse(_amount);
      _persistAlertDurationSetting(_alertDuration);
      setState(() {
        lastRequest = 'Alert duration set to ' + _amount;
      });
    }
  }

  void _sendAlert(String text) {
    http.get("http://" +
        ip +
        ":" +
        port +
        "/remote?action=SHOW_ALERT&message=&title=" +
        text +
        "&timer=$_alertDuration&type=alert");
    setState(() {
      lastRequest = "Sending alert";
    });
  }

  void _incrementPage() {
    http.get("http://" +
        ip +
        ":" +
        port +
        "/remote?action=NOTIFICATION&notification=PAGE_INCREMENT");
    print("Page Incremented");
    setState(() {
      lastRequest = "Page Incremented";
    });
  }

  void _decrementPage() {
    http.get("http://" +
        ip +
        ":" +
        port +
        "/remote?action=NOTIFICATION&notification=PAGE_DECREMENT");
    print("Page Decremented");
    setState(() {
      lastRequest = "Page Decremented";
    });
  }

  void _toggleMonitor() {
    if (_monitorToggleColor == Colors.white) {
      _toggleMonitorOff(true);
    } else {
      _toggleMonitorOn(true);
    }
  }

  void _toggleMonitorOn(bool stateChange) {
    http.get("http://" + ip + ":" + port + "/remote?action=MONITORON");
    print("MonitorOn");
    setState(() {
      _monitorToggleColor = Colors.white;

      if (stateChange) {
        lastRequest = "Monitor On";
      }
    });
    _persistMonitorSetting('ON');
  }

  void _toggleMonitorOff(bool stateChange) {
    http.get("http://" + ip + ":" + port + "/remote?action=MONITOROFF");
    print("MonitorOff");
    setState(() {
      _monitorToggleColor = Colors.black45;
      if (stateChange) {
        lastRequest = "Monitor Off";
      }
    });
    _persistMonitorSetting('OFF');
  }

  void _rebootPi() {
    http.get("http://" + ip + ":" + port + "/remote?action=REBOOT");
    print("Rebooting mirror");
    setState(() {
      lastRequest = "Rebooting mirror";
    });
  }

  void _shutdownPi() {
    http.get("http://" + ip + ":" + port + "/remote?action=SHUTDOWN");
    print("Shutting down mirror");
    setState(() {
      lastRequest = "Shutting down mirror";
    });
  }

  void _backgroundSlideShowNext() {
    http.get("http://" +
        ip +
        ":" +
        port +
        "/remote?action=NOTIFICATION&notification=BACKGROUNDSLIDESHOW_NEXT");
    print("Next picture");
    setState(() {
      lastRequest = "Next picture";
    });
  }

  void _backgroundSlideShowStop() {
    http.get("http://" +
        ip +
        ":" +
        port +
        "/remote?action=NOTIFICATION&notification=BACKGROUNDSLIDESHOW_STOP");
    print("Stopped SlideShow");
    setState(() {
      lastRequest = "Stopped SlideShow";
    });
  }

  void _backgroundSlideShowPlay() {
    http.get("http://" +
        ip +
        ":" +
        port +
        "/remote?action=NOTIFICATION&notification=BACKGROUNDSLIDESHOW_PLAY");
    print("Started SlideShow");
    setState(() {
      lastRequest = "Started SlideShow";
    });
  }
}
