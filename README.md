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
flutter pub get
flutter run
```

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

## Icono

El icono de la app está en `assets/icon.png`. Se generan los launcher icons para Android con:

```bash
dart run flutter_launcher_icons
```

## Política de privacidad y términos (repo "releases")

La app enlaza la **Política de privacidad** y los **Términos de uso** a tu repositorio **releases** en GitHub. En `lib/app_config.dart` sustituye `YOUR_GITHUB_USERNAME` por tu usuario de GitHub. En el repo **releases** crea la estructura:

- `fast/PRIVACY.md` — texto de la política de privacidad.
- `fast/TERMS.md` — texto de los términos de uso.

Las pantallas "Política de privacidad" y "Términos de uso" abren esas URLs en el navegador.

## Textos editables

Puedes editar los textos de **Acerca de** y **Contacto** en `lib/screens/about_screen.dart` y `lib/screens/contact_screen.dart`.
