import 'package:flutter/material.dart';

import '../../../domain/channels/channel.dart';
import '../../../l10n/generated/app_localizations.dart';

/// On-screen channel info card shown briefly when zapping (spec §9). The
/// now/next lines bind to EPG in Milestone 4; until then they show a hint.
class OsdChannelInfo extends StatelessWidget {
  const OsdChannelInfo({
    required this.channel,
    this.nowTitle,
    this.nextTitle,
    super.key,
  });

  final Channel channel;
  final String? nowTitle;
  final String? nextTitle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.topCenter,
      // Compact card, nudged toward the top edge.
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 6, 12, 0),
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: scheme.primary.withValues(alpha: 0.6)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Channel number badge.
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                channel.number?.toString() ?? '—',
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 10),
            _Logo(url: channel.logoUrl, isRadio: channel.isRadio),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    channel.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                  _EpgLine(
                      icon: Icons.play_arrow,
                      text: nowTitle ?? l10n.osdNoGuide,
                      accent: scheme.primary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EpgLine extends StatelessWidget {
  const _EpgLine(
      {required this.icon, required this.text, required this.accent});
  final IconData icon;
  final String text;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 14, color: accent),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({required this.url, required this.isRadio});
  final String? url;
  final bool isRadio;

  @override
  Widget build(BuildContext context) {
    final fallback = Icon(isRadio ? Icons.radio : Icons.live_tv,
        size: 22, color: Colors.white70);
    return SizedBox(
      width: 36,
      height: 36,
      child: (url == null || url!.isEmpty)
          ? fallback
          : Image.network(url!,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => fallback),
    );
  }
}
