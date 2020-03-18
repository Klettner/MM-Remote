class CommandArguments {
  String title;
  String notification;
  String payload;

  CommandArguments(this.title, this.notification,this.payload);

  CommandArguments.fromMap(Map map) {
    title = map[title];
    notification = map[notification];
    payload = map[payload];
  }
}