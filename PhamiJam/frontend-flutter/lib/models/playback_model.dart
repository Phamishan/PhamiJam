import 'package:flutter/material.dart';

class PlaybackModel extends ChangeNotifier {
  String artistName = '';
  String songName = '';
  bool isPlaying = false;
  Duration progress = Duration.zero;
  Duration? duration;
  double volume = 20.0;

  void setArtistAndSong(String artist, String song) {
    artistName = artist;
    songName = song;
    notifyListeners();
  }

  void setIsPlaying(bool value) {
    isPlaying = value;
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

  void setVolume(double value) {
    volume = value;
    notifyListeners();
  }
}
