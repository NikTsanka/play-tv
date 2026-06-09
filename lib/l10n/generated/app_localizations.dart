import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ka.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ka'),
    Locale('ru')
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'StreamHub'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @navThemeShowcase.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get navThemeShowcase;

  /// No description provided for @homeWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to StreamHub'**
  String get homeWelcomeTitle;

  /// No description provided for @homeWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Universal IPTV / TV / Radio player. The playback core, channel list, EPG and providers arrive in the next milestones.'**
  String get homeWelcomeBody;

  /// No description provided for @homeOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get homeOpenSettings;

  /// No description provided for @homeOpenShowcase.
  ///
  /// In en, this message translates to:
  /// **'View theme showcase'**
  String get homeOpenShowcase;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsThemeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme mode'**
  String get settingsThemeMode;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String settingsVersion(String version);

  /// No description provided for @showcaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme showcase'**
  String get showcaseTitle;

  /// No description provided for @showcaseColors.
  ///
  /// In en, this message translates to:
  /// **'Palette'**
  String get showcaseColors;

  /// No description provided for @showcaseGold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get showcaseGold;

  /// No description provided for @showcaseWhite.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get showcaseWhite;

  /// No description provided for @showcaseBlack.
  ///
  /// In en, this message translates to:
  /// **'Black'**
  String get showcaseBlack;

  /// No description provided for @showcaseButtons.
  ///
  /// In en, this message translates to:
  /// **'Buttons & focus'**
  String get showcaseButtons;

  /// No description provided for @showcasePrimaryAction.
  ///
  /// In en, this message translates to:
  /// **'Primary action'**
  String get showcasePrimaryAction;

  /// No description provided for @showcaseSecondaryAction.
  ///
  /// In en, this message translates to:
  /// **'Secondary'**
  String get showcaseSecondaryAction;

  /// No description provided for @showcaseSampleHeading.
  ///
  /// In en, this message translates to:
  /// **'Elegant heading'**
  String get showcaseSampleHeading;

  /// No description provided for @showcaseSampleBody.
  ///
  /// In en, this message translates to:
  /// **'Body text reads cleanly in both light and dark, with gold reserved for accents, focus and selection.'**
  String get showcaseSampleBody;

  /// No description provided for @toggleTheme.
  ///
  /// In en, this message translates to:
  /// **'Toggle light / dark'**
  String get toggleTheme;

  /// No description provided for @navPlayer.
  ///
  /// In en, this message translates to:
  /// **'Player'**
  String get navPlayer;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @playerOpenUrl.
  ///
  /// In en, this message translates to:
  /// **'Open stream URL'**
  String get playerOpenUrl;

  /// No description provided for @playerUrlHint.
  ///
  /// In en, this message translates to:
  /// **'http(s):// , rtsp:// , udp:// …'**
  String get playerUrlHint;

  /// No description provided for @playerPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get playerPlay;

  /// No description provided for @playerPlayDemo.
  ///
  /// In en, this message translates to:
  /// **'Play demo stream'**
  String get playerPlayDemo;

  /// No description provided for @playerNoMedia.
  ///
  /// In en, this message translates to:
  /// **'Nothing playing'**
  String get playerNoMedia;

  /// No description provided for @playerAudioTrack.
  ///
  /// In en, this message translates to:
  /// **'Audio track'**
  String get playerAudioTrack;

  /// No description provided for @playerSubtitles.
  ///
  /// In en, this message translates to:
  /// **'Subtitles'**
  String get playerSubtitles;

  /// No description provided for @playerSubtitlesOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get playerSubtitlesOff;

  /// No description provided for @playerAspect.
  ///
  /// In en, this message translates to:
  /// **'Aspect / fit'**
  String get playerAspect;

  /// No description provided for @playerSnapshot.
  ///
  /// In en, this message translates to:
  /// **'Snapshot'**
  String get playerSnapshot;

  /// No description provided for @playerStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get playerStop;

  /// No description provided for @playerMute.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get playerMute;

  /// No description provided for @playerUnmute.
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get playerUnmute;

  /// No description provided for @playerFullscreen.
  ///
  /// In en, this message translates to:
  /// **'Fullscreen'**
  String get playerFullscreen;

  /// No description provided for @navTv.
  ///
  /// In en, this message translates to:
  /// **'TV'**
  String get navTv;

  /// No description provided for @tvTogglePanel.
  ///
  /// In en, this message translates to:
  /// **'Toggle channel list'**
  String get tvTogglePanel;

  /// No description provided for @tvSelectChannel.
  ///
  /// In en, this message translates to:
  /// **'Select a channel to start watching'**
  String get tvSelectChannel;

  /// No description provided for @channelsSearch.
  ///
  /// In en, this message translates to:
  /// **'Search channels'**
  String get channelsSearch;

  /// No description provided for @channelsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No channels yet — import a playlist'**
  String get channelsEmpty;

  /// No description provided for @channelsUngrouped.
  ///
  /// In en, this message translates to:
  /// **'Ungrouped'**
  String get channelsUngrouped;

  /// No description provided for @channelsCountSuffix.
  ///
  /// In en, this message translates to:
  /// **'channels'**
  String get channelsCountSuffix;

  /// No description provided for @channelsImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Import playlist'**
  String get channelsImportTitle;

  /// No description provided for @channelsImportName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get channelsImportName;

  /// No description provided for @channelsImportUrl.
  ///
  /// In en, this message translates to:
  /// **'Playlist URL (M3U)'**
  String get channelsImportUrl;

  /// No description provided for @channelsImportFile.
  ///
  /// In en, this message translates to:
  /// **'From file'**
  String get channelsImportFile;

  /// No description provided for @channelsImportFromUrl.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get channelsImportFromUrl;

  /// No description provided for @osdNoGuide.
  ///
  /// In en, this message translates to:
  /// **'No guide data yet'**
  String get osdNoGuide;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @providersAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a source'**
  String get providersAddTitle;

  /// No description provided for @providersChooseType.
  ///
  /// In en, this message translates to:
  /// **'Choose a source type'**
  String get providersChooseType;

  /// No description provided for @providerName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get providerName;

  /// No description provided for @providerImport.
  ///
  /// In en, this message translates to:
  /// **'Add & import'**
  String get providerImport;

  /// No description provided for @providerImporting.
  ///
  /// In en, this message translates to:
  /// **'Importing…'**
  String get providerImporting;

  /// No description provided for @providerM3uUrl.
  ///
  /// In en, this message translates to:
  /// **'M3U playlist (URL)'**
  String get providerM3uUrl;

  /// No description provided for @providerM3uUrlDesc.
  ///
  /// In en, this message translates to:
  /// **'Download an M3U/M3U8 playlist from a URL'**
  String get providerM3uUrlDesc;

  /// No description provided for @providerM3uFile.
  ///
  /// In en, this message translates to:
  /// **'M3U playlist (file)'**
  String get providerM3uFile;

  /// No description provided for @providerM3uFileDesc.
  ///
  /// In en, this message translates to:
  /// **'Load an M3U/M3U8 playlist from a local file'**
  String get providerM3uFileDesc;

  /// No description provided for @providerGenericUrl.
  ///
  /// In en, this message translates to:
  /// **'Single stream'**
  String get providerGenericUrl;

  /// No description provided for @providerGenericUrlDesc.
  ///
  /// In en, this message translates to:
  /// **'One stream URL (HLS, RTSP, UDP…) as a channel'**
  String get providerGenericUrlDesc;

  /// No description provided for @providerIptvOrg.
  ///
  /// In en, this message translates to:
  /// **'iptv-org catalog'**
  String get providerIptvOrg;

  /// No description provided for @providerIptvOrgDesc.
  ///
  /// In en, this message translates to:
  /// **'Public free-to-air catalog from iptv-org'**
  String get providerIptvOrgDesc;

  /// No description provided for @providerXtream.
  ///
  /// In en, this message translates to:
  /// **'Xtream Codes'**
  String get providerXtream;

  /// No description provided for @providerXtreamDesc.
  ///
  /// In en, this message translates to:
  /// **'Xtream / XUI.one panel (server, username, password)'**
  String get providerXtreamDesc;

  /// No description provided for @providerStalker.
  ///
  /// In en, this message translates to:
  /// **'Stalker portal'**
  String get providerStalker;

  /// No description provided for @providerStalkerDesc.
  ///
  /// In en, this message translates to:
  /// **'Stalker / Ministra (MAG) portal by MAC address'**
  String get providerStalkerDesc;

  /// No description provided for @providerServerUrl.
  ///
  /// In en, this message translates to:
  /// **'Server URL'**
  String get providerServerUrl;

  /// No description provided for @providerUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get providerUsername;

  /// No description provided for @providerPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get providerPassword;

  /// No description provided for @providerPortalUrl.
  ///
  /// In en, this message translates to:
  /// **'Portal URL'**
  String get providerPortalUrl;

  /// No description provided for @providerMac.
  ///
  /// In en, this message translates to:
  /// **'MAC address'**
  String get providerMac;

  /// No description provided for @providerLoginOptional.
  ///
  /// In en, this message translates to:
  /// **'Login (optional)'**
  String get providerLoginOptional;

  /// No description provided for @providerOtt.
  ///
  /// In en, this message translates to:
  /// **'OTT service'**
  String get providerOtt;

  /// No description provided for @providerOttDesc.
  ///
  /// In en, this message translates to:
  /// **'Branded OTT login (Kartina, Sovok, TV Club…)'**
  String get providerOttDesc;

  /// No description provided for @providerOttService.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get providerOttService;

  /// No description provided for @providerParentalCode.
  ///
  /// In en, this message translates to:
  /// **'Parental PIN (optional)'**
  String get providerParentalCode;

  /// No description provided for @providerLocalFolder.
  ///
  /// In en, this message translates to:
  /// **'Local folder'**
  String get providerLocalFolder;

  /// No description provided for @providerLocalFolderDesc.
  ///
  /// In en, this message translates to:
  /// **'Index a folder of video / music files'**
  String get providerLocalFolderDesc;

  /// No description provided for @providerChooseFolder.
  ///
  /// In en, this message translates to:
  /// **'Choose folder…'**
  String get providerChooseFolder;

  /// No description provided for @providerNoFolder.
  ///
  /// In en, this message translates to:
  /// **'No folder selected'**
  String get providerNoFolder;

  /// No description provided for @providerYoutube.
  ///
  /// In en, this message translates to:
  /// **'YouTube'**
  String get providerYoutube;

  /// No description provided for @providerYoutubeDesc.
  ///
  /// In en, this message translates to:
  /// **'Channel, playlist or video URL'**
  String get providerYoutubeDesc;

  /// No description provided for @providerYoutubeUrl.
  ///
  /// In en, this message translates to:
  /// **'YouTube URL'**
  String get providerYoutubeUrl;

  /// No description provided for @providerPlaylistUrl.
  ///
  /// In en, this message translates to:
  /// **'Playlist URL'**
  String get providerPlaylistUrl;

  /// No description provided for @providerStreamUrl.
  ///
  /// In en, this message translates to:
  /// **'Stream URL'**
  String get providerStreamUrl;

  /// No description provided for @providerIsRadio.
  ///
  /// In en, this message translates to:
  /// **'Audio-only (radio)'**
  String get providerIsRadio;

  /// No description provided for @providerChooseFile.
  ///
  /// In en, this message translates to:
  /// **'Choose file…'**
  String get providerChooseFile;

  /// No description provided for @providerNoFile.
  ///
  /// In en, this message translates to:
  /// **'No file selected'**
  String get providerNoFile;

  /// No description provided for @providerScope.
  ///
  /// In en, this message translates to:
  /// **'Catalog'**
  String get providerScope;

  /// No description provided for @providerScopeAll.
  ///
  /// In en, this message translates to:
  /// **'All channels'**
  String get providerScopeAll;

  /// No description provided for @providerScopeCountry.
  ///
  /// In en, this message translates to:
  /// **'By country'**
  String get providerScopeCountry;

  /// No description provided for @providerScopeCategory.
  ///
  /// In en, this message translates to:
  /// **'By category'**
  String get providerScopeCategory;

  /// No description provided for @providerScopeLanguage.
  ///
  /// In en, this message translates to:
  /// **'By language'**
  String get providerScopeLanguage;

  /// No description provided for @providerScopeCode.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get providerScopeCode;

  /// No description provided for @providerScopeCodeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. us, uk, news, eng'**
  String get providerScopeCodeHint;

  /// No description provided for @providerManageTitle.
  ///
  /// In en, this message translates to:
  /// **'Sources'**
  String get providerManageTitle;

  /// No description provided for @providerRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get providerRefresh;

  /// No description provided for @providerImported.
  ///
  /// In en, this message translates to:
  /// **'Imported {count} channels'**
  String providerImported(int count);

  /// No description provided for @navGuide.
  ///
  /// In en, this message translates to:
  /// **'Guide'**
  String get navGuide;

  /// No description provided for @epgImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Import EPG (XMLTV)'**
  String get epgImportTitle;

  /// No description provided for @epgImportUrl.
  ///
  /// In en, this message translates to:
  /// **'XMLTV URL'**
  String get epgImportUrl;

  /// No description provided for @epgJumpToNow.
  ///
  /// In en, this message translates to:
  /// **'Jump to now'**
  String get epgJumpToNow;

  /// No description provided for @epgImported.
  ///
  /// In en, this message translates to:
  /// **'Imported {count} programmes'**
  String epgImported(int count);

  /// No description provided for @epgEmpty.
  ///
  /// In en, this message translates to:
  /// **'No guide yet — import an XMLTV source'**
  String get epgEmpty;

  /// No description provided for @epgNoMatches.
  ///
  /// In en, this message translates to:
  /// **'No channels matched the guide'**
  String get epgNoMatches;

  /// No description provided for @epgWatchCatchup.
  ///
  /// In en, this message translates to:
  /// **'Watch from start'**
  String get epgWatchCatchup;

  /// No description provided for @navVod.
  ///
  /// In en, this message translates to:
  /// **'VOD'**
  String get navVod;

  /// No description provided for @vodTitle.
  ///
  /// In en, this message translates to:
  /// **'Video on demand'**
  String get vodTitle;

  /// No description provided for @vodMovies.
  ///
  /// In en, this message translates to:
  /// **'Movies'**
  String get vodMovies;

  /// No description provided for @vodSeries.
  ///
  /// In en, this message translates to:
  /// **'Series'**
  String get vodSeries;

  /// No description provided for @vodFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get vodFavorites;

  /// No description provided for @vodSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get vodSearch;

  /// No description provided for @vodAllCategories.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get vodAllCategories;

  /// No description provided for @vodRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh catalog'**
  String get vodRefresh;

  /// No description provided for @vodEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing cached yet — refresh the catalog'**
  String get vodEmpty;

  /// No description provided for @vodNoSources.
  ///
  /// In en, this message translates to:
  /// **'No VOD-capable sources. Add an Xtream source first.'**
  String get vodNoSources;

  /// No description provided for @vodFavoritesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get vodFavoritesEmpty;

  /// No description provided for @vodSortDefault.
  ///
  /// In en, this message translates to:
  /// **'Default order'**
  String get vodSortDefault;

  /// No description provided for @vodSortTitle.
  ///
  /// In en, this message translates to:
  /// **'Title A–Z'**
  String get vodSortTitle;

  /// No description provided for @vodSortRating.
  ///
  /// In en, this message translates to:
  /// **'Top rated'**
  String get vodSortRating;

  /// No description provided for @vodPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get vodPlay;

  /// No description provided for @vodSeasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Season {n}'**
  String vodSeasonLabel(int n);

  /// No description provided for @vodNoEpisodes.
  ///
  /// In en, this message translates to:
  /// **'No episodes found'**
  String get vodNoEpisodes;

  /// No description provided for @vodLoadingEpisodes.
  ///
  /// In en, this message translates to:
  /// **'Loading episodes…'**
  String get vodLoadingEpisodes;

  /// No description provided for @vodSource.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get vodSource;

  /// No description provided for @navRecordings.
  ///
  /// In en, this message translates to:
  /// **'Recordings'**
  String get navRecordings;

  /// No description provided for @recTabActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get recTabActive;

  /// No description provided for @recTabScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get recTabScheduled;

  /// No description provided for @recTabFiles.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get recTabFiles;

  /// No description provided for @recRecordChannel.
  ///
  /// In en, this message translates to:
  /// **'Record current channel'**
  String get recRecordChannel;

  /// No description provided for @recNoActive.
  ///
  /// In en, this message translates to:
  /// **'No active recordings'**
  String get recNoActive;

  /// No description provided for @recNoScheduled.
  ///
  /// In en, this message translates to:
  /// **'Nothing scheduled'**
  String get recNoScheduled;

  /// No description provided for @recNoFiles.
  ///
  /// In en, this message translates to:
  /// **'No recordings yet'**
  String get recNoFiles;

  /// No description provided for @recStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get recStop;

  /// No description provided for @recPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get recPlay;

  /// No description provided for @recDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get recDelete;

  /// No description provided for @recConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get recConnecting;

  /// No description provided for @recRecording.
  ///
  /// In en, this message translates to:
  /// **'Recording'**
  String get recRecording;

  /// No description provided for @recError.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get recError;

  /// No description provided for @recRecord.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get recRecord;

  /// No description provided for @recScheduled.
  ///
  /// In en, this message translates to:
  /// **'Recording scheduled'**
  String get recScheduled;

  /// No description provided for @recNothingPlaying.
  ///
  /// In en, this message translates to:
  /// **'No channel is playing'**
  String get recNothingPlaying;

  /// No description provided for @recStarted.
  ///
  /// In en, this message translates to:
  /// **'Recording started'**
  String get recStarted;

  /// No description provided for @settingsMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get settingsMaintenance;

  /// No description provided for @settingsDownloadLogos.
  ///
  /// In en, this message translates to:
  /// **'Download channel logos'**
  String get settingsDownloadLogos;

  /// No description provided for @settingsDownloadLogosSub.
  ///
  /// In en, this message translates to:
  /// **'Cache logos for the current playlist'**
  String get settingsDownloadLogosSub;

  /// No description provided for @settingsTasks.
  ///
  /// In en, this message translates to:
  /// **'Background tasks'**
  String get settingsTasks;

  /// No description provided for @settingsNoTasks.
  ///
  /// In en, this message translates to:
  /// **'No active tasks'**
  String get settingsNoTasks;

  /// No description provided for @settingsClearTasks.
  ///
  /// In en, this message translates to:
  /// **'Clear finished'**
  String get settingsClearTasks;

  /// No description provided for @settingsUpdates.
  ///
  /// In en, this message translates to:
  /// **'Updates'**
  String get settingsUpdates;

  /// No description provided for @settingsCheckUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get settingsCheckUpdates;

  /// No description provided for @settingsUpdateChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking…'**
  String get settingsUpdateChecking;

  /// No description provided for @settingsUpToDate.
  ///
  /// In en, this message translates to:
  /// **'You\'re up to date ({version})'**
  String settingsUpToDate(String version);

  /// No description provided for @settingsUpdateAvailable.
  ///
  /// In en, this message translates to:
  /// **'Update available: {version}'**
  String settingsUpdateAvailable(String version);

  /// No description provided for @settingsUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Update check failed'**
  String get settingsUpdateFailed;

  /// No description provided for @taskCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get taskCancel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ka', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ka':
      return AppLocalizationsKa();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
