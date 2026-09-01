import 'package:flutter/material.dart';
import 'package:hodiy/core/localization/generated/app_localizations.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _privacyPolicyUrl =
      'https://samedtorlak.github.io/hodiy-site/privacy';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutSetting)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Hodiy', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('1.0.0', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 24),
          Text(l10n.aboutNoDataMessage),
          const SizedBox(height: 24),
          Text(l10n.privacyPolicyLabel),
          const SizedBox(height: 4),
          const SelectableText(_privacyPolicyUrl),
        ],
      ),
    );
  }
}
