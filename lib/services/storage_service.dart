import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Almacenamiento local: onboarding, historial, favoritos, etiquetas y tema.
///
/// Las listas se cachean en memoria al construir el servicio y se mantienen
/// sincronizadas en cada mutación, para no deserializar JSON en cada `build`.
class StorageService {
  static const _keyOnboardingDone = 'onboarding_done';
  static const _keyHistory = 'history';
  static const _keyFavorites = 'favorites';
  static const _keyLabels = 'labels';
  static const _keyThemeMode = 'theme_mode'; // 'system' | 'light' | 'dark'
  static const _keyOptionalMessage = 'optional_message';
  static const _maxHistory = 20;
  static const _maxFavorites = 50;
  static const _maxLabelLength = 40;

  final SharedPreferences _prefs;

  late List<String> _history;
  late List<String> _favorites;
  late Map<String, String> _labels;

  StorageService(this._prefs) {
    _history = _readStringList(_keyHistory);
    _favorites = _readStringList(_keyFavorites);
    _labels = _readStringMap(_keyLabels);
  }

  // --- Onboarding ---

  bool get onboardingDone => _prefs.getBool(_keyOnboardingDone) ?? false;
  Future<void> setOnboardingDone(bool value) =>
      _prefs.setBool(_keyOnboardingDone, value);

  // --- Tema y mensaje opcional ---

  String get themeMode => _prefs.getString(_keyThemeMode) ?? 'system';
  Future<void> setThemeMode(String value) =>
      _prefs.setString(_keyThemeMode, value);

  String get optionalMessage => _prefs.getString(_keyOptionalMessage) ?? '';
  Future<void> setOptionalMessage(String value) =>
      _prefs.setString(_keyOptionalMessage, value);

  // --- Historial ---

  List<String> get history => List.unmodifiable(_history);

  Future<void> addToHistory(String normalizedPhone) async {
    _history.remove(normalizedPhone);
    _history.insert(0, normalizedPhone);
    if (_history.length > _maxHistory) {
      _history = _history.sublist(0, _maxHistory);
    }
    await _persistList(_keyHistory, _history);
  }

  Future<void> removeFromHistory(String normalizedPhone) async {
    if (_history.remove(normalizedPhone)) {
      await _persistList(_keyHistory, _history);
    }
  }

  /// Reinserta un número en el historial en su posición original (para "Deshacer").
  Future<void> restoreHistory(String normalizedPhone, int index) async {
    _history.remove(normalizedPhone);
    _history.insert(index.clamp(0, _history.length), normalizedPhone);
    if (_history.length > _maxHistory) {
      _history = _history.sublist(0, _maxHistory);
    }
    await _persistList(_keyHistory, _history);
  }

  Future<void> clearHistory() async {
    _history = [];
    await _prefs.remove(_keyHistory);
  }

  // --- Favoritos ---

  List<String> get favorites => List.unmodifiable(_favorites);

  bool isFavorite(String normalizedPhone) =>
      _favorites.contains(normalizedPhone);

  Future<void> addFavorite(String normalizedPhone) async {
    if (_favorites.contains(normalizedPhone)) return;
    _favorites.insert(0, normalizedPhone);
    if (_favorites.length > _maxFavorites) {
      _favorites = _favorites.sublist(0, _maxFavorites);
    }
    await _persistList(_keyFavorites, _favorites);
  }

  Future<void> removeFavorite(String normalizedPhone) async {
    if (_favorites.remove(normalizedPhone)) {
      await _persistList(_keyFavorites, _favorites);
    }
  }

  /// Reinserta un favorito en su posición original (para "Deshacer").
  Future<void> restoreFavorite(String normalizedPhone, int index) async {
    _favorites.remove(normalizedPhone);
    _favorites.insert(index.clamp(0, _favorites.length), normalizedPhone);
    if (_favorites.length > _maxFavorites) {
      _favorites = _favorites.sublist(0, _maxFavorites);
    }
    await _persistList(_keyFavorites, _favorites);
  }

  Future<void> clearFavorites() async {
    _favorites = [];
    await _prefs.remove(_keyFavorites);
  }

  // --- Etiquetas (alias por número) ---

  String? labelFor(String normalizedPhone) => _labels[normalizedPhone];

  Future<void> setLabel(String normalizedPhone, String? label) async {
    final trimmed = label?.trim() ?? '';
    if (trimmed.isEmpty) {
      _labels.remove(normalizedPhone);
    } else {
      _labels[normalizedPhone] = trimmed.length > _maxLabelLength
          ? trimmed.substring(0, _maxLabelLength)
          : trimmed;
    }
    await _prefs.setString(_keyLabels, jsonEncode(_labels));
  }

  // --- Helpers de (de)serialización ---

  List<String> _readStringList(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => e.toString()).toList();
    } catch (e) {
      debugPrint('StorageService: lista corrupta en "$key": $e');
      return [];
    }
  }

  Map<String, String> _readStringMap(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return {};
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return map.map((k, v) => MapEntry(k, v.toString()));
    } catch (e) {
      debugPrint('StorageService: mapa corrupto en "$key": $e');
      return {};
    }
  }

  Future<void> _persistList(String key, List<String> list) =>
      _prefs.setString(key, jsonEncode(list));
}
