import 'package:hive/hive.dart';
import 'package:mm_remote/models/mirrorStateArguments.dart';

void initializeMirrorStateArguments(String deviceName) {
  final mirrorStateArgumentsBox = Hive.box('mirrorStateArguments');
  var setting = MirrorStateArguments(deviceName, '200', '10', 'ON');

  mirrorStateArgumentsBox.put(deviceName, setting);
}

MirrorStateArguments getMirrorStateArguments(String deviceName) {
  return Hive.box('mirrorStateArguments').get(deviceName);
}

void persistMirrorStateArguments(
    String deviceName, MirrorStateArguments setting) {
  Hive.box('mirrorStateArguments').put(deviceName, setting);
}

void updateMonitorState(String deviceName, String monitorStatus) {
  MirrorStateArguments mirrorStateArguments =
      Hive.box('mirrorStateArguments').get(deviceName);
  mirrorStateArguments.monitorStatus = monitorStatus;
  mirrorStateArguments.save();
}

void updateAlertDurationState(String deviceName, int duration) {
  MirrorStateArguments mirrorStateArguments =
      Hive.box('mirrorStateArguments').get(deviceName);
  mirrorStateArguments.alertDuration = "$duration";
  mirrorStateArguments.save();
}

void updateBrightnessState(String deviceName, int brightnessValue) {
  MirrorStateArguments mirrorStateArguments =
      Hive.box('mirrorStateArguments').get(deviceName);
  mirrorStateArguments.brightness = "$brightnessValue";
  mirrorStateArguments.save();
}
