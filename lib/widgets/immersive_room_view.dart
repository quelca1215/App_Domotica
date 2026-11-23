import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ImmersiveRoomView extends StatefulWidget {
  final bool isLightOn;
  final bool isIrLightOn;
  final int irRemainingSeconds;
  final int dimmerBrightness;
  final VoidCallback onToggle;

  const ImmersiveRoomView({
    super.key,
    required this.isLightOn,
    this.isIrLightOn = false,
    this.irRemainingSeconds = 0,
    this.dimmerBrightness = 0,
    required this.onToggle,
  });

  @override
  State<ImmersiveRoomView> createState() => _ImmersiveRoomViewState();
}

class _ImmersiveRoomViewState extends State<ImmersiveRoomView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    // Animación de pulso suave y continua para guiar la atención del usuario
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isCompact = size.height < 700;

    return AnimatedContainer(
      // Animación rápida y viva (240ms) en lugar de lenta
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      height: isCompact ? 430 : 490,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: widget.isLightOn
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
            color: widget.isLightOn
                ? const Color(0xFFFFB300).withValues(alpha: 0.28)
                : Colors.black.withValues(alpha: 0.4),
            blurRadius: widget.isLightOn ? 35 : 15,
            spreadRadius: widget.isLightOn ? 2 : 0,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: widget.isLightOn
              ? const Color(0xFFFFC107).withValues(alpha: 0.35)
              : Colors.white.withValues(alpha: 0.08),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onToggle();
            },
            splashColor: widget.isLightOn
                ? const Color(0xFFFFB300).withValues(alpha: 0.15)
                : const Color(0xFF38BDF8).withValues(alpha: 0.15),
            highlightColor: Colors.white.withValues(alpha: 0.04),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Fondo de arquitectura de habitación pintado
                CustomPaint(
                  painter: _RoomArchitecturePainter(isLightOn: widget.isLightOn),
                ),

                // Cono de luz dinámico cuando está encendido (transición rápida 220ms)
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  opacity: widget.isLightOn ? 1.0 : 0.0,
                  child: CustomPaint(
                    painter: _LightConePainter(),
                  ),
                ),

                // Muebles e ilustración inmersiva (Cama, ventana, mesa de noche y segundo foco IR)
                CustomPaint(
                  painter: _FurniturePainter(
                    isLightOn: widget.isLightOn,
                    dimmerBrightness:
                        widget.isIrLightOn ? 100 : widget.dimmerBrightness,
                  ),
                ),

                // Aro de baliza pulsante que rodea la bombilla cuando está apagada
                if (!widget.isLightOn)
                  Positioned(
                    top: 60,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          final double pulse = _pulseAnimation.value;
                          final double size = 68 + (pulse * 24);
                          return Container(
                            width: size,
                            height: size,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF38BDF8)
                                    .withValues(alpha: 0.45 * (1.0 - pulse * 0.4)),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF38BDF8)
                                      .withValues(alpha: 0.25 * (1.0 - pulse * 0.5)),
                                  blurRadius: 18,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                // Lámpara colgante y foco incandescente interactivo
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _HangingBulbWidget(isLightOn: widget.isLightOn),
                  ),
                ),

                // Placa superior izquierda de estado: "Foco 1 (Touch / Interruptor)"
                Positioned(
                  top: 14,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF070B14).withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: widget.isLightOn
                            ? const Color(0xFFFBBF24).withValues(alpha: 0.3)
                            : Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.isLightOn
                                ? const Color(0xFF34D399)
                                : const Color(0xFF64748B),
                            boxShadow: widget.isLightOn
                                ? [
                                    const BoxShadow(
                                      color: Color(0xFF34D399),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : [],
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          widget.isLightOn ? 'Foco 1: ON' : 'Foco 1: OFF',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: widget.isLightOn
                                ? const Color(0xFFFDE68A)
                                : const Color(0xFF94A3B8),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Placa superior derecha de estado: "Foco 2 IR"
                Positioned(
                  top: 14,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF070B14).withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: widget.isIrLightOn
                            ? const Color(0xFFA855F7).withValues(alpha: 0.45)
                            : Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.isIrLightOn
                                ? const Color(0xFFA855F7)
                                : const Color(0xFF64748B),
                            boxShadow: widget.isIrLightOn
                                ? [
                                    const BoxShadow(
                                      color: Color(0xFFA855F7),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : [],
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          widget.isIrLightOn
                              ? (widget.irRemainingSeconds > 0
                                  ? 'Foco 2 IR: ${widget.irRemainingSeconds}s'
                                  : 'Foco 2 IR: ON')
                              : 'Foco 2 IR: OFF',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: widget.isIrLightOn
                                ? const Color(0xFFE9D5FF)
                                : const Color(0xFF94A3B8),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Indicación flotante interactiva central/inferior súper intuitiva
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        final double pulse = _pulseAnimation.value;
                        final bool on = widget.isLightOn;

                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 11,
                          ),
                          decoration: BoxDecoration(
                            color: on
                                ? const Color(0xFF261B09).withValues(alpha: 0.88)
                                : const Color(0xFF0C1628).withValues(alpha: 0.88),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: on
                                  ? const Color(0xFFFBBF24).withValues(alpha: 0.45)
                                  : Color.lerp(
                                      const Color(0xFF38BDF8).withValues(alpha: 0.35),
                                      const Color(0xFF38BDF8).withValues(alpha: 0.90),
                                      pulse,
                                    )!,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: on
                                    ? const Color(0xFFFBBF24).withValues(alpha: 0.25)
                                    : const Color(0xFF38BDF8)
                                        .withValues(alpha: 0.15 + pulse * 0.20),
                                blurRadius: on ? 14 : 16 + (pulse * 8),
                                spreadRadius: on ? 1 : 1 + (pulse * 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Icono animado: dedo táctil cuando está apagada, foco cuando está encendida
                              if (!on)
                                Transform.translate(
                                  offset: Offset(0, -2 * pulse),
                                  child: const Icon(
                                    Icons.touch_app_rounded,
                                    size: 19,
                                    color: Color(0xFF38BDF8),
                                  ),
                                )
                              else
                                const Icon(
                                  Icons.lightbulb_rounded,
                                  size: 19,
                                  color: Color(0xFFFBBF24),
                                ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  on
                                      ? 'Foco 1 Encendido • Toca para apagar'
                                      : 'Toca la pantalla para encender Foco 1',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: on ? const Color(0xFFFEF08A) : Colors.white,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
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
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), backWallPaint);

    // Suelo con perspectiva
    final floorPath = Path()
      ..moveTo(0, height * 0.72)
      ..lineTo(width, height * 0.72)
      ..lineTo(width, height)
      ..lineTo(0, height)
      ..close();

    final floorPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isLightOn
            ? [
                const Color(0xFF3D2817),
                const Color(0xFF2B1C10),
              ]
            : [
                const Color(0xFF0A0F1A),
                const Color(0xFF05080E),
              ],
      ).createShader(Rect.fromLTWH(0, height * 0.72, width, height * 0.28));

    canvas.drawPath(floorPath, floorPaint);

    // Líneas de zócalo y unión de suelo/pared
    final baseboardPaint = Paint()
      ..color = (isLightOn ? const Color(0xFF4A3320) : const Color(0xFF131D2E))
      ..strokeWidth = 3;
    canvas.drawLine(
      Offset(0, height * 0.72),
      Offset(width, height * 0.72),
      baseboardPaint,
    );

    // Ventana en la pared izquierda
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
    final lightSource = Offset(width / 2, 86);

    // Gran resplandor radial
    final ambientGlowPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.62),
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
  final int dimmerBrightness;

  _FurniturePainter({
    required this.isLightOn,
    this.dimmerBrightness = 0,
  });

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
    final potRect = Rect.fromLTWH(bedLeft - 44, bedTop + 2, 14, 10);
    final potPaint = Paint()
      ..color = isLightOn ? const Color(0xFF8D6E63) : const Color(0xFF334155);
    canvas.drawRect(potRect, potPaint);

    final leafPaint = Paint()
      ..color = isLightOn ? const Color(0xFF4CAF50) : const Color(0xFF1B4323);
    canvas.drawCircle(Offset(bedLeft - 37, bedTop - 2), 5, leafPaint);
    canvas.drawCircle(Offset(bedLeft - 40, bedTop - 1), 3.5, leafPaint);

    // Lamparita de noche (Circuito Dimmer) sobre la mesa
    final lampX = bedLeft - 22;
    final lampY = bedTop + 2;
    final dimmerRatio = (dimmerBrightness / 100.0).clamp(0.0, 1.0);

    if (dimmerBrightness > 0) {
      final dimmerGlowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFD54F).withValues(alpha: 0.55 * dimmerRatio),
            const Color(0xFFFFB300).withValues(alpha: 0.22 * dimmerRatio),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(
          center: Offset(lampX, lampY - 8),
          radius: 56 * dimmerRatio + 12,
        ));
      canvas.drawCircle(
        Offset(lampX, lampY - 8),
        56 * dimmerRatio + 12,
        dimmerGlowPaint,
      );
    }

    // Pie de la lámpara
    final lampBasePaint = Paint()
      ..color = isLightOn ? const Color(0xFFCBD5E1) : const Color(0xFF64748B)
      ..strokeWidth = 2.0;
    canvas.drawLine(Offset(lampX, lampY), Offset(lampX, lampY - 7), lampBasePaint);

    // Pantalla de la lámpara
    final lampShadePath = Path()
      ..moveTo(lampX - 7, lampY - 7)
      ..lineTo(lampX + 7, lampY - 7)
      ..lineTo(lampX + 4.5, lampY - 16)
      ..lineTo(lampX - 4.5, lampY - 16)
      ..close();
    final lampShadePaint = Paint()
      ..color = dimmerBrightness > 0
          ? Color.lerp(const Color(0xFFE2E8F0), const Color(0xFFFDE047), dimmerRatio)!
          : const Color(0xFF475569)
      ..style = PaintingStyle.fill;
    canvas.drawPath(lampShadePath, lampShadePaint);

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
    return oldDelegate.isLightOn != isLightOn ||
        oldDelegate.dimmerBrightness != dimmerBrightness;
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
          height: 52,
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

        // Bombilla incandescente con animación de brillo rápida (220ms)
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
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

/// Dibuja el filamento de tungsteno en el centro de la bombilla
class _FilamentPainter extends CustomPainter {
  final double glowProgress;

  _FilamentPainter({required this.glowProgress});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Cables soporte del filamento
    final leadWirePaint = Paint()
      ..color = Color.lerp(
        const Color(0xFF64748B),
        const Color(0xFFFFE082),
        glowProgress,
      )!
      ..strokeWidth = 1.2;

    canvas.drawLine(Offset(width * 0.35, height * 0.8), Offset(width * 0.4, height * 0.4), leadWirePaint);
    canvas.drawLine(Offset(width * 0.65, height * 0.8), Offset(width * 0.6, height * 0.4), leadWirePaint);

    // Filamento helicoidal brillante
    final filamentPath = Path()
      ..moveTo(width * 0.4, height * 0.4)
      ..quadraticBezierTo(width * 0.45, height * 0.2, width * 0.5, height * 0.35)
      ..quadraticBezierTo(width * 0.55, height * 0.5, width * 0.6, height * 0.4);

    final filamentPaint = Paint()
      ..color = Color.lerp(
        const Color(0xFF475569),
        Colors.white,
        glowProgress,
      )!
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    canvas.drawPath(filamentPath, filamentPaint);
  }

  @override
  bool shouldRepaint(covariant _FilamentPainter oldDelegate) {
    return oldDelegate.glowProgress != glowProgress;
  }
}
