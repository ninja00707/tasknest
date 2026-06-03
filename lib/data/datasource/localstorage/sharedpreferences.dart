import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart'; // For debugPrint
import 'dart:convert'; // For jsonEncode and jsonDecode
import 'package:tasknest/presentation/login/Models/auth_responce_model.dart'; // For UserModel

class LocalStorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    if (kDebugMode) {
      debugPrint('LocalStorageService: Token saved: $token');
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (kDebugMode) {
      debugPrint('LocalStorageService: Token retrieved: $token');
    }
    return token;
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    if (kDebugMode) {
      debugPrint('LocalStorageService: Token cleared.');
    }
    await prefs.remove(_userKey); // Clear user data as well
  }

  Future<void> setUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = jsonEncode(user.toJson());
    await prefs.setString(_userKey, userJson);
    if (kDebugMode) {
      debugPrint('LocalStorageService: User saved: $userJson');
    }
  }

  Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (kDebugMode) {
      debugPrint('LocalStorageService: User retrieved: $userJson');
    }
    if (userJson != null) {
      return UserModel.fromJson(jsonDecode(userJson));
    }
    return null;
  }
}
