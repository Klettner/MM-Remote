class SettingArguments {
  int alertDuration;
  List<DefaultCommand> defaultCommands;

  SettingArguments(this.defaultCommands, this.alertDuration);

  SettingArguments.fromMap(Map map) {
    alertDuration = map[alertDuration];
    defaultCommands = map[defaultCommands];
  }
}

enum DefaultCommand {
  MonitorBrightness,
  PhotoSlideshow,
  StopwatchTimer
}
