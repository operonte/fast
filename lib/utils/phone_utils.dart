// Utilidades para normalizar y validar números de teléfono en formato Chile (código 56).

const String _chileCountryCode = '56';

/// Longitud esperada del número nacional (9 dígitos para móviles en Chile).
const int chileMobileLength = 9;

/// Total de dígitos de un móvil chileno normalizado: 56 + 9 = 11.
const int _chileMobileTotalLength = 11;

/// Normaliza el número para Chile: solo dígitos y prefijo 56 si corresponde.
///
/// Reglas:
/// - Elimina `+`, espacios, guiones y cualquier carácter no numérico.
/// - Quita un `0` de marcación nacional al inicio (ej. "09 ..." -> "9 ...").
/// - Si ya viene con el código país (11 dígitos empezando en 56), lo respeta.
/// - En otro caso antepone el código país 56.
///
/// Ejemplos:
///   "920047008"        -> "56920047008"
///   "+56 9 2004 7008"  -> "56920047008"
///   "09 2004 7008"     -> "56920047008"
String normalizePhoneForChile(String input) {
  if (input.isEmpty) return '';
  var digits = input.replaceAll(RegExp(r'[^\d]'), '');
  if (digits.isEmpty) return '';

  // Marcación nacional con 0 inicial (poco común, pero la gente lo escribe).
  if (digits.length == chileMobileLength + 1 && digits.startsWith('0')) {
    digits = digits.substring(1);
  }

  // Ya trae el código país (56 + 9 dígitos): respetarlo tal cual.
  if (digits.startsWith(_chileCountryCode) &&
      digits.length == _chileMobileTotalLength) {
    return digits;
  }

  // Número nacional (9 dígitos): anteponer código país.
  if (digits.length == chileMobileLength) {
    return _chileCountryCode + digits;
  }

  // Cualquier otro caso: si ya empieza por 56 lo dejamos, si no lo anteponemos.
  // La validación posterior decidirá si es un número válido.
  if (digits.startsWith(_chileCountryCode)) return digits;
  return _chileCountryCode + digits;
}

/// Formato visual para mostrar en UI (ej: "56 9 2004 7008").
String formatPhoneDisplay(String normalized) {
  if (normalized.length <= 2) return normalized;
  final cc = normalized.substring(0, 2);
  final rest = normalized.substring(2);
  if (rest.isEmpty) return cc;

  // Primer dígito aparte (el 9 de los móviles) y el resto en grupos de 4.
  final first = rest.substring(0, 1);
  final tail = rest.substring(1);
  final groups = <String>[];
  for (int i = 0; i < tail.length; i += 4) {
    final end = (i + 4) > tail.length ? tail.length : i + 4;
    groups.add(tail.substring(i, end));
  }
  return [cc, first, ...groups].where((p) => p.isNotEmpty).join(' ');
}

/// Valida número chileno móvil: 56 + 9 dígitos que empiezan en 9.
PhoneValidationResult validateChileMobile(String normalized) {
  if (normalized.isEmpty) return PhoneValidationResult.empty;
  if (!RegExp(r'^\d+$').hasMatch(normalized)) {
    return PhoneValidationResult.invalid;
  }
  if (!normalized.startsWith(_chileCountryCode)) {
    return PhoneValidationResult.invalid;
  }
  final national = normalized.substring(_chileCountryCode.length);
  if (national.length != chileMobileLength) {
    return PhoneValidationResult.wrongLength;
  }
  // Los móviles chilenos siempre empiezan con 9.
  if (!national.startsWith('9')) {
    return PhoneValidationResult.notMobile;
  }
  return PhoneValidationResult.valid;
}

enum PhoneValidationResult { valid, empty, invalid, wrongLength, notMobile }

extension PhoneValidationResultMessage on PhoneValidationResult {
  String get message {
    switch (this) {
      case PhoneValidationResult.valid:
        return '';
      case PhoneValidationResult.empty:
        return 'Ingresa un número de teléfono';
      case PhoneValidationResult.invalid:
        return 'Número no válido';
      case PhoneValidationResult.wrongLength:
        return 'El número debe tener 9 dígitos después del 56';
      case PhoneValidationResult.notMobile:
        return 'Los móviles chilenos empiezan con 9';
    }
  }
}
