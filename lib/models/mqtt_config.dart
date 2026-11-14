class MqttConfig {
  final String broker;
  final int port;
  final String clientId;
  final String? username;
  final String? password;
  final String topicCommand;
  final String topicStatus;
  final String topicAvailability;
  final String topicTelemetry;
  final String topicMode;
  final String topicLightSensor;
  final String topicManualSwitch;
  final bool useSimulation;

  const MqttConfig({
    this.broker = 'broker.emqx.io',
    this.port = 1883,
    this.clientId = '',
    this.username,
    this.password,
    this.topicCommand = 'domotica/cuarto/luz/set',
    this.topicStatus = 'domotica/cuarto/luz/state',
    this.topicAvailability = 'domotica/cuarto/esp32/status',
    this.topicTelemetry = 'domotica/cuarto/telemetria',
    this.topicMode = 'domotica/cuarto/modo',
    this.topicLightSensor = 'domotica/cuarto/fotocelula',
    this.topicManualSwitch = 'domotica/cuarto/interruptor_manual',
    this.useSimulation = false,
  });

  MqttConfig copyWith({
    String? broker,
    int? port,
    String? clientId,
    String? username,
    String? password,
    String? topicCommand,
    String? topicStatus,
    String? topicAvailability,
    String? topicTelemetry,
    String? topicMode,
    String? topicLightSensor,
    String? topicManualSwitch,
    bool? useSimulation,
  }) {
    return MqttConfig(
      broker: broker ?? this.broker,
      port: port ?? this.port,
      clientId: clientId ?? this.clientId,
      username: username ?? this.username,
      password: password ?? this.password,
      topicCommand: topicCommand ?? this.topicCommand,
      topicStatus: topicStatus ?? this.topicStatus,
      topicAvailability: topicAvailability ?? this.topicAvailability,
      topicTelemetry: topicTelemetry ?? this.topicTelemetry,
      topicMode: topicMode ?? this.topicMode,
      topicLightSensor: topicLightSensor ?? this.topicLightSensor,
      topicManualSwitch: topicManualSwitch ?? this.topicManualSwitch,
      useSimulation: useSimulation ?? this.useSimulation,
    );
  }

  factory MqttConfig.fromJson(Map<String, dynamic> json) {
    return MqttConfig(
      broker: json['broker']?.toString() ?? 'broker.emqx.io',
      port: (json['port'] as num?)?.toInt() ?? 1883,
      clientId: json['clientId']?.toString() ?? '',
      username: json['username']?.toString(),
      password: json['password']?.toString(),
      topicCommand: json['topicCommand']?.toString() ?? 'domotica/cuarto/luz/set',
      topicStatus: json['topicStatus']?.toString() ?? 'domotica/cuarto/luz/state',
      topicAvailability:
          json['topicAvailability']?.toString() ?? 'domotica/cuarto/esp32/status',
      topicTelemetry:
          json['topicTelemetry']?.toString() ?? 'domotica/cuarto/telemetria',
      topicMode: json['topicMode']?.toString() ?? 'domotica/cuarto/modo',
      topicLightSensor:
          json['topicLightSensor']?.toString() ?? 'domotica/cuarto/fotocelula',
      topicManualSwitch: json['topicManualSwitch']?.toString() ??
          'domotica/cuarto/interruptor_manual',
      useSimulation: json['useSimulation'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'broker': broker,
        'port': port,
        'clientId': clientId,
        'username': username,
        'password': password,
        'topicCommand': topicCommand,
        'topicStatus': topicStatus,
        'topicAvailability': topicAvailability,
        'topicTelemetry': topicTelemetry,
        'topicMode': topicMode,
        'topicLightSensor': topicLightSensor,
        'topicManualSwitch': topicManualSwitch,
        'useSimulation': useSimulation,
      };
}
