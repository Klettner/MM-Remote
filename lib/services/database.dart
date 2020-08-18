import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mmremotecontrol/models/deviceArguments.dart';
import 'package:mmremotecontrol/models/commandArguments.dart';
import 'package:mmremotecontrol/models/settingArguments.dart';

class SqLite{
  static Database _db;

  Future<Database> get db async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "magicMirror.db");
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }

  void _onCreate(Database db, int version) async {
    // When creating the db, create the tables
    await db.execute(
        "CREATE TABLE Commands(id INTEGER PRIMARY KEY,deviceName TEXT, commandName TEXT, notification TEXT, payload TEXT)");
    print("Created Commands table");
    await db.execute(
        "CREATE TABLE Devices(id INTEGER PRIMARY KEY,deviceName TEXT, ipAddress TEXT, port TEXT)");
    print("Created Devices table");
    await db.execute(
        "CREATE TABLE Settings(id INTEGER PRIMARY KEY,deviceName TEXT, brightness TEXT, alertDuration TEXT, monitorStatus TEXT)");
    print("Created Settings table");
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
    print('command Saved');
  }

  void deleteCommand(String deviceName, String commandName) async {
    var dbClient = await db;
    dbClient.delete('Commands',
        where: "deviceName = ? AND commandName = ?",
        whereArgs: [deviceName, commandName]);
    print("Deleted " + commandName);
  }

  Future<List<CommandArguments>> getCommands(String deviceName) async {
    print('getting persistent Commands');
    var dbClient = await db;
    List<Map> list = await dbClient
        .query('Commands', where: "deviceName = ?", whereArgs: [deviceName]);
    List<CommandArguments> commands = new List();
    for (int i = 0; i < list.length; i++) {
      commands.add(new CommandArguments(list[i]["deviceName"],
          list[i]["commandName"], list[i]["notification"], list[i]["payload"]));
    }
    return commands;
  }

  void saveDevice(DeviceArguments deviceArguments) async {
    var dbClient = await db;
    await dbClient.transaction((txn) async {
      return await txn.rawInsert(
          'INSERT INTO Devices(deviceName, ipAddress, port) VALUES(' +
              '\'' +
              deviceArguments.deviceName +
              '\'' +
              ',' +
              '\'' +
              deviceArguments.ip +
              '\'' +
              ',' +
              '\'' +
              deviceArguments.port +
              '\'' +
              ')');
    });
  }

  void deleteDevice(String deviceName) async {
    var dbClient = await db;
    dbClient
        .delete('Devices', where: "deviceName = ?", whereArgs: [deviceName]);
    dbClient
        .delete('Commands', where: "deviceName = ?", whereArgs: [deviceName]);
    dbClient
        .delete('Settings', where: "deviceName = ?", whereArgs: [deviceName]);
    print("Deleted " + deviceName);
  }

  Future<List<DeviceArguments>> getDevices() async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM Devices');
    List<DeviceArguments> devices = new List();
    for (int i = 0; i < list.length; i++) {
      devices.add(new DeviceArguments(
          list[i]["deviceName"], list[i]["ipAddress"], list[i]["port"]));
    }
    return devices;
  }

  void saveSetting(SettingArguments settingArguments) async {
    print('saving settings');
    var dbClient = await db;
    await dbClient.transaction((txn) async {
      return await txn.rawInsert(
          'INSERT INTO Settings(deviceName, brightness, alertDuration, monitorStatus) VALUES(' +
              '\'' +
              settingArguments.deviceName +
              '\'' +
              ',' +
              '\'' +
              settingArguments.brightness +
              '\'' +
              ',' +
              '\'' +
              settingArguments.alertDuration +
              '\'' +
              ',' +
              '\'' +
              settingArguments.monitorStatus +
              '\'' +
              ')');
    });
  }

  void deleteSettings(String deviceName) async {
    var dbClient = await db;
    dbClient
        .delete('Settings', where: "deviceName = ?", whereArgs: [deviceName]);
    print("Deleted Settings of " + deviceName);
  }

  Future<SettingArguments> getSettings(String deviceName) async {
    print('getting settings');
    var dbClient = await db;
    List<Map> list = await dbClient
        .query('Settings', where: "deviceName = ?", whereArgs: [deviceName]);
    SettingArguments setting;
    //there should only be one device per Name
    if(list.length >= 1) {
      setting = new SettingArguments(
          list[0]["deviceName"], list[0]["brightness"],
          list[0]["alertDuration"], list[0]["monitorStatus"]);
    }
    return setting;
  }
}
