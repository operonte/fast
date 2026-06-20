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

  testWidgets('Arranca en splash y navega al onboarding', (tester) async {
    await tester.pumpWidget(const FastApp());
    await tester.pump();

    // Splash visible.
    expect(find.text('fasT'), findsWidgets);

    // Deja que el timer del splash dispare y se complete la navegación.
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle();

    // Sin onboarding previo => primera pantalla del tutorial.
    expect(find.text('Abre WhatsApp al instante'), findsOneWidget);
  });
}
