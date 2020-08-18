import 'package:http/http.dart' as http;

class HttpRest {
  String ip;
  String port;

  HttpRest(this.ip, this.port);

  void _sendCustomCommand(String commandName, String notification,
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

  void _sendAlert(String text, int _alertDuration) {
    http.get("http://" +
        ip +
        ":" +
        port +
        "/remote?action=SHOW_ALERT&message=&title=" +
        text +
        "&timer=$_alertDuration&type=alert");
  }

  void _incrementPage() {
    http.get("http://" +
        ip +
        ":" +
        port +
        "/remote?action=NOTIFICATION&notification=PAGE_INCREMENT");
    print("Page Incremented");
  }

  void _decrementPage() {
    http.get("http://" +
        ip +
        ":" +
        port +
        "/remote?action=NOTIFICATION&notification=PAGE_DECREMENT");
    print("Page Decremented");
  }

  void _toggleMonitorOn(bool stateChange) {
    http.get("http://" + ip + ":" + port + "/remote?action=MONITORON");
    print("MonitorOn");
 }

  void _toggleMonitorOff(bool stateChange) {
    http.get("http://" + ip + ":" + port + "/remote?action=MONITOROFF");
    print("MonitorOff");
 }

  void _rebootPi() {
    http.get("http://" + ip + ":" + port + "/remote?action=REBOOT");
    print("Rebooting mirror");
  }

  void _shutdownPi() {
    http.get("http://" + ip + ":" + port + "/remote?action=SHUTDOWN");
    print("Shutting down mirror");
  }

  void _backgroundSlideShowNext() {
    http.get("http://" +
        ip +
        ":" +
        port +
        "/remote?action=NOTIFICATION&notification=BACKGROUNDSLIDESHOW_NEXT");
    print("Next picture");
  }

  void _backgroundSlideShowStop() {
    http.get("http://" +
        ip +
        ":" +
        port +
        "/remote?action=NOTIFICATION&notification=BACKGROUNDSLIDESHOW_STOP");
    print("Stopped SlideShow");
  }

  void _backgroundSlideShowPlay() {
    http.get("http://" +
        ip +
        ":" +
        port +
        "/remote?action=NOTIFICATION&notification=BACKGROUNDSLIDESHOW_PLAY");
    print("Started SlideShow");
  }
}