import os
from PIL import Image, ImageDraw, ImageFont

def draw_circle(draw_obj, center, radius, **kwargs):
    x, y = center
    draw_obj.ellipse([x - radius, y - radius, x + radius, y + radius], **kwargs)

def create_schematic():
    # 1920 x 1200 High Resolution Canvas
    w, h = 1920, 1200
    img = Image.new("RGB", (w, h), "#0F172A") # Slate 900 background
    draw = ImageDraw.Draw(img)

    # Fonts
    font_path_bold = "/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf"
    font_path_reg = "/usr/share/fonts/truetype/noto/NotoSans-Regular.ttf"

    title_font = ImageFont.truetype(font_path_bold, 36)
    subtitle_font = ImageFont.truetype(font_path_reg, 20)
    section_font = ImageFont.truetype(font_path_bold, 24)
    label_bold = ImageFont.truetype(font_path_bold, 18)
    label_reg = ImageFont.truetype(font_path_reg, 16)
    small_font = ImageFont.truetype(font_path_reg, 14)
    pin_font = ImageFont.truetype(font_path_bold, 15)

    # Header Card
    draw.rounded_rectangle([40, 30, w - 40, 120], radius=16, fill="#1E293B", outline="#334155", width=2)
    draw.text((70, 45), "DIAGRAMA DE CONEXIONES — SISTEMA DOMÓTICA ESP32", font=title_font, fill="#38BDF8")
    draw.text((70, 88), "Control de Foco AC (Relé) • Fotocélula Inteligente (LDR) • Pulsador Manual (NA) • Red Wi-Fi SoftAP", font=subtitle_font, fill="#94A3B8")

    # Legend at top right
    legends = [
        ("VCC (+5V / 3.3V)", "#EF4444"),
        ("GND (Tierra)", "#64748B"),
        ("Señales GPIO", "#F59E0B"),
        ("Fase AC (110/220V)", "#B45309"),
        ("Neutro AC", "#0284C7"),
    ]
    leg_x = 1250
    for i, (text, col) in enumerate(legends):
        lx = leg_x + (i % 3) * 200 if i < 3 else leg_x + 100 + ((i-3) % 2) * 220
        ly = 50 if i < 3 else 82
        draw.line([(lx, ly + 8), (lx + 25, ly + 8)], fill=col, width=4)
        draw.ellipse([lx + 22, ly + 5, lx + 28, ly + 11], fill=col)
        draw.text((lx + 35, ly), text, font=small_font, fill="#E2E8F0")

    # Left Zone: ESP32 Box
    # Center ESP32 in x: 450 to 800, y: 220 to 880
    esp_x1, esp_y1, esp_x2, esp_y2 = 500, 240, 840, 860
    draw.rounded_rectangle([esp_x1, esp_y1, esp_x2, esp_y2], radius=20, fill="#1E293B", outline="#38BDF8", width=3)
    
    # ESP32 Header
    draw.rectangle([esp_x1, esp_y1, esp_x2, esp_y1 + 55], fill="#0284C7")
    draw.text((esp_x1 + 35, esp_y1 + 14), "ESP32 DEVKIT V1 (30 PINES)", font=section_font, fill="#FFFFFF")

    # Micro USB connector at bottom
    draw.rounded_rectangle([620, esp_y2 - 25, 720, esp_y2 + 15], radius=6, fill="#64748B", outline="#94A3B8", width=2)
    draw.text((630, esp_y2 - 18), "Micro-USB 5V", font=small_font, fill="#F8FAFC")

    # ESP32 Antenna / Chip representation
    draw.rounded_rectangle([esp_x1 + 60, esp_y1 + 80, esp_x2 - 60, esp_y1 + 240], radius=10, fill="#0F172A", outline="#475569", width=2)
    draw.rectangle([esp_x1 + 80, esp_y1 + 85, esp_x2 - 80, esp_y1 + 130], fill="#334155")
    draw.text((esp_x1 + 100, esp_y1 + 95), "ANTENA Wi-Fi PCB", font=label_bold, fill="#CBD5E1")
    draw.text((esp_x1 + 95, esp_y1 + 160), "ESP-WROOM-32", font=section_font, fill="#38BDF8")
    draw.text((esp_x1 + 75, esp_y1 + 195), "SoftAP: ESP32_Domotica", font=small_font, fill="#94A3B8")

    # Pins coordinates
    # Left Header: 3V3, GND, etc.
    # Right Header: GPIO 23, GPIO 34, GPIO 4, VIN, GND
    pins_left = [
        ("3V3", esp_x1, 380, True, "#EF4444"),
        ("EN", esp_x1, 440, False, "#64748B"),
        ("VP (G36)", esp_x1, 500, False, "#64748B"),
        ("VN (G39)", esp_x1, 560, False, "#64748B"),
        ("G34 (ADC1)", esp_x1, 620, True, "#F59E0B"),
        ("G35", esp_x1, 680, False, "#64748B"),
        ("G32", esp_x1, 740, False, "#64748B"),
        ("GND", esp_x1, 800, True, "#64748B"),
    ]

    pins_right = [
        ("VIN (5V)", esp_x2, 380, True, "#EF4444"),
        ("GND", esp_x2, 440, True, "#64748B"),
        ("GPIO 23", esp_x2, 500, True, "#F59E0B"),
        ("GPIO 22", esp_x2, 560, False, "#64748B"),
        ("GPIO 4", esp_x2, 620, True, "#F59E0B"),
        ("GPIO 0", esp_x2, 680, False, "#64748B"),
        ("GPIO 2", esp_x2, 740, False, "#64748B"),
        ("GPIO 15", esp_x2, 800, False, "#64748B"),
    ]

    for name, px, py, active, col in pins_left:
        # Draw pin block
        draw.rectangle([px - 16, py - 12, px, py + 12], fill=col if active else "#334155")
        draw.text((px + 12, py - 9), name, font=pin_font, fill="#FFFFFF" if active else "#64748B")

    for name, px, py, active, col in pins_right:
        draw.rectangle([px, py - 12, px + 16, py + 12], fill=col if active else "#334155")
        draw.text((px - 95, py - 9), name, font=pin_font, fill="#FFFFFF" if active else "#64748B")

    # -------------------------------------------------------------
    # SENSOR LUZ LDR (Left side)
    # Box for LDR Circuit: x: 70 to 380, y: 340 to 670
    ldr_x1, ldr_y1, ldr_x2, ldr_y2 = 70, 360, 380, 680
    draw.rounded_rectangle([ldr_x1, ldr_y1, ldr_x2, ldr_y2], radius=14, fill="#1E293B", outline="#F59E0B", width=2)
    draw.rectangle([ldr_x1, ldr_y1, ldr_x2, ldr_y1 + 40], fill="#B45309")
    draw.text((ldr_x1 + 25, ldr_y1 + 10), "SENSOR DE LUZ (FOTOCÉLULA)", font=label_bold, fill="#FFFFFF")

    # Inside LDR Box: LDR Symbol & 10k resistor
    # LDR representation
    draw.ellipse([180, 430, 240, 490], outline="#FBBF24", width=3, fill="#0F172A")
    draw.text((195, 450), "LDR", font=label_bold, fill="#FBBF24")
    # Arrows indicating light
    draw.line([(150, 420), (175, 445)], fill="#FBBF24", width=2)
    draw.polygon([(175, 445), (170, 435), (165, 448)], fill="#FBBF24")
    draw.line([(160, 405), (185, 430)], fill="#FBBF24", width=2)
    draw.polygon([(185, 430), (180, 420), (175, 433)], fill="#FBBF24")

    # Resistor 10k representation
    draw.rectangle([195, 540, 225, 600], outline="#94A3B8", fill="#334155", width=2)
    draw.text((170, 610), "R = 10 kΩ", font=label_bold, fill="#E2E8F0")

    # Center junction dot between LDR and 10k
    draw.line([(210, 490), (210, 540)], fill="#F59E0B", width=3)
    draw.ellipse([205, 510, 215, 520], fill="#F59E0B")

    # Connect LDR Top to 3V3
    # From 210, 430 up to 390 then right to 3V3 pin (px: 500-16, py: 380)
    draw.line([(210, 430), (210, 390), (484, 380)], fill="#EF4444", width=4)
    draw.text((225, 395), "3.3V (VCC)", font=small_font, fill="#EF4444")

    # Connect Resistor Bottom to GND
    draw.line([(210, 600), (210, 650), (330, 650)], fill="#64748B", width=4)
    # Ground symbol
    draw.line([(330, 640), (330, 660)], fill="#64748B", width=3)
    draw.line([(338, 644), (338, 656)], fill="#64748B", width=3)
    draw.line([(346, 648), (346, 652)], fill="#64748B", width=3)
    draw.text((230, 630), "A Tierra (GND)", font=small_font, fill="#94A3B8")

    # Ground bus line to ESP32 GND
    draw.line([(330, 650), (420, 650), (420, 800), (484, 800)], fill="#64748B", width=4)

    # Signal from Junction (210, 515) to GPIO 34 (484, 620)
    draw.line([(210, 515), (420, 515), (420, 620), (484, 620)], fill="#F59E0B", width=4)
    draw.text((250, 495), "Señal Analógica (GPIO 34)", font=small_font, fill="#F59E0B")

    # -------------------------------------------------------------
    # INTERRUPTOR MANUAL NA (Bottom Left)
    # Box: x: 70 to 380, y: 730 to 920
    sw_x1, sw_y1, sw_x2, sw_y2 = 70, 730, 380, 920
    draw.rounded_rectangle([sw_x1, sw_y1, sw_x2, sw_y2], radius=14, fill="#1E293B", outline="#10B981", width=2)
    draw.rectangle([sw_x1, sw_y1, sw_x2, sw_y1 + 40], fill="#047857")
    draw.text((sw_x1 + 35, sw_y1 + 10), "PULSADOR MANUAL (NA)", font=label_bold, fill="#FFFFFF")

    # Switch schematic symbol
    draw_circle(draw, (160, 825), 6, outline="#10B981", width=2)
    draw_circle(draw, (260, 825), 6, outline="#10B981", width=2)
    draw.line([(166, 825), (250, 795)], fill="#10B981", width=3) # Open blade
    draw.text((150, 845), "Normalmente Abierto", font=small_font, fill="#A7F3D0")
    draw.text((140, 870), "(Sin resistencia externa)", font=small_font, fill="#94A3B8")

    # Wire 1: From terminal 1 (160, 825) to GND bus
    draw.line([(154, 825), (120, 825), (120, 800), (420, 800)], fill="#64748B", width=4)

    # Wire 2: From terminal 2 (266, 825) to GPIO 4 (on right header 856, 620)
    # Route under ESP32: down to 960, right to 930, up to 620, left to 856
    draw.line([(266, 825), (320, 825), (320, 960), (910, 960), (910, 620), (856, 620)], fill="#10B981", width=4)
    draw.text((450, 970), "GPIO 4 (Configurado INPUT_PULLUP)", font=small_font, fill="#10B981")

    # -------------------------------------------------------------
    # MÓDULO RELÉ (Center-Right)
    # Box: x: 1020 to 1340, y: 300 to 720
    rel_x1, rel_y1, rel_x2, rel_y2 = 1040, 300, 1360, 720
    draw.rounded_rectangle([rel_x1, rel_y1, rel_x2, rel_y2], radius=16, fill="#1E293B", outline="#38BDF8", width=3)
    draw.rectangle([rel_x1, rel_y1, rel_x2, rel_y1 + 45], fill="#0369A1")
    draw.text((rel_x1 + 25, rel_y1 + 12), "MÓDULO RELÉ 1 CANAL (5V)", font=label_bold, fill="#FFFFFF")

    # Relay Component Blue Cube
    draw.rounded_rectangle([1110, 380, 1310, 520], radius=8, fill="#1D4ED8", outline="#60A5FA", width=2)
    draw.text((1140, 420), "SONGLE RELAY", font=label_bold, fill="#FFFFFF")
    draw.text((1135, 450), "10A 250VAC / 10A 30VDC", font=small_font, fill="#BFDBFE")
    draw.text((1150, 475), "Bobina: 5V DC", font=small_font, fill="#93C5FD")

    # Low Voltage Pins on Relay (Left side of relay box)
    # VCC (360), GND (420), IN (480)
    relay_in_pins = [
        ("VCC", 1040, 380, "#EF4444"),
        ("GND", 1040, 440, "#64748B"),
        ("IN", 1040, 500, "#F59E0B"),
    ]
    for rname, rx, ry, rcol in relay_in_pins:
        draw.rectangle([rx - 16, ry - 12, rx, ry + 12], fill=rcol)
        draw.text((rx + 12, ry - 9), rname, font=pin_font, fill="#FFFFFF")

    # High Voltage Terminals on Relay (Right side bornera azul)
    # NO, COM, NC
    draw.rounded_rectangle([1320, 550, 1380, 690], radius=6, fill="#0284C7", outline="#38BDF8", width=2)
    ac_terminals = [
        ("NO", 1360, 580),
        ("COM", 1360, 620),
        ("NC", 1360, 660),
    ]
    for tname, tx, ty in ac_terminals:
        draw_circle(draw, (tx, ty), 7, fill="#E2E8F0", outline="#0F172A", width=2)
        draw.text((tx - 40, ty - 9), tname, font=pin_font, fill="#FFFFFF")

    # Wire ESP32 VIN to Relay VCC
    # VIN: (856, 380) to Relay VCC: (1024, 380)
    draw.line([(856, 380), (1024, 380)], fill="#EF4444", width=4)
    draw.text((890, 355), "5V (VIN)", font=small_font, fill="#EF4444")

    # Wire ESP32 GND to Relay GND
    # GND: (856, 440) to Relay GND: (1024, 440)
    draw.line([(856, 440), (1024, 440)], fill="#64748B", width=4)
    draw.text((900, 415), "GND", font=small_font, fill="#94A3B8")

    # Wire ESP32 GPIO 23 to Relay IN
    # GPIO 23: (856, 500) to Relay IN: (1024, 500)
    draw.line([(856, 500), (1024, 500)], fill="#F59E0B", width=4)
    draw.text((880, 475), "GPIO 23 (Control)", font=small_font, fill="#F59E0B")

    # -------------------------------------------------------------
    # HIGH VOLTAGE AC SECTOR (Right side)
    # Box: x: 1470 to 1860, y: 240 to 860
    ac_x1, ac_y1, ac_x2, ac_y2 = 1460, 240, 1870, 860
    draw.rounded_rectangle([ac_x1, ac_y1, ac_x2, ac_y2], radius=18, fill="#1E293B", outline="#EF4444", width=3)
    draw.rectangle([ac_x1, ac_y1, ac_x2, ac_y1 + 55], fill="#991B1B")
    draw.text((ac_x1 + 30, ac_y1 + 14), "ZONA DE ALTA TENSIÓN (110V / 220V AC)", font=label_bold, fill="#FFFFFF")

    # AC Source Plug / Socket representation
    draw.rounded_rectangle([1520, 340, 1810, 440], radius=10, fill="#0F172A", outline="#475569", width=2)
    draw.text((1540, 355), "RED ELÉCTRICA DOMICILIARIA", font=label_bold, fill="#F87171")
    draw.text((1540, 385), "110V - 220V AC (50/60 Hz)", font=small_font, fill="#CBD5E1")

    # Terminals on AC Source
    draw_circle(draw, (1560, 420), 8, fill="#B45309")
    draw.text((1580, 412), "FASE (L)", font=label_bold, fill="#F59E0B")

    draw_circle(draw, (1710, 420), 8, fill="#0284C7")
    draw.text((1730, 412), "NEUTRO (N)", font=label_bold, fill="#38BDF8")

    # Light Bulb representation
    foco_x, foco_y = 1660, 620
    # Bulb glass
    draw.ellipse([foco_x - 50, foco_y - 70, foco_x + 50, foco_y + 30], outline="#FDE047", width=3, fill="#422006")
    # Base / socket
    draw.rectangle([foco_x - 25, foco_y + 30, foco_x + 25, foco_y + 60], fill="#64748B", outline="#94A3B8")
    draw.line([(foco_x - 20, foco_y + 40), (foco_x + 20, foco_y + 40)], fill="#334155", width=2)
    draw.line([(foco_x - 20, foco_y + 50), (foco_x + 20, foco_y + 50)], fill="#334155", width=2)
    draw.text((foco_x - 45, foco_y - 20), "FOCO / CARGA", font=label_bold, fill="#FEF08A")
    draw.text((foco_x - 30, foco_y + 5), "💡 110/220V", font=small_font, fill="#FFFFFF")

    # WIRING AC:
    # 1. FASE (1560, 420) goes to Relay COM (1360, 620)
    draw.line([(1560, 428), (1560, 620), (1367, 620)], fill="#B45309", width=5)
    draw.text((1410, 600), "Fase al COM", font=small_font, fill="#FBBF24")

    # 2. Relay NO (1367, 580) goes to Bulb Phase contact (foco_x - 25, foco_y + 45)
    draw.line([(1367, 580), (1450, 580), (1450, 665), (foco_x - 25, 665)], fill="#B45309", width=5)
    draw.text((1460, 560), "Retorno Fase (NO)", font=small_font, fill="#FBBF24")

    # 3. NEUTRO (1710, 428) goes direct to Bulb Neutral contact (foco_x + 25, foco_y + 45)
    draw.line([(1710, 428), (1710, 665), (foco_x + 25, 665)], fill="#0284C7", width=5)
    draw.text((1720, 540), "Neutro Directo", font=small_font, fill="#38BDF8")

    # Warning banner inside AC box
    draw.rounded_rectangle([1490, 750, 1840, 830], radius=8, fill="#450A0A", outline="#DC2626", width=2)
    draw.text((1510, 762), "⚠️ PRECAUCIÓN DE SEGURIDAD", font=label_bold, fill="#FCA5A5")
    draw.text((1510, 792), "Manipular con la red desconectada.", font=small_font, fill="#FECACA")

    # Footer note
    draw.text((50, 1140), "PROYECTO: App_Domotica • Microcontrolador: ESP32 DevKit • Modos: 1. App Wi-Fi  |  2. Fotocélula Inteligente  |  3. Manual NA", font=label_reg, fill="#64748B")

    output_path = "/home/gabriel/Proyectos/App_Domotica/diagrama_esquematico_esp32.png"
    img.save(output_path, "PNG", quality=95)
    print(f"Diagram saved to {output_path}")

create_schematic()
