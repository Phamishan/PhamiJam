import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'result.dart';

class User {
  String id;
  String username;
  String email;

  User.fromJson(Map<String, dynamic> obj)
    : id = obj["id"].toString(),
      username = obj["username"],
      email = obj["email"];
}

class Client {
  Future<Result<User>> getUserInfo(String token) async {
    try {
      final res = await http.get(
        Uri.parse("$apiUrl/getUserInfo"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      if (res.statusCode != 200) {
        return Err(res.body);
      }
      final resData = json.decode(res.body);
      if (resData is! Map<String, dynamic> || resData["ok"] != true) {
        final message = resData["message"] ?? "Unknown error occurred";
        return Err(message);
      }
      final userJson = resData["user"];
      if (userJson == null) {
        return Err("No user data returned");
      }
      return Ok(User.fromJson(userJson));
    } catch (e) {
      debugPrint("getUserInfo error: $e");
      return Err("Network error: $e");
    }
  }

  final String apiUrl = "http://localhost:3333";

  Future<Result<String>> login(String username, String password) async {
    try {
      final body = json.encode({"username": username, "password": password});

      debugPrint(body);

      final res = await http.post(
        Uri.parse("$apiUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (res.statusCode != 200) {
        final resData = json.decode(res.body);
        final message =
            (resData is Map<String, dynamic> && resData["message"] != null)
                ? resData["message"]
                : "Unknown error occurred";
        return Err(message);
      }

      final resData = json.decode(res.body);

      if (resData is! Map<String, dynamic>) {
        return Err("Invalid response format");
      }

      final ok = resData["ok"];
      if (ok == true) {
        final token = resData["token"];
        if (token == null) {
          return Err("No token received from server");
        }
        return Ok(token);
      } else {
        final message = resData["message"] ?? "Unknown error occurred";
        return Err(message);
      }
    } catch (e) {
      debugPrint("Login error: $e");
      return Err("Network error: $e");
    }
  }

  Future<Result<Null>> register(
    String username,
    String password,
    String email,
  ) async {
    try {
      final body = json.encode({
        "username": username,
        "password": password,
        "email": email,
      });
      debugPrint(body);
      final res = await http.post(
        Uri.parse("$apiUrl/register"),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (res.statusCode != 200) {
        final resData = json.decode(res.body);
        final message =
            (resData is Map<String, dynamic> && resData["message"] != null)
                ? resData["message"]
                : "Unknown error occurred";
        return Err(message);
      }

      final resData = json.decode(res.body);

      if (resData is! Map<String, dynamic>) {
        return Err("Invalid response format");
      }

      final ok = resData["ok"];
      if (ok == true) {
        return Ok(null);
      } else {
        final message = resData["message"] ?? "Unknown error occurred";
        return Err(message);
      }
    } catch (e) {
      debugPrint("Register error: $e");
      return Err("Network error: $e");
    }
  }

  Future<Result<Null>> createPlaylist(
    String title,
    String description,
    String token, {
    String coverArt = "string",
  }) async {
    try {
      final body = json.encode({
        "title": title,
        "description": description,
        "coverArt": coverArt,
      });

      final res = await http.post(
        Uri.parse("$apiUrl/createPlaylist"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: body,
      );

      if (res.statusCode != 200) {
        final resData = json.decode(res.body);
        final message =
            (resData is Map<String, dynamic> && resData["message"] != null)
                ? resData["message"]
                : "Unknown error occurred";
        return Err(message);
      }
      return Ok(null);
    } catch (e) {
      debugPrint("createPlaylist error: $e");
      return Err("Network error: $e");
    }
  }

  Future<Result<List<Map<String, dynamic>>>> getPlaylists(String token) async {
    try {
      final res = await http.get(
        Uri.parse("$apiUrl/getPlaylists"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      if (res.statusCode != 200) {
        final resData = json.decode(res.body);
        final message =
            (resData is Map<String, dynamic> && resData["message"] != null)
                ? resData["message"]
                : "Unknown error occurred";
        return Err(message);
      }
      final resData = json.decode(res.body);
      if (resData is! Map<String, dynamic> || resData["ok"] != true) {
        final message = resData["message"] ?? "Unknown error occurred";
        return Err(message);
      }
      final playlists =
          (resData["playlists"] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
      return Ok(playlists ?? []);
    } catch (e) {
      debugPrint("getPlaylists error: $e");
      return Err("Network error: $e");
    }
  }

  Future<Result<Null>> deletePlaylist(String token, String id) async {
    try {
      final res = await http.delete(
        Uri.parse("$apiUrl/deletePlaylist/$id"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final contentType = res.headers['content-type'] ?? '';

      // If server returned non-JSON (HTML error page), surface a clear error instead of json.decode crash
      if (!contentType.contains('application/json')) {
        if (res.statusCode == 200) {
          return Ok(null); // allow success even if server omitted JSON
        }
        return Err('Server error ${res.statusCode}: ${res.body}');
      }

      // Safe JSON parse
      final resData = json.decode(res.body);
      if (res.statusCode != 200) {
        final message =
            (resData is Map<String, dynamic> && resData["message"] != null)
                ? resData["message"]
                : "Unknown error occurred";
        return Err(message);
      }

      if (resData is! Map<String, dynamic> || resData["ok"] != true) {
        final message = resData["message"] ?? "Unknown error occurred";
        return Err(message);
      }

      return Ok(null);
    } catch (e) {
      debugPrint("deletePlaylist error: $e");
      return Err("Network error: $e");
    }
  }

  Future<Result<Null>> addSongToPlaylist(
    String token,
    String playlistId,
    String songId,
  ) async {
    try {
      final body = json.encode({"playlistId": playlistId, "songId": songId});

      final res = await http.post(
        Uri.parse("$apiUrl/addSongToPlaylist"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: body,
      );

      if (res.statusCode != 200) {
        // attempt to parse error body if JSON
        try {
          final resData = json.decode(res.body);
          final message =
              (resData is Map<String, dynamic> && resData["message"] != null)
                  ? resData["message"]
                  : "Unknown error occurred";
          return Err(message);
        } catch (_) {
          return Err("Server error ${res.statusCode}: ${res.body}");
        }
      }

      final resData = json.decode(res.body);
      if (resData is! Map<String, dynamic> || resData["ok"] != true) {
        final message = resData["message"] ?? "Unknown error occurred";
        return Err(message);
      }

      return Ok(null);
    } catch (e) {
      debugPrint("addSongToPlaylist error: $e");
      return Err("Network error: $e");
    }
  }
}
