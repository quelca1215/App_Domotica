class Esp32Config {
  final String ipAddress;
  final int port;
  final String apSsid;
  final bool useSimulation;

  const Esp32Config({
    this.ipAddress = '192.168.4.1',
    this.port = 80,
    this.apSsid = 'ESP32_Domotica',
    this.useSimulation = false,
  });

  String get baseUrl => 'http://$ipAddress:$port';

  Esp32Config copyWith({
    String? ipAddress,
    int? port,
    String? apSsid,
    bool? useSimulation,
  }) {
    return Esp32Config(
      ipAddress: ipAddress ?? this.ipAddress,
      port: port ?? this.port,
      apSsid: apSsid ?? this.apSsid,
      useSimulation: useSimulation ?? this.useSimulation,
    );
  }

  factory Esp32Config.fromJson(Map<String, dynamic> json) {
    return Esp32Config(
      ipAddress: json['ipAddress']?.toString() ?? '192.168.4.1',
      port: (json['port'] as num?)?.toInt() ?? 80,
      apSsid: json['apSsid']?.toString() ?? 'ESP32_Domotica',
      useSimulation: json['useSimulation'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'ipAddress': ipAddress,
        'port': port,
        'apSsid': apSsid,
        'useSimulation': useSimulation,
      };
}
