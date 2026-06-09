import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/preferences.dart';
import '../channels/channel.dart';

/// Pure PIN hashing for parental control (spec §9). The PIN is never stored in
/// the clear — only `sha256(salt:pin)`.
abstract final class ParentalControl {
  const ParentalControl._();

  static String hashPin(String pin, String salt) =>
      sha256.convert(utf8.encode('$salt:$pin')).toString();

  static bool verify(String pin, String salt, String storedHash) =>
      hashPin(pin, salt) == storedHash;

  /// A random hex salt (uses a secure RNG when available).
  static String generateSalt([Random? random]) {
    final Random r = random ?? Random.secure();
    final List<int> bytes =
        List<int>.generate(16, (_) => r.nextInt(256));
    return bytes.map((int b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}

/// Whether a PIN is set, and whether protected content is currently unlocked
/// for this session.
@immutable
class ParentalState {
  const ParentalState({required this.hasPin, required this.unlocked});

  final bool hasPin;
  final bool unlocked;

  /// Whether [channel] is gated right now (PIN set, not unlocked, protected).
  bool isLocked(Channel channel) =>
      hasPin && !unlocked && channel.props['protected'] == 'true';

  ParentalState copyWith({bool? hasPin, bool? unlocked}) => ParentalState(
        hasPin: hasPin ?? this.hasPin,
        unlocked: unlocked ?? this.unlocked,
      );
}

/// Owns the parental PIN (persisted, hashed) and the per-session unlock flag.
class ParentalController extends Notifier<ParentalState> {
  @override
  ParentalState build() {
    final String? hash =
        ref.watch(sharedPreferencesProvider).getString(PrefKeys.parentalPinHash);
    // With no PIN, nothing is gated → treat as unlocked.
    return ParentalState(hasPin: hash != null, unlocked: hash == null);
  }

  Future<void> setPin(String pin) async {
    final prefs = ref.read(sharedPreferencesProvider);
    final String salt = ParentalControl.generateSalt();
    await prefs.setString(PrefKeys.parentalSalt, salt);
    await prefs.setString(
        PrefKeys.parentalPinHash, ParentalControl.hashPin(pin, salt));
    state = const ParentalState(hasPin: true, unlocked: true);
  }

  /// Removes the PIN if [currentPin] verifies. Returns success.
  Future<bool> removePin(String currentPin) async {
    if (!_check(currentPin)) return false;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove(PrefKeys.parentalPinHash);
    await prefs.remove(PrefKeys.parentalSalt);
    state = const ParentalState(hasPin: false, unlocked: true);
    return true;
  }

  /// Unlocks protected content for the session if [pin] verifies.
  bool unlock(String pin) {
    if (!_check(pin)) return false;
    state = state.copyWith(unlocked: true);
    return true;
  }

  /// Re-locks protected content.
  void lock() {
    if (state.hasPin) state = state.copyWith(unlocked: false);
  }

  bool isLocked(Channel channel) => state.isLocked(channel);

  bool _check(String pin) {
    final prefs = ref.read(sharedPreferencesProvider);
    final String? hash = prefs.getString(PrefKeys.parentalPinHash);
    final String? salt = prefs.getString(PrefKeys.parentalSalt);
    if (hash == null || salt == null) return false;
    return ParentalControl.verify(pin, salt, hash);
  }
}

final parentalControllerProvider =
    NotifierProvider<ParentalController, ParentalState>(
        ParentalController.new);
