import 'package:flutter_test/flutter_test.dart';
import 'package:streamhub/domain/channels/channel.dart';
import 'package:streamhub/domain/local/cue_parser.dart';
import 'package:streamhub/domain/local/local_scan.dart';
import 'package:streamhub/domain/local/media_types.dart';

void main() {
  group('media classification', () {
    test('classifies by extension', () {
      expect(classifyMedia('/a/b/movie.MKV'), MediaKind.video);
      expect(classifyMedia('song.flac'), MediaKind.audio);
      expect(classifyMedia('book.m4b'), MediaKind.audiobook);
      expect(classifyMedia('notes.txt'), MediaKind.unknown);
      expect(classifyMedia('noext'), MediaKind.unknown);
    });

    test('isMediaFile / isAudioMedia', () {
      expect(isMediaFile('a.mp4'), isTrue);
      expect(isMediaFile('a.txt'), isFalse);
      expect(isAudioMedia('a.mp3'), isTrue);
      expect(isAudioMedia('a.m4b'), isTrue);
      expect(isAudioMedia('a.mp4'), isFalse);
    });

    test('fileTitle / fileExtension handle separators and dots', () {
      expect(fileTitle(r'C:\Media\Movies\The Film (2023).mkv'),
          'The Film (2023)');
      expect(fileExtension('/x/y.Final.MP4'), 'mp4');
      expect(fileExtension('/x/y'), '');
    });
  });

  group('buildLocalChannels', () {
    test('classifies, groups by subdir and titles from filename', () {
      final List<Channel> channels = buildLocalChannels((
        root: '/media',
        paths: <String>[
          '/media/Movies/Alpha.mkv',
          '/media/Movies/Beta.mp4',
          '/media/Music/Song.mp3',
          '/media/readme.txt', // skipped (not media)
          '/media/Top.mkv', // directly in root → no group
        ],
      ));

      expect(channels.length, 4);
      final Channel song =
          channels.firstWhere((Channel c) => c.name == 'Song');
      expect(song.group, 'Music');
      expect(song.isRadio, isTrue);
      expect(song.url, startsWith('file:'));

      final Channel top = channels.firstWhere((Channel c) => c.name == 'Top');
      expect(top.group, isNull);
      expect(top.isRadio, isFalse);

      // Sequential numbering over the sorted media set.
      expect(channels.map((Channel c) => c.number).toSet(),
          <int>{1, 2, 3, 4});
    });

    test('handles backslash paths and nested subdirs', () {
      final List<Channel> channels = buildLocalChannels((
        root: r'C:\Media',
        paths: <String>[r'C:\Media\Shows\S1\Ep1.mp4'],
      ));
      expect(channels.single.group, 'Shows/S1');
      expect(channels.single.name, 'Ep1');
    });
  });

  group('parseCue', () {
    const String cue = '''
PERFORMER "The Author"
TITLE "Audiobook"
FILE "book.m4a" WAVE
  TRACK 01 AUDIO
    TITLE "Chapter One"
    INDEX 01 00:00:00
  TRACK 02 AUDIO
    TITLE "Chapter Two"
    PERFORMER "Narrator B"
    INDEX 01 03:30:00
''';

    test('reads file, tracks, titles and start offsets', () {
      final CueSheet sheet = parseCue(cue);
      expect(sheet.file, 'book.m4a');
      expect(sheet.performer, 'The Author');
      expect(sheet.tracks.length, 2);

      expect(sheet.tracks[0].title, 'Chapter One');
      expect(sheet.tracks[0].start, Duration.zero);
      // Album performer inherited when a track has none.
      expect(sheet.tracks[0].performer, 'The Author');

      expect(sheet.tracks[1].title, 'Chapter Two');
      expect(sheet.tracks[1].performer, 'Narrator B');
      expect(sheet.tracks[1].start, const Duration(minutes: 3, seconds: 30));
    });

    test('converts CUE frames (75/sec) to milliseconds', () {
      final CueSheet sheet = parseCue('''
FILE "a.flac" WAVE
  TRACK 01 AUDIO
    INDEX 01 00:01:60
''');
      // 1s + 60 frames (60/75 s = 800ms) = 1800ms.
      expect(sheet.tracks.single.start, const Duration(milliseconds: 1800));
    });
  });
}
