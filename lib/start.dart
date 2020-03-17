import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mmremotecontrol/app.dart';
import 'home.dart';
import 'addDevice.dart';

class StartPage extends StatefulWidget {
  static const routeName = '/startPage';
  final CardsStorage storage;

  StartPage({Key key, @required this.storage}) : super(key: key);

  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  List<Widget> _widgets = List<Widget>();
  String _cards;

  @override
  void initState() {
    super.initState();
    widget.storage.readCards().then((String value) {
      _cards = value;
      print(_cards);
      List<ScreenArguments> _screenargslist = _divideStorageString(_cards);
      final List<Widget> _widgetsTemp = List<Widget>();

      for (ScreenArguments args in _screenargslist) {
        Card _newCard = _createCards(args.title, args.ip, args.port);
        _widgetsTemp.add(_newCard);
      }

      setState(() {
        _widgets = _widgetsTemp;
      });
    });
  }

  List<ScreenArguments> _divideStorageString(String cards) {
    List<ScreenArguments> _result = List<ScreenArguments>();
    int _l = 0;
    while (_l < cards.length) {
      int _r = cards.indexOf('|', _l);
      String title = cards.substring(_l, _r);
      _l = _r + 1;
      _r = cards.indexOf('|', _l);
      String ip = cards.substring(_l, _r);
      _l = _r + 1;
      _r = cards.indexOf(';', _l);
      String port = cards.substring(_l, _r);
      _l = _r + 1;
      print('title: ' + title);
      print('ip: ' + ip);
      print('port: ' + port);
      print(_l);
      print(_r);
      ScreenArguments arg = new ScreenArguments(title, ip, port);
      _result.add(arg);
    }
    return _result;
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
                    crossAxisCount:  _deviceOrientation == Orientation.portrait ? 1 : 2,
                    padding: EdgeInsets.all(16.0),
                    childAspectRatio: _deviceOrientation == Orientation.portrait ? 8.0 / 3.0 : 8.0 / 4.0,
                    children: _widgets,
                  ),
            ),
            new SizedBox(height: 15.0),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blue,
        notchMargin: 5.0,
        shape: CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            new SizedBox(width: 5.0, height: 50),
               new IconButton(
                icon: Icon(
                  Icons.delete,
                  size: 35.0,
                  color: Colors.white,
                  semanticLabel: 'delete last',
                ),
                tooltip: 'delete last device',
                onPressed: () {
                  _deleteLastCard();
                },
              ),
          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        backgroundColor: Colors.blue,
        child: new Icon(
          Icons.add,
          size: 30.0,
          semanticLabel: 'add Device',
        ),
        tooltip: 'add new device',
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
    ScreenArguments _screenArguments = result;
    _changeCards(
        _screenArguments.title, _screenArguments.ip, _screenArguments.port);
  }

  Future<File> _changeCards(String title, String ip, String port) {
    Card _newCard = _createCards(title, ip, port);
    final List<Widget> _widgetsTemp = List<Widget>();

    _widgetsTemp.addAll(_widgets);
    _widgetsTemp.add(_newCard);

    setState(() {
      _cards = _cards + title + '|' + ip + '|' + port + ';';
      _widgets = _widgetsTemp;
    });
    return widget.storage.writeCards(_cards);
  }

  Future<File> _deleteLastCard() {
    final List<Widget> _widgetsTemp = List<Widget>();
    _widgetsTemp.addAll(_widgets);

    if (_widgetsTemp.isNotEmpty) {
      _widgetsTemp.removeLast();
    }

    setState(() {
      //delete last semicolon
      if (_cards.length > 0) {
        _cards = _cards.substring(0, _cards.length - 1);
        //delete everything after last semicolon (last card)
        if (_cards.contains(';')) {
          _cards = _cards.substring(0, _cards.lastIndexOf(';') + 1);
        }
        //if no semicolon present => there was only on card
        else {
          _cards = '';
        }
      }
      _widgets = _widgetsTemp;
    });
    return widget.storage.writeCards(_cards);
  }

  Card _createCards(String title, String ip, String port) {
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
                          title,
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
                    arguments: ScreenArguments(
                      title,
                      ip,
                      port,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScreenArguments {
  final String title;
  final String ip;
  final String port;

  ScreenArguments(this.title, this.ip, this.port);
}