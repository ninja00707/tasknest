import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasknest/presentation/login/Models/auth_responce_model.dart';

class LocalStorageService {
  static const String tokenKey = 'token';
  static const String userKey = 'user';

  /// SAVE TOKEN
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(tokenKey, token);
  }

  /// GET TOKEN
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(tokenKey);
  }

  /// SAVE USER
  Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();

    final userJson = jsonEncode({
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'role_id': user.roleId,
      'department_id': user.departmentId,
      'company_id': user.companyId,
      'is_active': user.isActive,
    });

    await prefs.setString(userKey, userJson);
  }

  /// GET USER
  Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();

    final userString = prefs.getString(userKey);

    if (userString == null) {
      return null;
    }

    final decoded = jsonDecode(userString);

    return UserModel.fromJson(decoded);
  }

  /// CLEAR STORAGE
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(tokenKey);
    await prefs.remove(userKey);
  }
}
