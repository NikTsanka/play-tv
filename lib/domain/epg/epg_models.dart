import 'package:flutter/foundation.dart';

/// An EPG channel declaration from a guide source (`<channel>` in XMLTV).
@immutable
class EpgChannel {
  const EpgChannel({
    required this.id,
    required this.displayNames,
    this.icon,
  });

  /// The guide channel id — matched to a [Channel.epgId] / tvg-id.
  final String id;
  final List<String> displayNames;
  final String? icon;

  String get primaryName => displayNames.isNotEmpty ? displayNames.first : id;
}

/// A single guide event (`<programme>`).
@immutable
class EpgProgramme {
  const EpgProgramme({
    required this.channelId,
    required this.start,
    required this.stop,
    required this.title,
    this.description,
    this.category,
  });

  final String channelId;
  final DateTime start; // UTC
  final DateTime stop; // UTC
  final String title;
  final String? description;
  final String? category;

  Duration get duration => stop.difference(start);

  bool isLiveAt(DateTime now) => !now.isBefore(start) && now.isBefore(stop);

  /// Fraction elapsed [0..1] at [now], for OSD/grid progress bars.
  double progressAt(DateTime now) {
    final total = duration.inSeconds;
    if (total <= 0) return 0;
    final done = now.difference(start).inSeconds;
    return (done / total).clamp(0.0, 1.0);
  }
}

/// Current + next programme for a channel (OSD now/next).
@immutable
class NowNext {
  const NowNext({this.now, this.next});
  final EpgProgramme? now;
  final EpgProgramme? next;

  static const NowNext empty = NowNext();
  bool get isEmpty => now == null && next == null;
}

/// Result of parsing an XMLTV document.
class EpgImportResult {
  EpgImportResult({required this.channels, required this.programmes});
  final List<EpgChannel> channels;
  final List<EpgProgramme> programmes;
}
