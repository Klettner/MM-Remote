import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class HttpRest {
  String ip;
  String port;
  String _baseUrl;
  Function() _getApiKey;
  Function(String) showSnackbar;

  HttpRest(this.ip, this._getApiKey, this.showSnackbar) {
    _baseUrl = "$ip:8080";
  }

  Map<String, String> _getHeader() {
    return {
      "Authorization": "apiKey " + _getApiKey(),
      HttpHeaders.contentTypeHeader: "application/json"
    };
  }

  void sendCustomCommand(String notification, String payload) {
    // Check if a MMM-Remote-Control API endpoint is used
    if (notification.trim().startsWith("/")) {
      _sendAPICommand(notification, payload);
    } else {
      _sendNotification(notification, payload);
    }
  }

  void _sendNotification(String notification, String payload) {
    // Check if a payload is used
    if (payload.trim().compareTo('') == 0) {
      http.get(Uri.http(_baseUrl, "/api/notification/$notification"),
          headers: _getHeader());
    } else {
      http.get(Uri.http(_baseUrl, "/api/notification/$notification/$payload"),
          headers: _getHeader());
    }
  }

  void _sendAPICommand(String notification, String payload) {
    // If a payload is used for the endpoint we need to send a post request
    if (payload.trim().compareTo('') == 0) {
      http.get(Uri.http(_baseUrl, "/api$notification"), headers: _getHeader());
    } else {
      http.post(Uri.http(_baseUrl, "/api$notification"),
          headers: _getHeader(), body: payload);
    }
  }

  void setBrightness(int value) {
    http.get(Uri.http(_baseUrl, "/api/brightness/$value"),
        headers: _getHeader());
  }

  Future<int> getBrightness() async {
    var response = await http.get(Uri.http(_baseUrl, "/api/brightness"),
        headers: _getHeader());
    var responseInJson = await jsonDecode(response.body);
    return responseInJson['result'] as int;
  }

  void setVolume(int value) {
    sendCustomCommand("VOLUME_SET", "$value");
  }

  void sendAlert(String text, int _alertDuration) {
    var body = {"title": text, "timer": _alertDuration * 1000};
    http.post(Uri.http(_baseUrl, "/api/module/alert/showalert"),
        headers: _getHeader(), body: jsonEncode(body));
  }

  void backgroundSlideShowPlay() {
    sendCustomCommand("BACKGROUNDSLIDESHOW_PLAY", "");
    showSnackbar("Started SlideShow");
  }

  void backgroundSlideShowNext() {
    sendCustomCommand("BACKGROUNDSLIDESHOW_NEXT", "");
    showSnackbar("Next picture");
  }

  void backgroundSlideShowStop() {
    sendCustomCommand("BACKGROUNDSLIDESHOW_PAUSE", "");
    showSnackbar("Stopped SlideShow");
  }

  void rebootPi() {
    http.get(Uri.http(_baseUrl, "/api/reboot"), headers: _getHeader());
  }

  void shutdownPi() {
    http.get(Uri.http(_baseUrl, "/api/shutdown"), headers: _getHeader());
  }

  void stopWatchUnpause() {
    sendCustomCommand("UNPAUSE_STOPWATCH", "");
    showSnackbar("Continued stopwatch");
  }

  void stopWatchStart() {
    sendCustomCommand("START_STOPWATCH", "");
    showSnackbar("Started stopwatch");
  }

  void stopWatchTimerPause(isTimer) {
    sendCustomCommand("PAUSE_STOPWATCHTIMER", "");
    isTimer ? showSnackbar("Paused timer") : showSnackbar("Paused stopwatch");
  }

  void stopWatchTimerInterrupt(bool isTimer) {
    sendCustomCommand("INTERRUPT_STOPWATCHTIMER", "");
    isTimer
        ? showSnackbar("Interrupted timer")
        : showSnackbar("Interrupted stopwatch");
  }

  void timerStart(
    int seconds,
  ) {
    sendCustomCommand("START_TIMER", "$seconds");
    showSnackbar("Started timer");
  }

  void timerUnpause() {
    sendCustomCommand("UNPAUSE_TIMER", "");
    showSnackbar("Continued timer");
  }

  void toggleMonitorOn() {
    http.post(Uri.http(_baseUrl, "/api/monitor/on"), headers: _getHeader());
  }

  void toggleMonitorOff() {
    http.post(Uri.http(_baseUrl, "/api/monitor/off"), headers: _getHeader());
  }

  Future<bool> isMonitorOn() async {
    var result = await http.get(Uri.http(_baseUrl, "/api/monitor"),
        headers: _getHeader());
    return !result.body.contains("off");
  }

  void incrementPage() {
    sendCustomCommand("PAGE_INCREMENT", "");
    showSnackbar('Page Incremented');
  }

  void decrementPage() {
    sendCustomCommand("PAGE_DECREMENT", "");
    showSnackbar('Page Decremented');
  }

  void executeCustomCommand(
    String commandName,
    String notification,
    String payload,
  ) {
    sendCustomCommand(notification, payload);
    showSnackbar(commandName + ' sended');
  }
}
