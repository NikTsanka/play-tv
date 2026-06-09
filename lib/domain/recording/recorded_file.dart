import 'package:flutter/foundation.dart';

/// A file in the recordings folder (recorded-files browser, spec §10).
@immutable
class RecordedFile {
  const RecordedFile({
    required this.path,
    required this.name,
    required this.sizeBytes,
    required this.modified,
  });

  final String path;
  final String name;
  final int sizeBytes;
  final DateTime modified;

  String get sizeLabel {
    const List<String> units = <String>['B', 'KB', 'MB', 'GB', 'TB'];
    double size = sizeBytes.toDouble();
    int unit = 0;
    while (size >= 1024 && unit < units.length - 1) {
      size /= 1024;
      unit++;
    }
    return '${size.toStringAsFixed(unit == 0 ? 0 : 1)} ${units[unit]}';
  }
}
