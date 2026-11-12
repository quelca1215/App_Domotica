# 🏠 App de Domótica IoT para ESP32 (Flutter)

Aplicación móvil moderna en Flutter para control domótico remoto de iluminación y actuadores mediante ESP32 a través de Internet (sin requerir estar en la misma red Wi-Fi local).

---

## ✨ Características Principales

1. **Acceso Inmediato Sin Login:**
   - La aplicación inicia directamente en el panel de control del dormitorio principal sin pantallas de autenticación innecesarias.

2. **Interfaz Inmersiva de la Habitación:**
   - Ilustración interactiva de alta fidelidad con iluminación volumétrica reactiva.
   - Lámpara colgante con bombilla incandescente, filamento de tungsteno visible y halo de resplandor nuclear.
   - Transición dinámica día/noche entre modo cálido encendido y ambiente nocturno azul profundo con luz de luna.
   - Interacción táctil directa: toca el cuarto o la bombilla para encender/apagar.

3. **Control Visual del Relé Electromecánico:**
   - Visualización esquemática del contacto del relé (Circuito Abierto vs Circuito Cerrado).
   - LEDs indicadores de estado de hardware simulados (`PWR` rojo y `IN` verde) idénticos a los módulos relé físicos Songle/Arduino.
   - Botón ergonómico de gran impacto táctil con retroalimentación háptica.

4. **Conexión IoT Remota (Internet / Nube):**
   - El ESP32 y la App no necesitan compartir la misma red local. Utilizan el protocolo **MQTT** sobre un broker en la nube (`broker.emqx.io`, `broker.hivemq.com` o broker privado).
   - Compatible con redes móviles 4G/5G y Wi-Fi externo.
   - Detección de presencia del microcontrolador mediante *Last Will and Testament (LWT)*.

5. **Modo Simulación / ESP32 Virtual:**
   - Viene activado por defecto para que puedas probar todas las animaciones, métricas y controles de inmediato en tu emulador o teléfono antes de conectar el ESP32 físico.
   - Se cambia a modo real con un solo toque desde la barra superior.

6. **Métricas Rápidas:**
   - Consumo estimado en vatios (12.5 W en foco LED encendido / 0 W apagado).
   - Temperatura y humedad ambiental (preparado para sensores DHT11/DHT22 o BME280).
   - Contador de tiempo de encendido activo.

7. **Guía Integrada para el ESP32:**
   - Incluye un diálogo accesible desde el icono de microchip con el código completo en C++ para Arduino IDE / PlatformIO y el esquema de conexión de pines.

---

## 📡 Arquitectura de Comunicación (MQTT)

| Topic | Dirección | Descripción | Payload |
|---|---|---|---|
| `domotica/cuarto/luz/set` | App ➔ ESP32 | Envía comando para abrir/cerrar relé | `ON` / `OFF` |
| `domotica/cuarto/luz/state` | ESP32 ➔ App | Confirma el estado real del foco | `ON` / `OFF` |
| `domotica/cuarto/esp32/status` | ESP32 ➔ App | Disponibilidad y heartbeat (LWT) | `online` / `offline` |
| `domotica/cuarto/telemetria` | ESP32 ➔ App | Datos de sensores (opcional) | JSON con temp y hum |

---

## 🚀 Cómo Ejecutar la Aplicación

Para lanzar la aplicación en un dispositivo Android, emulador o escritorio:

```bash
flutter run
```

Para ejecutar las pruebas automatizadas:

```bash
flutter test
```

Para verificar análisis de código estático:

```bash
flutter analyze
```

---

## 🔌 Esquema Rápido de Conexión de Pines (Futura fase)

- **ESP32 5V (VIN)** ➔ Pin **VCC** del Módulo Relé
- **ESP32 GND** ➔ Pin **GND** del Módulo Relé
- **ESP32 GPIO 23** ➔ Pin **IN** del Módulo Relé
- **Foco AC (110V/220V)** ➔ Conectado en serie a los terminales **COM** y **NO** del relé
