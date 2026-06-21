import 'package:flutter_test/flutter_test.dart';
import 'package:fast/utils/phone_utils.dart';

void main() {
  group('normalizePhoneForChile', () {
    test('vacío devuelve vacío', () {
      expect(normalizePhoneForChile(''), '');
      expect(normalizePhoneForChile('   '), '');
      expect(normalizePhoneForChile('abc'), '');
    });

    test('número nacional de 9 dígitos antepone 56', () {
      expect(normalizePhoneForChile('920047008'), '56920047008');
    });

    test('quita +, espacios y guiones', () {
      expect(normalizePhoneForChile('+56 9 2004 7008'), '56920047008');
      expect(normalizePhoneForChile('9-2004-7008'), '56920047008');
      expect(normalizePhoneForChile('(9) 2004 7008'), '56920047008');
    });

    test('respeta el código país si ya viene (11 dígitos)', () {
      expect(normalizePhoneForChile('56920047008'), '56920047008');
    });

    test('quita un 0 de marcación nacional al inicio', () {
      expect(normalizePhoneForChile('09 2004 7008'), '56920047008');
    });
  });

  group('validateChileMobile', () {
    test('válido: 56 + 9 dígitos empezando en 9', () {
      expect(validateChileMobile('56920047008'), PhoneValidationResult.valid);
    });

    test('vacío', () {
      expect(validateChileMobile(''), PhoneValidationResult.empty);
    });

    test('no numérico es inválido', () {
      expect(validateChileMobile('56abc'), PhoneValidationResult.invalid);
    });

    test('sin código país es inválido', () {
      expect(validateChileMobile('920047008'), PhoneValidationResult.invalid);
    });

    test('largo incorrecto', () {
      expect(
        validateChileMobile('5692004700'), // 8 dígitos nacionales
        PhoneValidationResult.wrongLength,
      );
    });

    test('no empieza con 9 => no es móvil', () {
      expect(
        validateChileMobile('56220047008'), // fijo de Santiago
        PhoneValidationResult.notMobile,
      );
    });

    test('cada resultado tiene mensaje coherente', () {
      expect(PhoneValidationResult.valid.message, isEmpty);
      expect(PhoneValidationResult.empty.message, isNotEmpty);
      expect(PhoneValidationResult.invalid.message, isNotEmpty);
      expect(PhoneValidationResult.wrongLength.message, isNotEmpty);
      expect(PhoneValidationResult.notMobile.message, isNotEmpty);
    });
  });

  group('formatPhoneDisplay', () {
    test('formatea con espacios legibles', () {
      expect(formatPhoneDisplay('56920047008'), '56 9 2004 7008');
    });

    test('cadenas cortas se devuelven tal cual', () {
      expect(formatPhoneDisplay('56'), '56');
      expect(formatPhoneDisplay('5'), '5');
    });
  });
}
