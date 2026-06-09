import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:streamhub/domain/channels/channel.dart';
import 'package:streamhub/domain/parental/parental_control.dart';

void main() {
  group('ParentalControl hashing', () {
    test('hashPin is deterministic for a given salt', () {
      final String a = ParentalControl.hashPin('1234', 'salt');
      final String b = ParentalControl.hashPin('1234', 'salt');
      expect(a, b);
      expect(a.length, 64); // sha256 hex
    });

    test('different salts produce different hashes', () {
      expect(ParentalControl.hashPin('1234', 's1'),
          isNot(ParentalControl.hashPin('1234', 's2')));
    });

    test('verify accepts the right PIN and rejects the wrong one', () {
      const String salt = 'abc123';
      final String hash = ParentalControl.hashPin('4321', salt);
      expect(ParentalControl.verify('4321', salt, hash), isTrue);
      expect(ParentalControl.verify('0000', salt, hash), isFalse);
    });

    test('the PIN is never present in the stored hash', () {
      final String hash = ParentalControl.hashPin('5678', 'salt');
      expect(hash.contains('5678'), isFalse);
    });

    test('generateSalt yields distinct 32-char hex values', () {
      final String s1 = ParentalControl.generateSalt(Random(1));
      final String s2 = ParentalControl.generateSalt(Random(2));
      expect(s1.length, 32);
      expect(RegExp(r'^[0-9a-f]+$').hasMatch(s1), isTrue);
      expect(s1, isNot(s2));
    });
  });

  group('ParentalState.isLocked', () {
    Channel protected() => const Channel(
          id: 'p',
          name: 'Protected',
          url: '',
          props: <String, String>{'protected': 'true'},
        );
    Channel open() => const Channel(id: 'o', name: 'Open', url: '');

    test('locks protected channels only when a PIN is set and not unlocked', () {
      const ParentalState locked =
          ParentalState(hasPin: true, unlocked: false);
      expect(locked.isLocked(protected()), isTrue);
      expect(locked.isLocked(open()), isFalse);
    });

    test('unlocked session lets protected channels through', () {
      const ParentalState unlocked =
          ParentalState(hasPin: true, unlocked: true);
      expect(unlocked.isLocked(protected()), isFalse);
    });

    test('no PIN means nothing is gated', () {
      const ParentalState noPin =
          ParentalState(hasPin: false, unlocked: true);
      expect(noPin.isLocked(protected()), isFalse);
    });
  });
}
