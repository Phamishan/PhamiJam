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
}
