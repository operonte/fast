import 'package:flutter/material.dart';
import 'app_state.dart';
import 'app_router.dart';
import 'services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  appStorage = StorageService(prefs);
  runApp(const FastApp());
}

class FastApp extends StatefulWidget {
  const FastApp({super.key});

  @override
  State<FastApp> createState() => _FastAppState();
}

class _FastAppState extends State<FastApp> {
  @override
  void initState() {
    super.initState();
    onThemeChanged = setState;
  }

  @override
  void dispose() {
    onThemeChanged = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = _themeModeFrom(appStorage.themeMode);
    return MaterialApp.router(
      title: 'fasT',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF25D366),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF25D366),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: themeMode,
      routerConfig: createAppRouter(),
    );
  }

  ThemeMode _themeModeFrom(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
