import 'package:hive/hive.dart';

part 'deviceArguments.g.dart';

@HiveType(typeId: 1)
class DeviceArguments {
  @HiveField(0)
  String deviceName;

  @HiveField(1)
  String ip;

  @HiveField(2)
  String apiKey;

  DeviceArguments(this.deviceName, this.ip, this.apiKey);

  DeviceArguments.fromMap(Map map) {
    deviceName = map[deviceName];
    ip = map[ip];
    apiKey = map[apiKey];
  }
}
