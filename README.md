# StreamHub

Universal **IPTV / TV / Radio player** built with Flutter. Clean-room reimplementation of a
production multi-provider TV player, re-targeted to Flutter — **without** any physical
DVB/satellite tuner functionality (network streaming, OTT, VOD, local files & radio only).

> Full functional specification: [`IPTV-Player-Flutter-Prompt.md`](IPTV-Player-Flutter-Prompt.md)

## Status — Milestones 1–12 ✅

- **Shell & theme** — TV/desktop `NavigationRail`, Riverpod (MVVM), go_router, Material 3
  gold/white/black with persisted System/Light/Dark; localization (en / ka / ru).
- **Playback** — `media_kit` engine behind a `PlaybackEngine` interface + transport controls.
- **Channels** — M3U parser, drift storage, virtualized channel tree, zapping, OSD now/next.
- **EPG** — streaming XMLTV import (isolate), EPG grid, alias matching, catch-up.
- **Providers** — `Provider` / `ProviderType` / `ProvidersManager` framework: M3U URL/file,
  Generic URL, iptv-org, **Xtream Codes**, **Stalker**, **OTT** (Kartina/Sovok/TV Club),
  **local folder**, **YouTube** (flagged); per-zap URL resolution for session sources.
- **VOD** — browser (movies / series / favorites), offline cache, search/sort.
- **Recording** — HTTP recorder, scheduler (record-by-programme), filename templates, time-shift buffer.
- **TaskManager** — cancellable background tasks with progress; logo fetch (fuzzy match); auto-update check.
- **Parental control** — hashed PIN gating protected channels; **D-pad** focus polish; **MSIX/leanback** packaging.

See [`IPTV-Player-Flutter-Prompt.md`](IPTV-Player-Flutter-Prompt.md) §13 for the milestone map.

## Project layout

```
lib/
  app/            bootstrap, router, shell, theme, locale
  core/           logging, storage (app paths, preferences)
  features/       UI feature modules (home, settings, theme_showcase, …)
  l10n/           ARB files + generated AppLocalizations
```
The **domain** and **playback engine** layers (added next) stay pure Dart and
platform-agnostic; only the playback surface and a few platform services touch native code.

## Getting started

Prerequisites: Flutter (stable, 3.44+).

```bash
flutter pub get
flutter gen-l10n        # generates lib/l10n/generated/app_localizations.dart
flutter run -d windows  # or: flutter run -d <android-device>
```

## Theming

Colors live in `lib/app/theme/app_colors.dart`; the light/dark `ThemeData` is built in
`lib/app/theme/app_theme.dart`. The active mode is a persisted Riverpod
`NotifierProvider` (`lib/app/theme/theme_controller.dart`). Gold is reserved for accents,
focus, selection and key actions — never large fills.

## Localization

Strings are authored in `lib/l10n/app_<locale>.arb` (template: `app_en.arb`). Run
`flutter gen-l10n` after editing. Add a locale by dropping in a new ARB file and listing it in
the language picker.

## Packaging

- **Windows (installer, recommended):** an [Inno Setup](https://jrsoftware.org/isinfo.php)
  script at `installer/streamhub.iss`. Build the release then compile:
  ```
  flutter build windows --release
  ISCC.exe installer\streamhub.iss
  ```
  Produces `installer/Output/StreamHub-Setup-0.1.0.exe` — a per-user installer (no admin),
  with Start-menu/desktop shortcuts and an uninstaller.
- **Windows (MSIX):** config lives under `msix_config:` in `pubspec.yaml`. Build with
  `dart run msix:create` (supply a signing certificate for store/sideload distribution).
- **Android / Android TV:** `flutter build apk` / `flutter build appbundle`. The manifest declares
  `INTERNET`, optional `leanback`/touchscreen features and a `LEANBACK_LAUNCHER` category so the
  same artifact installs on phones and on the Android TV launcher.

## Adding a provider

A source is one class implementing `Provider` (`lib/domain/providers/provider.dart`) plus a
`ProviderType` entry in the registry (`provider_type.dart`):

1. Implement `fetchChannelList(sink, ct)` (push `Channel`s; set `sink.epgUrl` if you have a guide).
2. For session/portal sources, override `resolveStreamUrl(channel)` — it's called per zap and the
   built provider is cached so your session/token persists. Override `vodCatalog` to feed the VOD browser.
3. Add a `ProviderType` value + a `ProviderTypeDescriptor` (capabilities + `create`).
4. Add a setup form branch in `features/providers/add_provider_dialog.dart`.

Worked examples: `sources/xtream` (deterministic URLs + VOD), `sources/stalker` (per-zap
`create_link`), `sources/ott` (a base + branded subclasses). API references are in
`IPTV-Player-Flutter-Prompt.md` Appendices A–D. Engines implement `PlaybackEngine` (§8).
