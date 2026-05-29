# Signal Processing Project: Sensor Data Integration and Analysis

## Project Overview

This project focuses on the acquisition, transmission, and analysis of sensor data for practical applications in renewable energy estimation and machinery health monitoring. The hardware foundation relies on a Raspberry Pi Pico 2 microcontroller integrated with multiple environmental and motion sensors. The system transmits telemetry data via the MAVLink protocol to QGroundControl (QGC) for real-time monitoring.

In addition to the microcontroller data pipeline, the project encompasses two software modules (SP03 and SP10) aimed at processing and analyzing sensor data across Desktop and Mobile (Android and iOS) platforms.

## Hardware Architecture and Communication

The core data acquisition system is built upon the Raspberry Pi Pico 2, which interfaces with the following modules:
*   **Ambient Light Sensor**: Captures local illumination levels.
*   **MPU6050 (Inertial Measurement Unit)**: Provides multi-axis acceleration data.
*   **Temperature Sensors**: Monitors ambient thermal conditions.

### MAVLink Integration

Data gathered by the Pico 2 and its connected sensors is serialized and transmitted using the **MAVLink protocol**. This allows for standardized, robust communication with **QGroundControl (QGC)**, enabling real-time visualization, logging, and analysis of the custom sensor data stream.

## Software Modules and Signal Processing

The project includes two primary applications designed for specific signal processing and analytical tasks:

### SP03: Solar Panel Output Estimator

This module utilizes ambient light sensor data to evaluate the potential energy yield of a solar panel at a specific geographic location.

*   **Data Acquisition**: Reads ambient light sensor data and estimates incident irradiance following a baseline calibration.
*   **Photovoltaic Modeling**: Implements a PV mathematical model to predict the expected current, voltage, and overall power output of a standard solar panel.
*   **Yield Analysis**: Logs continuous measurements over time to approximate daily energy yield, effectively highlighting the impact of dynamic variables such as shading and panel tilt angles.

### SP10: Vibration Analyzer and Machinery Health Monitor

Designed for predictive maintenance and mechanical analysis, this module processes inertial data to assess the operational health of machinery.

*   **Vibration Measurement**: Utilizes accelerometer readings to capture mechanical vibrations.
*   **Signal Processing**: Computes critical diagnostic metrics, including:
    *   **Fast Fourier Transform (FFT)**: To identify dominant frequency components and resonances.
    *   **Root Mean Square (RMS)**: To quantify overall vibration energy and severity.
    *   **Envelope Spectra**: To detect amplitude modulation often associated with bearing or gear faults.

## Conclusion

This project demonstrates the effective integration of embedded hardware, standardized aerospace communication protocols (MAVLink), and advanced signal processing techniques to create functional applications for environmental analysis and industrial monitoring.
