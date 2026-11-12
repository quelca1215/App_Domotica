import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/device_state.dart';
import '../models/mqtt_config.dart';
import '../services/mqtt_service.dart';
import '../services/storage_service.dart';

class HomeAutomationProvider extends ChangeNotifier {
  final MqttService _mqttService = MqttService();

  bool _isLightOn = false;
  ESP32ConnectionStatus _connectionStatus = ESP32ConnectionStatus.disconnected;
  String? _connectionError;
  bool _isESP32Available = false; // Se activa cuando el ESP32 envía status o LWT online
  DeviceTelemetry _telemetry = DeviceTelemetry(lastSeen: DateTime.now());
  MqttConfig _config = const MqttConfig();
  bool _isInitialized = false;

  Timer? _runtimeTimer;
  int _secondsOn = 0;

  Timer? _simulationTelemetryTimer;
  final List<String> _eventLogs = [];

  // Getters
  bool get isLightOn => _isLightOn;
  RelayState get relayState => _isLightOn ? RelayState.closed : RelayState.open;
  ESP32ConnectionStatus get connectionStatus => _connectionStatus;
  String? get connectionError => _connectionError;
  bool get isESP32Available => _config.useSimulation ? true : _isESP32Available;
  DeviceTelemetry get telemetry => _telemetry;
  MqttConfig get config => _config;
  bool get isInitialized => _isInitialized;
  int get secondsOn => _secondsOn;
  List<String> get eventLogs => List.unmodifiable(_eventLogs);

  String get formattedRuntime {
    final minutes = (_secondsOn ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsOn % 60).toString().padLeft(2, '0');
    final hours = (_secondsOn ~/ 3600).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  HomeAutomationProvider() {
    _setupCallbacks();
  }

  void _setupCallbacks() {
    _mqttService.onRelayStateReceived = (bool isOn) {
      _isESP32Available = true;
      _addLog('ESP32 reportó estado: ${isOn ? "ENCENDIDO" : "APAGADO"}');
      _setLightInternal(isOn, notifyESP32: false);
    };

    _mqttService.onAvailabilityReceived = (bool isOnline) {
      _isESP32Available = isOnline;
      _addLog('ESP32 ${isOnline ? "en línea (Cloud)" : "desconectado"}');
      notifyListeners();
    };

    _mqttService.onTelemetryReceived = (Map<String, dynamic> data) {
      _telemetry = DeviceTelemetry.fromJson(data);
      _addLog('Telemetría recibida: ${_telemetry.temperature}°C, ${_telemetry.humidity}%');
      notifyListeners();
    };

    _mqttService.onConnectionStatusChanged = (status, error) {
      _connectionStatus = status;
      _connectionError = error;
      if (status == ESP32ConnectionStatus.online) {
        _addLog('Conectado exitosamente al broker ${_config.broker}');
      } else if (status == ESP32ConnectionStatus.error) {
        _addLog('Error de conexión MQTT: ${error ?? "Desconocido"}');
      }
      notifyListeners();
    };
  }

  Future<void> initialize() async {
    _config = await StorageService.loadConfig();
    _isLightOn = await StorageService.loadLastRelayState();

    _addLog('App iniciada. Modo: ${_config.useSimulation ? "Simulador Virtual" : "MQTT Real"}');

    if (_config.useSimulation) {
      _startSimulation();
    } else {
      await _connectMqtt();
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _connectMqtt() async {
    _connectionStatus = ESP32ConnectionStatus.connecting;
    notifyListeners();
    await _mqttService.connect(_config);
  }

  void _startSimulation() {
    _connectionStatus = ESP32ConnectionStatus.online;
    _isESP32Available = true;

    // Simular telemetría cada 8 segundos con pequeñas variaciones naturales
    _simulationTelemetryTimer?.cancel();
    _simulationTelemetryTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (!_config.useSimulation) return;
      final rand = Random();
      final tempVariation = (rand.nextDouble() - 0.5) * 0.4;
      final humVariation = (rand.nextDouble() - 0.5) * 0.8;

      _telemetry = _telemetry.copyWith(
        temperature: double.parse((24.2 + tempVariation).toStringAsFixed(1)),
        humidity: double.parse((50.0 + humVariation).toStringAsFixed(1)),
        powerWatts: _isLightOn ? 12.4 + rand.nextDouble() * 0.4 : 0.0,
        rssi: -58 - rand.nextInt(10),
        ipAddress: '192.168.1.145 (WiFi Hogar)',
        lastSeen: DateTime.now(),
      );
      notifyListeners();
    });
  }

  Future<void> toggleLight() async {
    await setLight(!_isLightOn);
  }

  Future<void> setLight(bool turnOn) async {
    await _setLightInternal(turnOn, notifyESP32: true);
  }

  Future<void> _setLightInternal(bool turnOn, {required bool notifyESP32}) async {
    if (_isLightOn == turnOn) return;

    _isLightOn = turnOn;
    await StorageService.saveLastRelayState(_isLightOn);

    if (_isLightOn) {
      _startRuntimeTimer();
      _telemetry = _telemetry.copyWith(powerWatts: 12.5);
      _addLog('Acción: Relé CERRADO -> Foco ENCENDIDO');
    } else {
      _stopRuntimeTimer();
      _telemetry = _telemetry.copyWith(powerWatts: 0.0);
      _addLog('Acción: Relé ABIERTO -> Foco APAGADO');
    }

    if (notifyESP32 && !_config.useSimulation) {
      final success = await _mqttService.publishRelayCommand(turnOn);
      if (!success) {
        _addLog('Advertencia: Comando MQTT no pudo enviarse');
      }
    }

    notifyListeners();
  }

  void _startRuntimeTimer() {
    _runtimeTimer?.cancel();
    _runtimeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _secondsOn++;
      notifyListeners();
    });
  }

  void _stopRuntimeTimer() {
    _runtimeTimer?.cancel();
    _secondsOn = 0;
  }

  Future<void> updateConfig(MqttConfig newConfig) async {
    final changedMode = _config.useSimulation != newConfig.useSimulation;
    final changedBroker = _config.broker != newConfig.broker ||
        _config.port != newConfig.port ||
        _config.username != newConfig.username ||
        _config.password != newConfig.password;

    _config = newConfig;
    await StorageService.saveConfig(_config);

    if (newConfig.useSimulation) {
      _mqttService.disconnect();
      _startSimulation();
      _addLog('Cambiado a modo Simulación Virtual');
    } else {
      _simulationTelemetryTimer?.cancel();
      if (changedBroker || changedMode) {
        _addLog('Reconectando al broker MQTT: ${newConfig.broker}');
        await _connectMqtt();
      }
    }

    notifyListeners();
  }

  Future<void> reconnect() async {
    if (_config.useSimulation) {
      _startSimulation();
      notifyListeners();
    } else {
      await _connectMqtt();
    }
  }

  void _addLog(String message) {
    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    _eventLogs.insert(0, '[$timeStr] $message');
    if (_eventLogs.length > 50) {
      _eventLogs.removeLast();
    }
  }

  @override
  void dispose() {
    _runtimeTimer?.cancel();
    _simulationTelemetryTimer?.cancel();
    _mqttService.disconnect();
    super.dispose();
  }
}
