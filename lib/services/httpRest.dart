import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class HttpRest {
  String ip;
  String port;
  Function(String) updateLastRequest;
  Function(String, BuildContext) showSnackbar;

  HttpRest(this.ip, this.port, this.updateLastRequest, this.showSnackbar);

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

  void setBrightness(int value, bool message) async {
    http.get("http://" +
        ip +
        ":" +
        port +
        "/remote?action=BRIGHTNESS&value=" +
        '$value');
    if(message){
      updateLastRequest("Brightness changed to " + '$value');
    }
  }

  void sendAlert(String text, int _alertDuration) {
    updateLastRequest("Sending alert");
    http.get("http://" +
        ip +
        ":" +
        port +
        "/remote?action=SHOW_ALERT&message=&title=" +
        text +
        "&timer=$_alertDuration&type=alert");
  }

  void backgroundSlideShowPlay() {
    sendCustomCommand("BACKGROUNDSLIDESHOW_PLAY", "");
    updateLastRequest("Started SlideShow");
  }

  void backgroundSlideShowNext() {
    sendCustomCommand("BACKGROUNDSLIDESHOW_NEXT", "");
    updateLastRequest("Next picture");
  }

  void backgroundSlideShowStop() {
    sendCustomCommand("BACKGROUNDSLIDESHOW_STOP", "");
    updateLastRequest("Stopped SlideShow");
  }

  void rebootPi() {
    sendAction("REBOOT");
    updateLastRequest("Rebooting mirror");
  }

  void shutdownPi() {
    sendAction("SHUTDOWN");
    updateLastRequest("Shutting down mirror");
  }

  void stopWatchUnpause() {
    sendCustomCommand("UNPAUSE_STOPWATCH", "");
    updateLastRequest("Continued stop-watch");
  }

  void stopWatchStart() {
    sendCustomCommand("START_STOPWATCH", "");
    updateLastRequest("Started stop-watch");
  }

  void stopWatchTimerPause() {
    sendCustomCommand("PAUSE_STOPWATCHTIMER", "");
    updateLastRequest("Paused Timer/Stop-watch");
  }

  void stopWatchTimerInterrupt() {
    sendCustomCommand("INTERRUPT_STOPWATCHTIMER", "");
    updateLastRequest("Interrupted Timer/Stop-watch");
  }

  void timerStart(int seconds) {
    sendCustomCommand("START_TIMER", "$seconds");
    updateLastRequest("Started timer");
  }

  void timerUnpause() {
    sendCustomCommand("UNPAUSE_TIMER", "");
    updateLastRequest("Continued timer");
  }

  void toggleMonitorOn() {
    sendAction("MONITORON");
    updateLastRequest("Monitor on");
  }

  void toggleMonitorOff() {
    sendAction("MONITOROFF");
    updateLastRequest("Monitor off");
  }

  void incrementPage(BuildContext context) {
    sendCustomCommand("PAGE_INCREMENT", "");
    showSnackbar('Page Incremented', context);
    updateLastRequest("Page Incremented");
  }

  void decrementPage(BuildContext context) {
    sendCustomCommand("PAGE_DECREMENT", "");
    showSnackbar('Page Decremented', context);
    updateLastRequest("Page Decremented");
  }

  void executeCustomCommand(String commandName, String notification,
      String payload, BuildContext context) {
    sendCustomCommand(notification, payload);
    showSnackbar(commandName + ' sended', context);
    updateLastRequest(commandName + " sended");
  }
}