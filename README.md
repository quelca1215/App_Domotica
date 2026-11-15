# 🏠 App de Domótica IoT para ESP32 (Flutter)

Aplicación móvil moderna en Flutter para control domótico remoto de iluminación y actuadores mediante ESP32 a través de Internet (sin requerir estar en la misma red Wi-Fi local).

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
