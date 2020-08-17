class CommandArguments {
  String deviceName;
  String commandName;
  String notification;
  String payload;

  CommandArguments(this.deviceName, this.commandName, this.notification,this.payload);

  CommandArguments.fromMap(Map map) {
    deviceName = map[deviceName];
    commandName = map[commandName];
    notification = map[notification];
    payload = map[payload];
  }
}