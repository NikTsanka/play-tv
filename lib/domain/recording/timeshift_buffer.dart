import 'dart:typed_data';

/// Fixed-capacity circular byte buffer backing live time-shift (pause / rewind,
/// spec §10). Newest bytes overwrite the oldest once full, so it always holds
/// the most recent [capacityBytes] of the live stream.
///
/// This is the pure data structure; wiring it to media_kit playback (seek into
/// the buffered window) is engine-constrained and layered on separately.
class TimeshiftBuffer {
  TimeshiftBuffer({required this.capacityBytes})
      : assert(capacityBytes > 0),
        _buf = Uint8List(capacityBytes);

  final int capacityBytes;
  final Uint8List _buf;

  int _start = 0; // index of the oldest stored byte
  int _length = 0; // bytes currently stored (<= capacity)
  int _totalWritten = 0;

  /// Bytes currently buffered.
  int get length => _length;

  /// Total bytes ever written (the buffered window is the tail of this).
  int get totalWritten => _totalWritten;

  bool get isFull => _length == capacityBytes;

  void write(List<int> data) {
    for (final int b in data) {
      if (_length < capacityBytes) {
        _buf[(_start + _length) % capacityBytes] = b;
        _length++;
      } else {
        _buf[_start] = b;
        _start = (_start + 1) % capacityBytes;
      }
      _totalWritten++;
    }
  }

  /// The buffered bytes, oldest → newest.
  Uint8List snapshot() => readLast(_length);

  /// The most recent [n] bytes (clamped to what's available), oldest → newest.
  Uint8List readLast(int n) {
    final int count = n.clamp(0, _length);
    final Uint8List out = Uint8List(count);
    final int begin = _length - count;
    for (int i = 0; i < count; i++) {
      out[i] = _buf[(_start + begin + i) % capacityBytes];
    }
    return out;
  }

  void clear() {
    _start = 0;
    _length = 0;
  }
}
