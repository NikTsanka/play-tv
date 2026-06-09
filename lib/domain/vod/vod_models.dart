import 'package:flutter/foundation.dart';

/// Whether a VOD item is a standalone film or a series (seasons → episodes).
enum VodKind { movie, series }

extension VodKindId on VodKind {
  String get id => name;
  static VodKind fromId(String? id) =>
      id == 'series' ? VodKind.series : VodKind.movie;
}

/// A VOD category / genre exposed by a source.
@immutable
class VodCategory {
  const VodCategory({required this.id, required this.name});
  final String id;
  final String name;

  @override
  bool operator ==(Object other) =>
      other is VodCategory && other.id == id && other.name == name;
  @override
  int get hashCode => Object.hash(id, name);
}

/// A film or series entry in the catalog. Movies carry a playable [url]; series
/// resolve their episodes lazily via [VodCatalog.episodes].
@immutable
class VodItem {
  const VodItem({
    required this.id,
    required this.kind,
    required this.title,
    this.cover,
    this.categoryId,
    this.categoryName,
    this.plot,
    this.rating,
    this.year,
    this.url,
  });

  /// Source-scoped id (e.g. Xtream stream_id / series_id).
  final String id;
  final VodKind kind;
  final String title;
  final String? cover;
  final String? categoryId;
  final String? categoryName;
  final String? plot;
  final String? rating;
  final String? year;

  /// Direct playable URL for a [VodKind.movie]; null for series.
  final String? url;

  bool get isSeries => kind == VodKind.series;
}

/// A single episode of a series.
@immutable
class VodEpisode {
  const VodEpisode({
    required this.id,
    required this.title,
    required this.season,
    required this.url,
    this.episode,
  });

  final String id;
  final String title;
  final int season;
  final int? episode;
  final String url;
}
