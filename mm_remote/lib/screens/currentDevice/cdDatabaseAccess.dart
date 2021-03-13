import 'package:mm_remote/models/commandArguments.dart';
import 'package:mm_remote/models/settingArguments.dart';
import 'package:mm_remote/services/database.dart';

Future<List<String>> fetchDefaultCommandsFromDatabase(String deviceName) async {
  var dbHelper = SqLite();
  Future<List<String>> defaultCommandString =
      dbHelper.getDefaultCommands(deviceName);
  return defaultCommandString;
}

Future<List<CommandArguments>> fetchCommandsFromDatabase(
    String deviceName) async {
  var dbHelper = SqLite();
  Future<List<CommandArguments>> commands = dbHelper.getCommands(deviceName);
  return commands;
}

void persistCommand(String deviceName, String commandName, String notification,
    String payload) {
  var command =
      CommandArguments(deviceName, commandName, notification, payload);
  var dbHelper = SqLite();
  dbHelper.saveCommand(command);
}

void persistDefaultCommands(
    String deviceName, List<DefaultCommand> defaultCommands) {
  // delete already existing defaultCommands for this device
  var dbHelper = SqLite();
  dbHelper.deleteAllDefaultCommands(deviceName);
  for (DefaultCommand defaultCommand in defaultCommands) {
    String defaultCommandString = defaultCommand.toString().split('.').last;
    dbHelper.saveDefaultCommand(deviceName, defaultCommandString);
  }
}

void updateApiKey(String deviceName, String apiKey) {
  var dbHelper = SqLite();
  dbHelper.updateApiKey(deviceName, apiKey);
}
