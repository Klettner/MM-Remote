import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mm_remote/dao/mirrorStateArgumentsDao.dart';
import 'package:mm_remote/models/mirrorStateArguments.dart';
import 'package:mm_remote/services/httpRest.dart';
import 'package:mm_remote/shared/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class CurrentDeviceDrawer extends StatefulWidget {
  final HttpRest _httpRest;
  final String deviceName;
  final Function _navigateToSettingsPage;

  CurrentDeviceDrawer(
      this._httpRest, this.deviceName, this._navigateToSettingsPage);

  @override
  _CurrentDeviceDrawerState createState() => _CurrentDeviceDrawerState();
}

class _CurrentDeviceDrawerState extends State<CurrentDeviceDrawer> {
  File _image;
  SharedPreferences prefs;
  Color _monitorToggleColor;

  @override
  void initState() {
    super.initState();
    //get monitorToggleColor from database
    MirrorStateArguments tempSettings =
        getMirrorStateArguments(this.widget.deviceName);
    if (tempSettings != null) {
      setState(() {
        (tempSettings.monitorStatus.compareTo('ON') == 0)
            ? _monitorToggleColor = accentColor
            : _monitorToggleColor = tertiaryColorMedium;
      });
    }

    _syncMonitorStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: secondaryBackgroundColor,
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              this.widget.deviceName,
                              style: TextStyle(
                                color: secondaryColor,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
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
                        Divider(
                          color: lineColor,
                        ),
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
                          onTap: () async {
                            const url =
                                'https://klettner.github.io/MM-Remote_App.html';
                            _launchURL(url);
                          },
                        )
                      ],
                    ))))
          ],
        ),
      ),
    );
  }

  void _launchURL(String url) async => await canLaunch(url)
      ? await launch(url, forceWebView: true, forceSafariVC: false)
      : throw 'Could not launch $url';

  void _syncMonitorStatus() async {
    try {
      bool isMonitorOn = await this.widget._httpRest.isMonitorOn();
      setState(() {
        isMonitorOn
            ? _monitorToggleColor = accentColor
            : _monitorToggleColor = tertiaryColorMedium;
      });
    } catch (e) {
      print("Monitor currently unavailable");
    }
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
    updateMonitorState(widget.deviceName, 'ON');
  }

  void _toggleMonitorOff() async {
    setState(() {
      _monitorToggleColor = tertiaryColorDark;
    });
    this.widget._httpRest.toggleMonitorOff();
    updateMonitorState(widget.deviceName, 'OFF');
  }
}
