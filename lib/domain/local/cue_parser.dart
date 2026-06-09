import 'dart:convert';

import 'package:flutter/foundation.dart';

/// One track of a CUE sheet (album / audiobook chapter, spec §4.5).
@immutable
class CueTrack {
  const CueTrack({
    required this.number,
    required this.title,
    this.performer,
    required this.start,
  });

  final int number;
  final String title;
  final String? performer;

  /// Offset from the start of the referenced audio file.
  final Duration start;
}

/// Parsed CUE sheet: the referenced audio [file] and its ordered [tracks].
@immutable
class CueSheet {
  const CueSheet({this.file, this.performer, required this.tracks});
  final String? file;
  final String? performer;
  final List<CueTrack> tracks;
}

/// Parses CUE sheet text (chapters / album tracks). Pure & testable.
CueSheet parseCue(String content) {
  String? file;
  String? albumPerformer;
  final List<CueTrack> tracks = <CueTrack>[];

  int? curNumber;
  String? curTitle;
  String? curPerformer;
  Duration? curStart;
  bool inTrack = false;

  void flush() {
    if (inTrack && curNumber != null) {
      tracks.add(CueTrack(
        number: curNumber,
        title: curTitle ?? 'Track $curNumber',
        performer: curPerformer ?? albumPerformer,
        start: curStart ?? Duration.zero,
      ));
    }
  }

  for (final String raw in const LineSplitter().convert(content)) {
    final String line = raw.trim();
    if (line.isEmpty) continue;
    final int sp = line.indexOf(' ');
    final String cmd = (sp < 0 ? line : line.substring(0, sp)).toUpperCase();
    final String rest = sp < 0 ? '' : line.substring(sp + 1).trim();

    switch (cmd) {
      case 'FILE':
        file = _unquoteFirst(rest);
      case 'TRACK':
        flush();
        inTrack = true;
        curNumber = int.tryParse(rest.split(RegExp(r'\s+')).first);
        curTitle = null;
        curPerformer = null;
        curStart = null;
      case 'TITLE':
        if (inTrack) {
          curTitle = _unquote(rest);
        }
      case 'PERFORMER':
        if (inTrack) {
          curPerformer = _unquote(rest);
        } else {
          albumPerformer = _unquote(rest);
        }
      case 'INDEX':
        // `INDEX 01 MM:SS:FF` — use index 01 as the track start.
        final List<String> parts = rest.split(RegExp(r'\s+'));
        if (parts.length >= 2 && (parts[0] == '01' || parts[0] == '1')) {
          curStart = _parseCueTime(parts[1]);
        }
    }
  }
  flush();

  return CueSheet(file: file, performer: albumPerformer, tracks: tracks);
}

/// CUE time is `MM:SS:FF` (FF = frames, 75 per second).
Duration _parseCueTime(String s) {
  final List<String> p = s.split(':');
  if (p.length != 3) return Duration.zero;
  final int mm = int.tryParse(p[0]) ?? 0;
  final int ss = int.tryParse(p[1]) ?? 0;
  final int ff = int.tryParse(p[2]) ?? 0;
  return Duration(
      milliseconds: mm * 60000 + ss * 1000 + (ff * 1000 ~/ 75));
}

String _unquote(String s) {
  final String t = s.trim();
  if (t.length >= 2 && t.startsWith('"') && t.endsWith('"')) {
    return t.substring(1, t.length - 1);
  }
  return t;
}

String _unquoteFirst(String s) {
  final String t = s.trim();
  if (t.startsWith('"')) {
    final int end = t.indexOf('"', 1);
    if (end > 0) return t.substring(1, end);
  }
  final int sp = t.indexOf(' ');
  return sp < 0 ? t : t.substring(0, sp);
}
