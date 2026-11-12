import 'package:flutter/material.dart';
import '../models/device_state.dart';

class RelayStatusCard extends StatelessWidget {
  final bool isLightOn;
  final RelayState relayState;
  final VoidCallback onToggle;
  final bool isESP32Available;

  const RelayStatusCard({
    super.key,
    required this.isLightOn,
    required this.relayState,
    required this.onToggle,
    required this.isESP32Available,
  });

  @override
  Widget build(BuildContext context) {
    final isClosed = relayState == RelayState.closed;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isClosed
              ? const Color(0xFF10B981).withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.08),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isClosed
                ? const Color(0xFF10B981).withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado del Módulo Relé
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isClosed
                            ? const Color(0xFF10B981).withValues(alpha: 0.18)
                            : const Color(0xFF334155),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.electric_bolt_rounded,
                        color: isClosed
                            ? const Color(0xFF34D399)
                            : const Color(0xFF94A3B8),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Módulo Relé (ESP32)',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                          ),
                          Text(
                            'Control AC (Foco 110/220V)',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
              const SizedBox(width: 8),
              // LEDs físicos simulados del módulo relé
              _RelayHardwareLeds(isClosed: isClosed),
            ],
          ),

          const SizedBox(height: 18),

          // Diagrama interactivo del contacto del relé (Abierto vs Cerrado)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
            child: Row(
              children: [
                // Ilustración de terminales COM y NO
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 2,
                        children: [
                          Container(
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isClosed
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFEF4444),
                              boxShadow: [
                                BoxShadow(
                                  color: (isClosed
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFFEF4444))
                                      .withValues(alpha: 0.6),
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            isClosed
                                ? 'CIRCUITO CERRADO'
                                : 'CIRCUITO ABIERTO',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                              color: isClosed
                                  ? const Color(0xFF34D399)
                                  : const Color(0xFFF87171),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        isClosed
                            ? 'Paso de corriente activo al foco'
                            : 'Corriente interrumpida de forma segura',
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
                const SizedBox(width: 8),
                // Gráfico esquemático del switch mecánico
                CustomPaint(
                  size: const Size(54, 28),
                  painter: _RelayCircuitPainter(isClosed: isClosed),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Botón principal de acción: Abrir / Cerrar Relé
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: onToggle,
              style: ElevatedButton.styleFrom(
                backgroundColor: isClosed
                    ? const Color(0xFFE11D48) // Botón para apagar/abrir
                    : const Color(0xFF059669), // Botón para encender/cerrar
                foregroundColor: Colors.white,
                elevation: 6,
                shadowColor: (isClosed
                        ? const Color(0xFFE11D48)
                        : const Color(0xFF059669))
                    .withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isClosed
                        ? Icons.power_settings_new_rounded
                        : Icons.flash_on_rounded,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        isClosed ? 'ABRIR RELÉ (APAGAR FOCO)' : 'CERRAR RELÉ (ENCENDER FOCO)',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Representa visualmente los LEDs de alimentación (PWR) y señal (IN) típicos de módulos relé
class _RelayHardwareLeds extends StatelessWidget {
  final bool isClosed;

  const _RelayHardwareLeds({required this.isClosed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // LED PWR (Rojo constante si tiene energía)
          Column(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFEF4444),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFEF4444),
                      blurRadius: 5,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'PWR',
                style: TextStyle(fontSize: 8, color: Colors.white54, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // LED IN (Verde cuando el GPIO activa el relé)
          Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isClosed
                      ? const Color(0xFF10B981)
                      : const Color(0xFF1E293B),
                  boxShadow: isClosed
                      ? [
                          const BoxShadow(
                            color: Color(0xFF10B981),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'IN',
                style: TextStyle(fontSize: 8, color: Colors.white54, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Dibuja el esquemático de contacto abierto o cerrado
class _RelayCircuitPainter extends CustomPainter {
  final bool isClosed;

  _RelayCircuitPainter({required this.isClosed});

  @override
  void paint(Canvas canvas, Size size) {
    final terminalPaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 2.0;

    final contactPaint = Paint()
      ..color = isClosed ? const Color(0xFF34D399) : const Color(0xFFF87171)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..style = PaintingStyle.fill;

    // Terminal izquierda
    canvas.drawLine(Offset(0, size.height / 2), Offset(18, size.height / 2), terminalPaint);
    canvas.drawCircle(Offset(18, size.height / 2), 3, dotPaint);

    // Terminal derecha
    canvas.drawLine(Offset(42, size.height / 2), Offset(size.width, size.height / 2), terminalPaint);
    canvas.drawCircle(Offset(42, size.height / 2), 3, dotPaint);

    // Palanca móvil del relé (cerrada toca el terminal derecho, abierta se eleva en ángulo)
    if (isClosed) {
      canvas.drawLine(Offset(18, size.height / 2), Offset(42, size.height / 2), contactPaint);
    } else {
      // Inclinada hacia arriba
      canvas.drawLine(Offset(18, size.height / 2), Offset(38, size.height / 2 - 14), contactPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RelayCircuitPainter oldDelegate) {
    return oldDelegate.isClosed != isClosed;
  }
}
