import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_domotica/main.dart';
import 'package:app_domotica/widgets/immersive_room_view.dart';
import 'package:app_domotica/widgets/operating_modes_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
      'Domotica App test - renderiza cuarto inmersivo y los 3 modos de operacion',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const DomoticaApp());
    await tester.pumpAndSettle();

    // 1. Verificar encabezado y cuarto
    expect(find.text('Casa Inteligente'), findsOneWidget);
    expect(find.text('Dormitorio Principal'), findsOneWidget);
    expect(find.byType(ImmersiveRoomView), findsOneWidget);
    expect(find.byType(OperatingModesCard), findsOneWidget);

    // 2. Verificar Modo 1: Encendido con la app
    expect(find.text('1. Modo Encendido con la App'), findsOneWidget);
    expect(find.text('ENCENDER FOCO'), findsOneWidget);

    // Encender foco con el botón de la app
    await tester.tap(find.text('ENCENDER FOCO'));
    await tester.pumpAndSettle();
    expect(find.text('APAGAR FOCO'), findsOneWidget);

    // 3. Probar cambio a Modo 2: Fotocélula (Inteligente)
    await tester.tap(find.text('Fotocélula'));
    await tester.pumpAndSettle();
    expect(find.text('2. Modo Inteligente (Fotocélula)'), findsOneWidget);
    expect(find.text('Luz Ambiental Detectada:'), findsOneWidget);

    // 4. Probar cambio a Modo 3: Manual con Interruptor NA
    await tester.tap(find.text('Manual NA'));
    await tester.pumpAndSettle();
    expect(find.text('3. Modo Manual (Interruptor NA)'), findsOneWidget);
    expect(find.text('PULSAR / CERRAR INTERRUPTOR NA'), findsOneWidget);

    // Asegurar visibilidad en scroll y pulsar interruptor manual
    await tester.ensureVisible(find.text('PULSAR / CERRAR INTERRUPTOR NA'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('PULSAR / CERRAR INTERRUPTOR NA'));
    await tester.pumpAndSettle();
    expect(find.text('SOLTAR / ABRIR INTERRUPTOR NA'), findsOneWidget);
  });
}
