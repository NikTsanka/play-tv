// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'StreamHub';

  @override
  String get navHome => 'Home';

  @override
  String get navSettings => 'Settings';

  @override
  String get navThemeShowcase => 'Theme';

  @override
  String get homeWelcomeTitle => 'Welcome to StreamHub';

  @override
  String get homeWelcomeBody =>
      'Universal IPTV / TV / Radio player. The playback core, channel list, EPG and providers arrive in the next milestones.';

  @override
  String get homeOpenSettings => 'Open settings';

  @override
  String get homeOpenShowcase => 'View theme showcase';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsThemeMode => 'Theme mode';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsAbout => 'About';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get showcaseTitle => 'Theme showcase';

  @override
  String get showcaseColors => 'Palette';

  @override
  String get showcaseGold => 'Gold';

  @override
  String get showcaseWhite => 'White';

  @override
  String get showcaseBlack => 'Black';

  @override
  String get showcaseButtons => 'Buttons & focus';

  @override
  String get showcasePrimaryAction => 'Primary action';

  @override
  String get showcaseSecondaryAction => 'Secondary';

  @override
  String get showcaseSampleHeading => 'Elegant heading';

  @override
  String get showcaseSampleBody =>
      'Body text reads cleanly in both light and dark, with gold reserved for accents, focus and selection.';

  @override
  String get toggleTheme => 'Toggle light / dark';

  @override
  String get navPlayer => 'Player';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get playerOpenUrl => 'Open stream URL';

  @override
  String get playerUrlHint => 'http(s):// , rtsp:// , udp:// …';

  @override
  String get playerPlay => 'Play';

  @override
  String get playerPlayDemo => 'Play demo stream';

  @override
  String get playerNoMedia => 'Nothing playing';

  @override
  String get playerAudioTrack => 'Audio track';

  @override
  String get playerSubtitles => 'Subtitles';

  @override
  String get playerSubtitlesOff => 'Off';

  @override
  String get playerAspect => 'Aspect / fit';

  @override
  String get playerSnapshot => 'Snapshot';

  @override
  String get playerStop => 'Stop';

  @override
  String get playerMute => 'Mute';

  @override
  String get playerUnmute => 'Unmute';

  @override
  String get playerFullscreen => 'Fullscreen';

  @override
  String get navTv => 'TV';

  @override
  String get tvTogglePanel => 'Toggle channel list';

  @override
  String get tvSelectChannel => 'Select a channel to start watching';

  @override
  String get channelsSearch => 'Search channels';

  @override
  String get channelsEmpty => 'No channels yet — import a playlist';

  @override
  String get channelsUngrouped => 'Ungrouped';

  @override
  String get channelsCountSuffix => 'channels';

  @override
  String get channelsImportTitle => 'Import playlist';

  @override
  String get channelsImportName => 'Name';

  @override
  String get channelsImportUrl => 'Playlist URL (M3U)';

  @override
  String get channelsImportFile => 'From file';

  @override
  String get channelsImportFromUrl => 'Import';

  @override
  String get osdNoGuide => 'No guide data yet';

  @override
  String get commonBack => 'Back';

  @override
  String get commonDelete => 'Delete';

  @override
  String get providersAddTitle => 'Add a source';

  @override
  String get providersChooseType => 'Choose a source type';

  @override
  String get providerName => 'Name';

  @override
  String get providerImport => 'Add & import';

  @override
  String get providerImporting => 'Importing…';

  @override
  String get providerM3uUrl => 'M3U playlist (URL)';

  @override
  String get providerM3uUrlDesc => 'Download an M3U/M3U8 playlist from a URL';

  @override
  String get providerM3uFile => 'M3U playlist (file)';

  @override
  String get providerM3uFileDesc =>
      'Load an M3U/M3U8 playlist from a local file';

  @override
  String get providerGenericUrl => 'Single stream';

  @override
  String get providerGenericUrlDesc =>
      'One stream URL (HLS, RTSP, UDP…) as a channel';

  @override
  String get providerIptvOrg => 'iptv-org catalog';

  @override
  String get providerIptvOrgDesc => 'Public free-to-air catalog from iptv-org';

  @override
  String get providerXtream => 'Xtream Codes';

  @override
  String get providerXtreamDesc =>
      'Xtream / XUI.one panel (server, username, password)';

  @override
  String get providerStalker => 'Stalker portal';

  @override
  String get providerStalkerDesc =>
      'Stalker / Ministra (MAG) portal by MAC address';

  @override
  String get providerServerUrl => 'Server URL';

  @override
  String get providerUsername => 'Username';

  @override
  String get providerPassword => 'Password';

  @override
  String get providerPortalUrl => 'Portal URL';

  @override
  String get providerMac => 'MAC address';

  @override
  String get providerLoginOptional => 'Login (optional)';

  @override
  String get providerOtt => 'OTT service';

  @override
  String get providerOttDesc => 'Branded OTT login (Kartina, Sovok, TV Club…)';

  @override
  String get providerOttService => 'Service';

  @override
  String get providerParentalCode => 'Parental PIN (optional)';

  @override
  String get providerPlaylistUrl => 'Playlist URL';

  @override
  String get providerStreamUrl => 'Stream URL';

  @override
  String get providerIsRadio => 'Audio-only (radio)';

  @override
  String get providerChooseFile => 'Choose file…';

  @override
  String get providerNoFile => 'No file selected';

  @override
  String get providerScope => 'Catalog';

  @override
  String get providerScopeAll => 'All channels';

  @override
  String get providerScopeCountry => 'By country';

  @override
  String get providerScopeCategory => 'By category';

  @override
  String get providerScopeLanguage => 'By language';

  @override
  String get providerScopeCode => 'Code';

  @override
  String get providerScopeCodeHint => 'e.g. us, uk, news, eng';

  @override
  String get providerManageTitle => 'Sources';

  @override
  String get providerRefresh => 'Refresh';

  @override
  String providerImported(int count) {
    return 'Imported $count channels';
  }

  @override
  String get navGuide => 'Guide';

  @override
  String get epgImportTitle => 'Import EPG (XMLTV)';

  @override
  String get epgImportUrl => 'XMLTV URL';

  @override
  String get epgJumpToNow => 'Jump to now';

  @override
  String epgImported(int count) {
    return 'Imported $count programmes';
  }

  @override
  String get epgEmpty => 'No guide yet — import an XMLTV source';

  @override
  String get epgNoMatches => 'No channels matched the guide';

  @override
  String get epgWatchCatchup => 'Watch from start';

  @override
  String get navVod => 'VOD';

  @override
  String get vodTitle => 'Video on demand';

  @override
  String get vodMovies => 'Movies';

  @override
  String get vodSeries => 'Series';

  @override
  String get vodFavorites => 'Favorites';

  @override
  String get vodSearch => 'Search';

  @override
  String get vodAllCategories => 'All categories';

  @override
  String get vodRefresh => 'Refresh catalog';

  @override
  String get vodEmpty => 'Nothing cached yet — refresh the catalog';

  @override
  String get vodNoSources =>
      'No VOD-capable sources. Add an Xtream source first.';

  @override
  String get vodFavoritesEmpty => 'No favorites yet';

  @override
  String get vodSortDefault => 'Default order';

  @override
  String get vodSortTitle => 'Title A–Z';

  @override
  String get vodSortRating => 'Top rated';

  @override
  String get vodPlay => 'Play';

  @override
  String vodSeasonLabel(int n) {
    return 'Season $n';
  }

  @override
  String get vodNoEpisodes => 'No episodes found';

  @override
  String get vodLoadingEpisodes => 'Loading episodes…';

  @override
  String get vodSource => 'Source';

  @override
  String get navRecordings => 'Recordings';

  @override
  String get recTabActive => 'Active';

  @override
  String get recTabScheduled => 'Scheduled';

  @override
  String get recTabFiles => 'Files';

  @override
  String get recRecordChannel => 'Record current channel';

  @override
  String get recNoActive => 'No active recordings';

  @override
  String get recNoScheduled => 'Nothing scheduled';

  @override
  String get recNoFiles => 'No recordings yet';

  @override
  String get recStop => 'Stop';

  @override
  String get recPlay => 'Play';

  @override
  String get recDelete => 'Delete';

  @override
  String get recConnecting => 'Connecting…';

  @override
  String get recRecording => 'Recording';

  @override
  String get recError => 'Failed';

  @override
  String get recRecord => 'Record';

  @override
  String get recScheduled => 'Recording scheduled';

  @override
  String get recNothingPlaying => 'No channel is playing';

  @override
  String get recStarted => 'Recording started';

  @override
  String get settingsMaintenance => 'Maintenance';

  @override
  String get settingsDownloadLogos => 'Download channel logos';

  @override
  String get settingsDownloadLogosSub => 'Cache logos for the current playlist';

  @override
  String get settingsTasks => 'Background tasks';

  @override
  String get settingsNoTasks => 'No active tasks';

  @override
  String get settingsClearTasks => 'Clear finished';

  @override
  String get settingsUpdates => 'Updates';

  @override
  String get settingsCheckUpdates => 'Check for updates';

  @override
  String get settingsUpdateChecking => 'Checking…';

  @override
  String settingsUpToDate(String version) {
    return 'You\'re up to date ($version)';
  }

  @override
  String settingsUpdateAvailable(String version) {
    return 'Update available: $version';
  }

  @override
  String get settingsUpdateFailed => 'Update check failed';

  @override
  String get taskCancel => 'Cancel';
}
