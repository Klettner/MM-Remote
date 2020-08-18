import 'package:http/http.dart' as http;

class HttpRest {
  String ip;
  String port;

  HttpRest(this.ip, this.port);

  void sendCustomCommand(String commandName, String notification,
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

  void incrementPage() {
    http.get("http://" +
        ip +
        ":" +
        port +
        "/remote?action=NOTIFICATION&notification=PAGE_INCREMENT");
  }

  void decrementPage() {
    http.get("http://" +
        ip +
        ":" +
        port +
        "/remote?action=NOTIFICATION&notification=PAGE_DECREMENT");
  }

  void toggleMonitorOn() {
    http.get("http://" + ip + ":" + port + "/remote?action=MONITORON");
 }

  void toggleMonitorOff() {
    http.get("http://" + ip + ":" + port + "/remote?action=MONITOROFF");
 }

  void rebootPi() {
    http.get("http://" + ip + ":" + port + "/remote?action=REBOOT");
  }

  void shutdownPi() {
    http.get("http://" + ip + ":" + port + "/remote?action=SHUTDOWN");
  }

  void backgroundSlideShowNext() {
    http.get("http://" +
        ip +
        ":" +
        port +
        "/remote?action=NOTIFICATION&notification=BACKGROUNDSLIDESHOW_NEXT");
  }

  void backgroundSlideShowStop() {
    http.get("http://" +
        ip +
        ":" +
        port +
        "/remote?action=NOTIFICATION&notification=BACKGROUNDSLIDESHOW_STOP");
  }

  void backgroundSlideShowPlay() {
    http.get("http://" +
        ip +
        ":" +
        port +
        "/remote?action=NOTIFICATION&notification=BACKGROUNDSLIDESHOW_PLAY");
  }
}