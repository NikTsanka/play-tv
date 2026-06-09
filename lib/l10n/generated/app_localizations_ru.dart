// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'StreamHub';

  @override
  String get navHome => 'Главная';

  @override
  String get navSettings => 'Настройки';

  @override
  String get navThemeShowcase => 'Тема';

  @override
  String get homeWelcomeTitle => 'Добро пожаловать в StreamHub';

  @override
  String get homeWelcomeBody =>
      'Универсальный IPTV / TV / радио плеер. Ядро воспроизведения, список каналов, EPG и провайдеры появятся на следующих этапах.';

  @override
  String get homeOpenSettings => 'Открыть настройки';

  @override
  String get homeOpenShowcase => 'Показать тему';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsAppearance => 'Оформление';

  @override
  String get settingsThemeMode => 'Режим темы';

  @override
  String get settingsThemeSystem => 'Системная';

  @override
  String get settingsThemeLight => 'Светлая';

  @override
  String get settingsThemeDark => 'Тёмная';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsAbout => 'О приложении';

  @override
  String settingsVersion(String version) {
    return 'Версия $version';
  }

  @override
  String get showcaseTitle => 'Демонстрация темы';

  @override
  String get showcaseColors => 'Палитра';

  @override
  String get showcaseGold => 'Золотой';

  @override
  String get showcaseWhite => 'Белый';

  @override
  String get showcaseBlack => 'Чёрный';

  @override
  String get showcaseButtons => 'Кнопки и фокус';

  @override
  String get showcasePrimaryAction => 'Основное действие';

  @override
  String get showcaseSecondaryAction => 'Вторичное';

  @override
  String get showcaseSampleHeading => 'Элегантный заголовок';

  @override
  String get showcaseSampleBody =>
      'Основной текст хорошо читается в светлой и тёмной теме; золотой используется для акцентов, фокуса и выделения.';

  @override
  String get toggleTheme => 'Переключить светлую / тёмную';

  @override
  String get navPlayer => 'Плеер';

  @override
  String get commonCancel => 'Отмена';

  @override
  String get playerOpenUrl => 'Открыть URL потока';

  @override
  String get playerUrlHint => 'http(s):// , rtsp:// , udp:// …';

  @override
  String get playerPlay => 'Воспроизвести';

  @override
  String get playerPlayDemo => 'Демонстрационный поток';

  @override
  String get playerNoMedia => 'Ничего не воспроизводится';

  @override
  String get playerAudioTrack => 'Аудиодорожка';

  @override
  String get playerSubtitles => 'Субтитры';

  @override
  String get playerSubtitlesOff => 'Выкл';

  @override
  String get playerAspect => 'Соотношение / вписать';

  @override
  String get playerSnapshot => 'Снимок кадра';

  @override
  String get playerStop => 'Стоп';

  @override
  String get playerMute => 'Без звука';

  @override
  String get playerUnmute => 'Включить звук';

  @override
  String get playerFullscreen => 'Полный экран';

  @override
  String get navTv => 'ТВ';

  @override
  String get tvTogglePanel => 'Показать список каналов';

  @override
  String get tvSelectChannel => 'Выберите канал для просмотра';

  @override
  String get channelsSearch => 'Поиск каналов';

  @override
  String get channelsEmpty => 'Каналов пока нет — импортируйте плейлист';

  @override
  String get channelsUngrouped => 'Без группы';

  @override
  String get channelsCountSuffix => 'каналов';

  @override
  String get channelsImportTitle => 'Импорт плейлиста';

  @override
  String get channelsImportName => 'Название';

  @override
  String get channelsImportUrl => 'URL плейлиста (M3U)';

  @override
  String get channelsImportFile => 'Из файла';

  @override
  String get channelsImportFromUrl => 'Импорт';

  @override
  String get osdNoGuide => 'Нет данных программы';

  @override
  String get commonBack => 'Назад';

  @override
  String get commonDelete => 'Удалить';

  @override
  String get providersAddTitle => 'Добавить источник';

  @override
  String get providersChooseType => 'Выберите тип источника';

  @override
  String get providerName => 'Название';

  @override
  String get providerImport => 'Добавить и импортировать';

  @override
  String get providerImporting => 'Импорт…';

  @override
  String get providerM3uUrl => 'Плейлист M3U (URL)';

  @override
  String get providerM3uUrlDesc => 'Загрузить плейлист M3U/M3U8 по URL';

  @override
  String get providerM3uFile => 'Плейлист M3U (файл)';

  @override
  String get providerM3uFileDesc =>
      'Загрузить плейлист M3U/M3U8 из локального файла';

  @override
  String get providerGenericUrl => 'Один поток';

  @override
  String get providerGenericUrlDesc =>
      'Один URL потока (HLS, RTSP, UDP…) как канал';

  @override
  String get providerIptvOrg => 'Каталог iptv-org';

  @override
  String get providerIptvOrgDesc => 'Бесплатный публичный каталог от iptv-org';

  @override
  String get providerXtream => 'Xtream Codes';

  @override
  String get providerXtreamDesc =>
      'Панель Xtream / XUI.one (сервер, логин, пароль)';

  @override
  String get providerStalker => 'Портал Stalker';

  @override
  String get providerStalkerDesc =>
      'Портал Stalker / Ministra (MAG) по MAC-адресу';

  @override
  String get providerServerUrl => 'URL сервера';

  @override
  String get providerUsername => 'Логин';

  @override
  String get providerPassword => 'Пароль';

  @override
  String get providerPortalUrl => 'URL портала';

  @override
  String get providerMac => 'MAC-адрес';

  @override
  String get providerLoginOptional => 'Логин (необязательно)';

  @override
  String get providerOtt => 'OTT-сервис';

  @override
  String get providerOttDesc =>
      'Вход в брендовый OTT (Kartina, Sovok, TV Club…)';

  @override
  String get providerOttService => 'Сервис';

  @override
  String get providerParentalCode => 'Родительский PIN (необязательно)';

  @override
  String get providerLocalFolder => 'Локальная папка';

  @override
  String get providerLocalFolderDesc => 'Индексировать папку с видео / музыкой';

  @override
  String get providerChooseFolder => 'Выбрать папку…';

  @override
  String get providerNoFolder => 'Папка не выбрана';

  @override
  String get providerYoutube => 'YouTube';

  @override
  String get providerYoutubeDesc => 'URL канала, плейлиста или видео';

  @override
  String get providerYoutubeUrl => 'URL YouTube';

  @override
  String get providerPlaylistUrl => 'URL плейлиста';

  @override
  String get providerStreamUrl => 'URL потока';

  @override
  String get providerIsRadio => 'Только аудио (радио)';

  @override
  String get providerChooseFile => 'Выбрать файл…';

  @override
  String get providerNoFile => 'Файл не выбран';

  @override
  String get providerScope => 'Каталог';

  @override
  String get providerScopeAll => 'Все каналы';

  @override
  String get providerScopeCountry => 'По стране';

  @override
  String get providerScopeCategory => 'По категории';

  @override
  String get providerScopeLanguage => 'По языку';

  @override
  String get providerScopeCode => 'Код';

  @override
  String get providerScopeCodeHint => 'напр. us, uk, news, eng';

  @override
  String get providerManageTitle => 'Источники';

  @override
  String get providerRefresh => 'Обновить';

  @override
  String providerImported(int count) {
    return 'Импортировано каналов: $count';
  }

  @override
  String get navGuide => 'Программа';

  @override
  String get epgImportTitle => 'Импорт EPG (XMLTV)';

  @override
  String get epgImportUrl => 'URL XMLTV';

  @override
  String get epgJumpToNow => 'Перейти к текущему времени';

  @override
  String epgImported(int count) {
    return 'Импортировано программ: $count';
  }

  @override
  String get epgEmpty => 'Программы пока нет — импортируйте XMLTV';

  @override
  String get epgNoMatches => 'Нет каналов, совпавших с программой';

  @override
  String get epgWatchCatchup => 'Смотреть с начала';

  @override
  String get navVod => 'VOD';

  @override
  String get vodTitle => 'Видео по запросу';

  @override
  String get vodMovies => 'Фильмы';

  @override
  String get vodSeries => 'Сериалы';

  @override
  String get vodFavorites => 'Избранное';

  @override
  String get vodSearch => 'Поиск';

  @override
  String get vodAllCategories => 'Все категории';

  @override
  String get vodRefresh => 'Обновить каталог';

  @override
  String get vodEmpty => 'В кэше пусто — обновите каталог';

  @override
  String get vodNoSources =>
      'Нет источников с VOD. Сначала добавьте источник Xtream.';

  @override
  String get vodFavoritesEmpty => 'Избранного пока нет';

  @override
  String get vodSortDefault => 'По умолчанию';

  @override
  String get vodSortTitle => 'Название А–Я';

  @override
  String get vodSortRating => 'По рейтингу';

  @override
  String get vodPlay => 'Смотреть';

  @override
  String vodSeasonLabel(int n) {
    return 'Сезон $n';
  }

  @override
  String get vodNoEpisodes => 'Эпизоды не найдены';

  @override
  String get vodLoadingEpisodes => 'Загрузка эпизодов…';

  @override
  String get vodSource => 'Источник';

  @override
  String get navRecordings => 'Записи';

  @override
  String get recTabActive => 'Активные';

  @override
  String get recTabScheduled => 'Запланированные';

  @override
  String get recTabFiles => 'Файлы';

  @override
  String get recRecordChannel => 'Записать текущий канал';

  @override
  String get recNoActive => 'Нет активных записей';

  @override
  String get recNoScheduled => 'Ничего не запланировано';

  @override
  String get recNoFiles => 'Записей пока нет';

  @override
  String get recStop => 'Остановить';

  @override
  String get recPlay => 'Смотреть';

  @override
  String get recDelete => 'Удалить';

  @override
  String get recConnecting => 'Подключение…';

  @override
  String get recRecording => 'Идёт запись';

  @override
  String get recError => 'Ошибка';

  @override
  String get recRecord => 'Запись';

  @override
  String get recScheduled => 'Запись запланирована';

  @override
  String get recNothingPlaying => 'Канал не воспроизводится';

  @override
  String get recStarted => 'Запись начата';

  @override
  String get settingsMaintenance => 'Обслуживание';

  @override
  String get settingsDownloadLogos => 'Загрузить логотипы каналов';

  @override
  String get settingsDownloadLogosSub =>
      'Кэшировать логотипы текущего плейлиста';

  @override
  String get settingsTasks => 'Фоновые задачи';

  @override
  String get settingsNoTasks => 'Нет активных задач';

  @override
  String get settingsClearTasks => 'Очистить завершённые';

  @override
  String get settingsUpdates => 'Обновления';

  @override
  String get settingsCheckUpdates => 'Проверить обновления';

  @override
  String get settingsUpdateChecking => 'Проверка…';

  @override
  String settingsUpToDate(String version) {
    return 'У вас последняя версия ($version)';
  }

  @override
  String settingsUpdateAvailable(String version) {
    return 'Доступно обновление: $version';
  }

  @override
  String get settingsUpdateFailed => 'Не удалось проверить обновления';

  @override
  String get taskCancel => 'Отмена';

  @override
  String get settingsParental => 'Родительский контроль';

  @override
  String get settingsParentalOff =>
      'PIN не задан — защищённые каналы играют свободно';

  @override
  String get settingsParentalOn => 'Защищённые каналы требуют PIN';

  @override
  String get settingsSetPin => 'Задать PIN';

  @override
  String get settingsChangePin => 'Изменить PIN';

  @override
  String get settingsRemovePin => 'Удалить PIN';

  @override
  String get settingsRecording => 'Запись';

  @override
  String get settingsFilenameTemplate => 'Шаблон имени файла';

  @override
  String get settingsCast => 'Chromecast';

  @override
  String get settingsCastSoon => 'Скоро';

  @override
  String get parentalEnterPin => 'Введите PIN';

  @override
  String get parentalNewPin => 'Новый PIN';

  @override
  String get parentalCurrentPin => 'Текущий PIN';

  @override
  String get parentalWrongPin => 'Неверный PIN';

  @override
  String get parentalLocked => 'Этот канал заблокирован';

  @override
  String get commonOk => 'OK';

  @override
  String get commonSave => 'Сохранить';
}
