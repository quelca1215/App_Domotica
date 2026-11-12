import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_domotica/main.dart';
import 'package:app_domotica/widgets/immersive_room_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Domotica App smoke test - renderiza pantalla principal y cuarto',
      (WidgetTester tester) async {
    // Configurar tamaño de pantalla estándar de smartphone (e.g. 1080x2400, DPR 3.0 -> 360x800 pt)
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const DomoticaApp());
    await tester.pumpAndSettle();

    // Verificar que aparece el título de la app y el cuarto
    expect(find.text('Domótica ESP32'), findsOneWidget);
    expect(find.text('Dormitorio Principal'), findsOneWidget);

    // Verificar estado inicial del circuito (Abierto / Foco apagado)
    expect(find.text('CIRCUITO ABIERTO'), findsOneWidget);

    // Tocar directamente la vista inmersiva del cuarto
    await tester.tap(find.byType(ImmersiveRoomView));
    await tester.pumpAndSettle();

    // Verificar que el circuito pasa a cerrado
    expect(find.text('CIRCUITO CERRADO'), findsOneWidget);
    expect(find.text('ABRIR RELÉ (APAGAR FOCO)'), findsOneWidget);

    // Tocar nuevamente para apagar
    await tester.tap(find.byType(ImmersiveRoomView));
    await tester.pumpAndSettle();

    expect(find.text('CIRCUITO ABIERTO'), findsOneWidget);
  });
}
