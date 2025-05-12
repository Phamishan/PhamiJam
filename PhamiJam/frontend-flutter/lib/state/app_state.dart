import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  double _volume = 20.0;
  Duration _progress = Duration(seconds: 1);

  double get volume => _volume;
  Duration get progress => _progress;

  void setVolume(double value) {
    _volume = value;
    notifyListeners();
  }

  void setProgress(Duration value) {
    _progress = value;
    notifyListeners();
  }
}
