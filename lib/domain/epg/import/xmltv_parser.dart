import 'package:xml/xml_events.dart';

import '../epg_models.dart';

/// Parses an XMLTV document into channels + programmes using the streaming
/// event parser (no DOM) so multi-hundred-MB guides don't blow memory. Pure &
/// isolate-friendly — run via `compute` (spec §5/§12).
EpgImportResult parseXmltv(String content) {
  final List<EpgChannel> channels = <EpgChannel>[];
  final List<EpgProgramme> programmes = <EpgProgramme>[];

  _ChannelBuilder? chan;
  _ProgrammeBuilder? prog;
  String? leaf;
  final StringBuffer buf = StringBuffer();

  for (final XmlEvent event in parseEvents(content, withParent: false)) {
    if (event is XmlStartElementEvent) {
      switch (event.localName) {
        case 'channel':
          chan = _ChannelBuilder(_attr(event, 'id') ?? '');
        case 'programme':
          prog = _ProgrammeBuilder(
            channelId: _attr(event, 'channel') ?? '',
            start: _parseTime(_attr(event, 'start')),
            stop: _parseTime(_attr(event, 'stop')),
          );
        case 'display-name':
        case 'title':
        case 'desc':
        case 'category':
          leaf = event.localName;
          buf.clear();
          if (event.isSelfClosing) leaf = null;
        case 'icon':
          final String? src = _attr(event, 'src');
          if (src != null && chan != null) chan.icon ??= src;
        default:
          leaf = null;
      }
    } else if (event is XmlTextEvent) {
      if (leaf != null) buf.write(event.value);
    } else if (event is XmlCDATAEvent) {
      if (leaf != null) buf.write(event.value);
    } else if (event is XmlEndElementEvent) {
      switch (event.localName) {
        case 'channel':
          if (chan != null && chan.id.isNotEmpty) {
            channels.add(EpgChannel(
              id: chan.id,
              displayNames: chan.names,
              icon: chan.icon,
            ));
          }
          chan = null;
        case 'programme':
          final EpgProgramme? p = prog?.build();
          if (p != null) programmes.add(p);
          prog = null;
        case 'display-name':
          final String t = buf.toString().trim();
          if (chan != null && t.isNotEmpty) chan.names.add(t);
          leaf = null;
        case 'title':
          if (prog != null) prog.title = buf.toString().trim();
          leaf = null;
        case 'desc':
          if (prog != null) prog.desc = buf.toString().trim();
          leaf = null;
        case 'category':
          if (prog != null && prog.category == null) {
            prog.category = buf.toString().trim();
          }
          leaf = null;
        default:
          break;
      }
    }
  }

  return EpgImportResult(channels: channels, programmes: programmes);
}

String? _attr(XmlStartElementEvent e, String name) {
  for (final a in e.attributes) {
    if (a.localName == name) return a.value;
  }
  return null;
}

/// Parses an XMLTV timestamp: `YYYYMMDDHHMMSS[ ±HHMM]` → UTC [DateTime].
DateTime? _parseTime(String? raw) {
  if (raw == null) return null;
  final String s = raw.trim();
  if (s.length < 14) return null;
  int p(int a, int b) => int.parse(s.substring(a, b));
  try {
    final DateTime wall = DateTime.utc(
        p(0, 4), p(4, 6), p(6, 8), p(8, 10), p(10, 12), p(12, 14));
    Duration offset = Duration.zero;
    final String rest = s.substring(14).trim();
    final Match? m = RegExp(r'([+-])(\d{2})(\d{2})').firstMatch(rest);
    if (m != null) {
      final int sign = m.group(1) == '-' ? -1 : 1;
      offset = Duration(
              hours: int.parse(m.group(2)!), minutes: int.parse(m.group(3)!)) *
          sign;
    }
    // UTC = wall-clock (treated as UTC) minus the declared offset.
    return wall.subtract(offset);
  } catch (_) {
    return null;
  }
}

class _ChannelBuilder {
  _ChannelBuilder(this.id);
  final String id;
  final List<String> names = <String>[];
  String? icon;
}

class _ProgrammeBuilder {
  _ProgrammeBuilder({
    required this.channelId,
    required this.start,
    required this.stop,
  });
  final String channelId;
  final DateTime? start;
  final DateTime? stop;
  String title = '';
  String? desc;
  String? category;

  EpgProgramme? build() {
    if (channelId.isEmpty || start == null || stop == null) return null;
    if (!stop!.isAfter(start!)) return null;
    return EpgProgramme(
      channelId: channelId,
      start: start!,
      stop: stop!,
      title: title.isEmpty ? '—' : title,
      description: (desc != null && desc!.isNotEmpty) ? desc : null,
      category: (category != null && category!.isNotEmpty) ? category : null,
    );
  }
}
