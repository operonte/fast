// Smoke test: la app arranca en el splash y navega al onboarding (sin datos previos).

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fast/app_state.dart';
import 'package:fast/main.dart';
import 'package:fast/services/storage_service.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    appStorage = StorageService(prefs);
  });

  testWidgets('Arranca y navega al onboarding al instante', (tester) async {
    await tester.pumpWidget(const FastApp());
    // El splash navega tras el primer frame (sin esperas artificiales).
    await tester.pumpAndSettle();

    // Sin onboarding previo => primera pantalla del tutorial.
    expect(find.text('Abre WhatsApp al instante'), findsOneWidget);
  });
}
