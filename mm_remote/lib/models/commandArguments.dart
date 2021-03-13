import 'package:hive/hive.dart';

part 'commandArguments.g.dart';

@HiveType(typeId: 3)
class CommandArguments extends HiveObject {
  @HiveField(0)
  String deviceName;

  @HiveField(1)
  String commandName;

  @HiveField(2)
  String notification;

  @HiveField(3)
  String payload;

  CommandArguments(
      this.deviceName, this.commandName, this.notification, this.payload);

  CommandArguments.fromMap(Map map) {
    deviceName = map[deviceName];
    commandName = map[commandName];
    notification = map[notification];
    payload = map[payload];
  }
}
