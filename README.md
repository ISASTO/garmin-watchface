# Typeface 955 — fēnix 6 Sapphire branch

This branch adapts Typeface 955 for the **fēnix 6 Sapphire**.

Garmin groups the fēnix 6 Sapphire with the **fēnix 6 Pro** Connect IQ device family (`fenix6pro`). It has a 260×260 Memory-in-Pixel display, the same resolution as the Forerunner 955, but its Connect IQ API level is 3.4.

## Differences from the Forerunner 955 build

- Target product: `fenix6pro` (covers fēnix 6 Pro / 6 Sapphire / 6 Pro Solar family).
- Minimum Connect IQ API: 3.4.0.
- Geometry remains 260×260 with date/time/battery centers at 57 / 130 / 203 px.
- The API 4.2 battery-complication subscription is removed.
- Battery percentage is sampled once per hour and whenever the watch face becomes visible.
- All font, size, color, percent-symbol, and on-watch settings behavior is otherwise retained.

Time is fixed to **24-hour HHMM** with no colon. Fresh installs default to **Smackers**.

## Build target

In Visual Studio Code, check out this branch and run **Monkey C: Build for Device**. Select **fēnix 6 Pro**. Garmin uses that target for the fēnix 6 Sapphire.

The generated `.prg` is the file to sideload into the watch's `GARMIN/APPS` folder.
