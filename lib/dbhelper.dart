import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mmremotecontrol/commandArguments.dart';

class DBHelper {
  static Database _db;

  Future<Database> get db async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "mirror2.db");
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }

  void _onCreate(Database db, int version) async {
    // When creating the db, create the table
    await db.execute(
        "CREATE TABLE Commands(id INTEGER PRIMARY KEY,deviceName TEXT, commandName TEXT, notification TEXT, payload TEXT)");
    print("Created tables");
  }

  void saveCommand(CommandArguments customCommand) async {
    var dbClient = await db;
    await dbClient.transaction((txn) async {
      return await txn.rawInsert(
          'INSERT INTO Commands(deviceName, commandName, notification, payload) VALUES(' +
              '\'' +
              customCommand.deviceName +
              '\'' +
              ',' +
              '\'' +
              customCommand.commandName +
              '\'' +
              ',' +
              '\'' +
              customCommand.notification +
              '\'' +
              ',' +
              '\'' +
              customCommand.payload +
              '\'' +
              ')');
    });
  }

  void deleteCommand(String deviceName, String commandName) async{
    //TODO: mind deviceName
    var dbClient = await db;
    dbClient.delete('Commands', where: "deviceName = ? AND commandName = ?", whereArgs: [deviceName, commandName]);
    print("Deleted " + commandName);
  }

  Future<List<CommandArguments>> getCommands(String deviceName) async {
    var dbClient = await db;
    List<Map> list = await dbClient.query('Commands', where: "deviceName = ?", whereArgs: [deviceName]);
    List<CommandArguments> commands = new List();
    for (int i = 0; i < list.length; i++) {
      commands.add(new CommandArguments(list[i]["deviceName"], list[i]["commandName"], list[i]["notification"], list[i]["payload"]));
    }
    print(commands.length);
    return commands;
  }
}