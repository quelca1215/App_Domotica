import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/device_state.dart';
import '../models/esp32_config.dart';

typedef OnRelayStateReceived = void Function(bool isOn);
typedef OnOperatingModeReceived = void Function(OperatingMode mode);
typedef OnLightSensorReceived = void Function(double lightLevel);
typedef OnManualSwitchReceived = void Function(bool isClosed);
typedef OnConnectionStatusChanged = void Function(ESP32ConnectionStatus status, String? error);

class Esp32ApService {
  Esp32Config _config = const Esp32Config();
  Timer? _pollingTimer;
  bool _isPolling = false;

  OnRelayStateReceived? onRelayStateReceived;
  OnOperatingModeReceived? onOperatingModeReceived;
  OnLightSensorReceived? onLightSensorReceived;
  OnManualSwitchReceived? onManualSwitchReceived;
  OnConnectionStatusChanged? onConnectionStatusChanged;

  ESP32ConnectionStatus _status = ESP32ConnectionStatus.disconnected;
  ESP32ConnectionStatus get status => _status;

  void updateConfig(Esp32Config config) {
    _config = config;
  }

  void startPolling() {
    stopPolling();
    // Sondeo periódico cada 2 segundos mientras esté conectado al AP
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!_isPolling && !_config.useSimulation) {
        syncStatus();
      }
    });
    // Primer intento inmediato
    syncStatus();
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  HttpClient _createClient() {
    final client = HttpClient();
    client.connectionTimeout = const Duration(milliseconds: 1800);
    return client;
  }

  /// Sincroniza el estado del ESP32 llamando a GET /status
  Future<bool> syncStatus() async {
    if (_config.useSimulation) return true;

    _isPolling = true;
    final client = _createClient();

    try {
      final uri = Uri.parse('${_config.baseUrl}/status');
      final request = await client.getUrl(uri);
      final response = await request.close();

      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final Map<String, dynamic> data = jsonDecode(body);

        _setStatus(ESP32ConnectionStatus.online);

        // 1. Estado del Foco
        if (data.containsKey('foco')) {
          final bool focoOn = data['foco'] == true ||
              data['foco'].toString().toUpperCase() == 'ON' ||
              data['foco'] == 1;
          onRelayStateReceived?.call(focoOn);
        }

        // 2. Modo de Operación
        if (data.containsKey('modo')) {
          final modoStr = data['modo'].toString().toLowerCase();
          if (modoStr == 'photocell' || modoStr == 'fotocelula') {
            onOperatingModeReceived?.call(OperatingMode.photocell);
          } else if (modoStr == 'manual') {
            onOperatingModeReceived?.call(OperatingMode.manual);
          } else {
            onOperatingModeReceived?.call(OperatingMode.app);
          }
        }

        // 3. Luz ambiental
        if (data.containsKey('luz')) {
          final double light = (data['luz'] as num).toDouble();
          onLightSensorReceived?.call(light);
        }

        // 4. Interruptor NA
        if (data.containsKey('switch')) {
          final bool sw = data['switch'] == true || data['switch'] == 1;
          onManualSwitchReceived?.call(sw);
        }

        client.close();
        _isPolling = false;
        return true;
      } else {
        _setStatus(
          ESP32ConnectionStatus.error,
          'Respuesta HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('[ESP32 AP] Sin conexión al AP (${_config.baseUrl}): $e');
      _setStatus(ESP32ConnectionStatus.disconnected, e.toString());
    } finally {
      client.close();
      _isPolling = false;
    }

    return false;
  }

  /// Envía comando para encender o apagar el foco: GET /foco?state=ON o OFF
  Future<bool> setFoco(bool turnOn) async {
    if (_config.useSimulation) return true;

    final client = _createClient();
    try {
      final stateStr = turnOn ? 'ON' : 'OFF';
      final uri = Uri.parse('${_config.baseUrl}/foco?state=$stateStr');
      debugPrint('[ESP32 AP] Enviando comando: $uri');

      final request = await client.getUrl(uri);
      final response = await request.close();

      client.close();
      if (response.statusCode == 200) {
        _setStatus(ESP32ConnectionStatus.online);
        return true;
      }
    } catch (e) {
      debugPrint('[ESP32 AP] Error al enviar foco: $e');
      _setStatus(ESP32ConnectionStatus.error, e.toString());
    } finally {
      client.close();
    }
    return false;
  }

  /// Cambia el modo en el ESP32: GET /modo?value=app|photocell|manual
  Future<bool> setModo(OperatingMode mode) async {
    if (_config.useSimulation) return true;

    final client = _createClient();
    try {
      String modoStr;
      switch (mode) {
        case OperatingMode.app:
          modoStr = 'app';
          break;
        case OperatingMode.photocell:
          modoStr = 'photocell';
          break;
        case OperatingMode.manual:
          modoStr = 'manual';
          break;
      }

      final uri = Uri.parse('${_config.baseUrl}/modo?value=$modoStr');
      debugPrint('[ESP32 AP] Cambiando modo: $uri');

      final request = await client.getUrl(uri);
      final response = await request.close();

      client.close();
      if (response.statusCode == 200) {
        _setStatus(ESP32ConnectionStatus.online);
        return true;
      }
    } catch (e) {
      debugPrint('[ESP32 AP] Error al cambiar modo: $e');
      _setStatus(ESP32ConnectionStatus.error, e.toString());
    } finally {
      client.close();
    }
    return false;
  }

  void _setStatus(ESP32ConnectionStatus status, [String? error]) {
    if (_status != status) {
      _status = status;
      onConnectionStatusChanged?.call(status, error);
    }
  }

  void dispose() {
    stopPolling();
  }
}
