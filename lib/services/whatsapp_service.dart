import 'package:url_launcher/url_launcher.dart';

const String _baseUrl = 'https://api.whatsapp.com/send';

/// Construye la URL de WhatsApp con el número (solo dígitos) y mensaje opcional.
String buildWhatsAppUrl(String normalizedPhone, {String? text}) {
  var url = '$_baseUrl?phone=$normalizedPhone';
  if (text != null && text.trim().isNotEmpty) {
    url += '&text=${Uri.encodeComponent(text.trim())}';
  }
  return url;
}

/// Intenta abrir WhatsApp (app o web). Retorna true si se lanzó algo.
Future<bool> openWhatsApp(String normalizedPhone, {String? text}) async {
  final url = buildWhatsAppUrl(normalizedPhone, text: text);
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
  return launchUrl(uri, mode: LaunchMode.platformDefault);
}
