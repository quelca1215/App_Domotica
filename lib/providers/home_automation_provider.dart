import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/device_state.dart';
import '../models/esp32_config.dart';
import '../services/esp32_ap_service.dart';
import '../services/storage_service.dart';

class HomeAutomationProvider extends ChangeNotifier {
  final Esp32ApService _esp32Service = Esp32ApService();

  bool _foco1Encendido = false;
  bool _foco2Encendido = false;
  int _tiempoEncendidoSeg = 60;

  ESP32ConnectionStatus _connectionStatus = ESP32ConnectionStatus.disconnected;
  String? _connectionError;
  bool _isESP32Available = false;
  DeviceTelemetry _telemetry = DeviceTelemetry(lastSeen: DateTime.now());
  Esp32Config _config = const Esp32Config();
  bool _isInitialized = false;

  Timer? _foco1Timer;
  int _foco1Seconds = 0;

  Timer? _foco2CountdownTimer;
  int _foco2RemainingSeconds = 0;

  Timer? _simulationTimer;
  final List<String> _eventLogs = [];

  // Getters
  bool get foco1Encendido => _foco1Encendido;
  bool get foco2Encendido => _foco2Encendido;
  int get tiempoEncendidoSeg => _tiempoEncendidoSeg;
  ESP32ConnectionStatus get connectionStatus => _connectionStatus;
  String? get connectionError => _connectionError;
  bool get isESP32Available => _config.useSimulation ? true : _isESP32Available;
  DeviceTelemetry get telemetry => _telemetry;
  Esp32Config get config => _config;
  bool get isInitialized => _isInitialized;
  int get foco1Seconds => _foco1Seconds;
  int get foco2RemainingSeconds => _foco2RemainingSeconds;
  List<String> get eventLogs => List.unmodifiable(_eventLogs);

  String get formattedFoco1Runtime {
    final minutes = (_foco1Seconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_foco1Seconds % 60).toString().padLeft(2, '0');
    final hours = (_foco1Seconds ~/ 3600).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  HomeAutomationProvider() {
    _setupCallbacks();
  }

  void _setupCallbacks() {
    _esp32Service.onStatusReceived = ({
      required bool foco1,
      required bool foco2,
      required int tiempoSegundos,
      required bool dhtOk,
      required double temp,
      required double hum,
    }) {
      _isESP32Available = true;

      // Sincronizar Foco 1
      if (_foco1Encendido != foco1) {
        _foco1Encendido = foco1;
        _addLog('Foco 1 (Interruptor/App): ${foco1 ? "ENCENDIDO" : "APAGADO"}');
        if (foco1) {
          _startFoco1Timer();
        } else {
          _stopFoco1Timer();
        }
      }

      // Sincronizar Foco 2
      if (_foco2Encendido != foco2) {
        _foco2Encendido = foco2;
        _addLog('Foco 2 (Sensor IR): ${foco2 ? "ENCENDIDO (Detección)" : "APAGADO"}');
        if (foco2) {
          _startFoco2Countdown(tiempoSegundos);
        } else {
          _foco2CountdownTimer?.cancel();
          _foco2RemainingSeconds = 0;
        }
      }

      // Sincronizar tiempo configurado
      if (_tiempoEncendidoSeg != tiempoSegundos) {
        _tiempoEncendidoSeg = tiempoSegundos;
      }

      _telemetry = _telemetry.copyWith(
        foco1: foco1,
        foco2: foco2,
        tiempoSegundos: tiempoSegundos,
        dhtOk: dhtOk,
        temperature: temp,
        humidity: hum,
        lastSeen: DateTime.now(),
      );

      notifyListeners();
    };

    _esp32Service.onConnectionStatusChanged = (status, error) {
      _connectionStatus = status;
      _connectionError = error;
      if (status == ESP32ConnectionStatus.online) {
        _isESP32Available = true;
        _addLog('Conectado a ESP32 (${_config.ipAddress})');
      } else if (status == ESP32ConnectionStatus.disconnected) {
        _isESP32Available = false;
        _addLog('Sin conexión con ESP32 en ${_config.baseUrl}');
      }
      notifyListeners();
    };
  }

  Future<void> initialize() async {
    _config = await StorageService.loadEsp32Config();
    _foco1Encendido = await StorageService.loadLastRelayState();

    _addLog('Iniciando en SoftAP (${_config.apSsid} / ${_config.ipAddress})');
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

    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_config.useSimulation) return;
      final rand = Random();
      final tempVariation = (rand.nextDouble() - 0.5) * 0.4;
      final humVariation = (rand.nextDouble() - 0.5) * 0.8;

      _telemetry = _telemetry.copyWith(
        dhtOk: true,
        temperature: double.parse((24.0 + tempVariation).toStringAsFixed(1)),
        humidity: double.parse((50.0 + humVariation).toStringAsFixed(1)),
        foco1: _foco1Encendido,
        foco2: _foco2Encendido,
        tiempoSegundos: _tiempoEncendidoSeg,
        lastSeen: DateTime.now(),
      );
      notifyListeners();
    });
  }

  /// Conmuta el Foco 1 (App / Interruptor)
  Future<void> toggleFoco1() async {
    await setFoco1(!_foco1Encendido);
  }

  Future<void> setFoco1(bool turnOn) async {
    if (_foco1Encendido == turnOn) return;

    _foco1Encendido = turnOn;
    _addLog('Comando Foco 1: ${turnOn ? "ENCENDIDO" : "APAGADO"}');

    if (turnOn) {
      _startFoco1Timer();
    } else {
      _stopFoco1Timer();
    }

    notifyListeners();
    unawaited(StorageService.saveLastRelayState(_foco1Encendido));

    if (!_config.useSimulation) {
      _esp32Service.setFoco1(turnOn).then((success) {
        if (!success) {
          _addLog('Aviso: Falló el comando HTTP hacia Foco 1');
        }
      });
    }
  }

  /// Guarda el nuevo tiempo de encendido para el Foco 2 (Sensor IR)
  Future<void> setTiempoIR(int segundos) async {
    final clamped = segundos.clamp(1, 3600);
    _tiempoEncendidoSeg = clamped;
    _addLog('Tiempo de Foco 2 (IR) actualizado a: $clamped seg');
    notifyListeners();

    if (!_config.useSimulation) {
      final ok = await _esp32Service.setTiempoIR(clamped);
      if (!ok) {
        _addLog('Aviso: Falló el envío de nuevo tiempo al ESP32');
      }
    }
  }

  /// Simular detección de movimiento IR (útil para pruebas y modo demo)
  void simulateTriggerIR() {
    _foco2Encendido = true;
    _foco2RemainingSeconds = _tiempoEncendidoSeg;
    _addLog('¡Sensor IR activado! (Objeto detectado)');
    notifyListeners();

    _foco2CountdownTimer?.cancel();
    _foco2CountdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_foco2RemainingSeconds > 0) {
        _foco2RemainingSeconds--;
        notifyListeners();
      } else {
        _foco2Encendido = false;
        _addLog('Temporizador IR completado. Foco 2 APAGADO');
        timer.cancel();
        notifyListeners();
      }
    });
  }

  void _startFoco2Countdown(int seconds) {
    _foco2RemainingSeconds = seconds;
    _foco2CountdownTimer?.cancel();
    _foco2CountdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_foco2RemainingSeconds > 0) {
        _foco2RemainingSeconds--;
        notifyListeners();
      } else {
        _foco2RemainingSeconds = 0;
        timer.cancel();
        notifyListeners();
      }
    });
  }

  void _startFoco1Timer() {
    _foco1Timer?.cancel();
    _foco1Timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _foco1Seconds++;
      notifyListeners();
    });
  }

  void _stopFoco1Timer() {
    _foco1Timer?.cancel();
    _foco1Seconds = 0;
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
      _addLog('Modo Simulación Activado');
    } else {
      _simulationTimer?.cancel();
      if (changedHost || changedSim) {
        _addLog('Conectando a ESP32: ${newConfig.baseUrl}');
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
    _foco1Timer?.cancel();
    _foco2CountdownTimer?.cancel();
    _simulationTimer?.cancel();
    _esp32Service.dispose();
    super.dispose();
  }
}
