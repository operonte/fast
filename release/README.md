# Releases de fasT

Los binarios (APK / App Bundle) **no se versionan en el repositorio**.
Se publican como adjuntos en la sección de Releases de GitHub.

**Descargar última versión:** https://github.com/operonte/fast/releases/latest

## Generar los artefactos

```bash
# APK (instalación directa / sideload)
flutter build apk --release
# -> build/app/outputs/flutter-apk/app-release.apk

# App Bundle (para subir a Google Play Console)
flutter build appbundle --release
# -> build/app/outputs/bundle/release/app-release.aab
```

La firma requiere `android/key.properties` y el keystore (ver `android/key.properties.example`).
Ambos se mantienen fuera del control de versiones.
