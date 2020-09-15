import 'package:http/http.dart' as http;

class HttpRest {
  String ip;
  String port;

  HttpRest(this.ip, this.port);

  void sendCustomCommand(String notification,
      String payload) {
    if (payload.trim().compareTo('') == 0) {
      http.get("http://" +
          ip +
          ":" +
          port +
          "/remote?action=NOTIFICATION&notification=" +
          notification);
    } else {
      http.get("http://" +
          ip +
          ":" +
          port +
          "/remote?action=NOTIFICATION&notification=" +
          notification +
          "&payload=" +
          payload);
    }
  }

  void sendAction(String action) {
    http.get("http://" + ip + ":" + port + "/remote?action=" + action);
  }

  void setBrightnes(int value){
    http.get("http://" +
        ip +
        ":" +
        port +
        "/remote?action=BRIGHTNESS&value=" +
        '$value');
  }

  void sendAlert(String text, int _alertDuration) {
    http.get("http://" +
        ip +
        ":" +
        port +
        "/remote?action=SHOW_ALERT&message=&title=" +
        text +
        "&timer=$_alertDuration&type=alert");
  }
}