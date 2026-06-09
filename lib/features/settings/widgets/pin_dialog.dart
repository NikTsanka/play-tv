import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/generated/app_localizations.dart';

/// Prompts for a numeric PIN. Returns the entered PIN, or null if cancelled.
Future<String?> showPinDialog(BuildContext context, {required String title}) {
  final TextEditingController controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (context) {
      final AppLocalizations l10n = AppLocalizations.of(context);
      void submit() {
        final String pin = controller.text.trim();
        if (pin.isNotEmpty) Navigator.of(context).pop(pin);
      }

      return AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 8,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: const InputDecoration(counterText: ''),
          onSubmitted: (_) => submit(),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(onPressed: submit, child: Text(l10n.commonOk)),
        ],
      );
    },
  );
}
