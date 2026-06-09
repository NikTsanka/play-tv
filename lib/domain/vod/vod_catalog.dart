import 'vod_models.dart';

/// The VOD capability a provider may expose (spec §7). Sources that can serve a
/// catalog (Xtream today; Stalker / OTT / local folders later) return one from
/// `Provider.vodCatalog`; sources that can't return null and are hidden from the
/// VOD browser.
abstract class VodCatalog {
  /// Movie categories / genres.
  Future<List<VodCategory>> movieCategories();

  /// Films, optionally filtered to a category.
  Future<List<VodItem>> movies({String? categoryId});

  /// Series categories / genres.
  Future<List<VodCategory>> seriesCategories();

  /// Series entries, optionally filtered to a category.
  Future<List<VodItem>> seriesEntries({String? categoryId});

  /// Episodes of a [series] (all seasons; each carries its season number).
  Future<List<VodEpisode>> episodes(VodItem series);
}
