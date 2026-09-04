# Battery optimization notes (v2.7)

Forerunner 955-specific private build.

Implemented:
- Full screen is still redrawn on every Garmin `onUpdate()` callback for
  correctness on physical hardware.
- `System.getClockTime()` is the only normal per-callback data query.
- HHMM formatting occurs only when the minute changes.
- Calendar/date lookup occurs only when the hour changes.
- Battery percentage uses Garmin's native `COMPLICATION_TYPE_BATTERY` publish/
  subscribe path. Garmin notifies the face when the value changes, so charging
  updates stay fresh without adding a polling timer.
- The complication is read once when the face becomes visible so the first
  post-charge glance is current even if a notification arrived while hidden.
- `System.getSystemStats()` is retained only as an hourly fallback if native
  complication subscription is unavailable.
- Weekday names, geometry, justification, colors, and optical Y offsets are
  cached/constants instead of reconstructed in the hot path.
- No seconds, timers, animations, or `onPartialUpdate()`.
- Five time font atlases are hard 1-bit black/white and imported with
  anti-aliasing disabled.
- Font resources are loaded/reloaded outside normal screen-update work and only
  when their selection changes.
- Settings-only string resources use the `settings` resource scope so they are
  excluded from the normal runtime resource set.
- Jungle requests `project.optimization = 3p`.

Complication details:
- Connect IQ minimum API is 4.2.0.
- Manifest requests the `ComplicationSubscriber` permission.
- Subscription starts with the app and is removed on stop.
- Battery callbacks update only the cached battery string and request a redraw.
- There is no charging-state timer and no per-frame battery polling.

Not implemented intentionally:
- No full-screen `BufferedBitmap`; the face is too simple to justify its memory
  and graphics-pool cost without hardware profiling proving a benefit.
- Date and battery bitmap resources are not merged. Their corresponding named
  sizes intentionally use different native pixel sizes (for example Normal date
  and Normal battery are different font sizes). One bitmap-font resource cannot
  supply both native sizes for the same glyph without scaling one use, which
  would reduce sharpness.

Recommended next measurement:
Build a profiling version with Garmin's `-k`/profiling support only if real-world
battery drain remains suspicious. Do not use a profiling build as the everyday
battery-life build.
