import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as pPath;

import 'package:mmremotecontrol/models/mirrorStateArguments.dart';
import 'package:mmremotecontrol/screens/currentDevice/cdDatabaseAccess.dart';
import 'package:mmremotecontrol/shared/colors.dart';
import 'package:mmremotecontrol/services/httpRest.dart';
import 'package:mmremotecontrol/screens/help.dart';

class CurrentDeviceDrawer extends StatefulWidget {
  final HttpRest _httpRest;
  final String deviceName;
  final Function _navigateToSettingsPage;

  CurrentDeviceDrawer(this._httpRest, this.deviceName,
      this._navigateToSettingsPage);

  @override
  _CurrentDeviceDrawerState createState() => _CurrentDeviceDrawerState();
}

class _CurrentDeviceDrawerState extends State<CurrentDeviceDrawer> {
  File _image;
  final picker = ImagePicker();
  SharedPreferences prefs;
  Color _monitorToggleColor;

  @override
  void initState(){
    super.initState();
    getImage();
    //get monitorToggleColor from database
    fetchSettingsFromDatabase(this.widget.deviceName).then((MirrorStateArguments tempSettings) {
      if (tempSettings != null) {
        bool _tempMonitorColor =
            tempSettings.monitorStatus.compareTo('ON') == 0;
          if (_tempMonitorColor) {
            _monitorToggleColor = primaryColor;
          } else {
            _monitorToggleColor = tertiaryColorDark;
          }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          Expanded(
            // ListView contains a group of widgets that scroll inside the drawer
            child: ListView(
              children: <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(
                    image: (_image == null)
                        ? null
                        : DecorationImage(
                      image: FileImage(_image),
                      fit: BoxFit.cover,
                    ),
                    color: primaryColor,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        this.widget.deviceName,
                        style: TextStyle(
                          color: secondaryColor,
                          fontSize: 20,
                        ),
                      ),
                      Align(
                        alignment: FractionalOffset.bottomRight,
                        child: IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            _pickImage();
                          },
                        ),
                      )
                    ],
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.devices, color: tertiaryColorMedium),
                  title: Text('Choose device'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.tv,
                      color: _monitorToggleColor,
                      semanticLabel: 'toggleMonitor'),
                  title: Text('Toggle monitor on/off'),
                  onTap: () {
                    _toggleMonitor();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.refresh,
                      semanticLabel: 'reboot', color: tertiaryColorMedium),
                  title: Text('Reboot mirror'),
                  onTap: () {
                    _rebootPiDialog(context);
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.power_settings_new,
                    semanticLabel: 'shutdown',
                    color: tertiaryColorMedium,
                  ),
                  title: Text('Shutdown mirror'),
                  onTap: () {
                    _shutdownPiDialog(context);
                  },
                ),
              ],
            ),
          ),
          Container(
            // This align moves its children to the bottom
              child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: Container(
                      child: Column(
                        children: <Widget>[
                          Divider(),
                          ListTile(
                            leading: Icon(Icons.settings,
                                semanticLabel: 'settings',
                                color: tertiaryColorMedium),
                            title: Text('Settings'),
                            onTap: () {
                              this.widget._navigateToSettingsPage();
                            },
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.help,
                              color: tertiaryColorMedium,
                            ),
                            title: Text('Help & About (online)'),
                            onTap: () {
                              Navigator.pushNamed(context, HelpPage.routeName);
                            },
                          )
                        ],
                      ))))
        ],
      ),
    );
  }
  void _toggleMonitor() {
    if (_monitorToggleColor == primaryColor) {
      _toggleMonitorOff();
    } else {
      _toggleMonitorOn();
    }
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
                this.widget._httpRest.rebootPi();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
                this.widget._httpRest.shutdownPi();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _toggleMonitorOn() {
    _monitorToggleColor = primaryColor;
    this.widget._httpRest.toggleMonitorOn();
    updateMonitorStatus(widget.deviceName, 'ON');
  }

  void _toggleMonitorOff() {
    _monitorToggleColor = tertiaryColorDark;
    this.widget._httpRest.toggleMonitorOff();
    updateMonitorStatus(widget.deviceName, 'OFF');
  }

  Future _pickImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    // Check if a image was picked
    if (pickedFile == null) {
      return;
    }

    setState(() {
      _image = File(pickedFile.path);
    });

    final appDir = await pPath.getApplicationDocumentsDirectory();
    final String imagePath = appDir.path;
    final fileName = path.basename(pickedFile.path);
    final File localImage = await _image.copy('$imagePath/$fileName');

    //persist image path
    prefs = await SharedPreferences.getInstance();
    prefs.setString(this.widget.deviceName + 'Image', localImage.path);
  }

  Future getImage() async {
    prefs = await SharedPreferences.getInstance();
    if (prefs.getString(this.widget.deviceName + 'Image') != null) {
      setState(() {
        _image = File(prefs.getString(this.widget.deviceName + 'Image'));
      });
    }
  }
}
