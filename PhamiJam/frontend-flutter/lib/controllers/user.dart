import 'package:flutter/material.dart';
import '../client.dart';
import '../prefs.dart';
import '../result.dart';

class Session {
  final User user;
  final String token;

  const Session({required this.user, required this.token});
}

class UserController extends ChangeNotifier {
  final Client client;
  final Prefs prefs;
  Session? session;

  UserController({required this.client, required this.prefs}) {
    _loadFromPrefs();
  }

  void _loadFromPrefs() async {
    final token = await prefs.getToken();
    if (token == null) {
      return;
    }
    await refreshSessionWithToken(token);
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

  Future<Result<Null>> refreshSessionWithToken(String token) async {
    final res = await client.getUserInfo(token);
    switch (res) {
      case Ok(data: final user):
        await prefs.setToken(token);
        session = Session(user: user, token: token);
        notifyListeners();
        return Ok(null);
      case Err(message: final message):
        await prefs.removeToken();
        session = null;
        notifyListeners();
        return Err(message);
    }
  }
}
