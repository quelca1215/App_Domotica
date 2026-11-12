enum RelayState {
  open, // Circuito abierto: Foco apagado (desconectado)
  closed, // Circuito cerrado: Foco encendido (conduciendo corriente)
}

enum ESP32ConnectionStatus {
  disconnected,
  connecting,
  online,
  error,
}

class DeviceTelemetry {
  final double temperature;
  final double humidity;
  final double powerWatts;
  final int rssi;
  final String ipAddress;
  final DateTime lastSeen;

  const DeviceTelemetry({
    this.temperature = 23.5,
    this.humidity = 48.0,
    this.powerWatts = 0.0,
    this.rssi = -64,
    this.ipAddress = 'En espera de ESP32...',
    required this.lastSeen,
  });

  DeviceTelemetry copyWith({
    double? temperature,
    double? humidity,
    double? powerWatts,
    int? rssi,
    String? ipAddress,
    DateTime? lastSeen,
  }) {
    return DeviceTelemetry(
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      powerWatts: powerWatts ?? this.powerWatts,
      rssi: rssi ?? this.rssi,
      ipAddress: ipAddress ?? this.ipAddress,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }

  factory DeviceTelemetry.fromJson(Map<String, dynamic> json) {
    return DeviceTelemetry(
      temperature: (json['temperature'] as num?)?.toDouble() ?? 23.5,
      humidity: (json['humidity'] as num?)?.toDouble() ?? 48.0,
      powerWatts: (json['powerWatts'] as num?)?.toDouble() ?? 0.0,
      rssi: (json['rssi'] as num?)?.toInt() ?? -65,
      ipAddress: json['ip']?.toString() ?? '192.168.1.100',
      lastSeen: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'temperature': temperature,
        'humidity': humidity,
        'powerWatts': powerWatts,
        'rssi': rssi,
        'ip': ipAddress,
        'timestamp': lastSeen.toIso8601String(),
      };
}
