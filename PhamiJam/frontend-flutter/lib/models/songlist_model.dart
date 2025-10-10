import 'package:flutter/material.dart';

class SongListModel extends ChangeNotifier {
  final List<String> _songs = [];

  List<String> get songs => List.unmodifiable(_songs);

  void addSong(String song) {
    if (!_songs.contains(song)) {
      _songs.add(song);
      notifyListeners();
    }
  }

  void setSongs(List<String> songs) {
    _songs.clear();
    _songs.addAll(songs);
    notifyListeners();
  }
}
