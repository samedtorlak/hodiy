import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hodiy/core/localization/generated/app_localizations.dart';
import 'package:hodiy/features/notifications/notification_service.dart';
import 'package:hodiy/features/settings/state/settings_controller.dart';
import 'package:hodiy/features/settings/ui/settings_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeNotificationService implements NotificationServiceBase {
  @override
  Future<bool> canScheduleExact() async => true;

  @override
  Future<void> cancelAll() async {}

  @override
  Future<void> init() async {}

  @override
  Future<bool> requestExactAlarmPermission() async => true;

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> scheduleAt({
    required int id,
    required String channelId,
    required String title,
    required String body,
    required DateTime whenUtc,
    required bool exact,
  }) async {}

  @override
  Future<void> showNow({
    required int id,
    required String title,
    required String body,
  }) async {}
}

void main() {
  testWidgets('renders the settings screen title', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final settings = SettingsController();
    await settings.load();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsController>.value(value: settings),
          Provider<NotificationServiceBase>(
            create: (_) => FakeNotificationService(),
          ),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: SettingsScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('offers all supported languages using native names', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final settings = SettingsController();
    await settings.load();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsController>.value(value: settings),
          Provider<NotificationServiceBase>(
            create: (_) => FakeNotificationService(),
          ),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: SettingsScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('English'), findsOneWidget);
    await tester.tap(find.byType(DropdownButton<Locale>));
    await tester.pumpAndSettle();

    expect(find.text('Русский'), findsOneWidget);
    expect(find.text('Oʻzbekcha'), findsOneWidget);
    expect(find.text('Қазақша'), findsOneWidget);
    expect(find.text('Кыргызча'), findsOneWidget);
    expect(find.text('Тоҷикӣ'), findsOneWidget);
  });
}
