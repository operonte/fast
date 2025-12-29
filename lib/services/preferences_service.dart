import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _keyCountryCode = 'country_code';
  static const String _keyDefaultMessage = 'default_message';
  static const String _keyRecentNumbers = 'recent_numbers';
  static const String _keyMaxRecentNumbers = 'max_recent_numbers';
  static const String _keyAutoAddCountryCode = 'auto_add_country_code';
  static const String _keyThemeColor = 'theme_color';
  static const String _keySelectedCountry = 'selected_country'; // 'chile' o 'otros'
  static const String _keySelectedTheme = 'selected_theme'; // 'rosa', 'verde', 'celeste', 'sistema', 'oscuro'

  static Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  // Código de país
  static Future<String> getCountryCode() async {
    final prefs = await _prefs;
    return prefs.getString(_keyCountryCode) ?? '+56';
  }

  static Future<void> setCountryCode(String code) async {
    final prefs = await _prefs;
    await prefs.setString(_keyCountryCode, code);
  }

  // Mensaje predefinido
  static Future<String> getDefaultMessage() async {
    final prefs = await _prefs;
    return prefs.getString(_keyDefaultMessage) ?? '';
  }

  static Future<void> setDefaultMessage(String message) async {
    final prefs = await _prefs;
    await prefs.setString(_keyDefaultMessage, message);
  }

  // Números recientes
  static Future<List<String>> getRecentNumbers() async {
    final prefs = await _prefs;
    final numbersJson = prefs.getStringList(_keyRecentNumbers) ?? [];
    return numbersJson;
  }

  static Future<void> addRecentNumber(String number) async {
    final prefs = await _prefs;
    List<String> numbers = await getRecentNumbers();
    
    // Remover si ya existe
    numbers.remove(number);
    
    // Agregar al inicio
    numbers.insert(0, number);
    
    // Limitar cantidad
    final maxNumbers = await getMaxRecentNumbers();
    if (numbers.length > maxNumbers) {
      numbers = numbers.sublist(0, maxNumbers);
    }
    
    await prefs.setStringList(_keyRecentNumbers, numbers);
  }

  static Future<void> clearRecentNumbers() async {
    final prefs = await _prefs;
    await prefs.remove(_keyRecentNumbers);
  }

  static Future<void> removeRecentNumber(String number) async {
    final prefs = await _prefs;
    List<String> numbers = await getRecentNumbers();
    numbers.remove(number);
    await prefs.setStringList(_keyRecentNumbers, numbers);
  }

  // Máximo de números recientes
  static Future<int> getMaxRecentNumbers() async {
    final prefs = await _prefs;
    return prefs.getInt(_keyMaxRecentNumbers) ?? 10;
  }

  static Future<void> setMaxRecentNumbers(int max) async {
    final prefs = await _prefs;
    await prefs.setInt(_keyMaxRecentNumbers, max);
  }

  // Auto agregar código de país
  static Future<bool> getAutoAddCountryCode() async {
    final prefs = await _prefs;
    return prefs.getBool(_keyAutoAddCountryCode) ?? true;
  }

  static Future<void> setAutoAddCountryCode(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_keyAutoAddCountryCode, value);
  }

  // Color del tema
  static Future<int> getThemeColor() async {
    final prefs = await _prefs;
    return prefs.getInt(_keyThemeColor) ?? 0xFF9C27B0; // Morado por defecto
  }

  static Future<void> setThemeColor(int color) async {
    final prefs = await _prefs;
    await prefs.setInt(_keyThemeColor, color);
  }

  // País seleccionado (Chile u Otros)
  static Future<String> getSelectedCountry() async {
    final prefs = await _prefs;
    return prefs.getString(_keySelectedCountry) ?? 'chile';
  }

  static Future<void> setSelectedCountry(String country) async {
    final prefs = await _prefs;
    await prefs.setString(_keySelectedCountry, country);
  }

  // Tema seleccionado (rosa, verde, celeste, sistema, oscuro)
  static Future<String> getSelectedTheme() async {
    final prefs = await _prefs;
    return prefs.getString(_keySelectedTheme) ?? 'sistema';
  }

  static Future<void> setSelectedTheme(String theme) async {
    final prefs = await _prefs;
    await prefs.setString(_keySelectedTheme, theme);
  }
}

