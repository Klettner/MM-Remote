import 'package:hive/hive.dart';

part 'mirrorStateArguments.g.dart';

@HiveType(typeId: 2)
class MirrorStateArguments extends HiveObject {
  @HiveField(0)
  String deviceName;

  @HiveField(1)
  String brightness;

  @HiveField(2)
  String alertDuration;

  @HiveField(3)
  String monitorStatus;

  MirrorStateArguments(this.deviceName, this.brightness, this.alertDuration,
      this.monitorStatus);

  MirrorStateArguments.fromMap(Map map) {
    deviceName = map[deviceName];
    brightness = map[brightness];
    alertDuration = map[alertDuration];
    monitorStatus = map[monitorStatus];
  }
}
