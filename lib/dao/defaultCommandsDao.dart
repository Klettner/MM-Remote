import 'package:hive/hive.dart';
import 'package:mm_remote/models/settingArguments.dart';

void persistDefaultCommands(
    String deviceName, List<DefaultCommand> defaultCommands) {
  List<String> defaultCommandStrings = <String>[];
  defaultCommands.forEach((defaultCommand) {
    defaultCommandStrings.add(defaultCommand.toString().split('.').last);
  });
  Hive.box('defaultCommands3').delete(deviceName);

  Hive.box('defaultCommands3').put(deviceName, defaultCommandStrings);
}

List<String> getDefaultCommands(String deviceName) {
  return Hive.box('defaultCommands3').get(deviceName);
}
