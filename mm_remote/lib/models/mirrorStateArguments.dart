class MirrorStateArguments {
  String deviceName;
  String brightness;
  String alertDuration;
  String monitorStatus;

  MirrorStateArguments(
      this.deviceName, this.brightness, this.alertDuration, this.monitorStatus);

  MirrorStateArguments.fromMap(Map map) {
    deviceName = map[deviceName];
    brightness = map[brightness];
    alertDuration = map[alertDuration];
    monitorStatus = map[monitorStatus];
  }
}
