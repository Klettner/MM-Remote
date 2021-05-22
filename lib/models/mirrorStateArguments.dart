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

  @HiveField(4)
  String volume;

  MirrorStateArguments(this.deviceName, this.brightness, this.alertDuration,
      this.monitorStatus, this.volume);

  MirrorStateArguments.fromMap(Map map) {
    deviceName = map[deviceName];
    brightness = map[brightness];
    alertDuration = map[alertDuration];
    monitorStatus = map[monitorStatus];
    volume = map[volume];
  }
}
