import 'package:flutter/material.dart';
import 'package:phamijam/client.dart';
import 'package:phamijam/prefs.dart';
import 'package:phamijam/result.dart';

class Session {
  final User user;
  final String token;

  const Session({required this.user, required this.token});
}

class UserController extends ChangeNotifier {
  final Client client;
  final Prefs prefs;
  Session? session;

  List<String> playlistIds = [];
  List<String> playlistName = [];
  List<String> playlistDescription = [];
  List<String?> playlistCoverPaths = [];

  UserController({required this.client, required this.prefs}) {
    _init();
  }

  Future<void> _init() async {
    final token = await prefs.getToken();
    if (token != null) {
      await refreshSessionWithToken(token);
    }
  }

  Future<Result<Null>> register(
    String username,
    String password,
    String email,
  ) async {
    return await client.register(username, password, email);
  }

  Future<Result<Null>> login(String username, String password) async {
    final res = await client.login(username, password);
    switch (res) {
      case Ok(data: final token):
        await prefs.setToken(token);
        return await refreshSessionWithToken(token);
      case Err(message: final message):
        return Err(message);
    }
  }

  Future<Result<Null>> logout() async {
    await prefs.removeToken();
    session = null;
    notifyListeners();
    return Ok(null);
  }

  Future<Result<Null>> createPlaylist(
    String title,
    String description,
    String? coverArt,
  ) async {
    if (session == null) return Err("Not logged in");
    final token = session!.token;
    final res = await client.createPlaylist(
      title,
      description,
      token,
      coverArt: coverArt ?? "",
    );
    if (res is Ok) {
      // refresh playlists from server to get ids and canonical data
      final plRes = await client.getPlaylists(token);
      if (plRes is Ok) {
        final playlists = (plRes as Ok).data as List<Map<String, dynamic>>;
        playlistIds.clear();
        playlistName.clear();
        playlistDescription.clear();
        playlistCoverPaths.clear();
        for (final p in playlists) {
          playlistIds.add(p['id']?.toString() ?? '');
          playlistName.add(p['title']?.toString() ?? '');
          playlistDescription.add(p['description']?.toString() ?? '');
          playlistCoverPaths.add(p['coverArt']?.toString());
        }
        notifyListeners();
      }
      return Ok(null);
    } else if (res is Err) {
      return Err((res as Err).message);
    }
    return Err("Unknown error");
  }

  Future<Result<Null>> deletePlaylist(int index) async {
    if (session == null) return Err("Not logged in");
    if (index < 0 || index >= playlistIds.length) return Err("Invalid index");
    final token = session!.token;
    final id = playlistIds[index];
    final res = await client.deletePlaylist(token, id);
    if (res is Ok) {
      playlistIds.removeAt(index);
      playlistName.removeAt(index);
      playlistDescription.removeAt(index);
      playlistCoverPaths.removeAt(index);
      notifyListeners();
      return Ok(null);
    } else if (res is Err) {
      return Err((res as Err).message);
    }
    return Err("Unknown error");
  }

  Future<Result<Null>> refreshSessionWithToken(String token) async {
    final userRes = await client.getUserInfo(token);
    if (userRes is Err) {
      await prefs.removeToken();
      session = null;
      playlistIds.clear();
      playlistName.clear();
      playlistDescription.clear();
      playlistCoverPaths.clear();
      notifyListeners();
      return Err((userRes as Err).message);
    }

    final user = (userRes as Ok).data as User;
    session = Session(user: user, token: token);
    await prefs.setToken(token);
    notifyListeners();

    final plRes = await client.getPlaylists(token);
    if (plRes is Ok) {
      final playlists = (plRes as Ok).data as List<Map<String, dynamic>>;
      playlistIds.clear();
      playlistName.clear();
      playlistDescription.clear();
      playlistCoverPaths.clear();
      for (final p in playlists) {
        playlistIds.add(p['id']?.toString() ?? '');
        playlistName.add(p['title']?.toString() ?? '');
        playlistDescription.add(p['description']?.toString() ?? '');
        playlistCoverPaths.add(p['coverArt']?.toString());
      }
      notifyListeners();
      return Ok(null);
    } else {
      debugPrint("getPlaylists error: ${(plRes as Err).message}");
      return Ok(null);
    }
  }
}
