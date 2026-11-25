Import("env")
import os

libdeps = env.subst("$PROJECT_LIBDEPS_DIR/$PIOENV/audio-driver/src/AudioBoards")
targets = [
    os.path.join(libdeps, "ESP32S3AISmartSpeaker.h"),
    os.path.join(libdeps, "ESP32S3HosyondDisplay.h"),
]

for path in targets:
    if os.path.exists(path):
        with open(path, "r", encoding="utf-8") as f:
            txt = f.read()
        if not txt.startswith("#ifdef ARDUINO_ESP32S3_DEV"):
            txt = "#ifdef ARDUINO_ESP32S3_DEV\n" + txt + "\n#endif\n"
            with open(path, "w", encoding="utf-8") as f:
                f.write(txt)
