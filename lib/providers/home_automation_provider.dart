import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/device_state.dart';
import '../models/esp32_config.dart';
import '../services/esp32_ap_service.dart';
import '../services/storage_service.dart';

class HomeAutomationProvider extends ChangeNotifier {
  final Esp32ApService _esp32Service = Esp32ApService();

  bool _isLightOn = false;
  ESP32ConnectionStatus _connectionStatus = ESP32ConnectionStatus.disconnected;
  String? _connectionError;
  bool _isESP32Available = false;
  DeviceTelemetry _telemetry = DeviceTelemetry(lastSeen: DateTime.now());
  Esp32Config _config = const Esp32Config();
  bool _isInitialized = false;

  OperatingMode _operatingMode = OperatingMode.app;
  int _dimmerBrightness = 0;

  Timer? _runtimeTimer;
  int _secondsOn = 0;

  Timer? _simulationTelemetryTimer;
  Timer? _dimmerDebounceTimer;
  final List<String> _eventLogs = [];

  // Getters
  bool get isLightOn => _isLightOn;
  int get dimmerBrightness => _dimmerBrightness;
  RelayState get relayState => _isLightOn ? RelayState.closed : RelayState.open;
  ESP32ConnectionStatus get connectionStatus => _connectionStatus;
  String? get connectionError => _connectionError;
  bool get isESP32Available => _config.useSimulation ? true : _isESP32Available;
  DeviceTelemetry get telemetry => _telemetry;
  Esp32Config get config => _config;
  bool get isInitialized => _isInitialized;
  int get secondsOn => _secondsOn;
  List<String> get eventLogs => List.unmodifiable(_eventLogs);
  OperatingMode get operatingMode => _operatingMode;
  double get ambientLightLevel => _telemetry.ambientLightLevel;
  bool get isManualSwitchClosed => _telemetry.isManualSwitchClosed;

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
    _esp32Service.onRelayStateReceived = (bool isOn) {
      _isESP32Available = true;
      _addLog('ESP32 reportó foco: ${isOn ? "ENCENDIDO" : "APAGADO"}');
      _setLightInternal(isOn, notifyESP32: false);
    };

    _esp32Service.onDimmerReceived = (int brillo) {
      if (_dimmerBrightness != brillo) {
        _dimmerBrightness = brillo;
        _addLog('Dimmer sincronizado con ESP32: $brillo%');
        notifyListeners();
      }
    };

    _esp32Service.onOperatingModeReceived = (OperatingMode mode) {
      if (_operatingMode != mode) {
        _operatingMode = mode;
        _addLog('Modo sincronizado con ESP32: ${_modeName(mode)}');
        _applyCurrentModeLogic();
        notifyListeners();
      }
    };

    _esp32Service.onLightSensorReceived = (double level) {
      _telemetry = _telemetry.copyWith(ambientLightLevel: level);
      if (_operatingMode == OperatingMode.photocell) {
        _applyCurrentModeLogic();
      } else {
        notifyListeners();
      }
    };

    _esp32Service.onManualSwitchReceived = (bool isClosed) {
      _telemetry = _telemetry.copyWith(isManualSwitchClosed: isClosed);
      if (_operatingMode == OperatingMode.manual) {
        _applyCurrentModeLogic();
      } else {
        notifyListeners();
      }
    };

    _esp32Service.onConnectionStatusChanged = (status, error) {
      _connectionStatus = status;
      _connectionError = error;
      if (status == ESP32ConnectionStatus.online) {
        _isESP32Available = true;
        _addLog('Conectado al punto de acceso ESP32 (${_config.ipAddress})');
      } else if (status == ESP32ConnectionStatus.disconnected) {
        _isESP32Available = false;
        _addLog('Sin conexión con ESP32 en ${_config.baseUrl}');
      }
      notifyListeners();
    };
  }

  Future<void> initialize() async {
    _config = await StorageService.loadEsp32Config();
    _isLightOn = await StorageService.loadLastRelayState();

    _addLog('Iniciando en modo Punto de Acceso (AP: ${_config.ipAddress})');
    _esp32Service.updateConfig(_config);

    if (_config.useSimulation) {
      _startSimulation();
    } else {
      _connectionStatus = ESP32ConnectionStatus.connecting;
      _esp32Service.startPolling();
    }

    _isInitialized = true;
    notifyListeners();
  }

  void _startSimulation() {
    _connectionStatus = ESP32ConnectionStatus.online;
    _isESP32Available = true;

    // Simular telemetría periódica en modo simulación
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
        rssi: -45,
        ipAddress: '${_config.ipAddress} (SoftAP)',
        lastSeen: DateTime.now(),
      );
      notifyListeners();
    });
  }

  Future<void> setOperatingMode(OperatingMode mode) async {
    if (_operatingMode == mode) return;

    _operatingMode = mode;
    _addLog('Modo cambiado a: ${_modeName(mode)}');

    if (!_config.useSimulation) {
      await _esp32Service.setModo(mode);
    }

    _applyCurrentModeLogic();
    notifyListeners();
  }

  void _applyCurrentModeLogic() {
    switch (_operatingMode) {
      case OperatingMode.app:
        break;
      case OperatingMode.photocell:
        final shouldTurnOn = _telemetry.ambientLightLevel < 40.0;
        setLight(shouldTurnOn);
        break;
      case OperatingMode.manual:
        setLight(_telemetry.isManualSwitchClosed);
        break;
    }
  }

  void setAmbientLightLevel(double level) {
    final clamped = level.clamp(0.0, 100.0);
    _telemetry = _telemetry.copyWith(ambientLightLevel: clamped);
    _addLog('Luz ambiental ajustada: ${clamped.toStringAsFixed(0)}%');

    if (_operatingMode == OperatingMode.photocell) {
      final shouldTurnOn = clamped < 40.0;
      setLight(shouldTurnOn);
    } else {
      notifyListeners();
    }
  }

  void setManualSwitch(bool isClosed) {
    _telemetry = _telemetry.copyWith(isManualSwitchClosed: isClosed);
    _addLog('Interruptor NA: ${isClosed ? "CERRADO" : "ABIERTO"}');

    if (_operatingMode == OperatingMode.manual) {
      setLight(isClosed);
    } else {
      notifyListeners();
    }
  }

  Future<void> toggleLight() async {
    if (_operatingMode == OperatingMode.app) {
      await setLight(!_isLightOn);
    }
  }

  Future<void> setLight(bool turnOn) async {
    await _setLightInternal(turnOn, notifyESP32: true);
  }

  Future<void> _setLightInternal(bool turnOn, {required bool notifyESP32}) async {
    if (_isLightOn == turnOn) return;

    _isLightOn = turnOn;

    if (_isLightOn) {
      _startRuntimeTimer();
      _telemetry = _telemetry.copyWith(powerWatts: 12.5);
      _addLog('Foco ENCENDIDO');
    } else {
      _stopRuntimeTimer();
      _telemetry = _telemetry.copyWith(powerWatts: 0.0);
      _addLog('Foco APAGADO');
    }

    // ⚡ Actualización visual instantánea (0ms de latencia)
    notifyListeners();

    // Guardar estado en almacenamiento de fondo
    unawaited(StorageService.saveLastRelayState(_isLightOn));

    // Enviar comando HTTP al ESP32 en segundo plano
    if (notifyESP32 && !_config.useSimulation) {
      _esp32Service.setFoco(turnOn).then((success) {
        if (!success) {
          _addLog('Aviso: Falló el envío HTTP al ESP32');
        }
      });
    }
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

  Future<void> updateConfig(Esp32Config newConfig) async {
    final changedSim = _config.useSimulation != newConfig.useSimulation;
    final changedHost = _config.ipAddress != newConfig.ipAddress ||
        _config.port != newConfig.port;

    _config = newConfig;
    await StorageService.saveEsp32Config(_config);
    _esp32Service.updateConfig(_config);

    if (newConfig.useSimulation) {
      _esp32Service.stopPolling();
      _startSimulation();
      _addLog('Activado Modo Simulación');
    } else {
      _simulationTelemetryTimer?.cancel();
      if (changedHost || changedSim) {
        _addLog('Conectando a Punto de Acceso ESP32: ${newConfig.baseUrl}');
        _connectionStatus = ESP32ConnectionStatus.connecting;
        _esp32Service.startPolling();
      }
    }

    notifyListeners();
  }

  Future<void> reconnect() async {
    if (_config.useSimulation) {
      _startSimulation();
      notifyListeners();
    } else {
      _connectionStatus = ESP32ConnectionStatus.connecting;
      notifyListeners();
      await _esp32Service.syncStatus();
    }
  }

  String _modeName(OperatingMode mode) {
    switch (mode) {
      case OperatingMode.app:
        return 'Control App';
      case OperatingMode.photocell:
        return 'Fotocélula (Inteligente)';
      case OperatingMode.manual:
        return 'Interruptor NA (Manual)';
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

  /// Ajusta el brillo del circuito Dimmer (0 a 100%) con debounce suave
  void setDimmerBrightness(int brightness) {
    final clamped = brightness.clamp(0, 100);
    if (_dimmerBrightness == clamped) return;

    _dimmerBrightness = clamped;
    notifyListeners();

    _dimmerDebounceTimer?.cancel();
    _dimmerDebounceTimer = Timer(const Duration(milliseconds: 140), () {
      _esp32Service.setDimmer(_dimmerBrightness);
      _addLog('Dimmer regulado a $_dimmerBrightness%');
    });
  }

  @override
  void dispose() {
    _dimmerDebounceTimer?.cancel();
    _runtimeTimer?.cancel();
    _simulationTelemetryTimer?.cancel();
    _esp32Service.dispose();
    super.dispose();
  }
}
