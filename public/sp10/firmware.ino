#include <MAVLink.h>
#include <Wire.h>
#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>
#include <arduinoFFT.h>
#include <pico/multicore.h>

#define LED_PIN 25
#define SAMPLES 64
#define SAMPLING_FREQUENCY 100

Adafruit_MPU6050 mpu;
double vReal[SAMPLES];
double vImag[SAMPLES];

void sendToQGC(const char* name, float value);

class SensorsHandler {
public:
  SensorsHandler() {
    Wire.begin();
    mpu.begin();
    mpu.setAccelerometerRange(MPU6050_RANGE_8_G);
    mpu.setFilterBandwidth(MPU6050_BAND_21_HZ);
  }
  void exec() {
    uint32_t lastMPUTime = 0;
    uint16_t sampleIdx = 0;
    while (true) {
      uint32_t now = millis();
      if (now - lastMPUTime >= (1000 / SAMPLING_FREQUENCY)) {
        lastMPUTime = now;
        
        sensors_event_t a, g, temp;
        mpu.getEvent(&a, &g, &temp);

        float accelMag = sqrt(a.acceleration.x*a.acceleration.x + 
                              a.acceleration.y*a.acceleration.y + 
                              a.acceleration.z*a.acceleration.z) - 9.81;

        vReal[sampleIdx] = accelMag;
        vImag[sampleIdx] = 0.0;
        sampleIdx++;

        if (sampleIdx >= SAMPLES) {
          float sumSq = 0;
          for(int i=0; i<SAMPLES; i++) sumSq += (vReal[i] * vReal[i]);
          float rms = sqrt(sumSq / SAMPLES);

          ArduinoFFT<double> FFT = ArduinoFFT<double>(vReal, vImag, SAMPLES, SAMPLING_FREQUENCY);
          FFT.windowing(FFT_WIN_TYP_HAMMING, FFT_FORWARD);
          FFT.compute(FFT_FORWARD);
          FFT.complexToMagnitude();
          double peakFreq = FFT.majorPeak();

          sendToQGC("vib_peak", peakFreq);
          sendToQGC("vib_rms", rms);
          sendToQGC("vib_stat", (rms > 2.0) ? 1.0 : 0.0);
          sampleIdx = 0;
        }
      }
      delay(1);
    }
  }
};

class MavLinkHandler {
public:
  MavLinkHandler() { pinMode(LED_PIN, OUTPUT); digitalWrite(LED_PIN, LOW); }
  void exec() {
    sendHeartBeat();
    parseIncomingMavLinkMessages();
    handleLEDBlink();
  }
private:
  uint32_t lastQGCHeartbeat = 0;
  
  void sendHeartBeat();
  
  void handleLEDBlink() {
    static uint32_t lastBlink = 0;
    static bool ledState = false;
    if (millis() - lastQGCHeartbeat < 3000) {
      if (millis() - lastBlink > 500) {
        lastBlink = millis();
        ledState = !ledState;
        digitalWrite(LED_PIN, ledState ? HIGH : LOW);
      }
    } else {
      digitalWrite(LED_PIN, LOW);
      ledState = false;
    }
  }
  
  void parseIncomingMavLinkMessages();
};

void sensorsCore() {
  uintptr_t addr = multicore_fifo_pop_blocking();
  SensorsHandler* sensors = reinterpret_cast<SensorsHandler*>(addr);
  if (sensors) sensors->exec();
}

void setup() {
  Serial.begin(57600);
  MavLinkHandler mavlink;  
  SensorsHandler sensorsHandler;  
  multicore_launch_core1(sensorsCore);
  multicore_fifo_push_blocking(reinterpret_cast<uintptr_t>(&sensorsHandler));
  delay(500);
  while (true) {
    mavlink.exec();
    sleep_us(100);
  }
}
void loop(){}
