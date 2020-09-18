import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mmremotecontrol/models/mirrorStateArguments.dart';

import 'currentDevice/currentDevice.dart';
import 'addDevice.dart';
import 'package:mmremotecontrol/shared/colors.dart';
import 'package:mmremotecontrol/models/deviceArguments.dart';
import 'package:mmremotecontrol/services/database.dart';

Future<List<DeviceArguments>> fetchDevicesFromDatabase() async {
  var dbHelper = SqLite();
  Future<List<DeviceArguments>> devices = dbHelper.getDevices();
  return devices;
}

class StartPage extends StatefulWidget {
  static const routeName = '/startPage';

  StartPage({Key key}) : super(key: key);

  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  List<Widget> _devices = List<Widget>();

  @override
  void initState() {
    super.initState();
    final List<Widget> _devicesTemp = List<Widget>();
    fetchDevicesFromDatabase().then((List<DeviceArguments> devices) {
      for (DeviceArguments device in devices) {
        Card _newDevice =
            _createDevice(device.deviceName, device.ip, device.port, false);
        _devicesTemp.add(_newDevice);
      }
      setState(() {
        _devices = _devicesTemp;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var _deviceOrientation = MediaQuery.of(context).orientation;

    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        elevation: 10.0,
        titleSpacing: 20.0,
        title:  Text('Choose Device'),
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
        backgroundColor: primaryColor,
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

    Card _newDevice = _createDevice(_deviceArguments.deviceName, _deviceArguments.ip,
        _deviceArguments.port, true);
    _initializeDevice(_newDevice);
    _initializeDefaultCommands(_deviceArguments.deviceName);
    _initializeSettings(_deviceArguments.deviceName);
  }

  void _initializeDevice(Card _newDevice) {
    final List<Widget> _devicesTemp = List<Widget>();
    _devicesTemp.addAll(_devices);
    _devicesTemp.add(_newDevice);

    setState(() {
      _devices = _devicesTemp;
    })  ;
  }

  Future<void> _deleteDeviceDialog(BuildContext context, String deviceName) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Do you want to delete this device?'),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Delete'),
              onPressed: () {
                _deleteDevice(deviceName);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteDevice(String deviceName){
    var dbHelper = SqLite();
    dbHelper.deleteDevice(deviceName);

    final List<Widget> _devicesTemp = List<Widget>();
    fetchDevicesFromDatabase().then((List<DeviceArguments> devices) {
      for (DeviceArguments device in devices) {
        Card _newDevice =
        _createDevice(device.deviceName, device.ip, device.port, false);
        _devicesTemp.add(_newDevice);
      }
      setState(() {
        _devices = _devicesTemp;
      });
    });
  }

  Card _createDevice(String deviceName, String ip, String port, bool persist) {
    if (persist) {
      _persistDevice(deviceName, ip, port);
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
              child: FlatButton(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          deviceName,
                          textScaleFactor: 1.1,
                          style: TextStyle(
                            color: primaryColor,
                          ),
                        ),
                        SizedBox(height: 12.0),
                        Text('IP: ' + ip),
                        SizedBox(height: 8.0),
                        Text('Port: ' + port),
                        SizedBox(height: 4.0),
                      ],
                    ),
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    CurrentDevicePage.routeName,
                    arguments: DeviceArguments(
                      deviceName,
                      ip,
                      port,
                    ),
                  );
                },
              ),
            ),
            new IconButton(
              icon: Icon(
                Icons.delete,
                size: 30.0,
                color: tertiaryColorDark,
                semanticLabel: 'Delete device',
              ),
              tooltip: 'Delete device',
              onPressed: () {
                _deleteDeviceDialog(context, deviceName);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _persistDevice(String deviceName, String ipAdress, String port) {
    var device = DeviceArguments(deviceName, ipAdress, port);
    var dbHelper = SqLite();
    dbHelper.saveDevice(device);
  }

  void _initializeDefaultCommands(String deviceName) {
    // delete already existing defaultCommands for this device
    var dbHelper = SqLite();
    dbHelper.deleteAllDefaultCommands(deviceName);
    dbHelper.saveDefaultCommand(deviceName, "PhotoSlideshow");
    dbHelper.saveDefaultCommand(deviceName, "MonitorBrightness");
    dbHelper.saveDefaultCommand(deviceName, "StopwatchTimer");
  }

  void _initializeSettings(String deviceName) {
    var setting = MirrorStateArguments(
        deviceName, '200', '10', 'ON');
    var dbHelper = SqLite();
    dbHelper.deleteSettings(deviceName);
    dbHelper.saveSetting(setting);
  }
}
