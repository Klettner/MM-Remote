import 'package:flutter/material.dart';

var primaryColor = Colors.blue[400];
var secondaryColor = Colors.white;

var tertiaryColorDark = Colors.black87;
var tertiaryColorMedium = Colors.black45;
var tertiaryColorLight = Colors.black26;

var accentColor = Colors.blue[400];
var highlightColor = Colors.white;
var inverseHighlightColor = Colors.blue[400];
var lineColor = Colors.grey[300];
var backgroundColor = Colors.grey[200];
var secondaryBackgroundColor = Colors.white;
var cardBackgroundColor = Colors.white;

void setDarkMode() {
  primaryColor = Colors.blueGrey[800];
  secondaryColor = Colors.blueGrey[100];

  tertiaryColorDark = Colors.blueGrey[100];
  tertiaryColorMedium = Colors.grey[500];
  tertiaryColorLight = Colors.grey[600];

  accentColor = Colors.blue[400];
  highlightColor = Colors.blue[400];
  inverseHighlightColor = Colors.white;
  lineColor = Colors.blue[400];
  backgroundColor = Colors.blueGrey[900];
  secondaryBackgroundColor = Colors.blueGrey[900];
  cardBackgroundColor = Colors.blueGrey[800];
}

void setLightMode() {
  primaryColor = Colors.blue[400];
  secondaryColor = Colors.white;

  tertiaryColorDark = Colors.black87;
  tertiaryColorMedium = Colors.black45;
  tertiaryColorLight = Colors.black26;

  accentColor = Colors.blue[400];
  highlightColor = Colors.white;
  inverseHighlightColor = Colors.blue[400];
  lineColor = Colors.grey[300];
  backgroundColor = Colors.grey[200];
  secondaryBackgroundColor = Colors.white;
  cardBackgroundColor = Colors.white;
}
