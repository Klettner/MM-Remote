import 'package:flutter/material.dart';
import 'package:mm_remote/models/commandArguments.dart';
import 'package:mm_remote/shared/colors.dart';

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
  String _titleField = 'Command-Name ';
  String _notificationField = 'Notification of mirror module';
  String _payloadField = 'Payload (optional)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        iconTheme: IconThemeData(color: secondaryColor),
        brightness: Brightness.light,
        elevation: 10.0,
        titleSpacing: 0.0,
        title: Text(
          'Add Command',
          style: TextStyle(color: secondaryColor),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          children: <Widget>[
            SizedBox(height: 75),
            AccentColorOverride(
              color: accentColor,
              child: TextField(
                style: TextStyle(color: tertiaryColorDark),
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
              color: accentColor,
              child: TextField(
                style: TextStyle(color: tertiaryColorDark),
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
              color: accentColor,
              child: TextField(
                style: TextStyle(color: tertiaryColorDark),
                controller: _payloadController,
                decoration: InputDecoration(
                  labelText: _payloadField,
                ),
              ),
            ),
            ButtonBar(
              children: <Widget>[
                TextButton(
                  child: Text(
                    'CLEAR',
                    style: TextStyle(color: inverseHighlightColor),
                  ),
                  style: TextButton.styleFrom(
                    shape: BeveledRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(7.0)),
                    ),
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
                ElevatedButton(
                  child: Text(
                    'CREATE',
                    style: TextStyle(color: secondaryColor),
                  ),
                  style: ElevatedButton.styleFrom(
                    elevation: 5.0,
                    primary: accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    ),
                  ),
                  onPressed: (_isComposingTitle && _isComposingNotification)
                      ? () => _handleSubmitted(_titleController.text,
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

  void _handleSubmitted(
      String commandName, String notification, String payload) {
    _titleController.clear();
    _notificationController.clear();
    _payloadController.clear();
    setState(() {
      _isComposingTitle = false;
      _isComposingNotification = false;
    });
    if (_checkCommandNameLength(commandName)) {
      Navigator.pop(
        context,
        CommandArguments(
          '',
          commandName.trim(),
          notification.trim(),
          payload.trim(),
        ),
      );
    }
  }

  bool _checkCommandNameLength(String commandName) {
    if (commandName.length > 20) {
      _titleField = 'Name should not be longer than 20 characters';
      return false;
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
