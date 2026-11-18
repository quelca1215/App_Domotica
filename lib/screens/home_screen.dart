import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/device_state.dart';
import '../providers/home_automation_provider.dart';
import '../widgets/dimmer_control_card.dart';
import '../widgets/immersive_room_view.dart';
import '../widgets/operating_modes_card.dart';
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
        final isLightOn = provider.isLightOn;

        return Scaffold(
          backgroundColor: const Color(0xFF070B14),
          body: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light,
            child: SafeArea(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Barra Superior Minimalista
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(9),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF131B2E),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.06),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.home_rounded,
                                    color: Color(0xFF38BDF8),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Casa Inteligente',
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              'Dormitorio Principal',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.white.withValues(alpha: 0.5),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Container(
                                            width: 3.5,
                                            height: 3.5,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white30,
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            provider.config.useSimulation
                                                ? 'Modo Demo'
                                                : (provider.isESP32Available
                                                    ? 'AP Conectado'
                                                    : 'Buscando AP...'),
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: provider.config.useSimulation
                                                  ? const Color(0xFF818CF8)
                                                  : (provider.isESP32Available
                                                      ? const Color(0xFF34D399)
                                                      : const Color(0xFFFBBF24)),
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
                          // Botón Ajustes del Punto de Acceso
                          IconButton(
                            onPressed: () => _openSettings(context),
                            tooltip: 'Ajustes del Punto de Acceso',
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0xFF131B2E),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.06),
                                ),
                              ),
                            ),
                            icon: const Icon(
                              Icons.tune_rounded,
                              color: Colors.white70,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Interfaz Inmersiva del Cuarto (Foco y Lámpara)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
                      child: ImmersiveRoomView(
                        isLightOn: isLightOn,
                        dimmerBrightness: provider.dimmerBrightness,
                        onToggle: () {
                          HapticFeedback.mediumImpact();
                          if (provider.operatingMode == OperatingMode.app) {
                            provider.toggleLight();
                          } else {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  provider.operatingMode == OperatingMode.photocell
                                      ? 'Modo Fotocélula activo. Cambia a "App" para control directo.'
                                      : 'Modo Manual NA activo. Cambia a "App" para control directo.',
                                ),
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),

                  // Circuito 2: Luz Regulable (Dimmer Triac)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                      child: DimmerControlCard(
                        brightness: provider.dimmerBrightness,
                        onChanged: (val) => provider.setDimmerBrightness(val),
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
