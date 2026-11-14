import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/home_automation_provider.dart';
import '../widgets/esp32_guide_dialog.dart';
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

  void _openEsp32Guide(BuildContext context) {
    final provider = context.read<HomeAutomationProvider>();
    showDialog(
      context: context,
      builder: (_) => Esp32GuideDialog(config: provider.config),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeAutomationProvider>(
      builder: (context, provider, child) {
        final isLightOn = provider.isLightOn;

        return Scaffold(
          backgroundColor: const Color(0xFF0A0F1D),
          body: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light,
            child: SafeArea(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Barra Superior Minimalista
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E293B),
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
                                                color: Colors.white.withValues(alpha: 0.6),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Container(
                                            width: 4,
                                            height: 4,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white38,
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            provider.config.useSimulation
                                                ? 'Virtual'
                                                : 'Nube IoT',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: provider.config.useSimulation
                                                  ? const Color(0xFF818CF8)
                                                  : const Color(0xFF34D399),
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
                          const SizedBox(width: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Botón Guía ESP32
                              IconButton(
                                onPressed: () => _openEsp32Guide(context),
                                tooltip: 'Código y Pines ESP32',
                                style: IconButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E293B),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: Colors.white.withValues(alpha: 0.08),
                                    ),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.developer_board_rounded,
                                  color: Color(0xFF10B981),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 6),
                              // Botón Ajustes
                              IconButton(
                                onPressed: () => _openSettings(context),
                                tooltip: 'Ajustes del Broker',
                                style: IconButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E293B),
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
                        ],
                      ),
                    ),
                  ),

                  // Interfaz Inmersiva del Cuarto (Foco y Lámpara)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                      child: ImmersiveRoomView(
                        isLightOn: isLightOn,
                        onToggle: () {
                          HapticFeedback.mediumImpact();
                          provider.toggleLight();
                        },
                      ),
                    ),
                  ),

                  // Parte Final: Opciones de los 3 Modos de Operación
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      child: OperatingModesCard(
                        currentMode: provider.operatingMode,
                        isLightOn: isLightOn,
                        ambientLightLevel: provider.ambientLightLevel,
                        isManualSwitchClosed: provider.isManualSwitchClosed,
                        formattedRuntime: provider.formattedRuntime,
                        onModeChanged: (mode) => provider.setOperatingMode(mode),
                        onToggleLight: () => provider.toggleLight(),
                        onLightLevelChanged: (level) =>
                            provider.setAmbientLightLevel(level),
                        onManualSwitchChanged: (isClosed) =>
                            provider.setManualSwitch(isClosed),
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
