# SP10: Machinery Vibration Analyzer

## Overview
This standalone repository contains the specific C++ firmware and Qt/QML frontend for the SP10 project module. It demonstrates how to integrate an MPU6050 Inertial Measurement Unit with a Pico 2 to execute a real-time Fast Fourier Transform (FFT) and calculate RMS vibration, streaming the health status via MAVLink.

## Hardware Setup
- **Raspberry Pi Pico 2**
- **MPU6050 IMU**
  - VCC -> 3.3V
  - GND -> GND
  - SDA -> GPIO 4 (I2C0)
  - SCL -> GPIO 5 (I2C0)

## Dependencies
- `Adafruit MPU6050`
- `arduinoFFT` (v2.x)

## Files Included
- `firmware.ino`: The dual-core C++ code to run the 100Hz FFT analysis.
- `Custom.Widgets.qml`: The QML UI file to drop into QGroundControl to view the peak frequency and RMS severity.
