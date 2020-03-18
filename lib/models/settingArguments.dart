class SettingArguments {
  String deviceName;
  String brightness;
  String alertDuration;
  String monitorStatus;

  SettingArguments(this.deviceName, this.brightness, this.alertDuration, this.monitorStatus);

  SettingArguments.fromMap(Map map) {
    deviceName = map[deviceName];
    brightness = map[brightness];
    alertDuration = map[alertDuration];
    monitorStatus = map[monitorStatus];
  }
}