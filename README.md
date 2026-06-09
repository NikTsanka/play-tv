# StreamHub

Universal **IPTV / TV / Radio player** built with Flutter. Clean-room reimplementation of a
production multi-provider TV player, re-targeted to Flutter — **without** any physical
DVB/satellite tuner functionality (network streaming, OTT, VOD, local files & radio only).

> Full functional specification: [`IPTV-Player-Flutter-Prompt.md`](IPTV-Player-Flutter-Prompt.md)

## Status — Milestone 1 (Skeleton) ✅

- Flutter app shell (Windows + Android targets) with a TV/desktop `NavigationRail`.
- **Riverpod** state management (MVVM); **go_router** navigation.
- **Material 3 theme** — gold (`#D4AF37` / `#E6C463`), white, near-black — with a
  **System / Light / Dark** switch (settings + top-bar quick toggle), **persisted** and animated.
- **Localization** scaffold (`flutter_localizations` + ARB): English, ქართული, Русский (+ RTL ready).
- **App-data directories** (config / db / logos / recordings / cache / logs) via `path_provider`.
- **Logging** (`logger`).
- **Theme showcase** screen demonstrating the palette in both modes.

Upcoming milestones (see the spec, §13): playback core (`media_kit`), M3U import + channel
tree + drift storage, EPG (XMLTV), the provider framework, Xtream Codes / Stalker / OttBase,
VOD, recording/time-shift/scheduler, the background `TaskManager`, and full settings.

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

## Adding a provider / engine

Documented from Milestone 5/2 onward (provider-author guide + engine guide). The contracts are
specified in `IPTV-Player-Flutter-Prompt.md` §4 (providers) and §8 (engines), with concrete API
references in Appendices A–D (Xtream Codes, Stalker, OttBase, M3U catch-up).
