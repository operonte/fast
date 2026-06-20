import 'services/storage_service.dart';

/// Acceso global al almacenamiento (inicializado en main tras SharedPreferences).
late StorageService appStorage;

/// Llamar tras cambiar tema en ajustes para reconstruir la app (registrado en FastApp).
void Function(void Function())? onThemeChanged;
