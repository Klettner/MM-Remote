import 'package:hive/hive.dart';
import 'package:mm_remote/models/commandArguments.dart';

Iterable<dynamic> getAllCommandArguments(String deviceName) {
  return Hive.box('commandArguments').values.where((commandArguments) =>
      commandArguments.deviceName.compareTo('$deviceName') == 0);
}

void persistCommandArguments(String deviceName, String commandName,
    String notification, String payload) {
  var command =
      CommandArguments(deviceName, commandName, notification, payload);
  Hive.box('commandArguments').add(command);
}

void deleteCommandArguments(String deviceName, String commandName) {
  Hive.box('commandArguments')
      .values
      .where((commandArguments) =>
          commandArguments.deviceName.compareTo('$deviceName') == 0)
      .where((commandArguments) =>
          commandArguments.commandName.compareTo('$commandName') == 0)
      .forEach((commandArguments) {
    commandArguments.delete();
  });
}
