import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mm_remote/models/mirrorStateArguments.dart';
import 'package:mm_remote/screens/currentDevice/cdDatabaseAccess.dart';
import 'package:mm_remote/screens/help.dart';
import 'package:mm_remote/services/httpRest.dart';
import 'package:mm_remote/shared/colors.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as pPath;
import 'package:shared_preferences/shared_preferences.dart';

class CurrentDeviceDrawer extends StatefulWidget {
  final HttpRest _httpRest;
  final String deviceName;
  final File _image;
  final Function _navigateToSettingsPage;
  final Function _initializeDrawerImage;

  CurrentDeviceDrawer(this._httpRest, this.deviceName, this._image,
      this._navigateToSettingsPage, this._initializeDrawerImage);

  @override
  _CurrentDeviceDrawerState createState() => _CurrentDeviceDrawerState();
}

class _CurrentDeviceDrawerState extends State<CurrentDeviceDrawer> {
  File _image;
  final picker = ImagePicker();
  SharedPreferences prefs;
  Color _monitorToggleColor;

  @override
  void initState() {
    super.initState();
    _image = widget._image;
    //get monitorToggleColor from database
    fetchSettingsFromDatabase(this.widget.deviceName)
        .then((MirrorStateArguments tempSettings) {
      if (tempSettings != null) {
        setState(() {
          (tempSettings.monitorStatus.compareTo('ON') == 0)
              ? _monitorToggleColor = accentColor
              : _monitorToggleColor = tertiaryColorDark;
        });
      }
    });
    // get current monitor status from mirror
    this.widget._httpRest.isMonitorOn().then((bool isOn) {
      setState(() {
        isOn
            ? _monitorToggleColor = accentColor
            : _monitorToggleColor = tertiaryColorDark;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: backgroundColor,
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
                              color: highlightColor,
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
                    title: Text(
                      'Choose device',
                      style: TextStyle(color: tertiaryColorDark),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.tv,
                        color: _monitorToggleColor,
                        semanticLabel: 'toggleMonitor'),
                    title: Text(
                      'Toggle monitor on/off',
                      style: TextStyle(color: tertiaryColorDark),
                    ),
                    onTap: () {
                      _toggleMonitor();
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.refresh,
                        semanticLabel: 'reboot', color: tertiaryColorMedium),
                    title: Text(
                      'Reboot mirror',
                      style: TextStyle(color: tertiaryColorDark),
                    ),
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
                    title: Text(
                      'Shutdown mirror',
                      style: TextStyle(color: tertiaryColorDark),
                    ),
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
                          title: Text(
                            'Settings',
                            style: TextStyle(color: tertiaryColorDark),
                          ),
                          onTap: () {
                            this.widget._navigateToSettingsPage();
                          },
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.help,
                            color: tertiaryColorMedium,
                          ),
                          title: Text(
                            'Help & About (online)',
                            style: TextStyle(color: tertiaryColorDark),
                          ),
                          onTap: () {
                            Navigator.pushNamed(context, HelpPage.routeName);
                          },
                        )
                      ],
                    ))))
          ],
        ),
      ),
    );
  }

  void _toggleMonitor() {
    (_monitorToggleColor == accentColor)
        ? _toggleMonitorOff()
        : _toggleMonitorOn();
  }

  Future<void> _rebootPiDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Do you want to reboot the mirror?',
            style: TextStyle(color: tertiaryColorDark),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: tertiaryColorMedium),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Reboot',
                style: TextStyle(color: accentColor),
              ),
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
          title: Text(
            'Do you want to shutdown the mirror?',
            style: TextStyle(color: tertiaryColorDark),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: tertiaryColorMedium),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Shutdown',
                style: TextStyle(color: accentColor),
              ),
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

  void _toggleMonitorOn() async {
    setState(() {
      _monitorToggleColor = accentColor;
    });
    this.widget._httpRest.toggleMonitorOn();
    updateMonitorStatusSetting(widget.deviceName, 'ON');
  }

  void _toggleMonitorOff() async {
    setState(() {
      _monitorToggleColor = tertiaryColorDark;
    });
    this.widget._httpRest.toggleMonitorOff();
    updateMonitorStatusSetting(widget.deviceName, 'OFF');
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
    this.widget._initializeDrawerImage();
  }
}

Future<File> getImage(String deviceName) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.getString(deviceName + 'Image') != null) {
    return File(prefs.getString(deviceName + 'Image'));
  }
  return null;
}
