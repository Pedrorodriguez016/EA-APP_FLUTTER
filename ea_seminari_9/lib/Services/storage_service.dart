import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/user.dart';

class StorageService extends GetxService {
  late SharedPreferences _prefs;

  // Inicialización del servicio
  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // --- GUARDAR SESIÓN ---
  Future<void> saveSession(User user) async {

    await _prefs.setString('user_data', jsonEncode(user.toJson()));

    if (user.token != null) {
      await _prefs.setString('auth_token', user.token!);
    }
    if (user.refreshToken != null) {
      await _prefs.setString('refresh_token', user.refreshToken!);
    }
  }

  User? getUser() {
    final userString = _prefs.getString('user_data');
    final token = _prefs.getString('auth_token');
    final refreshToken = _prefs.getString('refresh_token');

    if (userString != null && token != null) {
      Map<String, dynamic> userMap = jsonDecode(userString);

      return User.fromJson({
        ...userMap,
        'token': token,
        'refreshToken': refreshToken,
      });
    }
    return null;
  }


  Future<void> clearSession() async {
    await _prefs.remove('user_data');
    await _prefs.remove('auth_token');
    await _prefs.remove('refresh_token');
  }

  String? get token => _prefs.getString('auth_token');
}