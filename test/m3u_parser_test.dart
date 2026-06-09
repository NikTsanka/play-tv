import 'package:flutter_test/flutter_test.dart';
import 'package:streamhub/domain/channels/channel.dart';
import 'package:streamhub/domain/channels/import/catchup_url_builder.dart';
import 'package:streamhub/domain/channels/import/m3u_parser.dart';

void main() {
  group('parseM3u', () {
    test('parses EXTINF attributes, group and url', () {
      const content = '''
#EXTM3U url-tvg="http://epg.example/guide.xml"
#EXTINF:-1 tvg-id="bbc1.uk" tvg-name="BBC One" tvg-logo="http://logo/bbc1.png" group-title="UK",BBC One HD
http://host/stream/bbc1.m3u8
''';
      final r = parseM3u(content);
      expect(r.epgUrl, 'http://epg.example/guide.xml');
      expect(r.channels.length, 1);
      final c = r.channels.first;
      expect(c.id, 'bbc1.uk');
      expect(c.epgId, 'bbc1.uk');
      expect(c.name, 'BBC One HD');
      expect(c.group, 'UK');
      expect(c.logoUrl, 'http://logo/bbc1.png');
      expect(c.url, 'http://host/stream/bbc1.m3u8');
    });

    test('falls back to tvg-name and sequential number', () {
      const content = '''
#EXTM3U
#EXTINF:-1 tvg-name="Channel A",
http://a
#EXTINF:-1,Channel B
http://b
''';
      final r = parseM3u(content);
      expect(r.channels[0].name, 'Channel A');
      expect(r.channels[0].number, 1);
      expect(r.channels[1].name, 'Channel B');
      expect(r.channels[1].number, 2);
    });

    test('reads EXTGRP, EXTVLCOPT headers and KODIPROP', () {
      const content = '''
#EXTM3U
#EXTINF:-1,Test
#EXTGRP:News
#EXTVLCOPT:http-user-agent=MyAgent/1.0
#EXTVLCOPT:http-referrer=http://ref.example/
#KODIPROP:inputstream.adaptive.manifest_type=hls
http://host/test
''';
      final c = parseM3u(content).channels.single;
      expect(c.group, 'News');
      expect(c.headers['User-Agent'], 'MyAgent/1.0');
      expect(c.headers['Referer'], 'http://ref.example/');
      expect(c.props['inputstream.adaptive.manifest_type'], 'hls');
    });

    test('parses flussonic catch-up declaration', () {
      const content = '''
#EXTM3U
#EXTINF:-1 catchup="flussonic" catchup-days="7",Arch
http://host/ch/index.m3u8
''';
      final c = parseM3u(content).channels.single;
      expect(c.catchup.type, CatchupType.flussonic);
      expect(c.catchup.days, 7);
      expect(c.hasArchive, isTrue);
    });

    test('handles radio flag and quoted commas in attributes', () {
      const content = '''
#EXTM3U
#EXTINF:-1 tvg-name="Jazz, Live" radio="true",Jazz Radio
http://host/jazz
''';
      final c = parseM3u(content).channels.single;
      expect(c.isRadio, isTrue);
      expect(c.name, 'Jazz Radio');
    });
  });

  group('CatchupUrlBuilder', () {
    final start = DateTime.utc(2024, 1, 2, 20, 0, 0);
    final end = DateTime.utc(2024, 1, 2, 21, 0, 0);
    const builder = CatchupUrlBuilder();

    test('flussonic derives archive path from live url', () {
      final url = builder.build(
        liveUrl: 'http://host/ch/index.m3u8',
        catchup: const CatchupInfo(type: CatchupType.flussonic, days: 7),
        startUtc: start,
        endUtc: end,
      );
      final s = start.millisecondsSinceEpoch ~/ 1000;
      expect(url, 'http://host/ch/archive-$s-3600.m3u8');
    });

    test('xc builds timeshift path from live url', () {
      final url = builder.build(
        liveUrl: 'http://host:8080/live/user/pass/123.ts',
        catchup: const CatchupInfo(type: CatchupType.xc),
        startUtc: start,
        endUtc: end,
      );
      expect(url, 'http://host:8080/timeshift/user/pass/60/2024-01-02:20-00/123.ts');
    });

    test('expands placeholders in a custom source template', () {
      final url = builder.build(
        liveUrl: 'http://host/live',
        catchup: const CatchupInfo(
            type: CatchupType.standard,
            source: r'http://host/a?start=${start}&dur={duration}'),
        startUtc: start,
        endUtc: end,
      );
      final s = start.millisecondsSinceEpoch ~/ 1000;
      expect(url, 'http://host/a?start=$s&dur=3600');
    });
  });
}
