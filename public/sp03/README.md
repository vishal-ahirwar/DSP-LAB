# SP03: Solar Yield Estimation

## Overview
This standalone repository contains the specific C++ firmware and Qt/QML frontend for the SP03 project module. It demonstrates how to integrate an ambient light sensor (TEMT6000) with a Pico 2 to calculate the expected energy yield of a solar panel, streaming the mathematical output via MAVLink.

## Hardware Setup
- **Raspberry Pi Pico 2**
- **TEMT6000 Ambient Light Sensor**
  - VCC -> 3.3V
  - GND -> GND
  - OUT -> GPIO 26 (ADC0)

## Files Included
- `firmware.ino`: The dual-core C++ code to read the sensor and calculate Power/Current.
- `Custom.Widgets.qml`: The QML UI file to drop into QGroundControl to view the real-time solar yield.
