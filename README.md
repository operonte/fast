# fasT

App Flutter para abrir WhatsApp al instante desde un número de teléfono. Pensada para Chile (código +56 por defecto).

## Qué hace

- **Pantalla principal**: Campo para ingresar un número y botón que abre el enlace oficial de WhatsApp (`https://api.whatsapp.com/send?phone=NUMERO`).
- **Normalización**: Quita `+`, espacios y guiones; si el número no empieza por 56, lo agrega automáticamente.
- **Validación**: Número móvil chileno = 9 dígitos después del 56.
- **Historial y favoritos**: Guarda los últimos números usados y permite marcar favoritos.
- **Onboarding**: Pantallas de bienvenida la primera vez.
- **Ajustes**: Modo oscuro, mensaje inicial opcional, limpiar historial/favoritos, Acerca de, Contacto, Política de privacidad, Términos de uso.

## Cómo ejecutar

```bash
git clone https://github.com/operonte/fast.git
cd fast
flutter pub get
flutter run
```

## Compilar APK

```bash
flutter build apk --release
```

El APK se genera en `build/app/outputs/flutter-apk/app-release.apk`

### Descargar APK

**[Descargar última versión](https://github.com/operonte/fast/releases/latest)**

## Política de privacidad y términos

- [Política de privacidad](https://operonte.github.io/releases/fast/policies/privacy_policy.html)
- [Términos de uso](https://operonte.github.io/releases/fast/policies/terms_of_use.html)

## Dependencias principales

- **url_launcher**: Abrir el enlace de WhatsApp en el navegador o en la app.
- **shared_preferences**: Guardar onboarding, historial, favoritos y preferencias (tema, mensaje opcional).
- **go_router**: Navegación entre pantallas.
- **share_plus**: Compartir el link de WhatsApp.
- **vibration**: Vibración al pulsar el botón.
- **package_info_plus**: Versión en Acerca de.

## Estructura

- `lib/main.dart`: App raíz y tema (claro/oscuro/sistema).
- `lib/app_router.dart`: Rutas (splash, onboarding, home, settings, about, contact, privacy, terms).
- `lib/app_state.dart`: Almacenamiento global y callback de tema.
- `lib/utils/phone_utils.dart`: Normalización y validación de número Chile.
- `lib/services/storage_service.dart`: Historial, favoritos, preferencias.
- `lib/services/whatsapp_service.dart`: Construcción de URL y apertura de WhatsApp.
- `lib/screens/`: Splash, onboarding, home, settings, about, contact, privacy, terms.
- `release/`: APK generados (también en [Releases](https://github.com/operonte/fast/releases)).

## Icono

El icono de la app está en `assets/icon.png`. Se generan los launcher icons para Android e iOS con:

```bash
dart run flutter_launcher_icons
```

## Textos editables

Puedes editar los textos de **Acerca de** en `lib/screens/about_screen.dart`. El contacto (email) está en `lib/screens/contact_screen.dart`.

## Desarrollador

**Cristian Bravo Droguett**  
cristian.bravo.droguett@gmail.com
