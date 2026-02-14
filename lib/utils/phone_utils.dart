// Utilidades para normalizar y validar números de teléfono en formato Chile (código 56).

const String _chileCountryCode = '56';
/// Longitud esperada del número nacional (9 dígitos para móviles en Chile).
const int chileMobileLength = 9;

/// Normaliza el número para Chile: solo dígitos y prefijo 56 si no está.
/// Ej: "920047008" -> "56920047008", "+56 9 2004 7008" -> "56920047008".
String normalizePhoneForChile(String input) {
  if (input.isEmpty) return '';
  final digits = input.replaceAll(RegExp(r'[^\d]'), '');
  if (digits.isEmpty) return '';
  if (digits.startsWith(_chileCountryCode)) {
    return digits;
  }
  return _chileCountryCode + digits;
}

/// Formato visual para mostrar en UI (ej: "56 9 2004 7008").
String formatPhoneDisplay(String normalized) {
  if (normalized.length <= 2) return normalized;
  final rest = normalized.substring(2);
  final buffer = StringBuffer('56');
  for (int i = 0; i < rest.length; i++) {
    if (i == 1) {
      buffer.write(' ');
    } else if (i > 1 && (i - 1) % 4 == 0) {
      buffer.write(' ');
    }
    buffer.write(rest[i]);
  }
  return buffer.toString();
}

/// Valida número chileno móvil: 56 + 9 dígitos.
PhoneValidationResult validateChileMobile(String normalized) {
  if (normalized.isEmpty) return PhoneValidationResult.empty;
  if (!RegExp(r'^\d+$').hasMatch(normalized)) return PhoneValidationResult.invalid;
  if (!normalized.startsWith(_chileCountryCode)) return PhoneValidationResult.invalid;
  final national = normalized.substring(_chileCountryCode.length);
  if (national.length != chileMobileLength) return PhoneValidationResult.wrongLength;
  return PhoneValidationResult.valid;
}

enum PhoneValidationResult {
  valid,
  empty,
  invalid,
  wrongLength,
}

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
    }
  }
}
