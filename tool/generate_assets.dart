// Generates StreamHub's brand assets (app icon, adaptive foreground, Android TV
// banner) from code so no external design tool is needed. Re-run with:
//   dart run tool/generate_assets.dart
// then `dart run flutter_launcher_icons` to fan out platform icons.
import 'dart:io';

import 'package:image/image.dart';

final Color _gold = ColorRgb8(0xD4, 0xAF, 0x37);
final Color _black = ColorRgb8(0x0D, 0x0D, 0x0D);

/// Draws the brand mark — a rounded "screen" with a play triangle + a stand —
/// centered at ([cx],[cy]).
void _drawMark(
  Image img, {
  required int cx,
  required int cy,
  required int size,
  required Color screen,
  required Color glyph,
}) {
  final int halfW = size ~/ 2;
  final int halfH = (size * 0.34).round();
  final int left = cx - halfW;
  final int right = cx + halfW;
  final int top = cy - halfH;
  final int bottom = cy + halfH;

  fillRect(img,
      x1: left,
      y1: top,
      x2: right,
      y2: bottom,
      color: screen,
      radius: (size * 0.12).round());

  // Stand.
  fillRect(img,
      x1: cx - (size * 0.16).round(),
      y1: bottom + (size * 0.015).round(),
      x2: cx + (size * 0.16).round(),
      y2: bottom + (size * 0.085).round(),
      color: screen);

  // Play triangle.
  final int tw = (size * 0.22).round();
  final int th = (size * 0.26).round();
  final int tx = cx - (tw * 0.35).round();
  fillPolygon(img, vertices: <Point>[
    Point(tx, cy - th ~/ 2),
    Point(tx, cy + th ~/ 2),
    Point(tx + tw, cy),
  ], color: glyph);
}

void _write(String path, Image img) {
  final File f = File(path)..parent.createSync(recursive: true);
  f.writeAsBytesSync(encodePng(img));
  stdout.writeln('wrote $path');
}

void main() {
  // 1024² launcher icon: gold screen on near-black.
  final Image icon = Image(width: 1024, height: 1024, numChannels: 4);
  fill(icon, color: _black);
  _drawMark(icon, cx: 512, cy: 500, size: 620, screen: _gold, glyph: _black);
  _write('assets/icon/icon.png', icon);

  // Adaptive foreground: transparent bg, padded mark (safe zone).
  final Image fg = Image(width: 1024, height: 1024, numChannels: 4);
  fill(fg, color: ColorRgba8(0, 0, 0, 0));
  _drawMark(fg, cx: 512, cy: 500, size: 470, screen: _gold, glyph: _black);
  _write('assets/icon/icon_foreground.png', fg);

  // 320×180 Android TV banner: mark + wordmark (arial24 fits the 320px width).
  final Image banner = Image(width: 320, height: 180, numChannels: 4);
  fill(banner, color: _black);
  _drawMark(banner, cx: 70, cy: 88, size: 86, screen: _gold, glyph: _black);
  drawString(banner, 'StreamHub', font: arial24, x: 126, y: 78, color: _gold);
  _write('assets/icon/banner.png', banner);
  // Same banner into the Android resources so the TV launcher can use it.
  _write('android/app/src/main/res/drawable/banner.png', banner);
}
