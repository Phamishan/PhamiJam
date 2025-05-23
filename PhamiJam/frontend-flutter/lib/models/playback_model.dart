import 'package:flutter/material.dart';

class PlaybackModel extends ChangeNotifier {
  String artistName = 'Unknown Artist';
  String songName = 'Unknown Song';
  Duration progress = Duration.zero;
  Duration? duration;
  bool isPlaying = false;
  bool isMuted = false;
  double currentSliderValue = 20.0;

  void setArtist(String artist) {
    artistName = artist;
    notifyListeners();
  }

  void setSongName(String name) {
    songName = name;
    notifyListeners();
  }

  void setProgress(Duration value) {
    progress = value;
    notifyListeners();
  }

  void setDuration(Duration? value) {
    duration = value;
    notifyListeners();
  }

  void setIsPlaying(bool value) {
    isPlaying = value;
    notifyListeners();
  }

  void setIsMuted(bool value) {
    isMuted = value;
    notifyListeners();
  }

  void setCurrentSliderValue(double value) {
    currentSliderValue = value;
    notifyListeners();
  }
}
