import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fast/services/storage_service.dart';

Future<StorageService> _newService([Map<String, Object> initial = const {}]) async {
  SharedPreferences.setMockInitialValues(initial);
  final prefs = await SharedPreferences.getInstance();
  return StorageService(prefs);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('historial', () {
    test('agrega al frente y deduplica', () async {
      final s = await _newService();
      await s.addToHistory('56911111111');
      await s.addToHistory('56922222222');
      await s.addToHistory('56911111111'); // duplicado: vuelve al frente
      expect(s.history, ['56911111111', '56922222222']);
    });

    test('elimina un ítem individual', () async {
      final s = await _newService();
      await s.addToHistory('56911111111');
      await s.addToHistory('56922222222');
      await s.removeFromHistory('56911111111');
      expect(s.history, ['56922222222']);
    });

    test('limpia todo', () async {
      final s = await _newService();
      await s.addToHistory('56911111111');
      await s.clearHistory();
      expect(s.history, isEmpty);
    });

    test('el getter es inmutable', () async {
      final s = await _newService();
      await s.addToHistory('56911111111');
      expect(() => s.history.add('x'), throwsUnsupportedError);
    });
  });

  group('favoritos', () {
    test('agrega, consulta y quita', () async {
      final s = await _newService();
      await s.addFavorite('56911111111');
      expect(s.isFavorite('56911111111'), isTrue);
      await s.removeFavorite('56911111111');
      expect(s.isFavorite('56911111111'), isFalse);
    });

    test('no duplica', () async {
      final s = await _newService();
      await s.addFavorite('56911111111');
      await s.addFavorite('56911111111');
      expect(s.favorites.length, 1);
    });
  });

  group('etiquetas', () {
    test('asigna, lee y limpia con vacío', () async {
      final s = await _newService();
      await s.setLabel('56911111111', 'Mamá');
      expect(s.labelFor('56911111111'), 'Mamá');
      await s.setLabel('56911111111', '   ');
      expect(s.labelFor('56911111111'), isNull);
    });

    test('recorta espacios', () async {
      final s = await _newService();
      await s.setLabel('56911111111', '  Pizzería  ');
      expect(s.labelFor('56911111111'), 'Pizzería');
    });
  });

  group('compatibilidad y persistencia', () {
    test('lee historial previo guardado como lista de strings', () async {
      final s = await _newService({'history': '["56911111111","56922222222"]'});
      expect(s.history, ['56911111111', '56922222222']);
    });

    test('datos corruptos no rompen (lista vacía)', () async {
      final s = await _newService({'history': 'no-es-json'});
      expect(s.history, isEmpty);
    });

    test('persiste entre instancias', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final s1 = StorageService(prefs);
      await s1.addFavorite('56911111111');
      await s1.setLabel('56911111111', 'Casa');
      final s2 = StorageService(prefs);
      expect(s2.isFavorite('56911111111'), isTrue);
      expect(s2.labelFor('56911111111'), 'Casa');
    });
  });
}
