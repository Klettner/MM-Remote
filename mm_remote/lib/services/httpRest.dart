import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HttpRest {
  String ip;
  String port;
  String _baseUrl;
  Function() _getApiKey;
  Function(String) updateLastRequest;
  Function(String, BuildContext) showSnackbar;

  HttpRest(
      this.ip, this._getApiKey, this.updateLastRequest, this.showSnackbar) {
    _baseUrl = "$ip:8080";
  }

  Map<String, String> _getHeader() {
    return {
      "Authorization": "apiKey " + _getApiKey(),
      HttpHeaders.contentTypeHeader: "application/json"
    };
  }

  void sendCustomCommand(String notification, String payload) {
    if (payload.trim().compareTo('') == 0) {
      http.get(Uri.http(_baseUrl, "/api/notification/$notification"),
          headers: _getHeader());
    } else {
      http.get(Uri.https(_baseUrl, "/api/notification/$notification/$payload"),
          headers: _getHeader());
    }
  }

  void setBrightness(int value, bool message) {
    http.get(Uri.http(_baseUrl, "/api/brightness/$value"),
        headers: _getHeader());
    if (message) {
      updateLastRequest("Brightness changed to $value");
    }
  }

  void sendAlert(String text, int _alertDuration) {
    updateLastRequest("Sending alert");

    var body = {"title": text, "timer": _alertDuration * 1000};
    http.post(Uri.http(_baseUrl, "/api/module/alert/showalert"),
        headers: _getHeader(), body: jsonEncode(body));
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
    http.get(Uri.https(_baseUrl, "/api/reboot"), headers: _getHeader());
    updateLastRequest("Rebooting mirror");
  }

  void shutdownPi() {
    http.get(Uri.https(_baseUrl, "/api/shutdown"), headers: _getHeader());
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
    http.post(Uri.https(_baseUrl, "/api/monitor/on"), headers: _getHeader());
    updateLastRequest("Monitor on");
  }

  void toggleMonitorOff() {
    http.post(Uri.https(_baseUrl, "/api/monitor/off"), headers: _getHeader());
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
