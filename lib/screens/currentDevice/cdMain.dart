import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mmremotecontrol/models/settingArguments.dart';
import 'package:mmremotecontrol/screens/currentDevice/cdDrawer.dart';

import 'package:mmremotecontrol/shared/colors.dart';
import 'package:mmremotecontrol/services/httpRest.dart';
import 'package:mmremotecontrol/screens/addCommand.dart';
import 'package:mmremotecontrol/models/mirrorStateArguments.dart';
import 'package:mmremotecontrol/models/commandArguments.dart';
import 'package:mmremotecontrol/models/deviceArguments.dart';
import 'package:mmremotecontrol/services/database.dart';
import 'package:mmremotecontrol/screens/settings.dart';
import 'package:mmremotecontrol/screens/currentDevice/cdDatabaseAccess.dart';

class CurrentDevicePage extends StatefulWidget {
  static const routeName = '/homePage';

  CurrentDevicePage({Key key}) : super(key: key);

  @override
  _CurrentDevicePageState createState() => _CurrentDevicePageState();
}

class _CurrentDevicePageState extends State<CurrentDevicePage>
    with SingleTickerProviderStateMixin {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<Tab> myTabs = <Tab>[
    Tab(text: 'HOME'),
    Tab(text: 'CUSTOM-COMMANDS'),
  ];
  TabController _tabController;

  String lastRequest = "Send alert";
  bool _isComposing = false;
  final TextEditingController _textController = new TextEditingController();
  final TextEditingController _timerMinutesController =
      new TextEditingController();
  final TextEditingController _timerSecondsController =
      new TextEditingController();
  String ip;
  String port;
  String deviceName;
  int _brightnessValue = 200;
  int _alertDuration = 10;
  bool _stateInitialized = false;
  List<Widget> _customCommands = List<Widget>();
  HttpRest _httpRest;
  CurrentDeviceDrawer _currentDeviceDrawer;

  bool _isPaused = false;
  String _stopWatchTimerValue = "Timer";
  List<Widget> _defaultCommandCards = new List<Widget>();
  List<DefaultCommand> _defaultCommands = new List<DefaultCommand>();

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
      // _httpRest will be needed for the initialization of DefaultCommandCards,
      // therefore it has to be instantiated first
      _httpRest = new HttpRest(ip, port, _updateLastRequest, _showSnackbar);
      _initializeDrawerImage();
      _initializeSettings(deviceName);
      _initializeDefaultCommandCards();
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
      key: _scaffoldKey,
      appBar: appBar,
      drawer: _currentDeviceDrawer,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Builder(
          builder: (context) => TabBarView(
            controller: _tabController,
            children: myTabs.map((Tab tab) {
              if (tab.text.compareTo('HOME') == 0) {
                return _createHomeTab(_deviceOrientation);
              } else {
                return _createCustomCommandsTab(_deviceOrientation);
              }
            }).toList(),
          ),
        ),
      ),
      bottomNavigationBar: Builder(
        builder: (context) => BottomAppBar(
          elevation: 10.0,
          child: _createBottomAppBar(_deviceOrientation),
        ),
      ),
    );
  }

  Widget _createBackgroundSlideShowCard() {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Align(
              alignment: Alignment.centerLeft,
              child: new Container(
                margin: new EdgeInsets.symmetric(horizontal: 6.0),
                child: new Text(
                  'Photo slideshow',
                  textScaleFactor: 1.3,
                ),
              ),
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new SizedBox(
                  width: 5.0,
                ),
                new IconButton(
                    icon: Icon(Icons.stop, semanticLabel: 'stop slideshow'),
                    tooltip: 'Stop slideshow',
                    color: tertiaryColorDark,
                    iconSize: 35.0,
                    onPressed: _httpRest.backgroundSlideShowStop),
                new IconButton(
                    icon: Icon(Icons.play_arrow,
                        semanticLabel: 'start slideshow'),
                    tooltip: 'Start slideshow',
                    color: tertiaryColorDark,
                    iconSize: 35.0,
                    onPressed: _httpRest.backgroundSlideShowPlay),
                new IconButton(
                    icon:
                        Icon(Icons.fast_forward, semanticLabel: 'next picture'),
                    tooltip: 'Next picture',
                    color: tertiaryColorDark,
                    iconSize: 35.0,
                    onPressed: _httpRest.backgroundSlideShowNext),
                new SizedBox(
                  width: 5.0,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _createStopWatchTimerCard() {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              children: [
                new Align(
                  alignment: Alignment.centerLeft,
                  child: new Container(
                      margin: new EdgeInsets.symmetric(horizontal: 6.0),
                      child: PopupMenuButton<String>(
                        onSelected: (String result) {
                          _timerSecondsController.clear();
                          _timerMinutesController.clear();
                          setState(() {
                            _stopWatchTimerValue = result;
                          });
                          _updateDefaultCommandCards();
                        },
                        child: Row(
                          children: [
                            Text(
                              (_isTimer()) ? "Timer" : "Stop-watch",
                              textScaleFactor: 1.3,
                            ),
                            Icon(
                             Icons.arrow_drop_down,
                              size: 25,
                            )
                          ],
                        ),
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            value: 'Timer',
                            child: Text('Timer'),
                          ),
                          PopupMenuItem<String>(
                              value: 'Stop-watch', child: Text('Stop-watch'))
                        ],
                      )),
                ),
                (_isTimer()) ? _createTimerInputFields() : new Container(),
              ],
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new SizedBox(
                  width: 5.0,
                ),
                new IconButton(
                    icon: Icon(Icons.pause,
                        semanticLabel: 'stop timer/stop-watch'),
                    tooltip: 'Stop timer/stop-watch',
                    color: tertiaryColorDark,
                    iconSize: 35.0,
                    onPressed: () {
                     _handlePauseUnpause();
                    }),
                new IconButton(
                    icon: Icon(Icons.play_arrow,
                        semanticLabel: 'start timer/stop-watch'),
                    tooltip: 'Start timer/stop-watch',
                    color: tertiaryColorDark,
                    iconSize: 35.0,
                    onPressed: () {
                      _handleStart();
                    }),
                new IconButton(
                    icon: Icon(Icons.flash_on, semanticLabel: 'interrupt'),
                    tooltip: 'Interrupt',
                    color: tertiaryColorDark,
                    iconSize: 30,
                    onPressed: _httpRest.stopWatchTimerInterrupt),
                new SizedBox(
                  width: 5.0,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handlePauseUnpause() {
    if (_isTimer()) {
      if(_isPaused) {
        _isPaused = false;
        _httpRest.timerUnpause();
      } else {
        _isPaused = true;
        _httpRest.stopWatchTimerPause();
      }
    } else {
      if(_isPaused) {
        _isPaused = false;
        _httpRest.stopWatchUnpause();
      } else {
        _isPaused = true;
        _httpRest.stopWatchTimerPause();
      }
    }
  }

  _handleStart(){
    if(_isTimer()) {
      _isPaused = false;
      _httpRest.timerStart(_getSeconds());
    } else {
      _isPaused = false;
      _httpRest.stopWatchStart();
    }
  }

  bool _isTimer() {
    if (_stopWatchTimerValue.compareTo("Timer") == 0) {
      return true;
    }
      return false;
  }

  Widget _createTimerInputFields() {
    return new Row(
      children: [
        SizedBox(
          width: 30,
        ),
        SizedBox(
          width: 50,
          child: TextField(
            keyboardType: TextInputType.number,
            controller: _timerMinutesController,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.zero,
              labelText: "min.",
            ),
          ),
        ),
        SizedBox(
          width: 15,
        ),
        SizedBox(
          width: 50,
          child: TextField(
            keyboardType: TextInputType.number,
            controller: _timerSecondsController,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.zero,
              labelText: "sec.",
            ),
          ),
        )
      ],
    );
  }

  int _getSeconds() {
    int minutes = 0;
    int seconds = 0;
    if (_timerMinutesController.text.trim().compareTo("") != 0) {
      minutes = int.parse(_timerMinutesController.text.trim());
    }
    if (_timerSecondsController.text.trim().compareTo("") != 0) {
      seconds = int.parse(_timerSecondsController.text.trim());
    }
    return minutes * 60 + seconds;
  }

  Widget _createBrightnessSliderCard() {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Align(
              alignment: Alignment.centerLeft,
              child: new Container(
                margin: new EdgeInsets.symmetric(horizontal: 6.0),
                child: new Text(
                  'Monitor brightness',
                  textScaleFactor: 1.3,
                ),
              ),
            ),
            new Slider(
              value: _brightnessValue.toDouble(),
              min: 0.0,
              max: 200.0,
              divisions: 20,
              activeColor: primaryColor,
              inactiveColor: tertiaryColorDark,
              label: 'changing brightness',
              semanticFormatterCallback: (double newValue) {
                return '${newValue.round()}/200 brightness';
              },
              onChanged: (double newValue) {
                setState(() {
                  _brightnessValue = newValue.round();
                });
                _updateBrightnessSliderCard();
                _httpRest.setBrightness(_brightnessValue, true);
              },
              onChangeEnd: (double newValue) {
                updateBrightnessSetting(deviceName, newValue.round());
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _createAlertLauncher() {
    return new Container(
      color: secondaryColor,
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
                margin: new EdgeInsets.symmetric(horizontal: 4.0),
                child: new IconButton(
                  icon: new Icon(Icons.send, semanticLabel: 'send alert'),
                  color: tertiaryColorDark,
                  disabledColor: tertiaryColorLight,
                  tooltip:
                      'Send an alert or send "/AlertDuration: int" to set the display-time of an alert',
                  onPressed: _isComposing
                      ? () => _evaluateAlert(_textController.text, context)
                      : null,
                ),
              ),
            ],
          ),
          //new Divider(height: 5.0),
        ],
      ),
    );
  }


  Widget _createHomeTab(var _deviceOrientation) {
    return new Container(
      color: backgroundColor,
      child: Column(
        children: <Widget>[
          Expanded(
            child: GridView.count(
              crossAxisCount:
                  _deviceOrientation == Orientation.portrait ? 1 : 2,
              padding: _deviceOrientation == Orientation.portrait
                  ? EdgeInsets.all(16.0)
                  : EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 4.0),
              childAspectRatio: _deviceOrientation == Orientation.portrait
                  ? 8.0 / 3.0
                  : 8.0 / 3.5,
              children: _defaultCommandCards,
            ),
          ),
          _createAlertLauncher(),
        ],
      ),
    );
  }

  void _initializeDrawerImage() {
    getImage(deviceName).then((_image) {
      setState(() {
        _currentDeviceDrawer = CurrentDeviceDrawer(_httpRest, deviceName, _image,
            _navigateToSettingsPage, _initializeDrawerImage);
      });
    });
  }

  void _initializeDefaultCommandCards() {
    _defaultCommands.add(DefaultCommand.PhotoSlideshow);
    _defaultCommands.add(DefaultCommand.MonitorBrightness);
    _defaultCommands.add(DefaultCommand.StopwatchTimer);
    _updateDefaultCommandCards();
  }

  void _updateDefaultCommandCards() {
    List<Widget> updatedList = new List<Widget>();
    for(DefaultCommand command in _defaultCommands){
        _addDefaultCommand(updatedList, command);
    }
    setState(() {
      _defaultCommandCards = updatedList;
    });
  }

  void _updateBrightnessSliderCard() {
    int brightnessCardIndex = _defaultCommands.indexOf(DefaultCommand.MonitorBrightness);
    List<Widget> updatedList = new List<Widget>();
    for(Widget widget in _defaultCommandCards) {
      updatedList.add(widget);
    }
    updatedList.removeAt(brightnessCardIndex);
    Widget brightnessSliderCard = _createBrightnessSliderCard();
    updatedList.insert(brightnessCardIndex, brightnessSliderCard);
    setState(() {
      _defaultCommandCards = updatedList;
    });
  }

  void _addDefaultCommand(List<Widget> commands, DefaultCommand command) {
    switch (command){
      case DefaultCommand.PhotoSlideshow:
        commands.add(_createBackgroundSlideShowCard());
        break;
      case DefaultCommand.MonitorBrightness:
        commands.add(_createBrightnessSliderCard());
        break;
      case DefaultCommand.StopwatchTimer:
        commands.add(_createStopWatchTimerCard());
        break;
      default:
        print("This default command is not specified");
    }
  }

  void _createDefaultCommands(List<String> defaultCommandStrings){
    _defaultCommands.clear();
    for(String defaultCommandString in defaultCommandStrings){
      if(defaultCommandString.compareTo("MonitorBrightness") == 0){
        _defaultCommands.add(DefaultCommand.MonitorBrightness);
      }
      if(defaultCommandString.compareTo("PhotoSlideshow") == 0) {
        _defaultCommands.add(DefaultCommand.PhotoSlideshow);
      }
      if(defaultCommandString.compareTo("StopwatchTimer") == 0) {
        _defaultCommands.add(DefaultCommand.StopwatchTimer);
      }
    }
    _updateDefaultCommandCards();
  }

  Widget _createCustomCommandsTab(var _deviceOrientation) {
    return new Container(
      color: backgroundColor,
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
              childAspectRatio: _deviceOrientation == Orientation.portrait
                  ? 8.0 / 2.0
                  : 8.0 / 2.25,
              children: _customCommands,
            ),
          ),
          Align(
              alignment:
                  Alignment.lerp(Alignment.center, Alignment.centerRight, 0.85),
              child: Tooltip(
                message: 'Create new custom-command',
                child: FloatingActionButton(
                  child: Icon(
                    Icons.add,
                    color: primaryColor,
                    size: 35,
                  ),
                  backgroundColor: secondaryColor,
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

  Widget _createBottomAppBar(var _deviceOrientation) {
    return new Container(
      height: _deviceOrientation == Orientation.portrait ? 50.0 : 40.0,
      color: primaryColor,
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          new IconButton(
              padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
              icon: new Icon(Icons.arrow_back,
                  size: 35.0,
                  color: secondaryColor,
                  semanticLabel: 'previous page'),
              tooltip: 'Previous mirror-page',
              onPressed: () {
                _httpRest.decrementPage(context);
              }),
          new SizedBox(
            width: 50.0,
            height: 50.0,
          ),
          new IconButton(
            padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
            icon: new Icon(Icons.arrow_forward,
                size: 35.0, color: secondaryColor, semanticLabel: 'next page'),
            tooltip: 'Next mirror-page',
            onPressed: () {
              _httpRest.incrementPage(context);
            },
          ),
        ],
      ),
    );
  }

  void _showSnackbar(String message, BuildContext context) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
      ),
      duration: new Duration(milliseconds: 400),
      backgroundColor: secondaryColor,
      content: Text(
        message,
        textScaleFactor: 1.2,
        style: TextStyle(
          color: primaryColor,
        ),
      ),
    ));
  }

  void _initializeSettings(String deviceName) {
    _stateInitialized = true;

    fetchSettingsFromDatabase(deviceName).then((MirrorStateArguments tempSettings) {
      if (tempSettings != null) {
        int _tempBrightnessValue = int.parse(tempSettings.brightness);
        int _tempAlertDuration = int.parse(tempSettings.alertDuration);
        setState(() {
          _brightnessValue = _tempBrightnessValue;
          _alertDuration = _tempAlertDuration;
        });
      }
    });

    fetchDefaultCommandsFromDatabase(deviceName)
        .then((List<String> defaultCommandStrings) {
      _createDefaultCommands(defaultCommandStrings);
    });

    final List<Widget> _customCommandsTemp = List<Widget>();
    fetchCommandsFromDatabase(deviceName)
        .then((List<CommandArguments> commands) {
      for (CommandArguments command in commands) {
        Card _newCommand = _createCommandCard(command.commandName,
            command.notification, command.payload, context, false);
        _customCommandsTemp.add(_newCommand);
      }
    });
    setState(() {
      _customCommands = _customCommandsTemp;
    });
  }

  void _evaluateAlert(String text, BuildContext context) {
    _textController.clear();
    setState(() {
      _isComposing = false;
    });
    String _temptext = text.toUpperCase().trim().replaceAll(' ', '');
    //Check if Command was send
    if (_temptext
            .substring(0, _temptext.indexOf(':') + 1)
            .compareTo('/ALERTDURATION:') ==
        0) {
      _setAlertDuration(_temptext);
    } else {
      _httpRest.sendAlert(text, _alertDuration);
    }
  }

  void _setAlertDuration(String text) {
    String _amount = text.substring(text.indexOf(':') + 1);

    if (int.tryParse(_amount) != null) {
      _alertDuration = int.tryParse(_amount);
      updateAlertDurationSetting(deviceName, _alertDuration);
      _updateLastRequest('Alert duration set to ' + _amount);
    }
  }

  _navigateAndCreateCustomCommand(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddCommandPage()),
    );
    CommandArguments _commandArguments = result;

    Card _newCommand = _createCommandCard(
        _commandArguments.commandName,
        _commandArguments.notification,
        _commandArguments.payload,
        context,
        true);
    final List<Widget> _customCommandsTemp = List<Widget>();
    _customCommandsTemp.addAll(_customCommands);
    _customCommandsTemp.add(_newCommand);

    setState(() {
      _customCommands = _customCommandsTemp;
    });
  }

  _navigateToSettingsPage() async {
    SettingArguments _currentSettings = new SettingArguments(_defaultCommands, _alertDuration);
    final result = await Navigator.pushNamed(
      context,
      SettingsPage.routeName,
      arguments: {
        "currentSettings": _currentSettings,
      }
    );
    if (result != null) {
      SettingArguments settings = result;
      _alertDuration = settings.alertDuration;
      _defaultCommands = settings.defaultCommands;
      _updateDefaultCommandCards();
      persistDefaultCommands(deviceName, _defaultCommands);
      updateAlertDurationSetting(deviceName, _alertDuration);
    }
  }

  Card _createCommandCard(String commandName, String notification,
      String payload, BuildContext context, bool persist) {
    if (persist) {
      persistCommand(deviceName, commandName, notification, payload);
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
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                onPressed: () {
                  _httpRest.executeCustomCommand(
                      commandName, notification, payload, context);
                },
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete, size: 24.0),
              color: tertiaryColorDark,
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
    var dbHelper = SqLite();
    dbHelper.deleteCommand(deviceName, commandName);

    final List<Widget> _customCommandsTemp = List<Widget>();
    fetchCommandsFromDatabase(deviceName)
        .then((List<CommandArguments> commands) {
      for (CommandArguments command in commands) {
        Card _newCommand = _createCommandCard(command.commandName,
            command.notification, command.payload, context, false);
        _customCommandsTemp.add(_newCommand);
      }
      setState(() {
        _customCommands = _customCommandsTemp;
      });
    });
  }

  void _updateLastRequest(String requestMessage) {
    setState(() {
      lastRequest = requestMessage;
    });
  }
}