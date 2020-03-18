import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mmremotecontrol/app.dart';
import 'package:mmremotecontrol/createCC.dart';
import 'package:mmremotecontrol/start.dart';
import 'start.dart';
import 'dart:io';
import 'createCC.dart';
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class MyHomePage extends StatefulWidget {
  static const routeName = '/homePage';
  final SettingsStorage settingsStorage;

  MyHomePage({Key key, @required this.settingsStorage}) : super(key: key);

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
  String title;
  Color _monitorToggleColor = Colors.blue;
  int _brightnessValue = 200;
  int _alertDuration = 10;
  String _settings = 'BRIGHTNESS:200|ALERTDURATION:10|Monitor:ON|;';
  bool _stateInitialized = false;
  List<Widget> _customCommands = List<Widget>();
  MirrorDatabase _mirrorDatabase;

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
    final ScreenArguments args = ModalRoute.of(context).settings.arguments;
    this.ip = args.ip;
    this.port = args.port;
    this.title = args.title;

    //Only after start of the App
    if (!_stateInitialized) {
      _mirrorDatabase = new MirrorDatabase(title);
      _initializeSettings(title + ':');
    }

    var appBar = AppBar(
      brightness: Brightness.light,
      elevation: 10.0,
      titleSpacing: 0.0,
      title: Text(
        args.title,
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
          children:  <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon( Icons.tv,
                color: _monitorToggleColor,
                semanticLabel: 'toggleMonitor'),
              title: Text('Toggle monitor on/off'),
              onTap: (){
                _toggleMonitor();
              },
            ),
            ListTile(
              leading: Icon(Icons.refresh,
                semanticLabel: 'reboot'),
              title: Text('Reboot Mirror'),
              onTap: () {
                _rebootPiDialog(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.power_settings_new,
                semanticLabel: 'shutdown',),
              title: Text('Shutdown Mirror'),
              onTap: () {
                _shutdownPiDialog(context);
                //Navigator.of(context).pop();
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
            height: 50.0,
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

  void _initializeSettings(String title) {
    _stateInitialized = true;
    _settings = title + _settings;
    // widget.settingsStorage.writeSettings('');
    widget.settingsStorage.readSettings().then((String value) {
      if (value.compareTo('') != 0 && value.contains(title)) {
        //choose settings of relevant device
        _settings = value.substring(value.indexOf(title));
        _settings = _settings.substring(0, _settings.indexOf(';') + 1);

        //delete device name
        String _tempSettings = _settings.substring(_settings.indexOf(':') + 1);

        //create String for every setting
        String _tempBrightness =
            _tempSettings.substring(0, _tempSettings.indexOf('|') + 1);
        String _tempAlertDuration =
            _tempSettings.replaceAll(_tempBrightness, '');
        _tempAlertDuration = _tempAlertDuration.substring(
            0, _tempAlertDuration.indexOf('|') + 1);
        String _tempMonitorToggle =
            _tempSettings.replaceAll(_tempBrightness + _tempAlertDuration, '');

        //actualize settings
        _settings = title + _tempSettings;

        print('homePage: initialState: ');
        print('_settings: ' + _settings);
        print('_brightnessValue: $_brightnessValue');
        print('_alertDuration: $_alertDuration');
        if (_monitorToggleColor == Colors.blue) {
          print('Monitor: ON');
        } else {
          print('Monitor: OFF');
        }
        setState(() {
          _brightnessValue = int.parse(_extractValue(_tempBrightness));
          _alertDuration = int.parse(_extractValue(_tempAlertDuration));
          if (_extractValue(_tempMonitorToggle).compareTo('ON') == 0) {
            _monitorToggleColor = Colors.blue;
          } else {
            _monitorToggleColor = Colors.black54;
          }
        });
      }
    });
    /*
    _mirrorDatabase.openDB(title.replaceAll(':', ''));
    final List<Widget> _customCommandsTemp = List<Widget>();

    _mirrorDatabase.getCommands().then((List<CommandArguments> values) {
      for (CommandArguments cargs in values) {
        _customCommandsTemp.add(
            _createCommandCard(cargs.title, cargs.notification, cargs.payload));
      }
      setState(() {
        _customCommands = _customCommandsTemp;
      });
    });
    */
  }

  String _extractValue(String setting) {
    print('initial setting: ' + setting);
    setting = setting.substring(setting.indexOf(':') + 1, setting.indexOf('|'));
    print('resulting setting: ' + setting);
    return setting;
  }

  Future<File> _writeSetting(String setting) {
    _settings = title + ':' + setting;

    widget.settingsStorage.readSettings().then((String value) {
      if (value.compareTo('') != 0 && value.contains(title + ':')) {
        return widget.settingsStorage.writeSettings(value.replaceRange(
            value.indexOf(title + ':'),
            value.indexOf(title + ':') + _settings.indexOf(';') + 1,
            _settings));
      } else {
        return widget.settingsStorage.writeSettings(value + _settings);
      }
    });
  }

  String _unifySettingAndDeleteDeviceName(String setting) {
    String _tempSettings = _settings.toUpperCase().trim().replaceAll(' ', '');
    _tempSettings = _tempSettings.substring(_tempSettings.indexOf(':') + 1);
    return _tempSettings;
  }

  void _persistBrightnessSetting(int newValue) {
    String _tempSettings = _unifySettingAndDeleteDeviceName(_settings);

    _tempSettings = _replaceValue(_tempSettings, '$newValue');

    _writeSetting(_tempSettings);
  }

  void _persistAlertDurationSetting(int newValue) {
    String _tempSettings = _unifySettingAndDeleteDeviceName(_settings);

    String _tempBrightness =
        _tempSettings.substring(0, _tempSettings.indexOf('|') + 1);
    String _tempAlertDuration = _tempSettings.replaceAll(_tempBrightness, '');
    _tempAlertDuration = _replaceValue(_tempAlertDuration, '$newValue');

    _tempSettings = _tempBrightness + _tempAlertDuration;
    _writeSetting(_tempSettings);
  }

  void _persistMonitorSetting(String newValue) {
    String _tempSettings = _unifySettingAndDeleteDeviceName(_settings);

    String _tempBrightness =
        _tempSettings.substring(0, _tempSettings.indexOf('|') + 1);
    String _tempAlertDuration = _tempSettings.replaceAll(_tempBrightness, '');
    _tempAlertDuration =
        _tempAlertDuration.substring(0, _tempAlertDuration.indexOf('|') + 1);
    String _tempMonitorToggle =
        _tempSettings.replaceAll(_tempBrightness + _tempAlertDuration, '');
    print('_tempBrightness: ' + _tempBrightness);
    print('_tempalertDuration: ' + _tempAlertDuration);
    print('_tempMonitorToggle: ' + _tempMonitorToggle);
    _tempMonitorToggle = _replaceValue(_tempMonitorToggle, newValue);

    _tempSettings = _tempBrightness + _tempAlertDuration + _tempMonitorToggle;
    _writeSetting(_tempSettings);
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

    Card _newCard = _createCommandCard(_commandArguments.title,
        _commandArguments.notification, _commandArguments.payload, context);
    final List<Widget> _customCommandsTemp = List<Widget>();
    _customCommandsTemp.addAll(_customCommands);
    _customCommandsTemp.add(_newCard);

    setState(() {
      _customCommands = _customCommandsTemp;
    });
  }

  Card _createCommandCard(
      String title, String notification, String payload, BuildContext context) {
    //_mirrorDatabase
    //  .insertCommand(new CommandArguments(title, notification, payload));
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 4.0),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Flexible(
              fit: FlexFit.tight,
              child: FlatButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
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
                  _sendCustomCommand(title, notification, payload, context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendCustomCommand(
      String title, String notification, String payload, BuildContext context) {
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
    _showSnackbar(title + ' sended', context);
    setState(() {
      lastRequest = title + " sended";
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

class CommandArguments {
  final String title;
  final String notification;
  final String payload;

  CommandArguments(this.title, this.notification, this.payload);

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'notification': notification,
      'payload': payload,
    };
  }

  @override
  String toString() {
    return 'Command{title: $title, notification: $notification, payload: $payload}';
  }
}

class MirrorDatabase {
  Future<Database> database;
  String tableName;

  MirrorDatabase(this.tableName);

  void openDB(String device) async {
    this.database = openDatabase(
      join(await getDatabasesPath(), device + '.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE $device(title TEXT PRIMARY KEY, notify TEXT, payload TEXT)",
        );
      },
      version: 1,
    );
  }

  Future<void> insertCommand(CommandArguments commandArguments) async {
    final Database db = await database;

    await db.insert(
      tableName,
      commandArguments.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<CommandArguments>> getCommands() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);

    // Convert the List<Map<String, dynamic> into a List<CommandArguments>.
    return List.generate(maps.length, (i) {
      return CommandArguments(
        maps[i]['title'],
        maps[i]['notification'],
        maps[i]['payload'],
      );
    });
  }

  Future<void> updateCommand(CommandArguments commandArguments) async {
    final db = await database;

    await db.update(
      tableName,
      commandArguments.toMap(),
      where: "title = ?",
      whereArgs: [commandArguments.title],
    );
  }

  Future<void> deleteCommand(String titel) async {
    final db = await database;

    await db.delete(
      tableName,
      where: "title = ?",
      whereArgs: [titel],
    );
  }
}
