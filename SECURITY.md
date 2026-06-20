# Política de seguridad

## Versiones soportadas

Se da soporte de seguridad a la última versión publicada en
[Releases](https://github.com/operonte/fast/releases/latest).

## Reportar una vulnerabilidad

Si encuentras un problema de seguridad, **no abras un issue público**.
Escribe en privado a: **cristian.bravo.droguett@gmail.com**.

Incluye, si puedes:

- Descripción del problema y su impacto.
- Pasos para reproducirlo.
- Versión de la app y del dispositivo.

Intentaremos responder dentro de **7 días**.

## Notas sobre datos y privacidad

- fasT **no** envía datos a servidores propios. El historial, favoritos,
  etiquetas y preferencias se guardan **solo en el dispositivo**
  (`SharedPreferences`).
- Las copias de seguridad en la nube y la transferencia entre dispositivos
  están **deshabilitadas** (`android:allowBackup="false"` +
  `data_extraction_rules.xml`) para no exponer a quién contactas.
- La app solo abre WhatsApp y enlaces oficiales por HTTPS; el tráfico en claro
  está bloqueado (`android:usesCleartextTraffic="false"`).

## Firma de los artefactos

Los APK/AAB se firman con un keystore que **no** está en el repositorio.
Verifica siempre que descargas desde la sección oficial de Releases.
