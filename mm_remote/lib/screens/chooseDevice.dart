import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mm_remote/dao/deviceArgumentsDao.dart';
import 'package:mm_remote/dao/mirrorStateArgumentsDao.dart';
import 'package:mm_remote/models/darkThemeProvider.dart';
import 'package:mm_remote/models/deviceArguments.dart';
import 'package:mm_remote/services/database.dart';
import 'package:mm_remote/shared/colors.dart';
import 'package:provider/provider.dart';

import 'addDevice.dart';
import 'currentDevice/cdMain.dart';

class StartPage extends StatefulWidget {
  static const routeName = '/startPage';

  StartPage({Key key}) : super(key: key);

  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  List<Widget> _devices = <Widget>[];

  @override
  void initState() {
    super.initState();
    final List<Widget> _devicesTemp = <Widget>[];

    getAllDeviceArguments().forEach((device) {
      Card _newDevice = _createDevice(device, false);
      _devicesTemp.add(_newDevice);
    });
    setState(() {
      _devices = _devicesTemp;
    });
  }

  @override
  Widget build(BuildContext context) {
    var _deviceOrientation = MediaQuery.of(context).orientation;
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        actions: [
          Icon(
            themeChange.darkTheme ? Icons.lightbulb : Icons.nights_stay,
            size: 25,
            color: secondaryColor,
          ),
          Switch(
              value: themeChange.darkTheme,
              activeColor: Colors.blue[400],
              activeTrackColor: tertiaryColorMedium,
              inactiveTrackColor: backgroundColor,
              onChanged: (bool isOn) {
                themeChange.darkTheme = isOn;
              }),
        ],
        brightness: Brightness.light,
        elevation: 10.0,
        titleSpacing: 20.0,
        title: Text(
          'Choose Device',
          style: TextStyle(
            color: secondaryColor,
          ),
        ),
      ),
      backgroundColor: backgroundColor,
      body: new SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: GridView.count(
                crossAxisCount:
                    _deviceOrientation == Orientation.portrait ? 1 : 2,
                padding: EdgeInsets.all(16.0),
                childAspectRatio: _deviceOrientation == Orientation.portrait
                    ? 8.0 / 3.0
                    : 8.0 / 4.0,
                children: _devices,
              ),
            ),
            new SizedBox(height: 15.0),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 10.0,
        color: primaryColor,
        notchMargin: 5.0,
        shape: CircularNotchedRectangle(),
        child: new SizedBox(height: 50),
      ),
      floatingActionButton: new FloatingActionButton(
        backgroundColor: accentColor,
        child: new Icon(
          Icons.add,
          size: 30.0,
          semanticLabel: 'Add Device',
        ),
        tooltip: 'Add new device',
        onPressed: () {
          _navigateAndCreateDevice(context);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  _navigateAndCreateDevice(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddDevicePage()),
    );
    DeviceArguments _deviceArguments = result;

    Card _newDevice = _createDevice(_deviceArguments, true);
    _initializeDevice(_newDevice);
    _initializeDefaultCommands(_deviceArguments.deviceName);
    initializeMirrorStateArguments(_deviceArguments.deviceName);
  }

  void _initializeDevice(Card _newDevice) {
    final List<Widget> _devicesTemp = <Widget>[];
    _devicesTemp.addAll(_devices);
    _devicesTemp.add(_newDevice);

    setState(() {
      _devices = _devicesTemp;
    });
  }

  Future<void> _deleteDeviceDialog(
      BuildContext context, String deviceName) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Do you want to delete this device?',
            style: TextStyle(color: tertiaryColorDark),
          ),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(color: accentColor),
                )),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteDevice(deviceName);
              },
              child: Text(
                'Delete',
                style: TextStyle(color: tertiaryColorMedium),
              ),
            )
          ],
        );
      },
    );
  }

  void _deleteDevice(String deviceName) {
    deleteDeviceArguments(deviceName);
    _updateDeviceCards();
  }

  void _updateDeviceCards() {
    final List<Widget> _devicesTemp = <Widget>[];

    getAllDeviceArguments().forEach((device) {
      Card _newDevice = _createDevice(device, false);
      _devicesTemp.add(_newDevice);
    });

    setState(() {
      _devices = _devicesTemp;
    });
  }

  Card _createDevice(DeviceArguments device, bool persist) {
    if (persist) {
      persistDeviceArguments(device);
    }
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Flexible(
              fit: FlexFit.tight,
              child: TextButton(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            device.deviceName,
                            textScaleFactor: 1.2,
                            style: TextStyle(
                              color: accentColor,
                            ),
                          ),
                          SizedBox(height: 12.0),
                          Text(
                            'IP: ' + device.ip,
                            textScaleFactor: 1.1,
                          ),
                          SizedBox(height: 4.0),
                        ],
                      ),
                    ),
                  ),
                  onPressed: () {
                    DeviceArguments newDevice =
                        getDeviceArgument(device.deviceName);
                    Navigator.pushNamed(
                      context,
                      CurrentDevicePage.routeName,
                      arguments: newDevice,
                    );
                  }),
            ),
            new IconButton(
              icon: Icon(
                Icons.delete,
                size: 30.0,
                semanticLabel: 'Delete device',
              ),
              tooltip: 'Delete device',
              onPressed: () {
                _deleteDeviceDialog(context, device.deviceName);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _initializeDefaultCommands(String deviceName) {
    // delete already existing defaultCommands for this device
    var dbHelper = SqLite();
    dbHelper.deleteAllDefaultCommands(deviceName);
    dbHelper.saveDefaultCommand(deviceName, "PhotoSlideshow");
    dbHelper.saveDefaultCommand(deviceName, "MonitorBrightness");
    dbHelper.saveDefaultCommand(deviceName, "StopwatchTimer");
  }
}