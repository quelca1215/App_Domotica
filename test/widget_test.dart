import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_domotica/main.dart';
import 'package:app_domotica/widgets/immersive_room_view.dart';
import 'package:app_domotica/widgets/ir_sensor_control_card.dart';
import 'package:app_domotica/widgets/dht_sensor_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
      'Domotica App test - cuarto iluminado (Foco 1 touch + Foco 2 IR programable) y DHT11',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const DomoticaApp());
    // ImmersiveRoomView usa una animación de pulso infinita; avanzar frames explícitamente
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // 1. Verificar encabezado y componentes principales
    expect(find.text('DomoHouse ESP32'), findsOneWidget);
    expect(find.byType(ImmersiveRoomView), findsOneWidget);
    expect(find.byType(IrSensorControlCard), findsOneWidget);

    // 2. Verificar estados iniciales en las placas del cuarto
    expect(find.text('Foco 1: OFF'), findsOneWidget);
    expect(find.text('Foco 2 IR: OFF'), findsOneWidget);
    expect(find.text('Toca la pantalla para encender Foco 1'), findsOneWidget);

    // 3. Tocar el cuarto para encender el Foco 1 (Circuito 1)
    await tester.tap(find.byType(ImmersiveRoomView));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Foco 1: ON'), findsOneWidget);
    expect(find.text('Foco 1 Encendido • Toca para apagar'), findsOneWidget);

    // 4. Hacer scroll para interactuar con la tarjeta del Sensor IR y ver DHT11
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -450));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Foco 2 (Sensor Infrarrojo)'), findsOneWidget);

    final textField = find.descendant(
      of: find.byType(IrSensorControlCard),
      matching: find.byType(TextField),
    );
    expect(textField, findsOneWidget);

    await tester.enterText(textField, '45');
    await tester.pump();
    await tester.tap(find.text('Guardar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Configurado para durar 45s al activarse'), findsOneWidget);

    // 5. Scroll adicional si es necesario y verificar tarjeta DHT11
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -350));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(DhtSensorCard), findsOneWidget);
    expect(find.text('Ambiente (Sensor DHT11)'), findsOneWidget);
  });
}
