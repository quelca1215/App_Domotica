import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IrSensorControlCard extends StatefulWidget {
  final bool isFoco2On;
  final int currentSeconds;
  final int remainingSeconds;
  final ValueChanged<int> onSaveSeconds;
  final VoidCallback? onSimulateTrigger;

  const IrSensorControlCard({
    super.key,
    required this.isFoco2On,
    required this.currentSeconds,
    required this.remainingSeconds,
    required this.onSaveSeconds,
    this.onSimulateTrigger,
  });

  @override
  State<IrSensorControlCard> createState() => _IrSensorControlCardState();
}

class _IrSensorControlCardState extends State<IrSensorControlCard> {
  late TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentSeconds.toString());
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant IrSensorControlCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentSeconds != widget.currentSeconds &&
        !_focusNode.hasFocus) {
      _controller.text = widget.currentSeconds.toString();
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final val = int.tryParse(_controller.text.trim());
    if (val != null && val >= 1 && val <= 3600) {
      widget.onSaveSeconds(val);
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tiempo de temporizador actualizado a $val segundos'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa un valor válido entre 1 y 3600 segundos.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOn = widget.isFoco2On;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF131B2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOn
              ? const Color(0xFFFACC15).withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.08),
          width: isOn ? 1.5 : 1.0,
        ),
        boxShadow: isOn
            ? [
                BoxShadow(
                  color: const Color(0xFFFACC15).withValues(alpha: 0.15),
                  blurRadius: 20,
                  spreadRadius: 1,
                )
              ]
            : null,
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
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFA855F7).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.sensors_rounded,
                        color: Color(0xFFA855F7),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Foco 2 (Sensor Infrarrojo)',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Activación automática por presencia',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white54,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isOn
                      ? const Color(0xFFFACC15).withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isOn
                        ? const Color(0xFFFACC15).withValues(alpha: 0.5)
                        : Colors.transparent,
                  ),
                ),
                child: Text(
                  isOn ? 'ENCENDIDO' : 'EN ESPERA',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: isOn ? const Color(0xFFFACC15) : Colors.white54,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Visualización del Estado y Cuenta Regresiva
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isOn
                        ? const Color(0xFFFACC15).withValues(alpha: 0.2)
                        : const Color(0xFF334155).withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lightbulb_rounded,
                    color: isOn ? const Color(0xFFFACC15) : const Color(0xFF64748B),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isOn
                            ? 'Objeto detectado por IR'
                            : 'Sin presencia detectada',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isOn ? Colors.white : Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isOn
                            ? 'Se apagará en aprox. ${widget.remainingSeconds > 0 ? widget.remainingSeconds : widget.currentSeconds}s'
                            : 'Configurado para durar ${widget.currentSeconds}s al activarse',
                        style: TextStyle(
                          fontSize: 12,
                          color: isOn ? const Color(0xFF38BDF8) : Colors.white38,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.onSimulateTrigger != null)
                  TextButton.icon(
                    onPressed: widget.onSimulateTrigger,
                    icon: const Icon(Icons.touch_app_rounded, size: 16),
                    label: const Text('Probar IR', style: TextStyle(fontSize: 11)),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFA855F7),
                      backgroundColor: const Color(0xFFA855F7).withValues(alpha: 0.12),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Entrada para configurar el tiempo
          const Text(
            'Configurar tiempo de encendido (segundos):',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ej. 60',
                    hintStyle: const TextStyle(color: Colors.white30),
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    suffixText: 'seg',
                    suffixStyle: const TextStyle(color: Color(0xFF38BDF8)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF38BDF8),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_rounded, size: 18),
                label: const Text('Guardar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF38BDF8),
                  foregroundColor: const Color(0xFF0F172A),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Botones de presets rápidos
          Wrap(
            spacing: 8,
            children: [10, 30, 60, 120, 300].map((sec) {
              final isCurrent = widget.currentSeconds == sec;
              return ActionChip(
                label: Text('${sec}s'),
                labelStyle: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isCurrent ? const Color(0xFF0F172A) : Colors.white70,
                ),
                backgroundColor: isCurrent ? const Color(0xFF38BDF8) : const Color(0xFF0F172A),
                side: BorderSide(
                  color: isCurrent ? const Color(0xFF38BDF8) : Colors.white12,
                ),
                onPressed: () {
                  _controller.text = sec.toString();
                  widget.onSaveSeconds(sec);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
