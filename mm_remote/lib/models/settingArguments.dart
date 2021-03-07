class SettingArguments {
  int alertDuration;
  String apiKey;
  List<DefaultCommand> defaultCommands;

  SettingArguments(
    this.defaultCommands,
    this.alertDuration,
    this.apiKey,
  );

  SettingArguments.fromMap(Map map) {
    alertDuration = map[alertDuration];
    apiKey = map[apiKey];
    defaultCommands = map[defaultCommands];
  }
}

enum DefaultCommand { MonitorBrightness, PhotoSlideshow, StopwatchTimer }
