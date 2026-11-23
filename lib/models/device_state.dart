enum RelayState {
  open,
  closed,
}

enum OperatingMode {
  app,
  photocell,
  manual,
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
  final bool dhtOk;
  final bool foco1;
  final bool foco2;
  final int tiempoSegundos;
  final DateTime lastSeen;

  const DeviceTelemetry({
    this.temperature = 24.0,
    this.humidity = 50.0,
    this.dhtOk = true,
    this.foco1 = false,
    this.foco2 = false,
    this.tiempoSegundos = 60,
    required this.lastSeen,
  });

  DeviceTelemetry copyWith({
    double? temperature,
    double? humidity,
    bool? dhtOk,
    bool? foco1,
    bool? foco2,
    int? tiempoSegundos,
    DateTime? lastSeen,
  }) {
    return DeviceTelemetry(
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      dhtOk: dhtOk ?? this.dhtOk,
      foco1: foco1 ?? this.foco1,
      foco2: foco2 ?? this.foco2,
      tiempoSegundos: tiempoSegundos ?? this.tiempoSegundos,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }

  factory DeviceTelemetry.fromJson(Map<String, dynamic> json) {
    return DeviceTelemetry(
      temperature: (json['temp'] as num?)?.toDouble() ?? 0.0,
      humidity: (json['hum'] as num?)?.toDouble() ?? 0.0,
      dhtOk: json['dhtOk'] as bool? ?? false,
      foco1: json['foco1'] as bool? ?? false,
      foco2: json['foco2'] as bool? ?? false,
      tiempoSegundos: (json['tiempo'] as num?)?.toInt() ?? 60,
      lastSeen: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'temp': temperature,
        'hum': humidity,
        'dhtOk': dhtOk,
        'foco1': foco1,
        'foco2': foco2,
        'tiempo': tiempoSegundos,
        'timestamp': lastSeen.toIso8601String(),
      };
}
