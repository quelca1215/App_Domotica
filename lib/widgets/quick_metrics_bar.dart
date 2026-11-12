import 'package:flutter/material.dart';
import '../models/device_state.dart';

class QuickMetricsBar extends StatelessWidget {
  final DeviceTelemetry telemetry;
  final bool isLightOn;
  final String formattedRuntime;

  const QuickMetricsBar({
    super.key,
    required this.telemetry,
    required this.isLightOn,
    required this.formattedRuntime,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Potencia instantánea
        Expanded(
          child: _MetricCard(
            label: 'Consumo',
            value: isLightOn
                ? '${telemetry.powerWatts.toStringAsFixed(1)} W'
                : '0.0 W',
            subtitle: isLightOn ? 'Foco LED 12W' : 'En reposo',
            icon: Icons.bolt_rounded,
            accentColor: isLightOn
                ? const Color(0xFFFFB300)
                : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(width: 10),

        // Temperatura del cuarto
        Expanded(
          child: _MetricCard(
            label: 'Temperatura',
            value: '${telemetry.temperature.toStringAsFixed(1)} °C',
            subtitle: 'Confort térmico',
            icon: Icons.thermostat_rounded,
            accentColor: const Color(0xFF38BDF8),
          ),
        ),
        const SizedBox(width: 10),

        // Tiempo encendido
        Expanded(
          child: _MetricCard(
            label: 'Tiempo ON',
            value: isLightOn ? formattedRuntime : '--:--',
            subtitle: isLightOn ? 'Activo' : 'Apagado',
            icon: Icons.timer_outlined,
            accentColor: isLightOn
                ? const Color(0xFF10B981)
                : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color accentColor;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
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
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.5),
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                icon,
                size: 13,
                color: accentColor,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9,
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}
