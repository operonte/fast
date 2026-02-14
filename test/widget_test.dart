// Smoke test: la app arranca y muestra la pantalla de splash u otra ruta inicial.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fast/app_state.dart';
import 'package:fast/main.dart';
import 'package:fast/services/storage_service.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    appStorage = StorageService(prefs);
  });

  testWidgets('App arranca y muestra fasT', (WidgetTester tester) async {
    await tester.pumpWidget(const FastApp());
    await tester.pump();
    expect(find.text('fasT'), findsWidgets);
  });
}
