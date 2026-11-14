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

  const OperatingModesCard({
    super.key,
    required this.currentMode,
    required this.isLightOn,
    required this.ambientLightLevel,
    required this.isManualSwitchClosed,
    required this.formattedRuntime,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.07),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selector Segmentado de Modos (Ultra limpio y minimalista)
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: const Color(0xFF070B14),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
            child: Row(
              children: [
                _buildTab(
                  mode: OperatingMode.app,
                  title: 'App',
                  icon: Icons.smartphone_rounded,
                ),
                _buildTab(
                  mode: OperatingMode.photocell,
                  title: 'Fotocélula',
                  icon: Icons.light_mode_rounded,
                ),
                _buildTab(
                  mode: OperatingMode.manual,
                  title: 'Manual NA',
                  icon: Icons.power_rounded,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Estado del modo activo (Limpio y puramente informativo)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: _buildCurrentState(),
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
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
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1E293B) : Colors.transparent,
            borderRadius: BorderRadius.circular(13),
            border: isSelected
                ? Border.all(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.35),
                  )
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected
                    ? const Color(0xFF38BDF8)
                    : Colors.white.withValues(alpha: 0.4),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentState() {
    switch (currentMode) {
      case OperatingMode.app:
        return _buildAppModeState();
      case OperatingMode.photocell:
        return _buildPhotocellModeState();
      case OperatingMode.manual:
        return _buildManualModeState();
    }
  }

  // --- 1. MODO APP: Solo estado y aviso de tocar la habitación ---
  Widget _buildAppModeState() {
    return Container(
      key: const ValueKey('app_state'),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF070B14).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLightOn
              ? const Color(0xFFFFB300).withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.04),
        ),
      ),
      child: Row(
        children: [
          // Indicador luminoso con halo
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isLightOn
                  ? const Color(0xFFFFB300)
                  : const Color(0xFF64748B),
              boxShadow: isLightOn
                  ? [
                      BoxShadow(
                        color: const Color(0xFFFFB300).withValues(alpha: 0.6),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        isLightOn ? 'FOCO ENCENDIDO' : 'FOCO APAGADO',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                          color: isLightOn
                              ? const Color(0xFFFFD54F)
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                    if (isLightOn) ...[
                      const SizedBox(width: 8),
                      Text(
                        formattedRuntime,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFFD54F),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Toca la habitación para alternar el foco',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 2. MODO FOTOCÉLULA: Nivel de luz ambiental y umbral de cambio ---
  Widget _buildPhotocellModeState() {
    final isDark = ambientLightLevel < 40.0;

    return Container(
      key: const ValueKey('photocell_state'),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF070B14).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? const Color(0xFF10B981).withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.04),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      isDark ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                      size: 14,
                      color: isDark ? const Color(0xFF34D399) : const Color(0xFFFBBF24),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Luz: ${ambientLightLevel.toStringAsFixed(0)}%',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF10B981).withValues(alpha: 0.15)
                      : const Color(0xFF64748B).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isDark ? 'Foco ON' : 'Foco OFF',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isDark ? const Color(0xFF34D399) : const Color(0xFF94A3B8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Barra delgada de nivel de luz ambiental
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ambientLightLevel / 100.0,
              minHeight: 5,
              backgroundColor: const Color(0xFF1E293B),
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? const Color(0xFF10B981) : const Color(0xFFFBBF24),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  isDark
                      ? 'Luz baja ➔ Encendido auto'
                      : 'Luz natural ➔ Apagado auto',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Umbral: 40%',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 3. MODO MANUAL NA: Estado real del interruptor físico en pared ---
  Widget _buildManualModeState() {
    return Container(
      key: const ValueKey('manual_state'),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF070B14).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isManualSwitchClosed
              ? const Color(0xFF10B981).withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.04),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isManualSwitchClosed
                  ? const Color(0xFF10B981)
                  : const Color(0xFF64748B),
              boxShadow: isManualSwitchClosed
                  ? [
                      BoxShadow(
                        color: const Color(0xFF10B981).withValues(alpha: 0.6),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        isManualSwitchClosed
                            ? 'INTERRUPTOR CERRADO'
                            : 'INTERRUPTOR ABIERTO (NA)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                          color: isManualSwitchClosed
                              ? const Color(0xFF34D399)
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isManualSwitchClosed ? 'Foco ON' : 'Foco OFF',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isManualSwitchClosed
                            ? const Color(0xFF34D399)
                            : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'El circuito responde al pulsador físico en la pared',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
