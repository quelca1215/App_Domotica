import 'package:flutter/material.dart';

class ImmersiveRoomView extends StatelessWidget {
  final bool isLightOn;
  final VoidCallback onToggle;

  const ImmersiveRoomView({
    super.key,
    required this.isLightOn,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isCompact = size.height < 700;

    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOutCubic,
        height: isCompact ? 300 : 360,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isLightOn
                ? [
                    const Color(0xFF261E14),
                    const Color(0xFF1F1610),
                    const Color(0xFF140F0B),
                  ]
                : [
                    const Color(0xFF0B111E),
                    const Color(0xFF070B14),
                    const Color(0xFF030509),
                  ],
          ),
          boxShadow: [
            BoxShadow(
              color: isLightOn
                  ? const Color(0xFFFFB300).withValues(alpha: 0.25)
                  : Colors.black.withValues(alpha: 0.4),
              blurRadius: isLightOn ? 35 : 15,
              spreadRadius: isLightOn ? 2 : 0,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(
            color: isLightOn
                ? const Color(0xFFFFC107).withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.08),
            width: 1.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Fondo de arquitectura de habitación pintado
              CustomPaint(
                painter: _RoomArchitecturePainter(isLightOn: isLightOn),
              ),

              // Cono de luz dinámico cuando está encendido
              AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                opacity: isLightOn ? 1.0 : 0.0,
                child: CustomPaint(
                  painter: _LightConePainter(),
                ),
              ),

              // Muebles e ilustración inmersiva (Cama, ventana, mesa de noche)
              CustomPaint(
                painter: _FurniturePainter(isLightOn: isLightOn),
              ),

              // Lámpara colgante y foco incandescente interactivo
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: _HangingBulbWidget(isLightOn: isLightOn),
                ),
              ),

              // Indicador visual discreto de interacción
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isLightOn
                                  ? Icons.wb_incandescent_rounded
                                  : Icons.nightlight_round,
                              size: 13,
                              color: isLightOn
                                  ? const Color(0xFFFFD54F)
                                  : const Color(0xFF64748B),
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                isLightOn ? 'Habitación ON' : 'Habitación OFF',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isLightOn
                                      ? const Color(0xFFFFE082)
                                      : const Color(0xFF94A3B8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.touch_app_rounded,
                            size: 12,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Toca aquí',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white.withValues(alpha: 0.75),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dibuja las paredes, esquinas y ventana con iluminación de luna o foco
class _RoomArchitecturePainter extends CustomPainter {
  final bool isLightOn;

  _RoomArchitecturePainter({required this.isLightOn});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Pared trasera
    final backWallPaint = Paint()
      ..color = isLightOn
          ? const Color(0xFF2A2016)
          : const Color(0xFF0F1726);
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height * 0.75), backWallPaint);

    // Piso de madera con perspectiva
    final floorPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isLightOn
            ? [
                const Color(0xFF382314),
                const Color(0xFF22140A),
              ]
            : [
                const Color(0xFF0C111C),
                const Color(0xFF060910),
              ],
      ).createShader(Rect.fromLTWH(0, height * 0.75, width, height * 0.25));

    final floorPath = Path()
      ..moveTo(0, height * 0.75)
      ..lineTo(width, height * 0.75)
      ..lineTo(width, height)
      ..lineTo(0, height)
      ..close();
    canvas.drawPath(floorPath, floorPaint);

    // Líneas del piso (madera)
    final floorLinesPaint = Paint()
      ..color = (isLightOn ? const Color(0xFF4A301E) : const Color(0xFF162032))
          .withValues(alpha: 0.4)
      ..strokeWidth = 1.0;

    for (double x = 40; x < width; x += 60) {
      canvas.drawLine(
        Offset(x, height * 0.75),
        Offset(x + (x - width / 2) * 0.4, height),
        floorLinesPaint,
      );
    }

    // Ventana a la izquierda con cielo nocturno estrellado
    final windowRect = Rect.fromLTWH(24, 45, 75, 120);
    final windowFramePaint = Paint()
      ..color = isLightOn
          ? const Color(0xFF3F2B1A)
          : const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(windowRect, const Radius.circular(8)),
      windowFramePaint,
    );

    // Cristal de la ventana (cielo nocturno azul profundo)
    final glassRect = Rect.fromLTWH(28, 49, 67, 112);
    final glassPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF030D1A),
          Color(0xFF0B192C),
          Color(0xFF1E3A8A),
        ],
      ).createShader(glassRect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(glassRect, const Radius.circular(6)),
      glassPaint,
    );

    // Luna creciente en la ventana
    final moonPaint = Paint()
      ..color = const Color(0xFFF8FAFC).withValues(alpha: 0.9);
    canvas.drawCircle(const Offset(70, 75), 9, moonPaint);
    final moonCutPaint = Paint()..color = const Color(0xFF0B192C);
    canvas.drawCircle(const Offset(74, 73), 8, moonCutPaint);

    // Marco interior de la ventana
    final frameBorderPaint = Paint()
      ..color = (isLightOn ? const Color(0xFF5A3E26) : const Color(0xFF334155))
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(28 + 33.5, 49), const Offset(28 + 33.5, 161), frameBorderPaint);
    canvas.drawLine(const Offset(28, 49 + 56), const Offset(95, 49 + 56), frameBorderPaint);
  }

  @override
  bool shouldRepaint(covariant _RoomArchitecturePainter oldDelegate) {
    return oldDelegate.isLightOn != isLightOn;
  }
}

/// Dibuja el cono radial de iluminación suave y difusa
class _LightConePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final lightSource = Offset(width / 2, 72);

    // Gran resplandor radial
    final ambientGlowPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.65),
        radius: 1.1,
        colors: [
          const Color(0xFFFFD54F).withValues(alpha: 0.42),
          const Color(0xFFFFB300).withValues(alpha: 0.22),
          const Color(0xFFFF8F00).withValues(alpha: 0.08),
          Colors.transparent,
        ],
        stops: const [0.0, 0.35, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, width, height));

    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), ambientGlowPaint);

    // Cono de luz triangular descendente
    final conePath = Path()
      ..moveTo(lightSource.dx - 18, lightSource.dy)
      ..lineTo(0, height)
      ..lineTo(width, height)
      ..lineTo(lightSource.dx + 18, lightSource.dy)
      ..close();

    final conePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFFFE082).withValues(alpha: 0.30),
          const Color(0xFFFFCA28).withValues(alpha: 0.12),
          Colors.transparent,
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromLTWH(0, lightSource.dy, width, height - lightSource.dy));

    canvas.drawPath(conePath, conePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Dibuja los muebles de la habitación con sombreado dinámico
class _FurniturePainter extends CustomPainter {
  final bool isLightOn;

  _FurniturePainter({required this.isLightOn});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Cama moderna en la derecha / centro
    final bedLeft = width * 0.42;
    final bedTop = height * 0.62;
    final bedWidth = width * 0.52;
    final bedHeight = height * 0.28;

    // Cabecera de la cama
    final headboardRect = Rect.fromLTWH(bedLeft + bedWidth - 20, bedTop - 45, 18, 90);
    final headboardPaint = Paint()
      ..color = isLightOn ? const Color(0xFF5D4037) : const Color(0xFF1E293B);
    canvas.drawRRect(
      RRect.fromRectAndRadius(headboardRect, const Radius.circular(6)),
      headboardPaint,
    );

    // Base de la cama
    final bedBaseRect = Rect.fromLTWH(bedLeft, bedTop + 25, bedWidth, bedHeight - 25);
    final bedBasePaint = Paint()
      ..color = isLightOn ? const Color(0xFF3E2723) : const Color(0xFF0F172A);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bedBaseRect, const Radius.circular(6)),
      bedBasePaint,
    );

    // Colchón / Edredón con sombra y luz cálida
    final mattressRect = Rect.fromLTWH(bedLeft - 10, bedTop, bedWidth + 5, 35);
    final mattressPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isLightOn
            ? [
                const Color(0xFFFFF3E0),
                const Color(0xFFFFE0B2),
              ]
            : [
                const Color(0xFF334155),
                const Color(0xFF1E293B),
              ],
      ).createShader(mattressRect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(mattressRect, const Radius.circular(8)),
      mattressPaint,
    );

    // Almohadas
    final pillowRect = Rect.fromLTWH(bedLeft + bedWidth - 42, bedTop - 12, 28, 16);
    final pillowPaint = Paint()
      ..color = isLightOn ? const Color(0xFFFFECB3) : const Color(0xFF475569);
    canvas.drawRRect(
      RRect.fromRectAndRadius(pillowRect, const Radius.circular(5)),
      pillowPaint,
    );

    // Mesa de noche a la izquierda con cuadro/planta
    final tableRect = Rect.fromLTWH(bedLeft - 48, bedTop + 10, 32, 50);
    final tablePaint = Paint()
      ..color = isLightOn ? const Color(0xFF4E342E) : const Color(0xFF1E293B);
    canvas.drawRRect(
      RRect.fromRectAndRadius(tableRect, const Radius.circular(4)),
      tablePaint,
    );

    // Planta pequeña sobre la mesa de noche
    final potRect = Rect.fromLTWH(bedLeft - 40, bedTop + 2, 16, 10);
    final potPaint = Paint()
      ..color = isLightOn ? const Color(0xFF8D6E63) : const Color(0xFF334155);
    canvas.drawRect(potRect, potPaint);

    final leafPaint = Paint()
      ..color = isLightOn ? const Color(0xFF4CAF50) : const Color(0xFF1B4323);
    canvas.drawCircle(Offset(bedLeft - 32, bedTop - 2), 6, leafPaint);
    canvas.drawCircle(Offset(bedLeft - 36, bedTop - 1), 4, leafPaint);

    // Alfombra debajo de la cama
    final rugRect = Rect.fromLTWH(bedLeft - 25, height * 0.82, bedWidth - 20, 32);
    final rugPaint = Paint()
      ..color = (isLightOn ? const Color(0xFF795548) : const Color(0xFF1E293B))
          .withValues(alpha: 0.6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rugRect, const Radius.circular(16)),
      rugPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _FurniturePainter oldDelegate) {
    return oldDelegate.isLightOn != isLightOn;
  }
}

/// Foco colgante interactivo con filamento y halo brillante
class _HangingBulbWidget extends StatelessWidget {
  final bool isLightOn;

  const _HangingBulbWidget({required this.isLightOn});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Cable colgante desde el techo
        Container(
          width: 3,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 2,
              ),
            ],
          ),
        ),

        // Casquillo metálico (socket) de latón
        Container(
          width: 22,
          height: 14,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFB8860B),
                Color(0xFFDAA520),
                Color(0xFF8B6508),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 3,
              ),
            ],
          ),
        ),

        // Bombilla incandescente con animación de brillo
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
          tween: Tween<double>(begin: 0, end: isLightOn ? 1.0 : 0.0),
          builder: (context, value, child) {
            final safeValue = value.clamp(0.0, 1.0);
            return Container(
              width: 52,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color.lerp(
                      const Color(0xFF334155),
                      const Color(0xFFFFFDE7),
                      safeValue,
                    )!,
                    Color.lerp(
                      const Color(0xFF1E293B),
                      const Color(0xFFFFD54F),
                      safeValue,
                    )!,
                    Color.lerp(
                      const Color(0xFF0F172A).withValues(alpha: 0.8),
                      const Color(0xFFFFB300),
                      safeValue,
                    )!,
                  ],
                  stops: const [0.2, 0.6, 1.0],
                ),
                boxShadow: [
                  // Gran halo externo
                  BoxShadow(
                    color: const Color(0xFFFFB300).withValues(alpha: 0.55 * safeValue),
                    blurRadius: 35 * safeValue + 4,
                    spreadRadius: 8 * safeValue,
                  ),
                  // Brillo blanco nuclear central
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.85 * safeValue),
                    blurRadius: (12 * safeValue).clamp(0.0, 50.0),
                    spreadRadius: (2 * safeValue).clamp(0.0, 20.0),
                  ),
                ],
                border: Border.all(
                  color: Color.lerp(
                    Colors.white.withValues(alpha: 0.15),
                    const Color(0xFFFFECB3),
                    safeValue,
                  )!,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: CustomPaint(
                  size: const Size(26, 26),
                  painter: _FilamentPainter(glowProgress: safeValue),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Dibuja el filamento de tungsteno interior del foco
class _FilamentPainter extends CustomPainter {
  final double glowProgress;

  _FilamentPainter({required this.glowProgress});

  @override
  void paint(Canvas canvas, Size size) {
    final filamentPaint = Paint()
      ..color = Color.lerp(
        const Color(0xFF475569),
        Colors.white,
        glowProgress,
      )!
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * 0.25, size.height * 0.8)
      ..lineTo(size.width * 0.35, size.height * 0.3)
      ..lineTo(size.width * 0.45, size.height * 0.45)
      ..lineTo(size.width * 0.55, size.height * 0.3)
      ..lineTo(size.width * 0.65, size.height * 0.45)
      ..lineTo(size.width * 0.75, size.height * 0.8);

    canvas.drawPath(path, filamentPaint);

    if (glowProgress > 0.4) {
      final glowPaint = Paint()
        ..color = const Color(0xFFFFD54F).withValues(alpha: glowProgress * 0.6)
        ..strokeWidth = 5.0
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawPath(path, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _FilamentPainter oldDelegate) {
    return oldDelegate.glowProgress != glowProgress;
  }
}
