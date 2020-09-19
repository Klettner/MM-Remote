import 'package:mmremotecontrol/models/mirrorStateArguments.dart';
import 'package:mmremotecontrol/models/commandArguments.dart';
import 'package:mmremotecontrol/services/database.dart';
import 'package:mmremotecontrol/models/settingArguments.dart';

Future<List<String>> fetchDefaultCommandsFromDatabase(String deviceName) async {
  var dbHelper = SqLite();
  Future<List<String>> defaultCommandString = dbHelper.getDefaultCommands(deviceName);
  return defaultCommandString;
}

Future<List<CommandArguments>> fetchCommandsFromDatabase(
    String deviceName) async {
  var dbHelper = SqLite();
  Future<List<CommandArguments>> commands = dbHelper.getCommands(deviceName);
  return commands;
}

Future<MirrorStateArguments> fetchSettingsFromDatabase(String deviceName) async {
  var dbHelper = SqLite();
  Future<MirrorStateArguments> setting = dbHelper.getSettings(deviceName);
  return setting;
}


void persistDefaultCommands(String deviceName, List<DefaultCommand> defaultCommands) {
  // delete already existing defaultCommands for this device
  var dbHelper = SqLite();
  dbHelper.deleteAllDefaultCommands(deviceName);
  for (DefaultCommand defaultCommand in defaultCommands){
    String defaultCommandString = defaultCommand.toString().split('.').last;
    dbHelper.saveDefaultCommand(deviceName, defaultCommandString);
  }
}

void persistCommand(String deviceName, String commandName, String notification,
    String payload) {
  var command =
  CommandArguments(deviceName, commandName, notification, payload);
  var dbHelper = SqLite();
  dbHelper.saveCommand(command);
}

void persistMirrorStateSettings(String deviceName, MirrorStateArguments setting) {
  var dbHelper = SqLite();
  dbHelper.deleteSettings(deviceName);
  dbHelper.saveSetting(setting);
}

void updateMonitorStatus(String deviceName, String monitorStatus){
  var dbHelper = SqLite();
  dbHelper.updateMonitorStatus(deviceName, monitorStatus);
}

