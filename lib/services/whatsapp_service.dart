import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

const String _baseUrl = 'https://api.whatsapp.com/send';
const String _waMeBase = 'https://wa.me';
const String _whatsappPackage = 'com.whatsapp';

/// Construye la URL de WhatsApp con el número (solo dígitos) y mensaje opcional.
String buildWhatsAppUrl(String normalizedPhone, {String? text}) {
  final query = <String, String>{'phone': normalizedPhone};
  if (text != null && text.trim().isNotEmpty) {
    query['text'] = text.trim();
  }
  return Uri.parse(_baseUrl).replace(queryParameters: query).toString();
}

/// Enlace corto `wa.me`, ideal para abrir en el navegador o compartir.
String buildWaMeUrl(String normalizedPhone, {String? text}) {
  final uri = Uri.parse('$_waMeBase/$normalizedPhone');
  if (text != null && text.trim().isNotEmpty) {
    return uri.replace(queryParameters: {'text': text.trim()}).toString();
  }
  return uri.toString();
}

/// Lanza una URI probando primero la app externa y luego el manejador por
/// defecto del sistema. Captura cualquier excepción y devuelve `true` solo si
/// se abrió algo.
Future<bool> _launch(Uri uri) async {
  try {
    if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      return true;
    }
  } catch (e, st) {
    debugPrint('launch externalApplication falló ($uri): $e\n$st');
  }
  try {
    return await launchUrl(uri, mode: LaunchMode.platformDefault);
  } catch (e, st) {
    debugPrint('launch platformDefault falló ($uri): $e\n$st');
    return false;
  }
}

/// Intenta abrir WhatsApp (app o web). Devuelve `true` solo si se lanzó algo.
Future<bool> openWhatsApp(String normalizedPhone, {String? text}) {
  return _launch(Uri.parse(buildWhatsAppUrl(normalizedPhone, text: text)));
}

/// Abre la conversación en el navegador usando el enlace corto `wa.me`.
/// Útil como alternativa cuando WhatsApp no está instalado.
Future<bool> openWhatsAppInBrowser(String normalizedPhone, {String? text}) {
  return _launch(Uri.parse(buildWaMeUrl(normalizedPhone, text: text)));
}

/// Abre la ficha de WhatsApp en la tienda para instalarlo.
Future<bool> openWhatsAppStorePage() async {
  // Primero la app de Play Store (market://), luego la web como respaldo.
  final market = Uri.parse('market://details?id=$_whatsappPackage');
  try {
    if (await launchUrl(market, mode: LaunchMode.externalApplication)) {
      return true;
    }
  } catch (e) {
    debugPrint('No se pudo abrir Play Store (market://): $e');
  }
  return _launch(
    Uri.parse(
      'https://play.google.com/store/apps/details?id=$_whatsappPackage',
    ),
  );
}
