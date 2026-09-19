# Typeface 955 — fēnix 6S compatibility branch

This branch adapts Typeface 955 for the **fēnix 6S / 6S Pro family**.

Garmin lists both fēnix 6S device families as 240×240 Memory-in-Pixel devices with Connect IQ API level 3.4. The layout is therefore recentered for 240×240, and the API 4.2 battery-complication feature from the Forerunner 955 build is removed.

## Differences from the Forerunner 955 build

- Target products: `fenix6s` and `fenix6spro`.
- Minimum Connect IQ API: 3.4.0.
- Geometry: date/time/battery centers are 53 / 120 / 187 px, centered at x=120.
- Battery percentage is sampled once per hour and whenever the watch face becomes visible.
- No `ComplicationSubscriber` permission is used.
- All font, size, color, percent-symbol, and on-watch settings behavior is otherwise retained.

Time is fixed to **24-hour HHMM** with no colon. Fresh installs default to **Smackers**.

## Time typefaces

1. Smackers
2. Nautica
3. Cleo
4. Pincoya
5. Alien

## Color palette

Black, Red, Orange, Yellow, Green, Blue, Purple, Pink, White.

## Build

In Visual Studio Code, check out this branch and use **Monkey C: Build for Device**. Choose **fēnix 6S** for a non-Pro 6S or **fēnix 6S Pro** for a Pro/Sapphire/Pro Solar model.

The generated `.prg` is device-family-specific. Copy it to the watch's `GARMIN/APPS` folder for sideloading.
