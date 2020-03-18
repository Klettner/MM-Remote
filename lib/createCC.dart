import 'package:flutter/material.dart';
import 'home.dart';

class AddCommandPage extends StatefulWidget {
  static const routeName = '/addCommand';

  @override
  _AddCommandPageState createState() => _AddCommandPageState();
}

class _AddCommandPageState extends State<AddCommandPage> {
  final _titleController = TextEditingController();
  final _notificationController = TextEditingController();
  final _payloadController = TextEditingController();
  bool _isComposingTitle = false;
  bool _isComposingNotification = false;
  String _titleField = 'Name (max. 13 characters)';
  String _notificationField = 'Notification of mirror module';
  String _payloadField = 'Payload (optional)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        elevation: 10.0,
        titleSpacing: 0.0,
        title: Text('Add Command'),
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
                controller: _notificationController,
                decoration: InputDecoration(
                  labelText: _notificationField,
                ),
                onChanged: (String text) {
                  setState(() {
                    _isComposingNotification = text.trim().length > 0;
                  });
                },
              ),
            ),
            SizedBox(height: 12.0),
            AccentColorOverride(
              color: Colors.blue,
              child: TextField(
                controller: _payloadController,
                decoration: InputDecoration(
                  labelText: _payloadField,
                ),
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
                    _notificationController.clear();
                    _payloadController.clear();
                    setState(() {
                      _isComposingTitle = false;
                      _isComposingNotification = false;
                    });
                  },
                ),
                RaisedButton(
                  child: Text('CREATE'),
                  elevation: 8.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                  onPressed:
                  (_isComposingTitle && _isComposingNotification)
                      ? () => _handleSubmittedNext(_titleController.text,
                      _notificationController.text, _payloadController.text)
                      : null,
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  void _handleSubmittedNext(String title, String notification, String payload) {
    _titleController.clear();
    _notificationController.clear();
    _payloadController.clear();
    setState(() {
      _isComposingTitle = false;
      _isComposingNotification = false;
    });
    if(_noIllegalCharacters(title, notification, payload)) {
      Navigator.pop(
        context,
        CommandArguments(
          title.trim(),
          notification.trim(),
          payload.trim(),
        ),
      );
    }
  }

  bool _noIllegalCharacters(String title, String _notification, String payload) {
    if (title.contains('|') || title.contains(';')) {
      _titleField = 'Device name should not contain | or ;';
      return false;
    } else {
      if (_notification.contains('|') || _notification.contains(';')) {
        _notificationField = 'Notification should not contain | or ;';
        return false;
      } else {
        if (payload.contains('|') || payload.contains(';')) {
          _payloadField = 'Payload should not contain | or ;';
          return false;
        } else {
          if(title.length > 13) {
            _titleField = 'Name should not be longer than 13 characters';
            return false;
          }
        }
      }
    }
    return true;
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
