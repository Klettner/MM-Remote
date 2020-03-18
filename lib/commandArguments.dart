class CommandArguments {
  String commandName;
  String notification;
  String payload;

  CommandArguments(this.commandName, this.notification,this.payload);

  CommandArguments.fromMap(Map map) {
    commandName = map[commandName];
    notification = map[notification];
    payload = map[payload];
  }
}