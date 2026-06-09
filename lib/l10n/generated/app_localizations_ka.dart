// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Georgian (`ka`).
class AppLocalizationsKa extends AppLocalizations {
  AppLocalizationsKa([String locale = 'ka']) : super(locale);

  @override
  String get appTitle => 'StreamHub';

  @override
  String get navHome => 'მთავარი';

  @override
  String get navSettings => 'პარამეტრები';

  @override
  String get navThemeShowcase => 'თემა';

  @override
  String get homeWelcomeTitle => 'კეთილი იყოს თქვენი მობრძანება StreamHub-ში';

  @override
  String get homeWelcomeBody =>
      'უნივერსალური IPTV / TV / რადიო პლეერი. დაკვრის ბირთვი, არხების სია, EPG და პროვაიდერები მომდევნო ეტაპებზე დაემატება.';

  @override
  String get homeOpenSettings => 'პარამეტრების გახსნა';

  @override
  String get homeOpenShowcase => 'თემის ჩვენება';

  @override
  String get settingsTitle => 'პარამეტრები';

  @override
  String get settingsAppearance => 'გარეგნობა';

  @override
  String get settingsThemeMode => 'თემის რეჟიმი';

  @override
  String get settingsThemeSystem => 'სისტემური';

  @override
  String get settingsThemeLight => 'ნათელი';

  @override
  String get settingsThemeDark => 'მუქი';

  @override
  String get settingsLanguage => 'ენა';

  @override
  String get settingsAbout => 'შესახებ';

  @override
  String settingsVersion(String version) {
    return 'ვერსია $version';
  }

  @override
  String get showcaseTitle => 'თემის ჩვენება';

  @override
  String get showcaseColors => 'პალიტრა';

  @override
  String get showcaseGold => 'ოქროსფერი';

  @override
  String get showcaseWhite => 'თეთრი';

  @override
  String get showcaseBlack => 'შავი';

  @override
  String get showcaseButtons => 'ღილაკები და ფოკუსი';

  @override
  String get showcasePrimaryAction => 'ძირითადი მოქმედება';

  @override
  String get showcaseSecondaryAction => 'მეორეხარისხოვანი';

  @override
  String get showcaseSampleHeading => 'ელეგანტური სათაური';

  @override
  String get showcaseSampleBody =>
      'ძირითადი ტექსტი მკაფიოდ იკითხება ნათელ და მუქ რეჟიმში; ოქროსფერი დაცულია აქცენტებისთვის, ფოკუსისა და მონიშვნისთვის.';

  @override
  String get toggleTheme => 'ნათელი / მუქის გადართვა';

  @override
  String get navPlayer => 'ფლეერი';

  @override
  String get commonCancel => 'გაუქმება';

  @override
  String get playerOpenUrl => 'სტრიმის URL-ის გახსნა';

  @override
  String get playerUrlHint => 'http(s):// , rtsp:// , udp:// …';

  @override
  String get playerPlay => 'დაკვრა';

  @override
  String get playerPlayDemo => 'სადემონსტრაციო სტრიმის დაკვრა';

  @override
  String get playerNoMedia => 'არაფერი იკვრება';

  @override
  String get playerAudioTrack => 'აუდიო ჩანაწერი';

  @override
  String get playerSubtitles => 'სუბტიტრები';

  @override
  String get playerSubtitlesOff => 'გამორთული';

  @override
  String get playerAspect => 'თანაფარდობა / მორგება';

  @override
  String get playerSnapshot => 'კადრის გადაღება';

  @override
  String get playerStop => 'გაჩერება';

  @override
  String get playerMute => 'ხმის გათიშვა';

  @override
  String get playerUnmute => 'ხმის ჩართვა';

  @override
  String get playerFullscreen => 'სრული ეკრანი';

  @override
  String get navTv => 'ტელევიზია';

  @override
  String get tvTogglePanel => 'არხების სიის ჩვენება';

  @override
  String get tvSelectChannel => 'ასარჩევად აირჩიეთ არხი';

  @override
  String get channelsSearch => 'არხების ძებნა';

  @override
  String get channelsEmpty => 'არხები ჯერ არ არის — დაამატეთ ფლეილისტი';

  @override
  String get channelsUngrouped => 'დაუჯგუფებელი';

  @override
  String get channelsCountSuffix => 'არხი';

  @override
  String get channelsImportTitle => 'ფლეილისტის იმპორტი';

  @override
  String get channelsImportName => 'სახელი';

  @override
  String get channelsImportUrl => 'ფლეილისტის URL (M3U)';

  @override
  String get channelsImportFile => 'ფაილიდან';

  @override
  String get channelsImportFromUrl => 'იმპორტი';

  @override
  String get osdNoGuide => 'გიდის მონაცემები ჯერ არ არის';

  @override
  String get commonBack => 'უკან';

  @override
  String get commonDelete => 'წაშლა';

  @override
  String get providersAddTitle => 'წყაროს დამატება';

  @override
  String get providersChooseType => 'აირჩიეთ წყაროს ტიპი';

  @override
  String get providerName => 'სახელი';

  @override
  String get providerImport => 'დამატება და იმპორტი';

  @override
  String get providerImporting => 'მიმდინარეობს იმპორტი…';

  @override
  String get providerM3uUrl => 'M3U ფლეილისტი (URL)';

  @override
  String get providerM3uUrlDesc => 'M3U/M3U8 ფლეილისტის ჩამოტვირთვა URL-დან';

  @override
  String get providerM3uFile => 'M3U ფლეილისტი (ფაილი)';

  @override
  String get providerM3uFileDesc =>
      'M3U/M3U8 ფლეილისტის ჩატვირთვა ლოკალური ფაილიდან';

  @override
  String get providerGenericUrl => 'ერთი ნაკადი';

  @override
  String get providerGenericUrlDesc =>
      'ერთი ნაკადის URL (HLS, RTSP, UDP…) როგორც არხი';

  @override
  String get providerIptvOrg => 'iptv-org კატალოგი';

  @override
  String get providerIptvOrgDesc => 'iptv-org-ის უფასო საჯარო კატალოგი';

  @override
  String get providerXtream => 'Xtream Codes';

  @override
  String get providerXtreamDesc =>
      'Xtream / XUI.one პანელი (სერვერი, მომხმარებელი, პაროლი)';

  @override
  String get providerStalker => 'Stalker პორტალი';

  @override
  String get providerStalkerDesc =>
      'Stalker / Ministra (MAG) პორტალი MAC-მისამართით';

  @override
  String get providerServerUrl => 'სერვერის URL';

  @override
  String get providerUsername => 'მომხმარებელი';

  @override
  String get providerPassword => 'პაროლი';

  @override
  String get providerPortalUrl => 'პორტალის URL';

  @override
  String get providerMac => 'MAC-მისამართი';

  @override
  String get providerLoginOptional => 'ლოგინი (არასავალდებულო)';

  @override
  String get providerOtt => 'OTT სერვისი';

  @override
  String get providerOttDesc =>
      'ბრენდირებული OTT შესვლა (Kartina, Sovok, TV Club…)';

  @override
  String get providerOttService => 'სერვისი';

  @override
  String get providerParentalCode => 'მშობლის PIN (არასავალდებულო)';

  @override
  String get providerPlaylistUrl => 'ფლეილისტის URL';

  @override
  String get providerStreamUrl => 'ნაკადის URL';

  @override
  String get providerIsRadio => 'მხოლოდ აუდიო (რადიო)';

  @override
  String get providerChooseFile => 'ფაილის არჩევა…';

  @override
  String get providerNoFile => 'ფაილი არ არის არჩეული';

  @override
  String get providerScope => 'კატალოგი';

  @override
  String get providerScopeAll => 'ყველა არხი';

  @override
  String get providerScopeCountry => 'ქვეყნის მიხედვით';

  @override
  String get providerScopeCategory => 'კატეგორიის მიხედვით';

  @override
  String get providerScopeLanguage => 'ენის მიხედვით';

  @override
  String get providerScopeCode => 'კოდი';

  @override
  String get providerScopeCodeHint => 'მაგ. us, uk, news, eng';

  @override
  String get providerManageTitle => 'წყაროები';

  @override
  String get providerRefresh => 'განახლება';

  @override
  String providerImported(int count) {
    return 'იმპორტირდა $count არხი';
  }

  @override
  String get navGuide => 'გიდი';

  @override
  String get epgImportTitle => 'EPG-ის იმპორტი (XMLTV)';

  @override
  String get epgImportUrl => 'XMLTV URL';

  @override
  String get epgJumpToNow => 'ახლანდელ დროზე გადასვლა';

  @override
  String epgImported(int count) {
    return 'იმპორტირდა $count გადაცემა';
  }

  @override
  String get epgEmpty => 'გიდი ჯერ არ არის — დაამატეთ XMLTV წყარო';

  @override
  String get epgNoMatches => 'გიდს არცერთი არხი არ დაემთხვა';

  @override
  String get epgWatchCatchup => 'თავიდან ყურება';

  @override
  String get navVod => 'VOD';

  @override
  String get vodTitle => 'ვიდეო მოთხოვნით';

  @override
  String get vodMovies => 'ფილმები';

  @override
  String get vodSeries => 'სერიალები';

  @override
  String get vodFavorites => 'რჩეულები';

  @override
  String get vodSearch => 'ძებნა';

  @override
  String get vodAllCategories => 'ყველა კატეგორია';

  @override
  String get vodRefresh => 'კატალოგის განახლება';

  @override
  String get vodEmpty => 'ქეშში არაფერია — განაახლეთ კატალოგი';

  @override
  String get vodNoSources =>
      'VOD-ის მხარდამჭერი წყარო არ არის. ჯერ დაამატეთ Xtream წყარო.';

  @override
  String get vodFavoritesEmpty => 'რჩეულები ჯერ არ არის';

  @override
  String get vodSortDefault => 'ნაგულისხმევი';

  @override
  String get vodSortTitle => 'სათაური ა–ჰ';

  @override
  String get vodSortRating => 'მაღალი რეიტინგი';

  @override
  String get vodPlay => 'დაკვრა';

  @override
  String vodSeasonLabel(int n) {
    return 'სეზონი $n';
  }

  @override
  String get vodNoEpisodes => 'ეპიზოდები ვერ მოიძებნა';

  @override
  String get vodLoadingEpisodes => 'იტვირთება ეპიზოდები…';

  @override
  String get vodSource => 'წყარო';

  @override
  String get navRecordings => 'ჩანაწერები';

  @override
  String get recTabActive => 'აქტიური';

  @override
  String get recTabScheduled => 'დაგეგმილი';

  @override
  String get recTabFiles => 'ფაილები';

  @override
  String get recRecordChannel => 'მიმდინარე არხის ჩაწერა';

  @override
  String get recNoActive => 'აქტიური ჩანაწერები არ არის';

  @override
  String get recNoScheduled => 'დაგეგმილი არაფერია';

  @override
  String get recNoFiles => 'ჩანაწერები ჯერ არ არის';

  @override
  String get recStop => 'გაჩერება';

  @override
  String get recPlay => 'დაკვრა';

  @override
  String get recDelete => 'წაშლა';

  @override
  String get recConnecting => 'მიერთება…';

  @override
  String get recRecording => 'მიმდინარეობს ჩაწერა';

  @override
  String get recError => 'ვერ მოხერხდა';

  @override
  String get recRecord => 'ჩაწერა';

  @override
  String get recScheduled => 'ჩაწერა დაიგეგმა';

  @override
  String get recNothingPlaying => 'არხი არ უკრავს';

  @override
  String get recStarted => 'ჩაწერა დაიწყო';
}
