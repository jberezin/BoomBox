#include <Arduino.h>
#include "AudioTools.h"
#include "AudioTools/AudioLibs/AudioBoardStream.h"
#include "BluetoothA2DPSink.h"

AudioBoardStream* kit = nullptr;
BluetoothA2DPSink* a2dp_sink = nullptr;

void setup() {
  Serial.begin(115200);
  delay(1000);
  Serial.println("\n=== Starting Base AudioKit BT ===");

  AudioToolsLogger.begin(Serial, AudioToolsLogLevel::Info);

  kit = new AudioBoardStream(AudioKitEs8388V1);

  auto cfg = kit->defaultConfig(TX_MODE);
  cfg.sd_active = false;
  cfg.sample_rate = 44100;
  cfg.channels = 2;
  cfg.bits_per_sample = 16;

  if (!kit->begin(cfg)) {
    Serial.println("ERROR: kit->begin() failed!");
    while (true) delay(1000);
  }

  kit->setVolume(0.75f);

  a2dp_sink = new BluetoothA2DPSink(*kit);
  a2dp_sink->start("OpenBoombox");

  Serial.println("=== READY: Connect phone to 'OpenBoombox' ===");
}

void loop() {
  delay(100);
}
