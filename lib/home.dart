import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mmremotecontrol/createCC.dart';
import 'package:mmremotecontrol/models/settingArguments.dart';
import 'createCC.dart';
import 'dart:async';
import 'package:mmremotecontrol/models/commandArguments.dart';
import 'package:mmremotecontrol/models/deviceArguments.dart';
import 'package:mmremotecontrol/dbhelper.dart';
import 'package:mmremotecontrol/settings.dart';

Future<List<CommandArguments>> fetchCommandsFromDatabase(
    String deviceName) async {
  var dbHelper = DBHelper();
  Future<List<CommandArguments>> commands = dbHelper.getCommands(deviceName);
  return commands;
}

Future<SettingArguments> fetchSettingsFromDatabase(String deviceName) async {
  var dbHelper = DBHelper();
  Future<SettingArguments> setting = dbHelper.getSettings(deviceName);
  return setting;
}

class MyHomePage extends StatefulWidget {
  static const routeName = '/homePage';

  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  final List<Tab> myTabs = <Tab>[
    Tab(text: 'HOME'),
    Tab(text: 'CUSTOM-COMMANDS'),
  ];
  TabController _tabController;

  String lastRequest = "send alert";
  bool _isComposing = false;
  final TextEditingController _textController = new TextEditingController();
  String ip;
  String port;
  String deviceName;
  Color _monitorToggleColor = Colors.blue;
  int _brightnessValue = 200;
  int _alertDuration = 10;
  bool _stateInitialized = false;
  List<Widget> _customCommands = List<Widget>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: myTabs.length);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var _deviceOrientation = MediaQuery.of(context).orientation;
    final DeviceArguments args = ModalRoute.of(context).settings.arguments;
    this.ip = args.ip;
    this.port = args.port;
    this.deviceName = args.deviceName;

    //Only after start of the App
    if (!_stateInitialized) {
      _initializeSettings(deviceName);
    }

    var appBar = AppBar(
      brightness: Brightness.light,
      elevation: 10.0,
      titleSpacing: 0.0,
      title: Text(
        args.deviceName,
      ),
      bottom: TabBar(
        controller: _tabController,
        tabs: myTabs,
        labelPadding: EdgeInsets.zero,
      ),
    );

    return Scaffold(
      appBar: appBar,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                deviceName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.tv,
                  color: _monitorToggleColor, semanticLabel: 'toggleMonitor'),
              title: Text('Toggle monitor on/off'),
              onTap: () {
                _toggleMonitor();
              },
            ),
            ListTile(
              leading: Icon(Icons.refresh, semanticLabel: 'reboot',
              color: Colors.black45),
              title: Text('Reboot Mirror'),
              onTap: () {
                _rebootPiDialog(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.power_settings_new,
                semanticLabel: 'shutdown',
                color: Colors.black45,
              ),
              title: Text('Shutdown Mirror'),
              onTap: () {
                _shutdownPiDialog(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, semanticLabel: 'settings',
              color: Colors.black45,),
              title: Text('Settings'),
              onTap: () {
                _navigateToSettingsPage();
              },
            ),
          ],
        ),
      ),
      body: Builder(
        builder: (context) => TabBarView(
          controller: _tabController,
          children: myTabs.map((Tab tab) {
            if (tab.text.compareTo('HOME') == 0) {
              return new Container(
                color: Colors.grey[200],
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: GridView.count(
                        crossAxisCount:
                            _deviceOrientation == Orientation.portrait ? 1 : 2,
                        padding: _deviceOrientation == Orientation.portrait
                            ? EdgeInsets.all(16.0)
                            : EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 4.0),
                        childAspectRatio:
                            _deviceOrientation == Orientation.portrait
                                ? 8.0 / 3.0
                                : 8.0 / 3.5,
                        children: <Widget>[
                          Card(
                            clipBehavior: Clip.antiAlias,
                            child: Padding(
                              padding:
                                  EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 0.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  new Align(
                                    alignment: Alignment.centerLeft,
                                    child: new Container(
                                      margin: new EdgeInsets.symmetric(
                                          horizontal: 6.0),
                                      child: new Text(
                                        'BackgroundSlideShow:',
                                        textScaleFactor: 1.3,
                                      ),
                                    ),
                                  ),
                                  new Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      new SizedBox(
                                        width: 5.0,
                                      ),
                                      new IconButton(
                                          icon: Icon(Icons.stop,
                                              semanticLabel: 'stop slideshow'),
                                          tooltip: 'Stop slideshow',
                                          color: Colors.black54,
                                          iconSize: 35.0,
                                          onPressed: _backgroundSlideShowStop),
                                      new IconButton(
                                          icon: Icon(Icons.play_arrow,
                                              semanticLabel: 'start slideshow'),
                                          tooltip: 'Start slideshow',
                                          color: Colors.black54,
                                          iconSize: 35.0,
                                          onPressed: _backgroundSlideShowPlay),
                                      new IconButton(
                                          icon: Icon(Icons.fast_forward,
                                              semanticLabel: 'next picture'),
                                          tooltip: 'Next picture',
                                          color: Colors.black54,
                                          iconSize: 35.0,
                                          onPressed: _backgroundSlideShowNext),
                                      new SizedBox(
                                        width: 5.0,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Card(
                            clipBehavior: Clip.antiAlias,
                            child: Padding(
                              padding:
                                  EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 0.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  new Align(
                                    alignment: Alignment.centerLeft,
                                    child: new Container(
                                      margin: new EdgeInsets.symmetric(
                                          horizontal: 6.0),
                                      child: new Text(
                                        'BrightnessSlider:',
                                        textScaleFactor: 1.3,
                                      ),
                                    ),
                                  ),
                                  new Slider(
                                    value: _brightnessValue.toDouble(),
                                    min: 0.0,
                                    max: 200.0,
                                    divisions: 20,
                                    activeColor: Colors.blue,
                                    inactiveColor: Colors.black54,
                                    label: 'changing brightness',
                                    semanticFormatterCallback:
                                        (double newValue) {
                                      return '${newValue.round()}/200 brightness';
                                    },
                                    onChanged: (double newValue) {
                                      setState(() {
                                        _brightnessValue = newValue.round();
                                        _setBrightness(_brightnessValue, true);
                                      });
                                    },
                                    onChangeEnd: (double newValue) {
                                      _persistBrightnessSetting(
                                          newValue.round());
                                    },
                                  )
                                ],
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
                          new Divider(height: 1.0),
                          new Row(
                            children: <Widget>[
                              new Flexible(
                                child: new TextField(
                                  enableSuggestions: false,
                                  controller: _textController,
                                  onChanged: (String text) {
                                    setState(() {
                                      _isComposing = text.length > 0;
                                    });
                                  },
                                  decoration: new InputDecoration.collapsed(
                                    hintText: "  " + lastRequest,
                                  ),
                                ),
                              ),
                              new Container(
                                margin:
                                    new EdgeInsets.symmetric(horizontal: 4.0),
                                child: new IconButton(
                                  icon: new Icon(Icons.send,
                                      semanticLabel: 'send alert'),
                                  color: Colors.black54,
                                  disabledColor: Colors.black26,
                                  tooltip:
                                      'Send an alert or send "/AlertDuration: int" to set the display-time of an alert',
                                  onPressed: _isComposing
                                      ? () => _evaluateAlert(
                                          _textController.text, context)
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
              );
            } else {
              return new Container(
                color: Colors.grey[200],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: GridView.count(
                        crossAxisCount:
                            _deviceOrientation == Orientation.portrait ? 1 : 2,
                        padding: _deviceOrientation == Orientation.portrait
                            ? EdgeInsets.all(16.0)
                            : EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                        childAspectRatio:
                            _deviceOrientation == Orientation.portrait
                                ? 8.0 / 2.0
                                : 8.0 / 2.25,
                        children: _customCommands,
                      ),
                    ),
                    Align(
                        alignment: Alignment.lerp(
                            Alignment.center, Alignment.centerRight, 0.85),
                        child: Tooltip(
                          message: 'Create new custom-command',
                          child: FloatingActionButton(
                            child: Icon(
                              Icons.add,
                              color: Colors.blue,
                              size: 35,
                            ),
                            backgroundColor: Colors.white,
                            //padding: EdgeInsets.fromLTRB(20.0, 13.0, 20.0, 13.0),
                            elevation: 5.0,
                            onPressed: () {
                              _navigateAndCreateCustomCommand(context);
                            },
                          ),
                        )),
                    SizedBox(height: 20),
                  ],
                ),
              );
            }
          }).toList(),
        ),
      ),
      bottomNavigationBar: Builder(
        builder: (context) => BottomAppBar(
          elevation: 10.0,
          child: new Container(
            height: _deviceOrientation == Orientation.portrait ? 50.0 : 40.0,
            color: Colors.blue,
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                new IconButton(
                    padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                    icon: new Icon(Icons.arrow_back,
                        size: 35.0,
                        color: Colors.white,
                        semanticLabel: 'previous page'),
                    tooltip: 'Previous mirror-page',
                    onPressed: () {
                      _decrementPage(context);
                    }),
                new SizedBox(
                  width: 50.0,
                  height: 50.0,
                ),
                new IconButton(
                  padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                  icon: new Icon(Icons.arrow_forward,
                      size: 35.0,
                      color: Colors.white,
                      semanticLabel: 'next page'),
                  tooltip: 'Next mirror-page',
                  onPressed: () {
                    _incrementPage(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSnackbar(String message, BuildContext context) {
    Scaffold.of(context).showSnackBar(SnackBar(
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
      ),
      duration: new Duration(milliseconds: 400),
      backgroundColor: Colors.white,
      content: Text(
        message,
        textScaleFactor: 1.2,
        style: TextStyle(
          color: Colors.blue,
        ),
      ),
    ));
  }

  void _initializeSettings(String deviceName) {
    print('initializing...');
    _stateInitialized = true;

    fetchSettingsFromDatabase(deviceName).then((SettingArguments tempSettings) {
      if(tempSettings != null) {
        int _tempBrightnessValue = int.parse(tempSettings.brightness);
        int _tempAlertDuration = int.parse(tempSettings.alertDuration);
        bool _tempMonitorColor = tempSettings.monitorStatus.compareTo('ON') == 0;
        setState(() {
          _brightnessValue = _tempBrightnessValue;
          _alertDuration = _tempAlertDuration;
          if (_tempMonitorColor) {
            _monitorToggleColor = Colors.blue;
          } else {
            _monitorToggleColor = Colors.black54;
          }
        });
      }
    });

    final List<Widget> _customCommandsTemp = List<Widget>();
    fetchCommandsFromDatabase(deviceName)
        .then((List<CommandArguments> commands) {
      for (CommandArguments command in commands) {
        Card _newCard = _createCommandCard(command.commandName,
            command.notification, command.payload, context, false);
        _customCommandsTemp.add(_newCard);
      }
    });
    setState(() {
      _customCommands = _customCommandsTemp;
    });
  }

  void _persistCommand(
      String commandName, String notification, String payload) {
    var command =
        CommandArguments(deviceName, commandName, notification, payload);
    var dbHelper = DBHelper();
    dbHelper.saveCommand(command);
  }

  void _persistBrightnessSetting(int newValue) {
    var setting = SettingArguments(
        deviceName, '$newValue', '$_alertDuration', '$_monitorToggleColor');
    var dbHelper = DBHelper();
    dbHelper.deleteSettings(deviceName);
    dbHelper.saveSetting(setting);
  }

  void _persistAlertDurationSetting(int newValue) {
    var setting = SettingArguments(
        deviceName, '$_brightnessValue', '$newValue', '$_monitorToggleColor');
    var dbHelper = DBHelper();
    dbHelper.deleteSettings(deviceName);
    dbHelper.saveSetting(setting);
  }

  void _persistMonitorSetting(String status) {
    var setting = SettingArguments(
        deviceName, '$_brightnessValue', '$_alertDuration', status);
    var dbHelper = DBHelper();
    dbHelper.deleteSettings(deviceName);
    dbHelper.saveSetting(setting);
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

  void _evaluateAlert(String text, BuildContext context) {
    _textController.clear();
    setState(() {
      _isComposing = false;
    });
    String _temptext = text.toUpperCase().trim().replaceAll(' ', '');
    print(_temptext);
    //Check if Command was send
    if (_temptext
            .substring(0, _temptext.indexOf(':') + 1)
            .compareTo('/ALERTDURATION:') ==
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

  _navigateAndCreateCustomCommand(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddCommandPage()),
    );
    CommandArguments _commandArguments = result;

    Card _newCard = _createCommandCard(
        _commandArguments.commandName,
        _commandArguments.notification,
        _commandArguments.payload,
        context,
        true);
    final List<Widget> _customCommandsTemp = List<Widget>();
    _customCommandsTemp.addAll(_customCommands);
    _customCommandsTemp.add(_newCard);

    setState(() {
      _customCommands = _customCommandsTemp;
    });
  }

  _navigateToSettingsPage() async {
    String result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsPage()),
    );
    if(result != null) {
      _alertDuration = int.parse(result);
      _persistAlertDurationSetting(_alertDuration);
      setState(() {
        lastRequest = 'Alert duration set to $_alertDuration';
      });
    }
  }

  Card _createCommandCard(String commandName, String notification,
      String payload, BuildContext context, bool persist) {
    if (persist) {
      _persistCommand(commandName, notification, payload);
    }
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 4.0),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Flexible(
              fit: FlexFit.tight,
              child: FlatButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      commandName,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      textScaleFactor: 1.1,
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                onPressed: () {
                  _sendCustomCommand(
                      commandName, notification, payload, context);
                },
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete, size: 24.0),
              color: Colors.black54,
              tooltip: 'Delete command',
              onPressed: () {
                _deleteCommand(commandName);
              },
            )
          ],
        ),
      ),
    );
  }

  void _deleteCommand(String commandName) {
    var dbHelper = DBHelper();
    dbHelper.deleteCommand(deviceName, commandName);

    final List<Widget> _customCommandsTemp = List<Widget>();
    fetchCommandsFromDatabase(deviceName)
        .then((List<CommandArguments> commands) {
      for (CommandArguments command in commands) {
        Card _newCard = _createCommandCard(command.commandName,
            command.notification, command.payload, context, false);
        _customCommandsTemp.add(_newCard);
      }
      setState(() {
        _customCommands = _customCommandsTemp;
      });
    });
  }

  void _sendCustomCommand(String commandName, String notification,
      String payload, BuildContext context) {
    if (payload.trim().compareTo('') == 0) {
      http.get("http://" +
          ip +
          ":" +
          port +
          "/remote?action=NOTIFICATION&notification=" +
          notification);
    } else {
      http.get("http://" +
          ip +
          ":" +
          port +
          "/remote?action=NOTIFICATION&notification=" +
          notification +
          "&payload=" +
          payload);
    }
    _showSnackbar(commandName + ' sended', context);
    setState(() {
      lastRequest = commandName + " sended";
    });
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

  void _incrementPage(BuildContext context) {
    http.get("http://" +
        ip +
        ":" +
        port +
        "/remote?action=NOTIFICATION&notification=PAGE_INCREMENT");
    print("Page Incremented");
    _showSnackbar('Page Incremented', context);
    setState(() {
      lastRequest = "Page Incremented";
    });
  }

  void _decrementPage(BuildContext context) {
    http.get("http://" +
        ip +
        ":" +
        port +
        "/remote?action=NOTIFICATION&notification=PAGE_DECREMENT");
    print("Page Decremented");
    _showSnackbar('Page Decremented', context);
    setState(() {
      lastRequest = "Page Decremented";
    });
  }

  void _toggleMonitor() {
    if (_monitorToggleColor == Colors.blue) {
      _toggleMonitorOff(true);
    } else {
      _toggleMonitorOn(true);
    }
  }

  void _toggleMonitorOn(bool stateChange) {
    http.get("http://" + ip + ":" + port + "/remote?action=MONITORON");
    print("MonitorOn");
    setState(() {
      _monitorToggleColor = Colors.blue;

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
      _monitorToggleColor = Colors.black54;
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

  Future<void> _rebootPiDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Do you want to reboot the mirror?'),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Reboot'),
              onPressed: () {
                _rebootPi();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _shutdownPi() {
    http.get("http://" + ip + ":" + port + "/remote?action=SHUTDOWN");
    print("Shutting down mirror");
    setState(() {
      lastRequest = "Shutting down mirror";
    });
  }

  Future<void> _shutdownPiDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Do you want to shutdown the mirror?'),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Shutdown'),
              onPressed: () {
                _shutdownPi();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
