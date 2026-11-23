import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/home_automation_provider.dart';
import '../widgets/dht_sensor_card.dart';
import '../widgets/immersive_room_view.dart';
import '../widgets/ir_sensor_control_card.dart';
import '../widgets/settings_sheet.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openSettings(BuildContext context) {
    final provider = context.read<HomeAutomationProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SettingsSheet(
        currentConfig: provider.config,
        eventLogs: provider.eventLogs,
        onSave: (newConfig) {
          provider.updateConfig(newConfig);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeAutomationProvider>(
      builder: (context, provider, child) {
        final isFoco1On = provider.foco1Encendido;
        final isFoco2On = provider.foco2Encendido;
        final telemetry = provider.telemetry;

        return Scaffold(
          backgroundColor: const Color(0xFF0A0F1D),
          body: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light,
            child: SafeArea(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Barra Superior con Estado del ESP32
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF131B2E),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.08),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.home_rounded,
                                    color: Color(0xFF38BDF8),
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'DomoHouse ESP32',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            width: 7,
                                            height: 7,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: provider.config.useSimulation
                                                  ? const Color(0xFF818CF8)
                                                  : (provider.isESP32Available
                                                      ? const Color(0xFF10B981)
                                                      : const Color(0xFFFBBF24)),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Flexible(
                                            child: Text(
                                              provider.config.useSimulation
                                                  ? 'Modo Demo (Simulación)'
                                                  : (provider.isESP32Available
                                                      ? 'Conectado a ${provider.config.apSsid}'
                                                      : 'Conectando a ${provider.config.ipAddress}...'),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white.withValues(alpha: 0.7),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Botón Ajustes
                          IconButton(
                            onPressed: () => _openSettings(context),
                            tooltip: 'Configuración ESP32',
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0xFF131B2E),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.08),
                                ),
                              ),
                            ),
                            icon: const Icon(
                              Icons.tune_rounded,
                              color: Colors.white70,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 1. Interfaz Inmersiva del Cuarto (Foco 1: Touch/App + Foco 2: Lámpara IR)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      child: ImmersiveRoomView(
                        isLightOn: isFoco1On,
                        isIrLightOn: isFoco2On,
                        irRemainingSeconds: provider.foco2RemainingSeconds,
                        onToggle: () {
                          HapticFeedback.mediumImpact();
                          provider.toggleFoco1();
                        },
                      ),
                    ),
                  ),

                  // 2. Tarjeta Foco 2 (Relé 2: Sensor Infrarrojo + Configuración de Tiempo)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      child: IrSensorControlCard(
                        isFoco2On: isFoco2On,
                        currentSeconds: provider.tiempoEncendidoSeg,
                        remainingSeconds: provider.foco2RemainingSeconds,
                        onSaveSeconds: (seg) => provider.setTiempoIR(seg),
                        onSimulateTrigger: provider.config.useSimulation
                            ? () => provider.simulateTriggerIR()
                            : null,
                      ),
                    ),
                  ),

                  // 3. Tarjeta Ambiente (DHT11: Temperatura y Humedad)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      child: DhtSensorCard(
                        temp: telemetry.temperature,
                        hum: telemetry.humidity,
                        dhtOk: telemetry.dhtOk,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
