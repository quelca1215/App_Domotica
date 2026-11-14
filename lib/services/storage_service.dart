import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/esp32_config.dart';

class StorageService {
  static const _apConfigKey = 'esp32_ap_config_v1';
  static const _lastRelayStateKey = 'last_relay_state_v1';

  static Future<Esp32Config> loadEsp32Config() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_apConfigKey);
      if (jsonStr != null) {
        final Map<String, dynamic> data = jsonDecode(jsonStr);
        return Esp32Config.fromJson(data);
      }
    } catch (_) {}
    return const Esp32Config();
  }

  static Future<void> saveEsp32Config(Esp32Config config) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_apConfigKey, jsonEncode(config.toJson()));
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
