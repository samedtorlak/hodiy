import 'package:flutter/material.dart';
import 'package:hodiy/app.dart';
import 'package:hodiy/features/settings/state/settings_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = SettingsController();
  await settings.load();
  runApp(HodiyApp(settings: settings));
}
