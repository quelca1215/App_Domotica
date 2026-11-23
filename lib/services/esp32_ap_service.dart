import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/device_state.dart';
import '../models/esp32_config.dart';

typedef OnStatusReceived = void Function({
  required bool foco1,
  required bool foco2,
  required int tiempoSegundos,
  required bool dhtOk,
  required double temp,
  required double hum,
});
typedef OnConnectionStatusChanged = void Function(ESP32ConnectionStatus status, String? error);

class Esp32ApService {
  Esp32Config _config = const Esp32Config();
  Timer? _pollingTimer;
  bool _isPolling = false;

  OnStatusReceived? onStatusReceived;
  OnConnectionStatusChanged? onConnectionStatusChanged;

  ESP32ConnectionStatus _status = ESP32ConnectionStatus.disconnected;
  ESP32ConnectionStatus get status => _status;

  void updateConfig(Esp32Config config) {
    _config = config;
  }

  void startPolling() {
    stopPolling();
    // Sondeo rápido cada 600ms para reflejar cambios del switch y sensor IR
    _pollingTimer = Timer.periodic(const Duration(milliseconds: 600), (_) {
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
    client.connectionTimeout = const Duration(milliseconds: 1500);
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

        final bool foco1 = data['foco1'] == true;
        final bool foco2 = data['foco2'] == true;
        final int tiempo = (data['tiempo'] as num?)?.toInt() ?? 60;
        final bool dhtOk = data['dhtOk'] == true;
        final double temp = (data['temp'] as num?)?.toDouble() ?? 0.0;
        final double hum = (data['hum'] as num?)?.toDouble() ?? 0.0;

        onStatusReceived?.call(
          foco1: foco1,
          foco2: foco2,
          tiempoSegundos: tiempo,
          dhtOk: dhtOk,
          temp: temp,
          hum: hum,
        );

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

  /// Envía comando para encender o apagar el Foco 1: GET /foco?state=ON o OFF
  Future<bool> setFoco1(bool turnOn) async {
    if (_config.useSimulation) return true;

    final client = _createClient();
    try {
      final stateStr = turnOn ? 'ON' : 'OFF';
      final uri = Uri.parse('${_config.baseUrl}/foco?state=$stateStr');
      debugPrint('[ESP32 AP] Enviando comando Foco 1: $uri');

      final request = await client.getUrl(uri);
      final response = await request.close();

      client.close();
      if (response.statusCode == 200) {
        _setStatus(ESP32ConnectionStatus.online);
        return true;
      }
    } catch (e) {
      debugPrint('[ESP32 AP] Error al enviar foco 1: $e');
      _setStatus(ESP32ConnectionStatus.error, e.toString());
    } finally {
      client.close();
    }
    return false;
  }

  /// Envía comando para configurar el tiempo del Foco 2: GET /set_tiempo?segundos=X
  Future<bool> setTiempoIR(int segundos) async {
    if (_config.useSimulation) return true;

    final client = _createClient();
    try {
      final clamped = segundos.clamp(1, 3600);
      final uri = Uri.parse('${_config.baseUrl}/set_tiempo?segundos=$clamped');
      debugPrint('[ESP32 AP] Enviando tiempo IR: $uri');

      final request = await client.getUrl(uri);
      final response = await request.close();

      client.close();
      if (response.statusCode == 200) {
        _setStatus(ESP32ConnectionStatus.online);
        return true;
      }
    } catch (e) {
      debugPrint('[ESP32 AP] Error al configurar tiempo IR: $e');
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
