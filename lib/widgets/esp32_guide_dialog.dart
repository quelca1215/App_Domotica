import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/mqtt_config.dart';

class Esp32GuideDialog extends StatelessWidget {
  final MqttConfig config;

  const Esp32GuideDialog({super.key, required this.config});

  String get _arduinoCode => '''
/*
  ==============================================================
  CÓDIGO ESP32 PARA DOMÓTICA IoT (CONTROL DE RELÉ / FOCO)
  Conexión por Internet a través de Broker MQTT
  Compatible con la App Flutter
  ==============================================================
  Librerías requeridas (Instalar desde el Gestor de Bibliotecas de Arduino):
  1. PubSubClient by Nick O'Leary
  2. WiFi (nativa de ESP32)
*/

#include <WiFi.h>
#include <PubSubClient.h>

// 1. Credenciales de tu Red WiFi local
const char* ssid = "TU_NOMBRE_DE_WIFI";
const char* password = "TU_PASSWORD_WIFI";

// 2. Configuración del Broker MQTT (Mismos datos configurados en la App)
const char* mqtt_server = "${config.broker}";
const int mqtt_port = ${config.port};

// 3. Topics MQTT sincronizados con la App
const char* TOPIC_COMMAND = "${config.topicCommand}";      // Escucha órdenes de la App
const char* TOPIC_STATE = "${config.topicStatus}";          // Reporta estado a la App
const char* TOPIC_AVAILABILITY = "${config.topicAvailability}"; // Heartbeat / LWT

// 4. Pin GPIO conectado al pin IN del Módulo Relé
const int RELAY_PIN = 23; // Puedes usar GPIO 23, 22, 19, etc.

// NOTA: La mayoría de módulos relé son "Active LOW" (0V activa, 3.3V apaga).
// Si tu relé es Active HIGH, cambia estas constantes:
const int RELAY_ON = LOW;   // O HIGH según tu modelo de relé
const int RELAY_OFF = HIGH; // O LOW

WiFiClient espClient;
PubSubClient client(espClient);

void setup_wifi() {
  delay(10);
  Serial.println();
  Serial.print("Conectando a WiFi: ");
  Serial.println(ssid);

  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("");
  Serial.println("¡WiFi Conectado!");
  Serial.print("Dirección IP local: ");
  Serial.println(WiFi.localIP());
}

// Callback: Se ejecuta cuando la App Flutter envía una orden
void callback(char* topic, byte* message, unsigned int length) {
  String messageTemp;
  for (int i = 0; i < length; i++) {
    messageTemp += (char)message[i];
  }
  
  Serial.print("Mensaje recibido en topic [");
  Serial.print(topic);
  Serial.print("]: ");
  Serial.println(messageTemp);

  if (String(topic) == TOPIC_COMMAND) {
    if (messageTemp == "ON") {
      digitalWrite(RELAY_PIN, RELAY_ON);
      Serial.println(">> Relé CERRADO -> Foco ENCENDIDO");
      client.publish(TOPIC_STATE, "ON", true); // Reportar a la App
    } else if (messageTemp == "OFF") {
      digitalWrite(RELAY_PIN, RELAY_OFF);
      Serial.println(">> Relé ABIERTO -> Foco APAGADO");
      client.publish(TOPIC_STATE, "OFF", true); // Reportar a la App
    }
  }
}

void reconnect() {
  while (!client.connected()) {
    Serial.print("Intentando conexión MQTT a la nube...");
    String clientId = "ESP32_Domotica_" + String(random(0xffff), HEX);

    // Conectar con Last Will & Testament (LWT) para avisar si se desconecta
    if (client.connect(clientId.c_str(), TOPIC_AVAILABILITY, 1, true, "offline")) {
      Serial.println("¡Conectado al Broker!");
      
      // Notificar a la app que el ESP32 está ONLINE
      client.publish(TOPIC_AVAILABILITY, "online", true);

      // Suscribirse al topic de comandos de la App
      client.subscribe(TOPIC_COMMAND);
      
      // Enviar estado inicial del relé
      client.publish(TOPIC_STATE, "OFF", true);
    } else {
      Serial.print("Error rc=");
      Serial.print(client.state());
      Serial.println(". Reintentando en 5 segundos...");
      delay(5000);
    }
  }
}

void setup() {
  Serial.begin(115200);

  // Configurar pin del relé como salida
  pinMode(RELAY_PIN, OUTPUT);
  digitalWrite(RELAY_PIN, RELAY_OFF); // Iniciar apagado

  setup_wifi();

  client.setServer(mqtt_server, mqtt_port);
  client.setCallback(callback);
}

void loop() {
  if (!client.connected()) {
    reconnect();
  }
  client.loop(); // Mantiene viva la conexión y escucha mensajes
}
''';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0F172A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.code_rounded, color: Color(0xFF10B981), size: 24),
                    SizedBox(width: 10),
                    Text(
                      'Código y Conexión ESP32',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, color: Colors.white54),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Este código en C++ para Arduino IDE / PlatformIO se sincroniza automáticamente con los topics configurados en esta app.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 14),

            // Diagrama de Pines Rápido
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Esquema de Pines (ESP32 <-> Relé):',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF38BDF8),
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    '• ESP32 VIN / 5V  -> VCC del Módulo Relé\n'
                    '• ESP32 GND      -> GND del Módulo Relé\n'
                    '• ESP32 GPIO 23   -> IN del Módulo Relé\n'
                    '• Foco 110/220V   -> Conectado en serie con COM y NO del Relé',
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.5,
                      color: Color(0xFFCBD5E1),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Código
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF070B14),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    _arduinoCode,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: Color(0xFF86EFAC),
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Botón Copiar Código
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _arduinoCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('¡Código copiado al portapapeles!'),
                      backgroundColor: Color(0xFF10B981),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: const Text('COPIAR CÓDIGO ESP32 (ARDUINO)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
