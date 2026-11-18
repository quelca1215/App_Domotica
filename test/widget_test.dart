import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_domotica/main.dart';
import 'package:app_domotica/widgets/immersive_room_view.dart';
import 'package:app_domotica/widgets/dimmer_control_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
      'Domotica App test - interfaz inmersiva reactiva con dimmer y feedback visual',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const DomoticaApp());
    await tester.pumpAndSettle();

    // 1. Verificar encabezado y componentes principales
    expect(find.text('Casa Inteligente'), findsOneWidget);
    expect(find.text('Dormitorio Principal'), findsOneWidget);
    expect(find.byType(ImmersiveRoomView), findsOneWidget);
    expect(find.byType(DimmerControlCard), findsOneWidget);

    // 2. Indicador visual intuitivo de toque inicial
    expect(find.text('Toca la pantalla para encender la luz'), findsOneWidget);
    expect(find.text('Luz Principal: OFF'), findsOneWidget);

    // 3. Encender foco tocando directamente la habitación
    await tester.tap(find.byType(ImmersiveRoomView));
    await tester.pumpAndSettle();

    // 4. Verificar cambio de estado inmediato a ON
    expect(find.text('Foco Encendido • Toca para apagar'), findsOneWidget);
    expect(find.text('Luz Principal: ON'), findsOneWidget);

    // 5. Verificar control del Dimmer
    expect(find.text('Luz Regulable (Dimmer)'), findsOneWidget);
  });
}
