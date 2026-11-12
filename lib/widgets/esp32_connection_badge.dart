import 'package:flutter/material.dart';
import '../models/device_state.dart';
import '../models/mqtt_config.dart';

class ESP32ConnectionBadge extends StatelessWidget {
  final ESP32ConnectionStatus status;
  final bool isESP32Available;
  final MqttConfig config;
  final VoidCallback onTap;
  final VoidCallback onReconnect;

  const ESP32ConnectionBadge({
    super.key,
    required this.status,
    required this.isESP32Available,
    required this.config,
    required this.onTap,
    required this.onReconnect,
  });

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    String statusTitle;
    String statusSubtitle;
    IconData iconData;

    if (config.useSimulation) {
      badgeColor = const Color(0xFF6366F1); // Indigo
      statusTitle = 'ESP32 Virtual (Simulador)';
      statusSubtitle = 'Modo demo activo • Toca para conectar a broker real';
      iconData = Icons.developer_board_rounded;
    } else {
      switch (status) {
        case ESP32ConnectionStatus.online:
          if (isESP32Available) {
            badgeColor = const Color(0xFF10B981); // Emerald
            statusTitle = 'ESP32 Conectado a la Nube';
            statusSubtitle = 'Enlace MQTT activo vía Internet (${config.broker})';
            iconData = Icons.cloud_done_rounded;
          } else {
            badgeColor = const Color(0xFFF59E0B); // Amber
            statusTitle = 'Broker Conectado • ESP32 Esperando';
            statusSubtitle = 'Esperando conexión del microcontrolador...';
            iconData = Icons.wifi_tethering_rounded;
          }
          break;
        case ESP32ConnectionStatus.connecting:
          badgeColor = const Color(0xFFF59E0B);
          statusTitle = 'Conectando a la Nube...';
          statusSubtitle = 'Estableciendo enlace con ${config.broker}';
          iconData = Icons.cloud_sync_rounded;
          break;
        case ESP32ConnectionStatus.error:
        case ESP32ConnectionStatus.disconnected:
          badgeColor = const Color(0xFFEF4444);
          statusTitle = 'Desconectado de la Nube';
          statusSubtitle = 'Toca para reintentar o configurar el broker';
          iconData = Icons.cloud_off_rounded;
          break;
      }
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B).withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: badgeColor.withValues(alpha: 0.35),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: badgeColor.withValues(alpha: 0.12),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icono con halo pulsante
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(
                iconData,
                color: badgeColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            // Textos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: badgeColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          statusTitle,
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
                  const SizedBox(height: 2),
                  Text(
                    statusSubtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            // Botón de configuración rápida
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.settings_outlined,
                size: 16,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
