import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mmremotecontrol/models/deviceArguments.dart';

class AddDevicePage extends StatefulWidget {
  static const routeName = '/addDevice';

  @override
  _AddDevicePageState createState() => _AddDevicePageState();
}

class _AddDevicePageState extends State<AddDevicePage> {
  final _titleController = TextEditingController();
  final _ipController = TextEditingController();
  final _portController = TextEditingController();
  bool _isComposingTitle = false;
  bool _isComposingIp = false;
  bool _isComposingPort = false;
  String _titleField = 'Device name';
  String _ipField = 'IP-Address';
  String _portField = 'Port';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        elevation: 10.0,
        titleSpacing: 0.0,
        title: Text('Add Device'),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          children: <Widget>[
            SizedBox(height: 75),
            AccentColorOverride(
              color: Colors.blue,
              child: TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: _titleField,
                ),
                onChanged: (String text) {
                  setState(() {
                    _isComposingTitle = text.trim().length > 0;
                  });
                },
              ),
            ),
            SizedBox(height: 12.0),
            AccentColorOverride(
              color: Colors.blue,
              child: TextField(
                controller: _ipController,
                decoration: InputDecoration(
                  labelText: _ipField,
                ),
                onChanged: (String text) {
                  setState(() {
                    _isComposingIp = text.trim().length > 0;
                  });
                },
              ),
            ),
            SizedBox(height: 12.0),
            AccentColorOverride(
              color: Colors.blue,
              child: TextField(
                controller: _portController,
                decoration: InputDecoration(
                  labelText: _portField,
                ),
                onChanged: (String text) {
                  setState(() {
                    _isComposingPort = text.trim().length > 0;
                  });
                },
              ),
            ),
            ButtonBar(
              children: <Widget>[
                FlatButton(
                  child: Text('CLEAR'),
                  shape: BeveledRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(7.0)),
                  ),
                  onPressed: () {
                    _titleController.clear();
                    _ipController.clear();
                    _portController.clear();
                    setState(() {
                      _isComposingTitle = false;
                      _isComposingIp = false;
                      _isComposingPort = false;
                    });
                  },
                ),
                RaisedButton(
                  child: Text('CREATE',
                  style: TextStyle(
                    color: Colors.white
                  ),),
                  elevation: 8.0,
                  color: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15.0)),
                  ),
                  onPressed:
                      (_isComposingTitle && _isComposingIp && _isComposingPort)
                          ? () => _handleSubmitted(_titleController.text,
                              _ipController.text, _portController.text)
                          : null,
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  void _handleSubmitted(String title, String ip, String port) {
    _titleController.clear();
    _ipController.clear();
    _portController.clear();
    setState(() {
      _isComposingTitle = false;
      _isComposingIp = false;
      _isComposingPort = false;
    });
    Navigator.pop(
      context,
      DeviceArguments(
        title.trim(),
        ip.trim(),
        port.trim(),
      ),
    );
  }
}

class AccentColorOverride extends StatelessWidget {
  const AccentColorOverride({Key key, this.color, this.child})
      : super(key: key);

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      child: child,
      data: Theme.of(context).copyWith(
        accentColor: color,
        brightness: Brightness.dark,
      ),
    );
  }
}
