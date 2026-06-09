import 'package:flutter/foundation.dart';

import '../channels/channel.dart';
import '../vod/vod_models.dart';

/// What a favorite points at (spec §5 channels, §7 VOD).
enum FavoriteKind { channel, vodMovie, vodSeries }

extension FavoriteKindId on FavoriteKind {
  String get id => name;
  static FavoriteKind fromId(String? id) => FavoriteKind.values.firstWhere(
        (k) => k.name == id,
        orElse: () => FavoriteKind.vodMovie,
      );
}

/// A favorited item. [refId] is composite (`source:kind:id`) so it stays unique
/// across sources and kinds.
@immutable
class FavoriteItem {
  const FavoriteItem({
    required this.refId,
    required this.kind,
    required this.title,
    this.sourceId,
    this.subtitle,
    this.imageUrl,
    this.playUrl,
  });

  final String refId;
  final FavoriteKind kind;
  final String title;
  final int? sourceId;
  final String? subtitle;
  final String? imageUrl;
  final String? playUrl;

  static String makeRefId(FavoriteKind kind, int? sourceId, String id) =>
      '${sourceId ?? 0}:${kind.id}:$id';

  factory FavoriteItem.fromChannel(Channel channel, int? sourceId) =>
      FavoriteItem(
        refId: makeRefId(FavoriteKind.channel, sourceId, channel.id),
        kind: FavoriteKind.channel,
        title: channel.name,
        sourceId: sourceId,
        subtitle: channel.group,
        imageUrl: channel.logoUrl,
        playUrl: channel.url,
      );

  factory FavoriteItem.fromVod(VodItem item, int sourceId) {
    final FavoriteKind kind =
        item.isSeries ? FavoriteKind.vodSeries : FavoriteKind.vodMovie;
    return FavoriteItem(
      refId: makeRefId(kind, sourceId, item.id),
      kind: kind,
      title: item.title,
      sourceId: sourceId,
      subtitle: item.categoryName,
      imageUrl: item.cover,
      playUrl: item.url,
    );
  }
}
