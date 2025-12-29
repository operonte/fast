# 📋 Permisos y Configuraciones - Fast

## ✅ Permisos Configurados

### Android

#### Permisos Declarados
- ✅ **INTERNET** (`android.permission.INTERNET`)
  - **Razón**: Necesario para abrir enlaces de WhatsApp (wa.me)
  - **Ubicación**: `android/app/src/main/AndroidManifest.xml`
  - **Nivel de protección**: Normal (no requiere aprobación del usuario)

#### Queries (Android 11+)
- ✅ **PROCESS_TEXT**: Para procesamiento de texto de Flutter
- ✅ **VIEW con https/http**: Para que `url_launcher` pueda abrir URLs
- ✅ **WhatsApp packages**: 
  - `com.whatsapp` (WhatsApp normal)
  - `com.whatsapp.w4b` (WhatsApp Business)

**Ubicación**: `android/app/src/main/AndroidManifest.xml` - Sección `<queries>`

### iOS

#### Info.plist Configuraciones
- ✅ **LSApplicationQueriesSchemes**: 
  - `https` - Para abrir URLs HTTPS
  - `http` - Para abrir URLs HTTP
  - `whatsapp` - Para abrir WhatsApp directamente

**Ubicación**: `ios/Runner/Info.plist`

### Web

- ✅ No requiere permisos especiales
- ✅ Usa APIs estándar del navegador

### Windows / Linux / macOS

- ✅ No requiere permisos especiales
- ✅ Usa APIs estándar del sistema operativo

## 🔒 Privacidad

### Permisos NO solicitados (y por qué)

- ❌ **LOCATION**: No necesario - La app no usa ubicación
- ❌ **CAMERA**: No necesario - La app no usa cámara
- ❌ **MICROPHONE**: No necesario - La app no usa micrófono
- ❌ **CONTACTS**: No necesario - La app no accede a contactos
- ❌ **STORAGE**: No necesario - SharedPreferences usa almacenamiento interno
- ❌ **PHONE**: No necesario - Solo genera URLs, no hace llamadas
- ❌ **SMS**: No necesario - No envía SMS
- ❌ **NOTIFICATIONS**: No necesario - No envía notificaciones

## ✅ Cumplimiento con Políticas

### Google Play Store
- ✅ Permisos mínimos necesarios
- ✅ Sin permisos sensibles innecesarios
- ✅ Queries declaradas correctamente (Android 11+)
- ✅ Política de privacidad disponible

### Apple App Store
- ✅ LSApplicationQueriesSchemes declarado
- ✅ Sin permisos innecesarios
- ✅ Política de privacidad disponible

### Microsoft Store
- ✅ Sin permisos especiales requeridos

## 📝 Notas Técnicas

### Android 11+ (API 30+)
Desde Android 11, Google requiere que las apps declaren explícitamente qué otras apps pueden abrir. Por eso se usan `<queries>` para:
- Abrir URLs (https/http)
- Acceder a WhatsApp si está instalado

### iOS
iOS requiere declarar en `LSApplicationQueriesSchemes` qué esquemas de URL se van a usar para evitar que la app falle al intentar abrirlos.

## ✅ Verificación Final

- [x] Permiso INTERNET declarado
- [x] Queries para Android 11+ configuradas
- [x] LSApplicationQueriesSchemes para iOS configurado
- [x] Sin permisos innecesarios
- [x] Cumple con políticas de privacidad
- [x] Listo para producción

