import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hodiy/core/localization/generated/app_localizations.dart';
import 'package:hodiy/features/tasbih/state/tasbih_controller.dart';

class TasbihScreen extends StatefulWidget {
  const TasbihScreen({super.key});

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen> {
  late final TasbihController _controller;
  bool _lapFeedbackScheduled = false;

  @override
  void initState() {
    super.initState();
    _controller = TasbihController();
    unawaited(_controller.load());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _scheduleLapFeedback(String message) {
    if (_lapFeedbackScheduled) {
      return;
    }
    _lapFeedbackScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      unawaited(HapticFeedback.heavyImpact());
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
      _lapFeedbackScheduled = false;
      _controller.acknowledgeLapCompletion();
    });
  }

  Future<void> _selectCustomTarget(AppLocalizations l10n) async {
    var customTarget = _controller.target.toString();
    final selectedTarget = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.tasbihCustomTargetLabel),
        content: TextFormField(
          initialValue: customTarget,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(labelText: l10n.tasbihTargetLabel),
          onChanged: (value) => customTarget = value,
          onFieldSubmitted: (value) {
            final target = int.tryParse(value);
            if (target != null && target > 0) {
              Navigator.of(dialogContext).pop(target);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancelButton),
          ),
          FilledButton(
            onPressed: () {
              final target = int.tryParse(customTarget);
              if (target != null && target > 0) {
                Navigator.of(dialogContext).pop(target);
              }
            },
            child: Text(l10n.confirmButton),
          ),
        ],
      ),
    );
    if (selectedTarget != null && mounted) {
      _controller.setTarget(selectedTarget);
    }
  }

  Future<void> _confirmReset(AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: Text(l10n.tasbihResetConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancelButton),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.tasbihResetButton),
          ),
        ],
      ),
    );
    if (mounted && (confirmed ?? false)) {
      _controller.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        if (_controller.justCompletedLap) {
          _scheduleLapFeedback(l10n.tasbihLapCompleteMessage);
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.tasbihTitle),
            actions: [
              IconButton(
                onPressed: () => _confirmReset(l10n),
                tooltip: l10n.tasbihResetButton,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final target in const [33, 99, 100])
                        ChoiceChip(
                          label: Text(target.toString()),
                          selected: _controller.target == target,
                          onSelected: (_) => _controller.setTarget(target),
                        ),
                      ChoiceChip(
                        label: Text(l10n.tasbihCustomTargetLabel),
                        selected: !const [
                          33,
                          99,
                          100,
                        ].contains(_controller.target),
                        onSelected: (_) => _selectCustomTarget(l10n),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    key: const ValueKey('tasbihTapArea'),
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      unawaited(HapticFeedback.selectionClick());
                      _controller.increment();
                    },
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _controller.count.toString(),
                            style: Theme.of(context).textTheme.displayLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${l10n.tasbihTargetLabel}: '
                            '${_controller.target}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
