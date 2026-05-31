# Signal Processing Project: Sensor Data Integration and Analysis (SP03 and SP10)

<img width="1919" height="979" alt="image" src="https://github.com/user-attachments/assets/321a461d-421d-4ccb-b6c1-36dcb22f3493" />
<img width="1915" height="978" alt="image" src="https://github.com/user-attachments/assets/c451dbc2-c7c0-4f84-8e91-0c3ea88934d0" />
<img width="1919" height="980" alt="image" src="https://github.com/user-attachments/assets/1c63fd60-eaf4-488f-b8f5-269fa0aa04ea" />
<img width="1919" height="978" alt="image" src="https://github.com/user-attachments/assets/130bac59-fe3a-4704-a6fc-1342accf750d" />
<img width="1919" height="992" alt="image" src="https://github.com/user-attachments/assets/9905ee2e-79ee-429d-a8ff-a563fa9803d8" />
<img width="1919" height="981" alt="image" src="https://github.com/user-attachments/assets/2e1872ea-64b5-4e56-8486-0a19a59a1653" />
<img width="1919" height="984" alt="image" src="https://github.com/user-attachments/assets/1993ca47-dbe9-4c65-86d2-1da8f3104f94" />
<img width="1919" height="988" alt="image" src="https://github.com/user-attachments/assets/2a66fe34-e64c-4edb-9701-b8033319857a" />
<img width="1919" height="983" alt="image" src="https://github.com/user-attachments/assets/657ede8d-6fcb-4073-b6e0-0b699c22da34" />
<img width="1919" height="989" alt="image" src="https://github.com/user-attachments/assets/e397da66-6fc5-426e-9486-b0841f92f769" />

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

#### SP03 Calculation Logic (C++)
Because the hardware relies on a TEMT6000 ambient light sensor, the firmware mathematically simulates a standard 12V (18.2 Vmp) 100W solar panel. The logic locks the system voltage and dynamically calculates Power and Current based on live irradiance:
```cpp
int rawLight = analogRead(TEMT6000_PIN);
float lux = rawLight * 2.5f; 
float irradiance = lux * 0.0079f; // Convert to W/m^2

// PV Mathematical Model
float expectedVolt = 18.2f; // Standard 12V Solar Panel Vmp
float expectedPower = irradiance * 0.15f; // Assuming 15% solar efficiency
float expectedCurr = (expectedVolt > 0) ? (expectedPower / expectedVolt) : 0;
```

### SP10: Vibration Analyzer and Machinery Health Monitor

Designed for predictive maintenance and mechanical analysis, this module processes inertial data to assess the operational health of machinery.

*   **Vibration Measurement**: Utilizes accelerometer readings to capture mechanical vibrations.
*   **Signal Processing**: Computes critical diagnostic metrics, including:
    *   **Fast Fourier Transform (FFT)**: To identify dominant frequency components and resonances.
    *   **Root Mean Square (RMS)**: To quantify overall vibration energy and severity.
    *   **Envelope Spectra**: To detect amplitude modulation often associated with bearing or gear faults.

#### SP10 Calculation Logic (C++)
The Pico 2 samples the MPU6050 at 100 Hz. It removes the static force of gravity (9.81 m/s²) to isolate dynamic vibration. It collects 64 samples in a buffer, calculates the RMS energy, and executes a real-time Fast Fourier Transform (FFT) on the microcontroller to pinpoint the peak frequency:
```cpp
// 1. Calculate magnitude and remove gravity
float accelMag = sqrt(a.acceleration.x*a.acceleration.x + 
                      a.acceleration.y*a.acceleration.y + 
                      a.acceleration.z*a.acceleration.z) - 9.81;

vReal[sampleIdx] = accelMag;
vImag[sampleIdx] = 0.0;
sampleIdx++;

if (sampleIdx >= SAMPLES) {
    // 2. Calculate RMS Vibration
    float sumSq = 0;
    for(int i=0; i<SAMPLES; i++) sumSq += (vReal[i] * vReal[i]);
    float rms = sqrt(sumSq / SAMPLES);

    // 3. Compute FFT for Peak Frequency
    ArduinoFFT<double> FFT = ArduinoFFT<double>(vReal, vImag, SAMPLES, SAMPLING_FREQUENCY);
    FFT.windowing(FFT_WIN_TYP_HAMMING, FFT_FORWARD);
    FFT.compute(FFT_FORWARD);
    FFT.complexToMagnitude();
    double peakFreq = FFT.majorPeak();
}
```

## Conclusion

This project demonstrates the effective integration of embedded hardware, standardized aerospace communication protocols (MAVLink), and advanced signal processing techniques to create functional applications for environmental analysis and industrial monitoring.
