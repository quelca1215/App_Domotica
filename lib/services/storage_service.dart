import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mqtt_config.dart';

class StorageService {
  static const _configKey = 'mqtt_config_v1';
  static const _lastRelayStateKey = 'last_relay_state_v1';

  static Future<MqttConfig> loadConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_configKey);
      if (jsonStr != null) {
        final Map<String, dynamic> data = jsonDecode(jsonStr);
        return MqttConfig.fromJson(data);
      }
    } catch (e) {
      // Retornar configuración por defecto en caso de error
    }
    return const MqttConfig();
  }

  static Future<void> saveConfig(MqttConfig config) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_configKey, jsonEncode(config.toJson()));
    } catch (_) {}
  }

  static Future<bool> loadLastRelayState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_lastRelayStateKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> saveLastRelayState(bool isOn) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_lastRelayStateKey, isOn);
    } catch (_) {}
  }
}
