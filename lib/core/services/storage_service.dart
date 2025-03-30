import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:helpper/data/models/user_model.dart';

class StorageService {
  static const String _keyHasSeenOnboarding = 'has_seen_onboarding';
  static const String _keyUserData = 'user_data';

  // Salvar o estado do onboarding
  Future<void> setOnboardingAsSeen() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasSeenOnboarding, true);
  }

  // Verificar se o usuário já viu o onboarding
  Future<bool> hasSeenOnboarding() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHasSeenOnboarding) ?? false;
  }

  // Salvar dados do usuário
  Future<void> saveUserData(UserModel user) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserData, jsonEncode(user.toMap()));
  }

  // Recuperar dados do usuário
  Future<UserModel?> getUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userData = prefs.getString(_keyUserData);

    if (userData != null) {
      return UserModel.fromMap(jsonDecode(userData));
    }

    return null;
  }

  // Limpar dados do usuário
  Future<void> clearUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserData);
  }
}
