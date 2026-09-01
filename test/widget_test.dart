import 'package:flutter_test/flutter_test.dart';
import 'package:hodiy/app.dart';
import 'package:hodiy/features/settings/state/settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('shows the temporary Hodiy home', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final settings = SettingsController();
    await settings.load();

    await tester.pumpWidget(HodiyApp(settings: settings));

    expect(find.text('Hodiy'), findsOneWidget);
  });
}
