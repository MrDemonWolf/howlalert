# DMG assets

Drop the following before the macOS release workflow can produce a branded DMG:

- `background.png` — 540×380 pt (1080×760 px @2x) per Section B styling. Cyan accent on navy backdrop. Generated from the Claude Design bundle.
- `volume.icns` — DMG volume icon. Export from Icon Composer.
- `dmg-spec.json` — `LinusU/node-appdmg` spec. Will be generated alongside the workflow in Slice 10.

Nothing here ships in the .app bundle — these are for the installer disk image only.
