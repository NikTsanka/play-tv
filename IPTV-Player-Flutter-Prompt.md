# Claude Code Build Prompt — Flutter Universal IPTV / TV / Radio Player ("StreamHub")

> **How to use:** Give this file to Claude Code and ask it to build the app. It is a complete
> functional spec reverse-engineered from a production .NET MAUI TV player (ProgTV 3.11.7),
> re-targeted to **Flutter**. Build a **new app with a fresh visual identity** and the **same
> feature set**, **minus all physical DVB / satellite tuner functionality** (IPTV / OTT /
> streaming / local-files / radio only). Clean-room: reuse no original code, names, or assets.

---

## 0. Mission

Build **"StreamHub"** — a cross-platform Flutter media player for live IPTV channels, OTT
subscription services, Video-On-Demand, local media, and radio. Accept channels from many
provider types, play them with a hardware-accelerated pipeline, and provide a full TV-style
experience (EPG, OSD, zapping, favorites) plus recording, time-shift, and scheduling.

**Primary targets:** Windows desktop + Android (incl. Android TV). Keep macOS/iOS/Linux
buildable. Design for both 10-foot remote/D-pad navigation **and** mouse/touch.

---

## 1. Flutter tech stack (use these unless you justify a better choice)

| Concern | Package / approach |
|---|---|
| **Video/audio playback** | **`media_kit`** (+ `media_kit_video`, `media_kit_libs_video`) — libmpv/FFmpeg core. Covers HLS, DASH, RTSP, RTP/UDP multicast, SRT, MMS, HTTP(S), local files; H.264/HEVC/AV1/VP9; hardware decoding; multiple audio/subtitle tracks; external subs. **This is the playback core.** |
| **State management** | **Riverpod** (`flutter_riverpod` + `riverpod_annotation`/codegen). MVVM-style: immutable state, providers as view-models. |
| **Navigation** | `go_router` (declarative, deep-link & TV-focus friendly). |
| **HTTP** | `dio` (interceptors for user-agent/referer/proxy/retry, connection pooling, cancel tokens). |
| **Channel DB / persistence** | **`drift`** (SQLite) for the channel store + EPG + VOD cache (handles 10k+ channels, fast queries, FTS for search). `shared_preferences` for simple settings; app-data dir via `path_provider`. |
| **XML (XMLTV/XSPF/W3U)** | `xml` with the **streaming/event parser** for large XMLTV files. |
| **JSON** | `dart:convert` + `json_serializable` for typed provider DTOs. |
| **Localization** | `flutter_localizations` + `intl` + ARB files. RTL support (Arabic/Hebrew). |
| **Background tasks** | Dart `Isolate`s (via `compute`/`Isolate.run`) for parsing & downloads; a task-manager service with progress streams. Optional `workmanager`/`flutter_background_service` for scheduled records on mobile. |
| **DI** | Riverpod providers (no separate DI container needed). |
| **Logging** | `logger` package; route to a debug page + rolling file. |
| **Casting** | `cast`/`flutter_chrome_cast` (gate behind a feature flag; desktop may no-op). |
| **Theming** | Material 3 (`useMaterial3: true`) with a custom `ColorScheme` (see §9) + `ThemeMode` switch. |

Keep the **domain & engine layers pure Dart and platform-agnostic**; only the playback
surface and a few platform services touch Flutter/native.

---

## 2. Architecture (layering to copy from the reference)

```
┌──────────────────────────────────────────────────────────────────┐
│  Presentation (Flutter widgets + Riverpod view-models)             │
│    Video view + OSD, EPG grid, channel tree, VOD browser, options  │
├──────────────────────────────────────────────────────────────────┤
│  Application/Control services                                      │
│    Engine selection, scheduler, recording, time-shift, profiles    │
├──────────────────────────────────────────────────────────────────┤
│  Domain (pure Dart)                                                │
│    providers/  channel_list/  epg/  vod/  task_hub/                 │
├──────────────────────────────────────────────────────────────────┤
│  Playback engine abstraction  (PlaybackEngine interface)           │
│    MediaKitEngine (primary) · NativePlayerEngine · CastEngine       │
├──────────────────────────────────────────────────────────────────┤
│  media_kit (libmpv + FFmpeg)                                       │
└──────────────────────────────────────────────────────────────────┘
```

Suggested folder layout:
```
lib/
  app/            // bootstrap, router, theme, localization
  core/           // result types, errors, http, storage, isolates, logging
  domain/
    providers/    // Provider base + ProviderType registry + concrete providers
    channels/     // channel model, tree, import (m3u/xspf/w3u), storage (drift)
    epg/          // xmltv/jtv import, storage, alias matching
    vod/          // catalog model, cache
    playback/     // PlaybackEngine interface + engines
    recording/    // recorder, timeshift, scheduler, filename templates
    tasks/        // TaskManager, downloaders
  features/       // UI feature modules (player, epg, channel_list, vod, settings, setup)
  l10n/           // ARB files
```

Core design principles (mirror the original):
- **Provider abstraction** — every channel source implements one `Provider` interface
  (caption, available functions, async channel fetch, per-zap dynamic URL, EPG fetch, update
  interval, logo source, setup dialog, persistence). A `ProvidersManager` owns & persists them.
  New source = new class.
- **Engine abstraction** — a `PlaybackEnginesManager` selects an engine per channel/VOD/file
  and exposes play/stop/seek/track-switch/volume/aspect + record + time-shift.
- **Background task hub** — a `TaskManager` runs all I/O as cancellable tasks with progress.
- **Customization profiles** — a profile/config switch lets the same binary ship as a branded
  single-provider app or the full multi-provider app.

---

## 3. EXCLUDE THESE (do not build)

All physical tuner / broadcast-RF features:
- DVB-S/S2/T/T2/C, satellite, ATSC tuners; BDA device drivers / hardware tuner modules;
  CI/CAM conditional access; DiSEqC, LNB, positioner/USALS; blind scan; transponder lists;
  Sat>IP / DVB-over-IP of a real tuner; tuner signal meters / scanner / transponder editor.

Keep everything delivered over the network or from local files. Rule of thumb: HTTP/UDP/RTSP/
SRT/HLS/DASH stream → keep; real RF tuner → drop.

---

## 4. Provider types to implement (build bold base mechanisms first)

`Provider` interface + `ProviderType` registry + `ProvidersManager`, then:

### 4.1 Generic IPTV (highest priority)
- **M3U / M3U8** (file or URL): parse `#EXTINF`, `tvg-id`, `tvg-name`, `tvg-logo`,
  `group-title`, `catchup`/`catchup-source`, `#EXTVLCOPT`/`#EXTGRP`, per-channel user-agent
  & referer, Kodi props; auto-detect codepage.
- **XSPF** and **W3U** import.
- **Generic URL** (single stream as a channel).
- **Preset/template M3U** with `{login}`/`{password}`/`{token}` placeholders.
- **iptv-org** public JSON + M3U catalog.
- **Custom remote list** with periodic auto-update.

### 4.2 Xtream Codes (very high priority — dominant OTT API)
Full `player_api.php` client: login → account info; live categories & streams; VOD categories
& info; series → seasons → episodes; short-EPG + full XMLTV; catch-up/archive URL generation.
Build live/VOD/series trees.

### 4.3 Stalker / Ministra portal (high priority)
Handshake (token, MAC auth), categories, ordered channel list, `create_link` dynamic URL
resolution, VOD & series, short EPG.

### 4.4 OTT subscription services (shared base + subclasses)
Generic **`OttBaseProvider`** with a command pipeline (PreLogin → Login → GetSettings →
ChannelList → Guide → GetUrl → Logout) and a `Session`/`SessionSettings` (bitrate, source
server, stream standard). Implement these as thin, config-driven subclasses: Kartina TV,
Sovok TV, TV Club, Edem/iEdem, OTT Club, Shura TV, Rodina TV, Tolkun TV, Megogo, Planeta TV,
Nasche TV, Rodnoe TV, Torrent-TV, MyMagic TV, and a couple of generic JSON-API portals.
One base class should cover ~90% of each.

### 4.5 Local & on-device
Local files playlist, Video folder, Music folder, Audio books (CUE / M4B / embedded chapters),
Recorded-files browser; metadata reader (tags, cover, duration) + recursive folder indexing
as a background isolate task.

### 4.6 Other streaming
- **YouTube** (`youtube_explode_dart`): channel/playlist/video → playable stream, thumbnails,
  VOD source. Feature-flagged.
- **Internet-TV directory** (curated online list with multi-format fallback).

### Provider interface (Dart)
```dart
abstract class Provider {
  String get caption;
  ProviderType get type;
  Set<ProviderFunction> get availableFunctions; // {live, vod, epg, catchup, radio, logos}
  Future<void> fetchChannelList(ChannelSink sink, CancelToken ct);
  Future<String?> resolveStreamUrl(Channel ch, {bool forceNewSession = false}); // per-zap (OTT/Stalker)
  Future<void> fetchEpgForChannel(Channel ch);     // lazy per-channel EPG
  Duration get updateInterval;                      // auto-refresh cadence
  LogoSource get logoSource;
  Duration get archiveWindow;                       // catch-up depth
  Map<String, dynamic> toJson();                    // persistence
  factory Provider.fromJson(Map<String, dynamic> j) => ...;
  Widget buildSetupDialog(BuildContext ctx);        // credentials/options UI
}
```

---

## 5. Channel list & tree

- **Channel model**: id, name, providerId, primary + alternate stream URLs, group/category,
  logo, epgId/aliases, isRadio, parentalLocked, archive flag, custom props.
- **Tree**: root → groups/folders → channels, user-reorderable; **Favorites** trees;
  **History**; **Most Popular** (play counters); **Deleted** bucket. Change-history (undo).
- **Import**: M3U/M3U8, XSPF, W3U (auto codepage).
- **Storage** (drift/SQLite): channels + side tables (descriptions, EPG aliases, logo links,
  alt links); fast indexes; FTS for search.
- **Grouping/sorting**: by group, provider, alphabetical, frequency-of-use.
- **Logos**: logo-pack manager + per-user folder + background downloader with fuzzy name match.

---

## 6. EPG

- **Import**: **XMLTV** (streaming reader for huge files, off the UI isolate) + **JTV** (zip);
  from URL or file; per-provider guide URLs; **dynamic** per-channel EPG (Xtream/Stalker/OTT).
- **Model**: `EpgChannel` → ordered `EpgEvent`s (start/stop, title, desc, category, multi-lang).
  Storage with fast "now/next" and by-interval lookup.
- **Channel↔EPG relations**: alias matching (tvg-id, normalized name) across naming schemes.
- **Export**; async DB load/save. Powers OSD now/next, EPG grid, record-by-program, reminders,
  catch-up navigation.

---

## 7. VOD

Catalog tree: sources → categories/genres → films / **series → seasons → episodes**. Film &
file models, cover/logos, details (cast, year, rating, plot), filter/sort/search, favorites,
**offline cache**, paged lazy loading. Sources plug into VOD-capable providers (Xtream,
Stalker, Megogo, …) + "VOD from folder" + JSON "VOD list" import.

---

## 8. Playback engine

- **`PlaybackEngine` interface**; `PlaybackEnginesManager` picks an engine per item. Support
  multiple concurrent sessions (PiP / multi-record).
- **Engines**:
  1. **MediaKitEngine** (primary, `media_kit`) — all network + local formats, HW decode.
  2. **NativePlayerEngine** (fallback; platform player where it helps).
  3. **CastEngine** (Chromecast sender, flagged).
- **Controls**: play/stop/pause, seek, audio-track & subtitle-track switch (incl. external +
  bitmap subs), volume + per-channel normalization, mute, aspect/zoom/letterbox/pan, video
  color (brightness/contrast/hue/saturation), audio equalizer + AC3 passthrough mode,
  deinterlace, snapshot.
- **Video surface**: resizable `Video` widget with an overlay stack for OSD/subtitles;
  fullscreen, multi-monitor, orientation lock; keep-awake during playback (`wakelock_plus`).
- **HW acceleration** on by default; expose decoder/output selection in options.
- **Robustness**: on stream failure, auto-fallback to alternate URLs; "crash-channel
  protection" (skip a channel that crashed playback on next launch).

---

## 9. Visual identity — Gold / White / Black, Light + Dark

Build a **distinct** Material 3 design (do not resemble the reference). Theme palette:

- **Primary accent:** Gold `#D4AF37` (interactive accents, focus ring, selection, now-line,
  active tab, progress). Provide a slightly brighter gold for dark mode (`#E6C463`) so it pops.
- **Neutrals:** pure White `#FFFFFF` and near-Black `#0D0D0D` / `#1A1A1A` surfaces.
- **Light theme:** white backgrounds, black text, gold accents; elevated surfaces in soft grey.
- **Dark theme:** black/near-black backgrounds, white text, gold accents.
- **`ThemeMode` switch:** System / Light / Dark, toggleable from settings **and** a quick
  toggle in the top bar; persist the choice. Animate the transition.

Define both as `ColorScheme`s, e.g.:
```dart
const gold = Color(0xFFD4AF37);
final lightScheme = ColorScheme.fromSeed(
  seedColor: gold, brightness: Brightness.light,
  primary: gold, surface: Colors.white, onSurface: const Color(0xFF0D0D0D),
);
final darkScheme = ColorScheme.fromSeed(
  seedColor: gold, brightness: Brightness.dark,
  primary: const Color(0xFFE6C463), surface: const Color(0xFF0D0D0D), onSurface: Colors.white,
);
```
Use a refined serif/elegant display font for headings (gold-on-dark feels premium) and a clean
sans for body. Gold accents should read as luxury, not gaudy — use them on edges, focus,
selection, and key actions, not large fills.

### UI surfaces (replicate the interaction model, not the look)
- **Main video view** with **OSD**: channel info card (number, name, logo, now/next EPG,
  stream stats), volume bar, clock, status indicators.
- **Zapping**: number entry, up/down, last-channel toggle, channel-list overlay, quick search;
  long-press/hotkey context menus; **D-pad / remote / gamepad focus** support (use `Focus`/
  `FocusTraversal`, visible gold focus highlight).
- **Left channel-tree panel**: groups, favorites, history, most-popular.
- **Full EPG grid** (timeline × channels) with gold now-line, scroll, jump-to-now, program
  details popup, record/remind/catch-up actions.
- **Right panels**: VOD browser, channel context, search.
- **Settings pages** (mirror these, minus tuner ones): UI/Theme, Controls, Channel list,
  Playback, Video, Video colors, Audio, Codecs/renderers, Subtitles, Network, Record,
  Time-shift, Scheduler, Parental control, App data, Reset, Debug.
- **Provider setup dialogs** per type (credentials, URL, options, login subpanel, proxy
  subpanel, guide-URL helper).
- **Parental control**: PIN-locked channels/categories.
- **Localization** from day one (target ~30 languages; ship a few + scaffold), RTL support.

---

## 10. Recording, Time-shift, Scheduler

- **Recording**: live stream → file; filename template engine with tokens (`{channel}`,
  `{day}`, `{month}`, `{hour}`, `{minute}`, `{epgTitle}`, `{percent}`, …); optional transcode;
  multi-stream record; recorded-files browser.
- **Time-shift**: pause/rewind live via ring buffer; configurable size/location.
- **Scheduler**: schedule record / channel-switch / reminder at a time or recurring interval;
  EPG-driven ("record this program"); sleep timer. (On mobile, back with platform background
  services where allowed.)

---

## 11. Background services (TaskManager)

Cancellable tasks with progress streams, parsing/downloads on isolates:
- Playlist (M3U) downloader, custom-by-provider update.
- EPG (XMLTV/JTV) downloader + async DB load/save.
- Logo downloader (channel + VOD), clip downloader.
- VOD catalog fetch, local-file index/collect.
- App auto-update (version check + changelog + download), gated per platform/store.
- Web-client stack: pooling, retry, per-request user-agent/referer/proxy.

---

## 12. Non-functional requirements

- Handle 10k+ channel playlists and multi-hundred-MB XMLTV without jank (streaming parsers,
  list virtualization, isolates, drift queries).
- HTTP/HTTPS/UDP/RTP/RTSP/SRT/HLS/DASH; optional UDP→HTTP proxy + HTTP proxy settings.
- Human-readable JSON config for providers/settings; SQLite for channel/EPG/VOD; per-user
  app-data folder.
- Packaging: MSIX (Windows) + APK/AAB (Android, incl. Android TV leanback). Design for store
  submission.
- Custom file association for a settings/playlist file type on desktop.

---

## 13. Build order (milestones — each runnable)

1. **Skeleton**: Flutter app, Riverpod + go_router + Material 3 theme (gold/white/black,
   Light/Dark switch + persistence), localization scaffold, app-data dirs, logging.
2. **Playback core**: MediaKitEngine + `Video` widget + transport controls. Play an HLS URL.
3. **Channel model + M3U import** + drift storage + left channel tree + zapping + OSD now/next.
4. **EPG**: XMLTV import (isolate) + EPG grid + now/next binding + alias matching.
5. **Provider framework**: interface + registry + manager + setup dialogs; wire Generic-URL,
   M3U-URL, iptv-org.
6. **Xtream Codes** (live + VOD + series + EPG + catch-up), then **Stalker**.
7. **OttBase** + 2–3 branded OTT subclasses.
8. **VOD** browser + favorites + offline cache.
9. **Recording + time-shift + scheduler** + filename templates.
10. **TaskManager** downloaders + logo fetch + auto-update.
11. **Local files / music / audiobooks / recorded browser**; YouTube (flagged).
12. **Full settings, parental control, Chromecast, D-pad polish, packaging.**

Cover pure logic with unit tests (M3U/XMLTV/XSPF parsers, filename templates, EPG time lookup,
alias matching). Keep DVB/tuner concerns out entirely (§3).

---

## 14. Deliverables

- Buildable Flutter solution with the layering in §2 and folder layout above.
- README: architecture, how to add a provider, how to add an engine, theme overview.
- Provider-author guide (`Provider` interface + a worked example).
- Sample config + demo public M3U/XMLTV sources for testing.
- A theme showcase screen demonstrating gold/white/black in both Light and Dark.
- No code, assets, names, or branding copied from the reference app.

---

# Appendix A — Xtream Codes API (implementation reference)

Xtream Codes / XUI.one panels expose a JSON API plus deterministic stream-URL patterns. The
provider only needs **base URL + username + password**.

### A.1 Base & auth
```
BASE = {scheme}://{host}:{port}        // e.g. http://example.com:8080
AUTH = ?username={u}&password={p}
```
All API calls hit `player_api.php`. Login = call it with no `action`:
```
GET {BASE}/player_api.php{AUTH}
```
Response (store `auth==1` & `status=="Active"`; `exp_date` is unix seconds, may be null for
unlimited):
```jsonc
{
  "user_info": {
    "username":"u","password":"p","message":"","auth":1,"status":"Active",
    "exp_date":"1735689600","is_trial":"0","active_cons":"0","created_at":"1600000000",
    "max_connections":"1","allowed_output_formats":["m3u8","ts","rtmp"]
  },
  "server_info": {
    "url":"example.com","port":"8080","https_port":"443","server_protocol":"http",
    "rtmp_port":"1935","timezone":"Europe/London","timestamp_now":1700000000,"time_now":"2024-..."
  }
}
```
> Prefer `server_info.server_protocol` + `url` + `port` to rebuild stream URLs (panels often
> redirect to a different delivery host than the login host).

### A.2 Endpoints (append to `{BASE}/player_api.php{AUTH}`)
| Purpose | Query | Notes |
|---|---|---|
| Login / account | *(no action)* | see A.1 |
| Live categories | `&action=get_live_categories` | `[{category_id,category_name,parent_id}]` |
| Live streams | `&action=get_live_streams` `[&category_id=ID]` | see A.3 |
| VOD categories | `&action=get_vod_categories` | same shape as live categories |
| VOD streams | `&action=get_vod_streams` `[&category_id=ID]` | see A.4 |
| VOD info (details) | `&action=get_vod_info&vod_id=ID` | `{info, movie_data}` |
| Series categories | `&action=get_series_categories` | same shape as categories |
| Series list | `&action=get_series` `[&category_id=ID]` | see A.5 |
| Series info | `&action=get_series_info&series_id=ID` | `{seasons, info, episodes}` |
| Short EPG | `&action=get_short_epg&stream_id=ID[&limit=N]` | `epg_listings[]`, **base64** title/desc |
| Full EPG table | `&action=get_simple_data_table&stream_id=ID` | `epg_listings[]`, **base64** title/desc |
| Full XMLTV dump | `{BASE}/xmltv.php{AUTH}` | standard XMLTV (not player_api.php) |

### A.3 `get_live_streams` item
```jsonc
{
  "num":1,"name":"BBC One HD","stream_type":"live","stream_id":12345,
  "stream_icon":"http://logo.png","epg_channel_id":"bbc1.uk","added":"1600000000",
  "category_id":"10","custom_sid":"","tv_archive":1,"direct_source":"",
  "tv_archive_duration":7   // catch-up days; 0/absent = none
}
```
**Live stream URL:**
```
{scheme}://{host}:{port}/live/{u}/{p}/{stream_id}.{ext}     // ext = ts  (or m3u8 if allowed)
```

### A.4 `get_vod_streams` item + `get_vod_info`
```jsonc
// list item
{ "num":1,"name":"Movie (2023)","stream_type":"movie","stream_id":999,"stream_icon":"...",
  "rating":"7.5","rating_5based":3.8,"added":"...","category_id":"5",
  "container_extension":"mkv","custom_sid":"","direct_source":"" }

// get_vod_info?vod_id=999
{ "info":{ "tmdb_id":..., "name":..., "o_name":..., "cover_big":..., "movie_image":...,
           "releasedate":..., "youtube_trailer":..., "director":..., "actors":..., "cast":...,
           "description":..., "plot":..., "age":..., "country":..., "genre":...,
           "duration_secs":..., "duration":"01:58:00", "rating":..., "backdrop_path":[...] },
  "movie_data":{ "stream_id":999, "name":..., "container_extension":"mp4", "direct_source":... } }
```
**VOD stream URL** (use `container_extension`):
```
{scheme}://{host}:{port}/movie/{u}/{p}/{stream_id}.{container_extension}
```

### A.5 Series → seasons → episodes
```jsonc
// get_series item
{ "num":1,"name":"Show","series_id":50,"cover":"...","plot":"...","cast":"...","director":"...",
  "genre":"...","releaseDate":"...","rating":"...","rating_5based":...,"backdrop_path":[...],
  "youtube_trailer":"...","episode_run_time":"45","category_id":"7" }

// get_series_info?series_id=50
{ "seasons":[ {"season_number":1,"name":"Season 1","cover":"...","episode_count":"10"} ],
  "info":{ "name":..., "cover":..., "plot":..., "genre":..., "rating":... },
  "episodes":{
    "1":[ { "id":"1001","episode_num":1,"title":"S01E01","container_extension":"mkv",
            "info":{"movie_image":...,"plot":...,"duration_secs":...,"duration":...,"rating":...},
            "season":1,"custom_sid":"","added":"...","direct_source":"" } ]
  } }
```
**Episode stream URL** (use episode `id` + `container_extension`):
```
{scheme}://{host}:{port}/series/{u}/{p}/{episode_id}.{container_extension}
```

### A.6 EPG decoding
`get_short_epg` / `get_simple_data_table` return:
```jsonc
{ "epg_listings":[ { "id":"...","epg_id":"...","title":"<base64>","lang":"",
    "start":"2024-01-01 20:00:00","end":"2024-01-01 21:00:00","description":"<base64>",
    "channel_id":"bbc1.uk","start_timestamp":"1704139200","stop_timestamp":"1704142800",
    "now_playing":1,"has_archive":0 } ] }
```
**`title` and `description` are Base64** → decode to UTF-8. Prefer `*_timestamp` (unix) over the
string dates. For full guide across all channels, parse `xmltv.php` instead.

### A.7 Catch-up / archive (`tv_archive==1`)
Two URL forms exist; support both, prefer the path form, fall back to the php form:
```
// path form  (start = "YYYY-MM-DD:HH-MM", duration in minutes)
{scheme}://{host}:{port}/timeshift/{u}/{p}/{duration}/{start}/{stream_id}.ts
// php form
{scheme}://{host}:{port}/streaming/timeshift.php?username={u}&password={p}&stream={stream_id}&start={start}&duration={duration}
```
Drive `start`/`duration` from the selected EPG event's timestamps.

### A.8 Implementation notes
- Always send a realistic `User-Agent` (e.g. an IPTV-app or VLC UA); some panels reject defaults.
- Handle non-JSON / HTML error pages and `auth:0` gracefully; surface "expired/blocked".
- Respect `max_connections` (don't open guide + zap concurrently if it's 1).
- Build the channel tree from categories; map `epg_channel_id` → EPG via alias matching (§6).
- Cache category/stream lists; refresh on `updateInterval`.

---

# Appendix B — Stalker / Ministra (MAG portal) API (implementation reference)

Stalker Portal (a.k.a. Ministra, MAG STB middleware) authenticates by **MAC address** and a
**handshake token**, then resolves each stream URL on demand via `create_link`. Provider input:
**portal URL + MAC** (some portals also need login/password).

### B.1 Portal endpoint & headers
Portal base is usually one of:
```
{host}/portal.php          {host}/stalker_portal/server/load.php          {host}/c/portal.php
```
Every request is `GET {portal}?type={t}&action={a}&...&JsHttpRequest=1-xml` with headers:
```
Cookie: mac={MAC}; stb_lang=en; timezone=Europe/London
User-Agent: Mozilla/5.0 (QtEmbedded; U; Linux; C) AppleWebKit/533.3 (KHTML, like Gecko)
            MAG200 stbapp ver: 2 rev: 250 Safari/533.3
X-User-Agent: Model: MAG250; Link: WiFi
Authorization: Bearer {token}        // added after handshake
Referer: {host}/c/                    // some portals validate this
```
MAC format `00:1A:79:XX:XX:XX`. Responses wrap payload in `{"js": ...}`.

### B.2 Auth flow (in order)
```
1) Handshake → get token
   GET {portal}?type=stb&action=handshake&token=&JsHttpRequest=1-xml
   → { "js": { "token":"A1B2C3...", "random":"..." } }

2) Authorize / get profile (send token in Authorization header)
   GET {portal}?type=stb&action=get_profile&hd=1&ver=...&num_banks=2
       &sn={serial}&stb_type=MAG250&device_id={dev}&device_id2={dev}
       &signature={sig}&auth_second_step=0&hw_version=1.7-BD-00
       &not_valid_token=0&JsHttpRequest=1-xml
   → { "js": { "id":..., "name":..., "...": ... } }   // session established
   // Many public portals accept handshake + get_profile with empty signature/device_id.
   // Token can expire → re-handshake and retry on 401/empty js.

3) (optional) Account/subscription info
   GET {portal}?type=account_info&action=get_main_info&JsHttpRequest=1-xml
   → { "js": { "mac":..., "phone":... (expiry on some panels), "...":... } }
```

### B.3 Live TV endpoints (`type=itv`)
| Purpose | Query |
|---|---|
| Genres (categories) | `type=itv&action=get_genres` → `[{id,title,alias,censored}]` |
| All channels (one shot) | `type=itv&action=get_all_channels` |
| Ordered list (paged) | `type=itv&action=get_ordered_list&genre={genreId|*}&p={page}&sortby=number` |
| **Resolve stream URL** | `type=itv&action=create_link&cmd={urlEncoded cmd}&forced_storage=0&disable_ad=0` |
| Short EPG | `type=itv&action=get_short_epg&ch_id={id}&size=10` |
| EPG window | `type=itv&action=get_epg_info&period={hours}` |

**Channel item** (from `get_all_channels` / `get_ordered_list` → `js.data[]`):
```jsonc
{ "id":"1234","name":"Channel 1","number":"1","cmd":"ffmpeg http://localhost/ch/1234_",
  "logo":"...","tv_genre_id":"5","censored":0,"xmltv_id":"chan1","use_http_tmp_link":"1",
  "cmds":[ {"id":"...","ch_id":"1234","url":"ffmpeg http://localhost/ch/1234_"} ] }
```
Paged response also carries `js.total_items` and `js.max_page_items` → loop pages.

**Resolving the playable URL (the critical step):**
```
GET {portal}?type=itv&action=create_link&cmd={urlEncode(channel.cmd)}&JsHttpRequest=1-xml
→ { "js": { "id":0, "cmd":"ffmpeg http://real.cdn/stream/12345?token=..." } }
```
Strip a leading `ffmpeg ` (and any leading token like `auto ` / numeric id) from `js.cmd` to
get the final URL. **Resolve on every zap** — links are short-lived/session-bound.

### B.4 VOD & Series
```
type=vod&action=get_categories
type=vod&action=get_ordered_list&category={id}&sortby=added&p={page}&search=&fav=0
type=vod&action=create_link&cmd={urlEncoded cmd}        // same strip-prefix rule
type=series&action=get_categories
type=series&action=get_ordered_list&category={id}&movie_id={id}&season_id={id}&episode_id={id}&p={page}
```
VOD item resembles the channel item (`id`, `name`, `cmd`, `screenshot_uri`, `time`, `year`,
`description`, `rating_imdb`, `director`, `actors`). For series, `cmd` may encode episode list;
follow `series` array / `get_ordered_list` drill-down for seasons → episodes.

### B.5 EPG
- `type=itv&action=get_short_epg&ch_id={id}` → `js[]` of `{id,ch_id,name,descr,time,time_to,
  start_timestamp,stop_timestamp,duration}`.
- `type=epg&action=get_simple_data_table&...` on portals that support a guide table.
- Many portals also publish an external **XMLTV** URL — if `get_profile` returns one or the
  provider supplies it, import via the standard XMLTV path (§6) and alias-match on `xmltv_id`.

### B.6 Implementation notes
- Persist the token; transparently **re-handshake** on empty `js`/auth failure, then retry once.
- Send **all three** UA headers; spoof a MAG250/MAG254 STB. Keep the same MAC across calls.
- URL-encode the entire `cmd` when calling `create_link`; always strip the engine prefix.
- Honor `total_items`/`max_page_items` pagination; throttle to avoid portal bans.
- Build the tree from genres → ordered lists; store `cmd` per channel (resolve lazily on play).
- Treat portal variability defensively (field names differ across Stalker/Ministra forks);
  decode tolerantly and log unknown shapes to the debug page.

---

# Appendix C — OttBase framework (login / get_url flow)

Most branded OTT services (Kartina TV, Sovok, TV Club, Rodina, Shura, Tolkun, OTT Club, Megogo,
etc.) share one session-based JSON API shape: **login → get a session id/token → list channels
→ resolve a per-channel play URL on demand → logout**. Instead of writing each one separately,
build **one `OttBaseProvider` + a command pipeline**, and implement each service as a subclass
that overrides only the endpoint paths, field names, and auth quirks. Reference base classes:
`OttBaseProvider`, `ApiManagerBase`, `StackProcessor`, `ApiCommand`, `Session`,
`SessionSettings`, and the `*BaseCommand` family.

### C.1 Core model
```dart
class OttSession {                       // persisted between launches
  String? sid;                           // session id / token (cookie or query param)
  DateTime? issuedAt;
  DateTime? expiresAt;                   // re-login when near/!valid
  Map<String,String> extra = {};         // service-specific (e.g. salt, csrf, server host)
  bool get isValid => sid != null && (expiresAt == null || DateTime.now().isBefore(expiresAt!));
}

class OttSessionSettings {               // chosen + available options from GetSettings
  String? bitrate;        List<Bitrate> bitrates;          // e.g. "12 Mbit", "variant"
  String? sourceServer;   List<SourceServer> servers;      // CDN / datacenter choice
  String? streamStandard; List<StreamStandard> standards;  // hls / mpegts / dash
  bool    timeshiftEnabled;
  String? parentalCode;                                    // for protected channels
}

abstract class OttApiCommand<T> {        // one request unit
  String build(OttSession s);            // URL + params (uses session)
  T parse(Object json, OttSession s);    // typed result; may mutate session
  bool get needsSession => true;         // false for PreLogin/Login
}
```

### C.2 The pipeline (`ApiManagerBase` + `StackProcessor`)
A single serial processor runs commands FIFO and centralizes auth recovery:

```
PreLogin → Login → GetSettings → ChannelList → Guide(s) →  …  → GetUrl(per zap) → Logout
```
- **`StackProcessor`** executes commands one at a time (these APIs are session-stateful and
  rate-limited). It owns retry + **auto re-login**: if any command returns "auth error /
  session expired", it transparently re-runs PreLogin→Login→(GetSettings), then retries the
  original command **once**, then surfaces the error.
- Commands enqueue follow-ups (e.g. Login success → GetSettings → ChannelList).
- All network errors map to a typed `ApiCommandError` shown on a status panel.

### C.3 Command roles (override points per service)
| Command | Purpose | Typical request → response |
|---|---|---|
| **PreLogin** | optional: fetch salt/captcha/csrf or a temp token | `GET /api/login` → `{salt, token}` (many services skip this) |
| **Login** | exchange credentials for a session | `GET/POST /api/json/login?login={u}&pass={p}` → `{sid:"...", account...}` (or sets a cookie) |
| **GetSettings** | available bitrates / servers / standards / timeshift / parental | `?action=settings&sid=` → fills `OttSessionSettings` |
| **AccountInformation** | subscription status, expiry, payments | `?action=account_info` → `{exp_date, packages[], payments[]}` |
| **ChannelList** | groups + channels | `?action=channel_list&sid=` → groups→channels (id,name,logo,epg flags,protected,ts) |
| **Guide / OneChannelGuide** | EPG (bulk or per-channel) | `?action=epg&cid={id}&day=` → events list |
| **GetUrl** | **resolve playable URL for a channel (per zap)** | see C.4 |
| **SetSettings** | persist user choice (bitrate/server/parental) | `?action=set&bitrate=&server=` |
| **Logout** | end session | `?action=logout&sid=` |
| **VOD: Genres / Films / FilmDetails / Search** | VOD catalog | `?action=vod_*` → genres, paged films, details |

Each subclass overrides: base URL, the action/path names above, the field mapping in `parse`,
the auth carrier (query `sid=` vs `Cookie: sid=` vs `Authorization: Bearer`), and any signing.

### C.4 GetUrl flow (the critical per-zap step)
Live channels in these services are **not** static URLs — you call GetUrl right before play to
get a short-lived, token-stamped stream URL:

```
GetUrlBaseParams {
  channelId,                 // service channel id (cid)
  protectCode?,              // parental PIN if channel.protected == true
  bitrate?, sourceServer?,   // from SessionSettings (user choice)
  timeshiftStart?,           // for catch-up: epg event start (unix or Y-M-D:H-M)
}
```
```
GET {base}/api/json/get_url?cid={channelId}&sid={session.sid}
    [&protect_code={protectCode}][&srv={sourceServer}][&bitrate={bitrate}][&gmt={tsStart}]
→ { "url": "http://cdn.example/live/12345.m3u8?token=ABC&exp=..." }    // shape varies
```
Resolution rules to implement generically:
1. **Always resolve on zap** (and on archive seek); never cache the final URL past its expiry.
2. If response says **session expired** → re-login (C.2) and retry once.
3. If channel is `protected` and no/invalid `protect_code` → prompt for parental PIN, retry.
4. Substitute the user-selected **bitrate / source server / stream standard** into the request.
5. Some services return a relative path or a host-less URL → prepend `session.extra['host']`
   or `server_info`-style base.
6. For **catch-up**, pass the EPG event's start (and sometimes duration) per the service's
   timeshift param; otherwise GetUrl returns the live edge.
7. Strip any player prefix (rare here, common in Stalker) and validate scheme before handing
   the URL to the engine; on failure, fall back to alternate bitrate/server.

### C.5 Worked shape (Kartina/Sovok-style JSON — typical of this family)
```jsonc
// Login → { "sid":"abcd1234", "sid_name":"sid", "account":{ "login":"u", ... } }
// channel_list → { "groups":[ { "id":1,"name":"News","channels":[
//     { "id":101,"name":"BBC","number":1,"icon":"http://...","epg_start":1700000000,
//       "epg_progname":"News at Ten","protected":0,"have_archive":1 } ] } ] }
// get_url?cid=101&sid=abcd1234 → { "url":"http://srv/live/101/index.m3u8?token=..." }
// epg?cid=101&day=20240101 → { "epg":[ {"id":..,"name":"..","descr":"..","start":..,"end":..} ] }
```
> Field names differ per service (`sid`/`token`, `channels`/`ch`, `url`/`cmd`/`href`,
> `protected`/`is_protected`). Keep mappings in the subclass; the base owns the **flow**.

### C.6 Implementation notes
- Persist `OttSession` + `OttSessionSettings`; restore on launch and validate with a cheap call
  (AccountInformation) before reusing.
- Serialize all calls per provider through one `StackProcessor`; respect rate limits.
- Centralize re-login + single-retry in the processor so commands stay simple.
- Map `protected` channels to parental-control (§9) and require the PIN at GetUrl time.
- Build live + VOD trees from ChannelList / VOD commands; alias-match EPG by id/name (§6).
- New service = subclass overriding ~6 endpoints + field maps; target <300 lines each.

---

# Appendix D — M3U catch-up / archive formats (implementation reference)

For plain M3U/M3U8 providers, "catch-up" (archive / time-shift TV) is declared with per-channel
`#EXTINF` attributes. To play a past EPG event you transform the channel's live URL using the
declared **catchup type** + **catchup-source template**, substituting time placeholders from the
selected EPG event. Implement one `CatchupUrlBuilder` that covers all types below.

### D.1 Declaring attributes (on `#EXTINF` and/or `#EXTGRP`/Kodi props)
```m3u
#EXTINF:-1 tvg-id="bbc1.uk" catchup="flussonic" catchup-days="7"
        catchup-source="http://host/bbc1/timeshift_abs-${start}.m3u8",BBC One
http://host/bbc1/index.m3u8
```
Recognized keys (accept Kodi aliases):
- `catchup` (a.k.a. `catchup-type`, `tvg-rec`) — one of: `default` · `append` · `shift`
  (a.k.a. `timeshift`) · `flussonic` · `xc` · `vod`.
- `catchup-source` — URL template with placeholders (D.3). Optional for `flussonic`/`xc`/`shift`.
- `catchup-days` (a.k.a. `catchup-time` in seconds) — archive depth → set channel `archiveWindow`.
- `catchup-correction` — hour offset applied to the timestamps (server TZ correction).
- Kodi `#KODIPROP:`/`#EXTVLCOPT:` lines may carry the same as properties — parse both.

### D.2 Type resolution
Given live URL `L`, template `S` (catchup-source), event start/end:
| `catchup` | How to build the archive URL |
|---|---|
| **default** | If `S` set → use `S` with placeholders (D.3). Else append a default query to `L`: `?utc={start}&lutc={now}`. |
| **append** | `L` **+** (placeholder-expanded `S`). `S` is a suffix/query appended to the live URL. |
| **shift** / **timeshift** | Append `?utc={start}&lutc={now}` (or expanded `S`) to `L`. Equivalent to default-append for shift servers. |
| **flussonic** | Flussonic media server. If `S` given, expand it; else derive from `L` (D.4). |
| **xc** | Xtream Codes archive path (D.5). |
| **vod** | Treat the expanded `S`/`L` as a static VOD-style file (no live edge). |

If `catchup` is absent but `catchup-source` is present → treat as **default**.

### D.3 Placeholder tokens (expand in `catchup-source`)
Times are **UTC**, derived from the chosen EPG event (apply `catchup-correction` hours first).
Support both `{token}` and `${token}` forms:

| Token(s) | Meaning |
|---|---|
| `{utc}` `${start}` `{start}` `{utc:…}` | event **start**, unix seconds |
| `{utcend}` `${end}` `{end}` | event **end** = start + duration, unix seconds |
| `{lutc}` `{now}` `{timestamp}` | **current** time, unix seconds |
| `{duration}` | event duration in **seconds** |
| `{durmin}` `{duration:min}` | duration in **minutes** |
| `{offset}` `{offset:N}` | seconds from now back to start (`now - start`); `:N` = literal seconds |
| `{Y}{m}{d}{H}{M}{S}` | UTC date parts of **start** (4-2-2-2-2-2 digits) |
| `{utc:YmdHMS}` / strftime-like | formatted start (support `Y m d H M S` letters) |
| `{catchup-id}` | per-channel id from `catchup-id="..."` attribute, if present |

`{start}`/`{end}` may also need strftime formatting in some lists — support
`{start:%Y-%m-%d-%H-%M-%S}`-style specifiers in addition to bare unix output.

### D.4 Flussonic patterns (when deriving from the live URL)
Flussonic live URLs and their archive equivalents (HLS shown; DASH/TS analogous):
```
live  : http://host/CH/index.m3u8            | http://host/CH/mono.m3u8
archive: http://host/CH/timeshift_abs-{start}.m3u8           // absolute start
         http://host/CH/archive-{start}-{duration}.m3u8      // start + length
         http://host/CH/index-{start}-{duration}.m3u8        // variant
TS     : http://host/CH/archive-{start}-{duration}.ts
```
Algorithm when no explicit `catchup-source`: take the live URL, replace the trailing
`index.m3u8`/`mono.m3u8`/`video.m3u8` (or `.ts` playlist) with
`archive-{start}-{duration}.m3u8` (HLS) keeping query string and auth tokens. Prefer an explicit
`catchup-source` template when the provider supplies one (handles tokenized/non-standard hosts).

### D.5 Xtream Codes (`xc`) archive
Build the XC timeshift path from the live URL's user/pass/stream id:
```
live   : http://host:port/live/{u}/{p}/{id}.ts
archive: http://host:port/timeshift/{u}/{p}/{durmin}/{Y}-{m}-{d}:{H}-{M}/{id}.ts
```
`{durmin}` = event duration in minutes; date parts = event **start** (UTC, after correction).
This matches Appendix A.7 — reuse the same builder.

### D.6 Builder contract & rules
```dart
String? buildCatchupUrl({
  required String liveUrl,
  required CatchupType type,        // default|append|shift|flussonic|xc|vod
  required String? source,          // catchup-source template (may be null)
  required DateTime startUtc,       // EPG event start
  required DateTime endUtc,         // EPG event end
  int correctionHours = 0,
});
```
- Apply `correctionHours` to start/end before formatting.
- Expand **all** placeholder forms; leave unknown tokens untouched but log them.
- URL-encode only the substituted values that land in a query component, not the template.
- Validate the result has a scheme/host before handing to the engine; on 404/failure, fall back
  to the live edge and surface "archive unavailable".
- Drive `startUtc`/`endUtc` from the EPG grid selection (§5/§6); clamp to `catchup-days` depth.
- A channel with `catchup-days > 0` (or any catchup attr) → mark `archive` flag → show the
  catch-up affordance on EPG events within the window.

