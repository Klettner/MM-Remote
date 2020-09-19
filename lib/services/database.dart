import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';

import 'package:sqflite/sqflite.dart';
import 'package:mmremotecontrol/models/deviceArguments.dart';
import 'package:mmremotecontrol/models/commandArguments.dart';
import 'package:mmremotecontrol/models/mirrorStateArguments.dart';

class SqLite{
  static Database _db;
  var loggerNoStack = Logger(printer: PrettyPrinter(methodCount: 0));

  Future<Database> get db async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "magicMirror1.db");
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }

  void _onCreate(Database db, int version) async {
    // When creating the db, create the tables
    await db.execute(
        "CREATE TABLE Commands(id INTEGER PRIMARY KEY,deviceName TEXT, commandName TEXT, notification TEXT, payload TEXT)");
    loggerNoStack.i("Created Commands table");
    await db.execute(
        "CREATE TABLE Devices(id INTEGER PRIMARY KEY,deviceName TEXT, ipAddress TEXT, port TEXT)");
    loggerNoStack.i("Created Devices table");
    await db.execute(
        "CREATE TABLE Settings(id INTEGER PRIMARY KEY,deviceName TEXT, brightness TEXT, alertDuration TEXT, monitorStatus TEXT)");
    loggerNoStack.i("Created Settings table");
    await db.execute(
        "CREATE TABLE DefaultCommands(id INTEGER PRIMARY KEY, deviceName TEXT, defaultCommand TEXT)");
    loggerNoStack.i("Created DefaultCommands table");
  }

  void saveDefaultCommand(String deviceName, String defaultCommand) async {
    var dbClient = await db;
    await dbClient.transaction((txn) async {
      return await txn.rawInsert(
          'INSERT INTO DefaultCommands(deviceName, defaultCommand) VALUES(' +
              '\'' +
              deviceName +
              '\'' +
              ',' +
              '\'' +
              defaultCommand +
              '\'' +
              ')');
    });
    loggerNoStack.i('defaultCommand saved');
  }

  void deleteDefaultCommand(String deviceName, String defaultCommand) async {
    var dbClient = await db;
    dbClient.delete('DefaultCommands',
        where: "deviceName = ? AND defaultCommand = ?",
        whereArgs: [deviceName, defaultCommand]);
    loggerNoStack.i("Deleted " + defaultCommand);
  }

  void deleteAllDefaultCommands(String deviceName) async {
    var dbClient = await db;
    dbClient.delete('DefaultCommands',
        where: "deviceName = ?",
        whereArgs: [deviceName]);
    loggerNoStack.i("Deleted all defaultCommands of" + deviceName);
  }

  Future<List<String>> getDefaultCommands(String deviceName) async {
    loggerNoStack.i('getting persistent DefaultCommands');
    var dbClient = await db;
    List<Map> list = await dbClient
        .query('DefaultCommands', where: "deviceName = ?", whereArgs: [deviceName]);
    List<String> defaultCommands = new List();
    for (int i = 0; i < list.length; i++) {
      defaultCommands.add(list[i]["defaultCommand"]);
    }
    return defaultCommands;
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
    loggerNoStack.i('command saved');
  }

  void deleteCommand(String deviceName, String commandName) async {
    var dbClient = await db;
    dbClient.delete('Commands',
        where: "deviceName = ? AND commandName = ?",
        whereArgs: [deviceName, commandName]);
    loggerNoStack.i("Deleted " + commandName);
  }

  Future<List<CommandArguments>> getCommands(String deviceName) async {
    loggerNoStack.i('getting persistent Commands');
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
    loggerNoStack.i("Deleted " + deviceName);
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

  void saveSetting(MirrorStateArguments settingArguments) async {
    loggerNoStack.i('saving settings');
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

  Future updateMonitorStatus(String deviceName, String monitorStatus) async {
    var dbClient = await db;
    await dbClient.transaction((txn) async {
      return await txn.rawUpdate(
          'UPDATE Settings SET monitorStatus = ? WHERE deviceName = ?',
          [
            monitorStatus,
            deviceName,
          ]);
    });
    loggerNoStack.i('Monitor status updated');
  }

  void deleteSettings(String deviceName) async {
    var dbClient = await db;
    dbClient
        .delete('Settings', where: "deviceName = ?", whereArgs: [deviceName]);
    loggerNoStack.i("Deleted Settings of " + deviceName);
  }

  Future<MirrorStateArguments> getSettings(String deviceName) async {
    loggerNoStack.i('getting settings');
    var dbClient = await db;
    List<Map> list = await dbClient
        .query('Settings', where: "deviceName = ?", whereArgs: [deviceName]);
    MirrorStateArguments setting;
    //there should only be one device per Name
    if(list.length >= 1) {
      setting = new MirrorStateArguments(
          list[0]["deviceName"], list[0]["brightness"],
          list[0]["alertDuration"], list[0]["monitorStatus"]);
    }
    return setting;
  }
}
