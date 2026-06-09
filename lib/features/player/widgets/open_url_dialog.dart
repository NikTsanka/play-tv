import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';

/// A public test stream (Apple's reference HLS bip-bop). Used as the default in
/// the open-URL dialog until the channel list (Milestone 3) provides sources.
const String kDemoHlsUrl =
    'https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8';

/// Prompts for a stream URL. Returns the URL, or `null` if cancelled.
Future<String?> showOpenUrlDialog(BuildContext context) {
  final controller = TextEditingController(text: kDemoHlsUrl);
  final l10n = AppLocalizations.of(context);

  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.playerOpenUrl),
      content: SizedBox(
        width: 480,
        child: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.playerUrlHint,
            prefixIcon: const Icon(Icons.link),
          ),
          onSubmitted: (v) => Navigator.of(context).pop(v.trim()),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(controller.text.trim()),
          child: Text(l10n.playerPlay),
        ),
      ],
    ),
  );
}
