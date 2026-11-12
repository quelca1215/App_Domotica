import 'package:flutter/material.dart';
import '../models/mqtt_config.dart';

class SettingsSheet extends StatefulWidget {
  final MqttConfig currentConfig;
  final List<String> eventLogs;
  final ValueChanged<MqttConfig> onSave;

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
  late TextEditingController _brokerController;
  late TextEditingController _portController;
  late TextEditingController _clientIdController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _cmdTopicController;
  late TextEditingController _statusTopicController;
  late TextEditingController _availTopicController;
  late bool _useSimulation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final c = widget.currentConfig;
    _brokerController = TextEditingController(text: c.broker);
    _portController = TextEditingController(text: c.port.toString());
    _clientIdController = TextEditingController(text: c.clientId);
    _usernameController = TextEditingController(text: c.username ?? '');
    _passwordController = TextEditingController(text: c.password ?? '');
    _cmdTopicController = TextEditingController(text: c.topicCommand);
    _statusTopicController = TextEditingController(text: c.topicStatus);
    _availTopicController = TextEditingController(text: c.topicAvailability);
    _useSimulation = c.useSimulation;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _brokerController.dispose();
    _portController.dispose();
    _clientIdController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _cmdTopicController.dispose();
    _statusTopicController.dispose();
    _availTopicController.dispose();
    super.dispose();
  }

  void _save() {
    final port = int.tryParse(_portController.text.trim()) ?? 1883;
    final newConfig = widget.currentConfig.copyWith(
      broker: _brokerController.text.trim(),
      port: port,
      clientId: _clientIdController.text.trim(),
      username: _usernameController.text.trim().isEmpty
          ? null
          : _usernameController.text.trim(),
      password: _passwordController.text.trim().isEmpty
          ? null
          : _passwordController.text.trim(),
      topicCommand: _cmdTopicController.text.trim(),
      topicStatus: _statusTopicController.text.trim(),
      topicAvailability: _availTopicController.text.trim(),
      useSimulation: _useSimulation,
    );

    widget.onSave(newConfig);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
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
                    Icon(Icons.tune_rounded, color: Color(0xFF38BDF8), size: 22),
                    SizedBox(width: 10),
                    Text(
                      'Configuración IoT (Nube)',
                      style: TextStyle(
                        fontSize: 18,
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
              Tab(text: 'Servidor y Topics'),
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
              height: 52,
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
                  'GUARDAR Y APLICAR CAMBIOS',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
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
        // Switch de Simulación
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
                      'Modo Simulación Virtual',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _useSimulation
                          ? 'Prueba la app de inmediato sin ESP32 encendido'
                          : 'Conectando a broker MQTT real en internet',
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
          'BROKER MQTT (ACCESO POR INTERNET)',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF94A3B8),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              flex: 3,
              child: _buildTextField(
                controller: _brokerController,
                label: 'Broker Host',
                hint: 'broker.emqx.io o hivemq',
                icon: Icons.dns_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 1,
              child: _buildTextField(
                controller: _portController,
                label: 'Puerto',
                hint: '1883',
                keyboardType: TextInputType.number,
                icon: Icons.tag_rounded,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _usernameController,
                label: 'Usuario (opcional)',
                hint: 'Dejar vacío si es público',
                icon: Icons.person_outline_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildTextField(
                controller: _passwordController,
                label: 'Contraseña (opcional)',
                hint: '••••••',
                obscureText: true,
                icon: Icons.lock_outline_rounded,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),
        const Text(
          'TOPICS DE COMUNICACIÓN (ESP32)',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF94A3B8),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),

        _buildTextField(
          controller: _cmdTopicController,
          label: 'Topic Comandos (App -> ESP32)',
          hint: 'domotica/cuarto/luz/set',
          icon: Icons.send_rounded,
        ),
        const SizedBox(height: 10),
        _buildTextField(
          controller: _statusTopicController,
          label: 'Topic Estado (ESP32 -> App)',
          hint: 'domotica/cuarto/luz/state',
          icon: Icons.sync_rounded,
        ),
        const SizedBox(height: 10),
        _buildTextField(
          controller: _availTopicController,
          label: 'Topic Disponibilidad LWT (Online/Offline)',
          hint: 'domotica/cuarto/esp32/status',
          icon: Icons.wifi_find_rounded,
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
        final isError = log.toLowerCase().contains('error');
        final isSuccess = log.toLowerCase().contains('exitos') ||
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
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
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
