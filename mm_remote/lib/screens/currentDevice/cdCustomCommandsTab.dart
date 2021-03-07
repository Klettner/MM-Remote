import 'package:flutter/material.dart';
import 'package:mm_remote/models/commandArguments.dart';
import 'package:mm_remote/screens/addCommand.dart';
import 'package:mm_remote/screens/currentDevice/cdDatabaseAccess.dart';
import 'package:mm_remote/services/database.dart';
import 'package:mm_remote/services/httpRest.dart';
import 'package:mm_remote/shared/colors.dart';

class CustomCommandsTab extends StatefulWidget {
  final String deviceName;
  final HttpRest _httpRest;

  CustomCommandsTab(this.deviceName, this._httpRest);

  @override
  _CustomCommandsTabState createState() => _CustomCommandsTabState();
}

class _CustomCommandsTabState extends State<CustomCommandsTab> {
  List<Widget> _customCommands = List<Widget>();

  @override
  void initState() {
    super.initState();
    final List<Widget> _customCommandsTemp = List<Widget>();
    fetchCommandsFromDatabase(this.widget.deviceName)
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

  @override
  Widget build(BuildContext context) {
    var _deviceOrientation = MediaQuery.of(context).orientation;
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

  void _deleteCommand(String commandName) {
    var dbHelper = SqLite();
    dbHelper.deleteCommand(widget.deviceName, commandName);

    final List<Widget> _customCommandsTemp = List<Widget>();
    fetchCommandsFromDatabase(widget.deviceName)
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

  Card _createCommandCard(String commandName, String notification,
      String payload, BuildContext context, bool persist) {
    if (persist) {
      persistCommand(widget.deviceName, commandName, notification, payload);
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
                  this.widget._httpRest.executeCustomCommand(
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
}
