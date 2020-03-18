import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mmremotecontrol/app.dart';
import 'home.dart';
import 'addDevice.dart';
import 'package:mmremotecontrol/models/deviceArguments.dart';
import 'package:mmremotecontrol/dbhelper.dart';

Future<List<DeviceArguments>> fetchDevicesFromDatabase() async {
  var dbHelper = DBHelper();
  Future<List<DeviceArguments>> devices = dbHelper.getDevices();
  return devices;
}

class StartPage extends StatefulWidget {
  static const routeName = '/startPage';
  final CardsStorage storage;

  StartPage({Key key, @required this.storage}) : super(key: key);

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
        Card _newCard =
            _createCards(device.deviceName, device.ip, device.port, false);
        _devicesTemp.add(_newCard);
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
        titleSpacing: 0.0,
        title: Text('     Choose Device'),
      ),
      backgroundColor: Colors.grey[200],
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
        color: Colors.blue,
        notchMargin: 5.0,
        shape: CircularNotchedRectangle(),
        child: new SizedBox(height: 50),
      ),
      floatingActionButton: new FloatingActionButton(
        backgroundColor: Colors.blue,
        child: new Icon(
          Icons.add,
          size: 30.0,
          semanticLabel: 'add Device',
        ),
        tooltip: 'Add new device',
        onPressed: () {
          _navigateAndCreateNewCard(context);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  _navigateAndCreateNewCard(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddDevicePage()),
    );
    DeviceArguments _deviceArguments = result;
    _changeCards(_deviceArguments.deviceName, _deviceArguments.ip,
        _deviceArguments.port);
  }

  void _changeCards(String deviceName, String ip, String port) {
    Card _newCard = _createCards(deviceName, ip, port, true);
    final List<Widget> _devicesTemp = List<Widget>();
    _devicesTemp.addAll(_devices);
    _devicesTemp.add(_newCard);

    setState(() {
      _devices = _devicesTemp;
    });
  }

  Future<void> _deleteCardDialog(BuildContext context, String deviceName) async {
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
    var dbHelper = DBHelper();
    dbHelper.deleteDevice(deviceName);

    final List<Widget> _devicesTemp = List<Widget>();
    fetchDevicesFromDatabase().then((List<DeviceArguments> devices) {
      for (DeviceArguments device in devices) {
        Card _newCard =
        _createCards(device.deviceName, device.ip, device.port, false);
        _devicesTemp.add(_newCard);
      }
      setState(() {
        _devices = _devicesTemp;
      });
    });
  }

  Card _createCards(String deviceName, String ip, String port, bool persist) {
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
                            color: Colors.blue,
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
                    MyHomePage.routeName,
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
                color: Colors.black54,
                semanticLabel: 'delete device',
              ),
              tooltip: 'Delete device',
              onPressed: () {
                _deleteCardDialog(context, deviceName);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _persistDevice(String deviceName, String ipAdress, String port) {
    var device = DeviceArguments(deviceName, ipAdress, port);
    var dbHelper = DBHelper();
    dbHelper.saveDevice(device);
  }
}
