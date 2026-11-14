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

enum OperatingMode {
  app, // 1. Modo Encendido con la App
  photocell, // 2. Modo Inteligente con Fotocélula (Sensor de Luz)
  manual, // 3. Modo Manual con Interruptor Normalmente Abierto (NA)
}

class DeviceTelemetry {
  final double temperature;
  final double humidity;
  final double powerWatts;
  final double ambientLightLevel; // 0% (Oscuridad total) a 100% (Luz máxima solar)
  final bool isManualSwitchClosed; // Estado del interruptor físico NA
  final int rssi;
  final String ipAddress;
  final DateTime lastSeen;

  const DeviceTelemetry({
    this.temperature = 23.5,
    this.humidity = 48.0,
    this.powerWatts = 0.0,
    this.ambientLightLevel = 25.0, // Por defecto luz baja (enciende foco)
    this.isManualSwitchClosed = false,
    this.rssi = -64,
    this.ipAddress = 'En espera de ESP32...',
    required this.lastSeen,
  });

  DeviceTelemetry copyWith({
    double? temperature,
    double? humidity,
    double? powerWatts,
    double? ambientLightLevel,
    bool? isManualSwitchClosed,
    int? rssi,
    String? ipAddress,
    DateTime? lastSeen,
  }) {
    return DeviceTelemetry(
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      powerWatts: powerWatts ?? this.powerWatts,
      ambientLightLevel: ambientLightLevel ?? this.ambientLightLevel,
      isManualSwitchClosed: isManualSwitchClosed ?? this.isManualSwitchClosed,
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
      ambientLightLevel: (json['light'] as num?)?.toDouble() ?? 25.0,
      isManualSwitchClosed: json['manualSwitch'] as bool? ?? false,
      rssi: (json['rssi'] as num?)?.toInt() ?? -65,
      ipAddress: json['ip']?.toString() ?? '192.168.1.100',
      lastSeen: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'temperature': temperature,
        'humidity': humidity,
        'powerWatts': powerWatts,
        'light': ambientLightLevel,
        'manualSwitch': isManualSwitchClosed,
        'rssi': rssi,
        'ip': ipAddress,
        'timestamp': lastSeen.toIso8601String(),
      };
}
