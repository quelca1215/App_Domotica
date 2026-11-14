import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/device_state.dart';

class OperatingModesCard extends StatelessWidget {
  final OperatingMode currentMode;
  final bool isLightOn;
  final double ambientLightLevel;
  final bool isManualSwitchClosed;
  final String formattedRuntime;
  final ValueChanged<OperatingMode> onModeChanged;
  final VoidCallback onToggleLight;
  final ValueChanged<double> onLightLevelChanged;
  final ValueChanged<bool> onManualSwitchChanged;

  const OperatingModesCard({
    super.key,
    required this.currentMode,
    required this.isLightOn,
    required this.ambientLightLevel,
    required this.isManualSwitchClosed,
    required this.formattedRuntime,
    required this.onModeChanged,
    required this.onToggleLight,
    required this.onLightLevelChanged,
    required this.onManualSwitchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF131B2E),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.tune_rounded,
                      color: Color(0xFF38BDF8),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Modos de Operación',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (isLightOn)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB300).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFFB300).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        size: 13,
                        color: Color(0xFFFFD54F),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        formattedRuntime,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFFD54F),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Selector Segmentado de Modos (Minimalista y Moderno)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0F1D),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
            child: Row(
              children: [
                _buildModeTab(
                  mode: OperatingMode.app,
                  title: 'App',
                  icon: Icons.smartphone_rounded,
                ),
                _buildModeTab(
                  mode: OperatingMode.photocell,
                  title: 'Fotocélula',
                  icon: Icons.light_mode_rounded,
                ),
                _buildModeTab(
                  mode: OperatingMode.manual,
                  title: 'Manual NA',
                  icon: Icons.power_rounded,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Contenido dinámico según el modo seleccionado
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: _buildModeContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildModeTab({
    required OperatingMode mode,
    required String title,
    required IconData icon,
  }) {
    final isSelected = currentMode == mode;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onModeChanged(mode);
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF1E293B)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: isSelected
                ? Border.all(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.5),
                    width: 1.2,
                  )
                : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                      blurRadius: 10,
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? const Color(0xFF38BDF8)
                    : Colors.white.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeContent() {
    switch (currentMode) {
      case OperatingMode.app:
        return _buildAppModeContent();
      case OperatingMode.photocell:
        return _buildPhotocellModeContent();
      case OperatingMode.manual:
        return _buildManualModeContent();
    }
  }

  // --- 1. MODO ENCENDIDO CON LA APP ---
  Widget _buildAppModeContent() {
    return Column(
      key: const ValueKey('app_mode'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '1. Modo Encendido con la App',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isLightOn
                        ? 'Foco encendido desde la app'
                        : 'Foco apagado desde la app',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Switch(
              value: isLightOn,
              activeThumbColor: const Color(0xFFFFB300),
              activeTrackColor: const Color(0xFFFFB300).withValues(alpha: 0.3),
              onChanged: (_) {
                HapticFeedback.mediumImpact();
                onToggleLight();
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.heavyImpact();
              onToggleLight();
            },
            icon: Icon(
              isLightOn ? Icons.power_settings_new_rounded : Icons.flash_on_rounded,
              size: 20,
            ),
            label: Text(
              isLightOn ? 'APAGAR FOCO' : 'ENCENDER FOCO',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isLightOn
                  ? const Color(0xFFEF4444)
                  : const Color(0xFF0284C7),
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- 2. MODO INTELIGENTE CON FOTOCÉLULA ---
  Widget _buildPhotocellModeContent() {
    final isDark = ambientLightLevel < 40.0;

    return Column(
      key: const ValueKey('photocell_mode'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '2. Modo Inteligente (Fotocélula)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Sensor LDR automático de luz',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF10B981).withValues(alpha: 0.18)
                    : const Color(0xFF64748B).withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF10B981).withValues(alpha: 0.4)
                      : Colors.white12,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isDark ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                    size: 13,
                    color: isDark ? const Color(0xFF34D399) : const Color(0xFFFBBF24),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isDark ? 'Poca Luz' : 'Mucha Luz',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isDark ? const Color(0xFF34D399) : const Color(0xFFFBBF24),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Tarjeta de estado de la fotocélula
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF10B981).withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.05),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Luz Ambiental Detectada:',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${ambientLightLevel.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: ambientLightLevel / 100.0,
                  minHeight: 8,
                  backgroundColor: const Color(0xFF1E293B),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDark ? const Color(0xFF10B981) : const Color(0xFFFBBF24),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    isDark ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                    size: 14,
                    color: isDark ? const Color(0xFF34D399) : const Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      isDark
                          ? 'Oscuridad detectada (< 40%) ➔ Foco ENCENDIDO'
                          : 'Luz detectada (≥ 40%) ➔ Foco APAGADO',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? const Color(0xFF34D399)
                            : Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Botones rápidos para simular o probar la fotocélula
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  onLightLevelChanged(20.0);
                },
                icon: const Icon(Icons.nightlight_round, size: 15),
                label: const Text('Noche (20%)', style: TextStyle(fontSize: 11)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF38BDF8),
                  side: BorderSide(
                    color: isDark
                        ? const Color(0xFF38BDF8)
                        : Colors.white.withValues(alpha: 0.15),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  onLightLevelChanged(80.0);
                },
                icon: const Icon(Icons.wb_sunny_rounded, size: 15),
                label: const Text('Día (80%)', style: TextStyle(fontSize: 11)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFBBF24),
                  side: BorderSide(
                    color: !isDark
                        ? const Color(0xFFFBBF24)
                        : Colors.white.withValues(alpha: 0.15),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- 3. MODO MANUAL CON INTERRUPTOR NORMALMENTE ABIERTO (NA) ---
  Widget _buildManualModeContent() {
    return Column(
      key: const ValueKey('manual_mode'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '3. Modo Manual (Interruptor NA)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Pulsador o switch normalmente abierto',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isManualSwitchClosed
                    ? const Color(0xFF10B981).withValues(alpha: 0.18)
                    : const Color(0xFFEF4444).withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isManualSwitchClosed
                      ? const Color(0xFF10B981).withValues(alpha: 0.4)
                      : const Color(0xFFEF4444).withValues(alpha: 0.4),
                ),
              ),
              child: Text(
                isManualSwitchClosed ? 'CERRADO (Activo)' : 'ABIERTO (Reposo)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isManualSwitchClosed
                      ? const Color(0xFF34D399)
                      : const Color(0xFFF87171),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Tarjeta esquemática del switch NA
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isManualSwitchClosed
                  ? const Color(0xFF10B981).withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.05),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isManualSwitchClosed
                      ? const Color(0xFF10B981).withValues(alpha: 0.2)
                      : const Color(0xFF1E293B),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isManualSwitchClosed
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: isManualSwitchClosed
                      ? const Color(0xFF34D399)
                      : const Color(0xFF94A3B8),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isManualSwitchClosed
                          ? 'Circuito Manual Cerrado'
                          : 'Circuito Manual Abierto',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isManualSwitchClosed
                            ? const Color(0xFF34D399)
                            : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isManualSwitchClosed
                          ? 'El interruptor de pared conduce corriente ➔ Foco ON'
                          : 'El interruptor en reposo corta el paso ➔ Foco OFF',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Botón interactivo para pulsar/conmutar el interruptor NA
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.mediumImpact();
              onManualSwitchChanged(!isManualSwitchClosed);
            },
            icon: Icon(
              isManualSwitchClosed
                  ? Icons.power_settings_new_rounded
                  : Icons.touch_app_rounded,
              size: 18,
            ),
            label: Text(
              isManualSwitchClosed
                  ? 'SOLTAR / ABRIR INTERRUPTOR NA'
                  : 'PULSAR / CERRAR INTERRUPTOR NA',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isManualSwitchClosed
                  ? const Color(0xFF334155)
                  : const Color(0xFF0D9488),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
