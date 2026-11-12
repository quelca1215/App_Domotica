import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import '../models/device_state.dart';
import '../models/mqtt_config.dart';

typedef OnRelayStateReceived = void Function(bool isOn);
typedef OnAvailabilityReceived = void Function(bool isOnline);
typedef OnTelemetryReceived = void Function(Map<String, dynamic> data);
typedef OnConnectionStatusChanged = void Function(ESP32ConnectionStatus status, String? error);

class MqttService {
  MqttServerClient? _client;
  MqttConfig _config = const MqttConfig();

  OnRelayStateReceived? onRelayStateReceived;
  OnAvailabilityReceived? onAvailabilityReceived;
  OnTelemetryReceived? onTelemetryReceived;
  OnConnectionStatusChanged? onConnectionStatusChanged;

  ESP32ConnectionStatus _status = ESP32ConnectionStatus.disconnected;
  ESP32ConnectionStatus get status => _status;

  bool get isConnected =>
      _client?.connectionStatus?.state == MqttConnectionState.connected;

  void updateConfig(MqttConfig config) {
    _config = config;
  }

  Future<bool> connect(MqttConfig config) async {
    _config = config;

    // Desconectar cliente previo si existe
    disconnect();

    _setStatus(ESP32ConnectionStatus.connecting);

    final generatedClientId = config.clientId.isNotEmpty
        ? config.clientId
        : 'flutter_domotica_${DateTime.now().millisecondsSinceEpoch % 100000}';

    _client = MqttServerClient.withPort(
      config.broker,
      generatedClientId,
      config.port,
    );

    _client!.logging(on: false);
    _client!.keepAlivePeriod = 30;
    _client!.autoReconnect = true;
    _client!.resubscribeOnAutoReconnect = true;

    _client!.onConnected = _onConnected;
    _client!.onDisconnected = _onDisconnected;
    _client!.onAutoReconnect = () {
      debugPrint('[MQTT] Auto reconectando...');
      _setStatus(ESP32ConnectionStatus.connecting);
    };
    _client!.onAutoReconnected = () {
      debugPrint('[MQTT] Auto reconectado exitosamente');
      _setStatus(ESP32ConnectionStatus.online);
      _subscribeToTopics();
    };

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(generatedClientId)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    if (config.username != null && config.username!.isNotEmpty) {
      connMessage.authenticateAs(config.username, config.password);
    }

    _client!.connectionMessage = connMessage;

    try {
      debugPrint('[MQTT] Conectando a ${config.broker}:${config.port}...');
      final connResult = await _client!.connect();
      if (connResult?.state == MqttConnectionState.connected) {
        debugPrint('[MQTT] Conexión establecida con éxito');
        _setStatus(ESP32ConnectionStatus.online);
        _subscribeToTopics();
        _listenToUpdates();
        return true;
      } else {
        debugPrint('[MQTT] Fallo de conexión: ${connResult?.state}');
        _setStatus(ESP32ConnectionStatus.error, 'Estado: ${connResult?.state}');
        disconnect();
        return false;
      }
    } catch (e) {
      debugPrint('[MQTT] Excepción al conectar: $e');
      _setStatus(ESP32ConnectionStatus.error, e.toString());
      disconnect();
      return false;
    }
  }

  void _subscribeToTopics() {
    if (_client == null || !isConnected) return;

    try {
      debugPrint('[MQTT] Suscribiendo a ${_config.topicStatus}');
      _client!.subscribe(_config.topicStatus, MqttQos.atLeastOnce);

      debugPrint('[MQTT] Suscribiendo a ${_config.topicAvailability}');
      _client!.subscribe(_config.topicAvailability, MqttQos.atLeastOnce);

      debugPrint('[MQTT] Suscribiendo a ${_config.topicTelemetry}');
      _client!.subscribe(_config.topicTelemetry, MqttQos.atLeastOnce);
    } catch (e) {
      debugPrint('[MQTT] Error al suscribir a topics: $e');
    }
  }

  void _listenToUpdates() {
    _client!.updates?.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
      for (final msg in messages) {
        final recMess = msg.payload as MqttPublishMessage;
        final payload = MqttPublishPayload.bytesToStringAsString(
          recMess.payload.message,
        );
        final topic = msg.topic;

        debugPrint('[MQTT Recibido] $topic -> $payload');

        if (topic == _config.topicStatus) {
          _processStatusMessage(payload);
        } else if (topic == _config.topicAvailability) {
          _processAvailabilityMessage(payload);
        } else if (topic == _config.topicTelemetry) {
          _processTelemetryMessage(payload);
        }
      }
    });
  }

  void _processStatusMessage(String payload) {
    final clean = payload.trim().toUpperCase();
    if (clean == 'ON' || clean == '1' || clean == 'TRUE') {
      onRelayStateReceived?.call(true);
    } else if (clean == 'OFF' || clean == '0' || clean == 'FALSE') {
      onRelayStateReceived?.call(false);
    } else {
      // Intentar JSON { "state": "ON" } o { "relay": 1 }
      try {
        final json = jsonDecode(payload);
        if (json is Map) {
          final state = json['state']?.toString().toUpperCase() ??
              json['relay']?.toString().toUpperCase();
          if (state == 'ON' || state == '1' || state == 'TRUE') {
            onRelayStateReceived?.call(true);
          } else if (state == 'OFF' || state == '0' || state == 'FALSE') {
            onRelayStateReceived?.call(false);
          }
        }
      } catch (_) {}
    }
  }

  void _processAvailabilityMessage(String payload) {
    final clean = payload.trim().toLowerCase();
    final isOnline = clean == 'online' || clean == '1' || clean == 'connected';
    onAvailabilityReceived?.call(isOnline);
  }

  void _processTelemetryMessage(String payload) {
    try {
      final json = jsonDecode(payload);
      if (json is Map<String, dynamic>) {
        onTelemetryReceived?.call(json);
      }
    } catch (_) {}
  }

  Future<bool> publishRelayCommand(bool turnOn) async {
    if (_client == null || !isConnected) {
      debugPrint('[MQTT] No conectado. No se puede enviar comando.');
      return false;
    }

    try {
      final builder = MqttClientPayloadBuilder();
      final commandStr = turnOn ? 'ON' : 'OFF';
      builder.addString(commandStr);

      _client!.publishMessage(
        _config.topicCommand,
        MqttQos.atLeastOnce,
        builder.payload!,
        retain: true, // Retener para que el ESP32 reciba el último estado al conectarse
      );
      debugPrint('[MQTT Publicado] ${_config.topicCommand} -> $commandStr');
      return true;
    } catch (e) {
      debugPrint('[MQTT] Error al publicar comando: $e');
      return false;
    }
  }

  void disconnect() {
    try {
      _client?.disconnect();
    } catch (_) {}
    _setStatus(ESP32ConnectionStatus.disconnected);
  }

  void _onConnected() {
    debugPrint('[MQTT] Callback: Cliente conectado.');
    _setStatus(ESP32ConnectionStatus.online);
  }

  void _onDisconnected() {
    debugPrint('[MQTT] Callback: Cliente desconectado.');
    _setStatus(ESP32ConnectionStatus.disconnected);
  }

  void _setStatus(ESP32ConnectionStatus status, [String? error]) {
    _status = status;
    onConnectionStatusChanged?.call(status, error);
  }
}
