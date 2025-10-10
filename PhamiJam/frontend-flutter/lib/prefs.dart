import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecurePrefs implements Prefs {
  static const _tokenKey = 'token';
  final FlutterSecureStorage _storage;

  const SecurePrefs(this._storage);

  static Future<Prefs> loadPrefs() async {
    return SecurePrefs(const FlutterSecureStorage());
  }

  @override
  Future<void> setToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  @override
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  @override
  Future<void> removeToken() async {
    await _storage.delete(key: _tokenKey);
  }
}

abstract class Prefs {
  Future<void> setToken(String token);
  Future<String?> getToken();
  Future<void> removeToken();
}
