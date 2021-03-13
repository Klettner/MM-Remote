import 'package:mm_remote/models/settingArguments.dart';
import 'package:mm_remote/services/database.dart';

Future<List<String>> fetchDefaultCommandsFromDatabase(String deviceName) async {
  var dbHelper = SqLite();
  Future<List<String>> defaultCommandString =
      dbHelper.getDefaultCommands(deviceName);
  return defaultCommandString;
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
