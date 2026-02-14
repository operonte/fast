import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Almacenamiento local: onboarding, historial, favoritos y preferencias de tema.
class StorageService {
  static const _keyOnboardingDone = 'onboarding_done';
  static const _keyHistory = 'history';
  static const _keyFavorites = 'favorites';
  static const _keyThemeMode = 'theme_mode'; // 'system' | 'light' | 'dark'
  static const _keyOptionalMessage = 'optional_message';
  static const _maxHistory = 20;
  static const _maxFavorites = 50;

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  bool get onboardingDone => _prefs.getBool(_keyOnboardingDone) ?? false;
  Future<void> setOnboardingDone(bool value) => _prefs.setBool(_keyOnboardingDone, value);

  String get themeMode => _prefs.getString(_keyThemeMode) ?? 'system';
  Future<void> setThemeMode(String value) => _prefs.setString(_keyThemeMode, value);

  String get optionalMessage => _prefs.getString(_keyOptionalMessage) ?? '';
  Future<void> setOptionalMessage(String value) => _prefs.setString(_keyOptionalMessage, value);

  List<String> get history {
    final raw = _prefs.getString(_keyHistory);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => e as String).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> addToHistory(String normalizedPhone) async {
    var list = history;
    list.remove(normalizedPhone);
    list.insert(0, normalizedPhone);
    if (list.length > _maxHistory) list = list.sublist(0, _maxHistory);
    await _prefs.setString(_keyHistory, jsonEncode(list));
  }

  Future<void> clearHistory() => _prefs.remove(_keyHistory);

  List<String> get favorites {
    final raw = _prefs.getString(_keyFavorites);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => e as String).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> addFavorite(String normalizedPhone) async {
    var list = favorites;
    if (list.contains(normalizedPhone)) return;
    list.insert(0, normalizedPhone);
    if (list.length > _maxFavorites) list = list.sublist(0, _maxFavorites);
    await _prefs.setString(_keyFavorites, jsonEncode(list));
  }

  Future<void> removeFavorite(String normalizedPhone) async {
    var list = favorites;
    list.remove(normalizedPhone);
    await _prefs.setString(_keyFavorites, jsonEncode(list));
  }

  Future<void> clearFavorites() => _prefs.remove(_keyFavorites);

  bool isFavorite(String normalizedPhone) => favorites.contains(normalizedPhone);
}
