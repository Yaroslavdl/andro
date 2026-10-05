# X21 MIXER diagnostic player

Purpose: create a deliberately ordinary Android `AudioTrack` PCM stream for the X21-SC162 HUR projection experiment. This is a diagnostic source, not a production player.

## Why

The controlled AAC test used framework compressed offload. The controlled WAV test used framework DIRECT PCM and the Qualcomm HAL selected a compress-device backend. Neither isolated the ordinary AudioFlinger mixer path.

This app requests:

- `AudioAttributes.USAGE_MEDIA`
- `CONTENT_TYPE_MUSIC`
- PCM 16-bit
- 48 kHz
- stereo
- `MODE_STREAM`
- no direct/offload flags from the app

The experiment is accepted only if `dumpsys media.audio_flinger` proves that the resulting track is on an ordinary MIXER output with no `DIRECT` and no `COMPRESS_OFFLOAD`. Android/vendor policy may still promote a stream despite the app request; in that case the run is not a valid MIXER isolation test.

## Build

This directory intentionally contains a tiny standalone Android Gradle project. Build on a machine with Android SDK/JDK available:

```powershell
cd tools\x21-mixer-player
.\gradlew.bat assembleDebug
```

If the Gradle wrapper is not present yet, open this directory in Android Studio and use its installed Gradle/SDK, or generate a wrapper once with a local Gradle installation.

Install:

```powershell
D:\platform-tools\adb.exe -s 192.168.1.35:5555 install -r .\app\build\outputs\apk\debug\app-debug.apk
```

Launch `X21 Mixer Test`. It generates the tone itself; no WAV file is needed.

## Test procedure

1. Keep HUR connected and showing the X21 UI.
2. Launch X21 Mixer Test. Initial state is PAUSED.
3. Run `scripts/collect-dudu-hur-audio.ps1 -Mode MIXER`.
4. Follow PLAY/PAUSE prompts using the app button.
5. Accept the capture as a MIXER experiment only after checking AudioFlinger evidence.

The app generates a continuous 48 kHz stereo S16 tone and alternates 440/660 Hz with a one-second silence every five seconds, matching the earlier controlled test signal concept.
