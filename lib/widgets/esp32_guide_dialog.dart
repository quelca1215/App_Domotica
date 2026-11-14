import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/mqtt_config.dart';

class Esp32GuideDialog extends StatelessWidget {
  final MqttConfig config;

  const Esp32GuideDialog({super.key, required this.config});

  String get _arduinoCode => '''
/*
  ==============================================================
  DOMÓTICA IoT: ESP32 CON 3 MODOS DE CONTROL (APP / FOTOCÉLULA / MANUAL NA)
  Sincronizado con la App Flutter
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

// 2. Configuración del Broker MQTT
const char* mqtt_server = "${config.broker}";
const int mqtt_port = ${config.port};

// 3. Topics MQTT sincronizados con la App
const char* TOPIC_COMMAND       = "${config.topicCommand}";       // Comandos ON/OFF directos
const char* TOPIC_STATE         = "${config.topicStatus}";        // Estado real del foco
const char* TOPIC_AVAILABILITY  = "${config.topicAvailability}";  // Presencia LWT
const char* TOPIC_MODE          = "${config.topicMode}";          // APP, FOTOCELULA, MANUAL
const char* TOPIC_LIGHT_SENSOR  = "${config.topicLightSensor}";   // Nivel de luz (0-100%)
const char* TOPIC_MANUAL_SWITCH = "${config.topicManualSwitch}";  // Estado interruptor NA

// 4. Pines del ESP32
const int RELAY_PIN         = 23; // Pin digital conectado al relé
const int LDR_PIN           = 34; // Pin analógico ADC para fotocélula (sensor de luz)
const int MANUAL_SWITCH_PIN = 4;  // Pin digital para pulsador/switch NA (a GND)

// Lógica del Relé (Active LOW en la mayoría de módulos Songle)
const int RELAY_ON  = LOW;  
const int RELAY_OFF = HIGH; 

// Modos de Operación: 0 = APP, 1 = FOTOCELULA, 2 = MANUAL
enum ModoControl { MODO_APP, MODO_FOTOCELULA, MODO_MANUAL };
ModoControl modoActual = MODO_APP;

bool focoEncendido = false;
unsigned long ultimoSensorMillis = 0;

WiFiClient espClient;
PubSubClient client(espClient);

void encenderFoco(bool encender) {
  if (focoEncendido != encender) {
    focoEncendido = encender;
    digitalWrite(RELAY_PIN, encender ? RELAY_ON : RELAY_OFF);
    client.publish(TOPIC_STATE, encender ? "ON" : "OFF", true);
    Serial.println(encender ? ">> FOCO ENCENDIDO" : ">> FOCO APAGADO");
  }
}

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

  Serial.println("\n¡WiFi Conectado!");
}

// Callback: Recibe mensajes desde la App Flutter
void callback(char* topic, byte* message, unsigned int length) {
  String msg = "";
  for (int i = 0; i < length; i++) {
    msg += (char)message[i];
  }
  msg.trim();
  
  Serial.print("[MQTT Recibido] [");
  Serial.print(topic);
  Serial.print("]: ");
  Serial.println(msg);

  // Cambio de Modo
  if (String(topic) == TOPIC_MODE) {
    if (msg == "APP" || msg == "0") {
      modoActual = MODO_APP;
      Serial.println(">> Modo cambiado a: CONTROL POR APP");
    } else if (msg == "FOTOCELULA" || msg == "1") {
      modoActual = MODO_FOTOCELULA;
      Serial.println(">> Modo cambiado a: FOTOCÉLULA INTELIGENTE");
    } else if (msg == "MANUAL" || msg == "2") {
      modoActual = MODO_MANUAL;
      Serial.println(">> Modo cambiado a: INTERRUPTOR MANUAL NA");
    }
  }

  // Comandos directos en Modo App
  if (String(topic) == TOPIC_COMMAND && modoActual == MODO_APP) {
    if (msg == "ON") encenderFoco(true);
    else if (msg == "OFF") encenderFoco(false);
  }
}

void reconnect() {
  while (!client.connected()) {
    Serial.print("Conectando a MQTT Broker...");
    String clientId = "ESP32_Domotica_" + String(random(0xffff), HEX);

    if (client.connect(clientId.c_str(), TOPIC_AVAILABILITY, 1, true, "offline")) {
      Serial.println("¡Conectado!");
      client.publish(TOPIC_AVAILABILITY, "online", true);

      // Suscribirse a tópicos de comando y modo
      client.subscribe(TOPIC_COMMAND);
      client.subscribe(TOPIC_MODE);

      // Reportar estado inicial
      client.publish(TOPIC_STATE, focoEncendido ? "ON" : "OFF", true);
      client.publish(TOPIC_MODE, "APP", true);
    } else {
      delay(4000);
    }
  }
}

void setup() {
  Serial.begin(115200);

  // Configurar pines
  pinMode(RELAY_PIN, OUTPUT);
  digitalWrite(RELAY_PIN, RELAY_OFF);

  // Switch físico normalmente abierto conectado a GND con resistencia pull-up interna
  pinMode(MANUAL_SWITCH_PIN, INPUT_PULLUP);

  setup_wifi();
  client.setServer(mqtt_server, mqtt_port);
  client.setCallback(callback);
}

void loop() {
  if (!client.connected()) {
    reconnect();
  }
  client.loop();

  // 1. MODO INTELIGENTE: Sensor de luz (Fotocélula LDR)
  if (modoActual == MODO_FOTOCELULA) {
    // Leer cada 1.5 segundos
    if (millis() - ultimoSensorMillis > 1500) {
      ultimoSensorMillis = millis();
      int lecturaAnalogica = analogRead(LDR_PIN); // 0 a 4095
      // Calcular porcentaje de luz (ajustar según tu circuito LDR)
      float porcentajeLuz = map(lecturaAnalogica, 0, 4095, 0, 100);

      char bufferLuz[8];
      dtostrf(porcentajeLuz, 1, 0, bufferLuz);
      client.publish(TOPIC_LIGHT_SENSOR, bufferLuz, false);

      // Si hay poca luz (< 40%), enciende; si hay mucha luz (>= 40%), apaga
      if (porcentajeLuz < 40.0) {
        encenderFoco(true);
      } else {
        encenderFoco(false);
      }
    }
  }

  // 2. MODO MANUAL: Interruptor Normalmente Abierto (NA)
  else if (modoActual == MODO_MANUAL) {
    // Al usar INPUT_PULLUP: LOW = pulsado/cerrado, HIGH = abierto/reposo
    bool switchPresionado = (digitalRead(MANUAL_SWITCH_PIN) == LOW);
    encenderFoco(switchPresionado);
  }
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
                      'Código ESP32 (3 Modos)',
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
              'Este código incluye los 3 modos: App, Fotocélula LDR e Interruptor NA físico.',
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
                    'Pines del ESP32:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF38BDF8),
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    '• GPIO 23 -> Pin IN del Módulo Relé (Foco)\n'
                    '• GPIO 34 -> Fotocélula / LDR (Pin analógico de luz)\n'
                    '• GPIO 4  -> Interruptor físico Normalmente Abierto (a GND)\n'
                    '• VIN / GND -> Alimentación 5V y Tierra común',
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
