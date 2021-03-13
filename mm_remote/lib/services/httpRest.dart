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
  Function(String, BuildContext) showSnackbar;

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
    if (payload.trim().compareTo('') == 0) {
      http.get(Uri.http(_baseUrl, "/api/notification/$notification"),
          headers: _getHeader());
    } else {
      http.get(Uri.http(_baseUrl, "/api/notification/$notification/$payload"),
          headers: _getHeader());
    }
  }

  void setBrightness(int value, bool message, BuildContext context) {
    http.get(Uri.http(_baseUrl, "/api/brightness/$value"),
        headers: _getHeader());
    if (message) {
      showSnackbar("Brightness changed to $value", context);
    }
  }

  Future<int> getBrightness() async {
    var response = await http.get(Uri.http(_baseUrl, "/api/brightness"),
        headers: _getHeader());
    var responseInJson = await jsonDecode(response.body);
    return responseInJson['result'] as int;
  }

  void sendAlert(String text, int _alertDuration) {
    var body = {"title": text, "timer": _alertDuration * 1000};
    http.post(Uri.http(_baseUrl, "/api/module/alert/showalert"),
        headers: _getHeader(), body: jsonEncode(body));
  }

  void backgroundSlideShowPlay(BuildContext context) {
    sendCustomCommand("BACKGROUNDSLIDESHOW_PLAY", "");
    showSnackbar("Started SlideShow", context);
  }

  void backgroundSlideShowNext(BuildContext context) {
    sendCustomCommand("BACKGROUNDSLIDESHOW_NEXT", "");
    showSnackbar("Next picture", context);
  }

  void backgroundSlideShowStop(BuildContext context) {
    sendCustomCommand("BACKGROUNDSLIDESHOW_STOP", "");
    showSnackbar("Stopped SlideShow", context);
  }

  void rebootPi() {
    http.get(Uri.http(_baseUrl, "/api/reboot"), headers: _getHeader());
  }

  void shutdownPi() {
    http.get(Uri.http(_baseUrl, "/api/shutdown"), headers: _getHeader());
  }

  void stopWatchUnpause(BuildContext context) {
    sendCustomCommand("UNPAUSE_STOPWATCH", "");
    showSnackbar("Continued stop-watch", context);
  }

  void stopWatchStart(BuildContext context) {
    sendCustomCommand("START_STOPWATCH", "");
    showSnackbar("Started stop-watch", context);
  }

  void stopWatchTimerPause(BuildContext context) {
    sendCustomCommand("PAUSE_STOPWATCHTIMER", "");
    showSnackbar("Paused Timer/Stop-watch", context);
  }

  void stopWatchTimerInterrupt(BuildContext context) {
    sendCustomCommand("INTERRUPT_STOPWATCHTIMER", "");
    showSnackbar("Interrupted Timer/Stop-watch", context);
  }

  void timerStart(int seconds, BuildContext context) {
    sendCustomCommand("START_TIMER", "$seconds");
    showSnackbar("Started timer", context);
  }

  void timerUnpause(BuildContext context) {
    sendCustomCommand("UNPAUSE_TIMER", "");
    showSnackbar("Continued timer", context);
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

  void incrementPage(BuildContext context) {
    sendCustomCommand("PAGE_INCREMENT", "");
    showSnackbar('Page Incremented', context);
  }

  void decrementPage(BuildContext context) {
    sendCustomCommand("PAGE_DECREMENT", "");
    showSnackbar('Page Decremented', context);
  }

  void executeCustomCommand(String commandName, String notification,
      String payload, BuildContext context) {
    sendCustomCommand(notification, payload);
    showSnackbar(commandName + ' sended', context);
  }
}
