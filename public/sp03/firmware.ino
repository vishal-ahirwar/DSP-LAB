#include <MAVLink.h>
#include <pico/multicore.h>

#define TEMT6000_PIN 26
#define LED_PIN 25


class SensorsHandler {
public:
  SensorsHandler() { pinMode(TEMT6000_PIN, INPUT); }
  void exec() {
    uint32_t lastLightTime = 0;
    while (true) {
      uint32_t now = millis();
      if (now - lastLightTime >= 500) {
        lastLightTime = now;
        int rawLight = analogRead(TEMT6000_PIN);
        float lux = rawLight * 2.5f; 
        float irradiance = lux * 0.0079f;
        
        float expectedVolt = 18.2f;
        float expectedPower = irradiance * 0.15f;
        float expectedCurr = (expectedVolt > 0) ? (expectedPower / expectedVolt) : 0;
        
        sendNamedFloat("irrad", irradiance);
        sendNamedFloat("volt", expectedVolt);
        sendNamedFloat("curr", expectedCurr);
        sendNamedFloat("power", expectedPower);
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
  
  void sendHeartBeat() {
  }
  
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
  
  void parseIncomingMavLinkMessages() {
  }
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
