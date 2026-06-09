import 'package:flutter_test/flutter_test.dart';
import 'package:streamhub/domain/channels/channel.dart';
import 'package:streamhub/domain/epg/epg_matcher.dart';
import 'package:streamhub/domain/epg/epg_models.dart';
import 'package:streamhub/domain/epg/import/xmltv_parser.dart';

void main() {
  group('parseXmltv', () {
    const xml = '''
<?xml version="1.0" encoding="UTF-8"?>
<tv>
  <channel id="bbc1.uk">
    <display-name>BBC One</display-name>
    <icon src="http://logo/bbc1.png"/>
  </channel>
  <programme start="20240102200000 +0000" stop="20240102210000 +0000" channel="bbc1.uk">
    <title>News at Ten</title>
    <desc>The latest headlines.</desc>
    <category>News</category>
  </programme>
  <programme start="20240102210000 +0000" stop="20240102220000 +0000" channel="bbc1.uk">
    <title>Drama</title>
  </programme>
</tv>
''';

    test('parses channels and programmes', () {
      final r = parseXmltv(xml);
      expect(r.channels.length, 1);
      expect(r.channels.first.id, 'bbc1.uk');
      expect(r.channels.first.primaryName, 'BBC One');
      expect(r.channels.first.icon, 'http://logo/bbc1.png');

      expect(r.programmes.length, 2);
      final p = r.programmes.first;
      expect(p.title, 'News at Ten');
      expect(p.description, 'The latest headlines.');
      expect(p.category, 'News');
      expect(p.start, DateTime.utc(2024, 1, 2, 20));
      expect(p.stop, DateTime.utc(2024, 1, 2, 21));
    });

    test('applies timezone offset to UTC', () {
      const x = '''
<tv><programme start="20240102200000 +0200" stop="20240102210000 +0200" channel="c">
<title>T</title></programme></tv>''';
      final p = parseXmltv(x).programmes.single;
      expect(p.start, DateTime.utc(2024, 1, 2, 18)); // 20:00 +0200 == 18:00 UTC
    });

    test('now/next + isLiveAt', () {
      final r = parseXmltv(xml);
      final now = DateTime.utc(2024, 1, 2, 20, 30);
      expect(r.programmes[0].isLiveAt(now), isTrue);
      expect(r.programmes[1].isLiveAt(now), isFalse);
      expect(r.programmes[0].progressAt(now), closeTo(0.5, 0.01));
    });
  });

  group('buildChannelEpgMap', () {
    final epg = <EpgChannel>[
      const EpgChannel(id: 'bbc1.uk', displayNames: <String>['BBC One']),
      const EpgChannel(id: 'cnn.us', displayNames: <String>['CNN']),
    ];

    test('matches by tvg-id exactly (case-insensitive)', () {
      final channels = <Channel>[
        const Channel(id: 'a', name: 'BBC 1', url: 'u', epgId: 'BBC1.UK'),
      ];
      final map = buildChannelEpgMap(channels, epg);
      expect(map['a'], 'bbc1.uk');
    });

    test('falls back to normalized name', () {
      final channels = <Channel>[
        const Channel(id: 'b', name: 'CNN HD', url: 'u'),
      ];
      final map = buildChannelEpgMap(channels, epg);
      expect(map['b'], 'cnn.us');
    });

    test('leaves unmatched channels out', () {
      final channels = <Channel>[
        const Channel(id: 'c', name: 'Unknown Channel', url: 'u'),
      ];
      expect(buildChannelEpgMap(channels, epg), isEmpty);
    });
  });
}
