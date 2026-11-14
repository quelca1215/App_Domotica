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
      'Domotica App test - interfaz minimalista con control tactil en cuarto y 3 modos',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const DomoticaApp());
    await tester.pumpAndSettle();

    // 1. Verificar encabezado limpio y cuarto
    expect(find.text('Casa Inteligente'), findsOneWidget);
    expect(find.text('Dormitorio Principal'), findsOneWidget);
    expect(find.byType(ImmersiveRoomView), findsOneWidget);
    expect(find.byType(OperatingModesCard), findsOneWidget);

    // 2. Modo 1: App activo por defecto
    expect(find.text('FOCO APAGADO'), findsOneWidget);
    expect(find.text('Toca la habitación para alternar el foco'), findsOneWidget);

    // Encender foco tocando directamente la habitación
    await tester.tap(find.byType(ImmersiveRoomView));
    await tester.pumpAndSettle();
    expect(find.text('FOCO ENCENDIDO'), findsOneWidget);

    // 3. Cambiar a Modo 2: Fotocélula
    await tester.tap(find.text('Fotocélula'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Luz:'), findsOneWidget);
    expect(find.text('Umbral: 40%'), findsOneWidget);

    // 4. Cambiar a Modo 3: Manual NA
    await tester.tap(find.text('Manual NA'));
    await tester.pumpAndSettle();
    expect(find.text('INTERRUPTOR ABIERTO (NA)'), findsOneWidget);
    expect(
      find.text('El circuito responde al pulsador físico en la pared'),
      findsOneWidget,
    );

    // Tocar el cuarto en modo manual -> muestra aviso informativo
    await tester.tap(find.byType(ImmersiveRoomView));
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);
  });
}
