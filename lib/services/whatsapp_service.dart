import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

const String _baseUrl = 'https://api.whatsapp.com/send';

/// Construye la URL de WhatsApp con el número (solo dígitos) y mensaje opcional.
String buildWhatsAppUrl(String normalizedPhone, {String? text}) {
  final query = <String, String>{'phone': normalizedPhone};
  if (text != null && text.trim().isNotEmpty) {
    query['text'] = text.trim();
  }
  return Uri.parse(_baseUrl).replace(queryParameters: query).toString();
}

/// Intenta abrir WhatsApp (app o web). Devuelve `true` solo si se lanzó algo.
///
/// Prueba primero la app externa y, si falla, el manejador por defecto de la
/// plataforma. Captura cualquier excepción de `url_launcher` para que la UI
/// pueda mostrar un mensaje en vez de romperse.
Future<bool> openWhatsApp(String normalizedPhone, {String? text}) async {
  final uri = Uri.parse(buildWhatsAppUrl(normalizedPhone, text: text));

  try {
    if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      return true;
    }
  } catch (e, st) {
    debugPrint('openWhatsApp externalApplication falló: $e\n$st');
  }

  // Fallback: navegador / manejador por defecto del sistema.
  try {
    return await launchUrl(uri, mode: LaunchMode.platformDefault);
  } catch (e, st) {
    debugPrint('openWhatsApp platformDefault falló: $e\n$st');
    return false;
  }
}
