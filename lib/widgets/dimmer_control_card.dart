import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DimmerControlCard extends StatelessWidget {
  final int brightness;
  final ValueChanged<int> onChanged;

  const DimmerControlCard({
    super.key,
    required this.brightness,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOn = brightness > 0;
    final double normalized = (brightness / 100.0).clamp(0.0, 1.0);

    // Color que transiciona de gris oscuro (apagado) a amarillo cálido resplandeciente
    final glowColor = Color.lerp(
      const Color(0xFF64748B),
      const Color(0xFFFBBF24),
      normalized,
    )!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isOn
              ? glowColor.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.07),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isOn
                ? glowColor.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera: Título, Pines y Nivel Actual
          Row(
            children: [
              // Icono indicador con resplandor proporcional al brillo
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onChanged(isOn ? 0 : 100);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isOn
                        ? glowColor.withValues(alpha: 0.18)
                        : const Color(0xFF1E293B),
                    shape: BoxShape.circle,
                    boxShadow: isOn
                        ? [
                            BoxShadow(
                              color: glowColor.withValues(alpha: 0.35),
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                          ]
                        : [],
                    border: Border.all(
                      color: isOn
                          ? glowColor.withValues(alpha: 0.4)
                          : Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Icon(
                    isOn ? Icons.light_mode_rounded : Icons.light_mode_outlined,
                    color: glowColor,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Luz Regulable (Dimmer)',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isOn
                                ? const Color(0xFF34D399)
                                : const Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            isOn
                                ? 'Regulado al $brightness% • Triac (Pin 33 / 27)'
                                : 'Apagado (0%) • Circuito Dimmer',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Badge de porcentaje numérico
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF131B2E),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Text(
                  '$brightness%',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: glowColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Control Deslizante (Slider)
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 8,
              activeTrackColor: glowColor,
              inactiveTrackColor: const Color(0xFF1E293B),
              thumbColor: Colors.white,
              overlayColor: glowColor.withValues(alpha: 0.2),
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 11,
                elevation: 4,
              ),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            ),
            child: Slider(
              value: brightness.toDouble(),
              min: 0,
              max: 100,
              onChanged: (val) {
                onChanged(val.round());
              },
            ),
          ),

          const SizedBox(height: 8),

          // Presets rápidos (0%, 25%, 50%, 75%, 100%)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPresetButton(0, '0%'),
              _buildPresetButton(25, '25%'),
              _buildPresetButton(50, '50%'),
              _buildPresetButton(75, '75%'),
              _buildPresetButton(100, '100%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPresetButton(int value, String label) {
    final bool isSelected = (brightness == value);
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onChanged(value);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF38BDF8).withValues(alpha: 0.2)
              : const Color(0xFF131B2E),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF38BDF8)
                : Colors.white.withValues(alpha: 0.05),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? const Color(0xFF38BDF8) : const Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }
}
