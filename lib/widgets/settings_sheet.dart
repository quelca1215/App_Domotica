import 'package:flutter/material.dart';
import '../models/esp32_config.dart';

class SettingsSheet extends StatefulWidget {
  final Esp32Config currentConfig;
  final List<String> eventLogs;
  final ValueChanged<Esp32Config> onSave;

  const SettingsSheet({
    super.key,
    required this.currentConfig,
    required this.eventLogs,
    required this.onSave,
  });

  @override
  State<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _ipController;
  late TextEditingController _portController;
  late TextEditingController _ssidController;
  late bool _useSimulation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final c = widget.currentConfig;
    _ipController = TextEditingController(text: c.ipAddress);
    _portController = TextEditingController(text: c.port.toString());
    _ssidController = TextEditingController(text: c.apSsid);
    _useSimulation = c.useSimulation;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _ipController.dispose();
    _portController.dispose();
    _ssidController.dispose();
    super.dispose();
  }

  void _save() {
    final port = int.tryParse(_portController.text.trim()) ?? 80;
    final newConfig = widget.currentConfig.copyWith(
      ipAddress: _ipController.text.trim().isEmpty
          ? '192.168.4.1'
          : _ipController.text.trim(),
      port: port,
      apSsid: _ssidController.text.trim().isEmpty
          ? 'Aplicaciones_Moviles'
          : _ssidController.text.trim(),
      useSimulation: _useSimulation,
    );

    widget.onSave(newConfig);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      padding: const EdgeInsets.only(top: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Barra de arrastre
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Título
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.wifi_tethering_rounded,
                        color: Color(0xFF38BDF8), size: 22),
                    SizedBox(width: 10),
                    Text(
                      'Punto de Acceso ESP32',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, color: Colors.white54),
                ),
              ],
            ),
          ),

          // Tabs
          TabBar(
            controller: _tabController,
            indicatorColor: const Color(0xFF38BDF8),
            labelColor: const Color(0xFF38BDF8),
            unselectedLabelColor: Colors.white54,
            tabs: const [
              Tab(text: 'Conexión SoftAP'),
              Tab(text: 'Registro en Vivo (Logs)'),
            ],
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildConfigTab(),
                _buildLogsTab(),
              ],
            ),
          ),

          // Botón Guardar
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'GUARDAR Y CONECTAR AL ESP32',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Modo Simulación
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _useSimulation
                  ? const Color(0xFF6366F1).withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _useSimulation
                      ? const Color(0xFF6366F1).withValues(alpha: 0.2)
                      : const Color(0xFF334155),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.developer_board_rounded,
                  color: _useSimulation
                      ? const Color(0xFF818CF8)
                      : const Color(0xFF94A3B8),
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Modo Simulación (Demo)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _useSimulation
                          ? 'Prueba sin necesidad de conectarte al Wi-Fi del ESP32'
                          : 'Conectando al Wi-Fi del ESP32 en tiempo real',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _useSimulation,
                activeThumbColor: const Color(0xFF818CF8),
                onChanged: (val) {
                  setState(() {
                    _useSimulation = val;
                  });
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        const Text(
          'RED WI-FI EMITIDA POR EL ESP32',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF94A3B8),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),

        _buildTextField(
          controller: _ssidController,
          label: 'Nombre de Red Wi-Fi (SSID del ESP32)',
          hint: 'Aplicaciones_Moviles',
          icon: Icons.wifi_rounded,
        ),

        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
              flex: 3,
              child: _buildTextField(
                controller: _ipController,
                label: 'IP del ESP32 (SoftAP)',
                hint: '192.168.4.1',
                icon: Icons.router_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 1,
              child: _buildTextField(
                controller: _portController,
                label: 'Puerto',
                hint: '80',
                keyboardType: TextInputType.number,
                icon: Icons.tag_rounded,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF0B132B),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  color: Color(0xFF38BDF8), size: 18),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'El ESP32 emite su propia red Wi-Fi. Conecta tu teléfono a ella antes de operar la app en modo real.',
                  style: TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLogsTab() {
    if (widget.eventLogs.isEmpty) {
      return Center(
        child: Text(
          'No hay eventos registrados aún',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: widget.eventLogs.length,
      separatorBuilder: (context, index) => const Divider(
        color: Colors.white12,
        height: 1,
      ),
      itemBuilder: (context, index) {
        final log = widget.eventLogs[index];
        final isError = log.toLowerCase().contains('error') ||
            log.toLowerCase().contains('sin conexión');
        final isSuccess = log.toLowerCase().contains('conectado') ||
            log.toLowerCase().contains('encendido');

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            log,
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'monospace',
              color: isError
                  ? const Color(0xFFF87171)
                  : isSuccess
                      ? const Color(0xFF34D399)
                      : const Color(0xFFCBD5E1),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 13, color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 12,
          color: Colors.white.withValues(alpha: 0.6),
        ),
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 12,
          color: Colors.white.withValues(alpha: 0.3),
        ),
        prefixIcon: Icon(icon, size: 16, color: const Color(0xFF38BDF8)),
        filled: true,
        fillColor: const Color(0xFF1E293B),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF38BDF8), width: 1.5),
        ),
      ),
    );
  }
}
