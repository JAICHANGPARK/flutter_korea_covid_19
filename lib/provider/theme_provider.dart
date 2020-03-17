import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {

  bool isLightTheme;

  ThemeProvider({this.isLightTheme});

  ThemeData get getThemeData => isLightTheme ? lightTheme : darkTheme;

  set setThemeData(bool val) {
    if (val) {
      isLightTheme = true;
    } else {
      isLightTheme = false;
    }
    notifyListeners();
  }
}


final darkTheme = ThemeData.dark();

final lightTheme = ThemeData(primarySwatch: Colors.blue,
    primaryColor: Colors.teal,
    accentColor: Colors.red);