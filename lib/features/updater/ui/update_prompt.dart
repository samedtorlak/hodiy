import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hodiy/core/localization/generated/app_localizations.dart';
import 'package:hodiy/features/updater/update_service.dart';

/// Checks for a newer GitHub release and walks the user through
/// download + install. Silently does nothing when up to date or offline.
Future<void> maybePromptForUpdate(
  BuildContext context,
  UpdateService service,
) async {
  final update = await service.checkForUpdate();
  if (update == null || !context.mounted) {
    return;
  }

  final l10n = AppLocalizations.of(context);
  final accepted = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.updateAvailableTitle),
      content: Text(l10n.updateAvailableMessage(update.version)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(l10n.updateLaterButton),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(l10n.updateDownloadButton),
        ),
      ],
    ),
  );
  if (accepted != true || !context.mounted) {
    return;
  }

  final progress = ValueNotifier<double?>(null);
  unawaited(
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.updateDownloadingMessage),
        content: ValueListenableBuilder<double?>(
          valueListenable: progress,
          builder: (_, value, _) => LinearProgressIndicator(value: value),
        ),
      ),
    ),
  );

  try {
    final apkFile = await service.downloadApk(
      update,
      onProgress: (value) => progress.value = value,
    );
    await service.installApk(apkFile);
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  } catch (_) {
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.updateFailedMessage)));
    }
  }
}
