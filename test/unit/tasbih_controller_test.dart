import 'package:flutter_test/flutter_test.dart';
import 'package:hodiy/features/tasbih/state/tasbih_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('increment increases the count by one', () async {
    final controller = TasbihController();
    await controller.load();

    controller.increment();

    expect(controller.count, 1);
  });

  test('reaching the target completes a lap and resets the count', () async {
    final controller = TasbihController();
    await controller.load();
    controller.setTarget(3);

    controller.increment();
    controller.increment();
    controller.increment();

    expect(controller.count, 0);
    expect(controller.laps, 1);
    expect(controller.justCompletedLap, isTrue);

    controller.acknowledgeLapCompletion();

    expect(controller.justCompletedLap, isFalse);
  });

  test('reset clears the count without changing completed laps', () async {
    final controller = TasbihController();
    await controller.load();
    controller.setTarget(2);
    controller.increment();
    controller.increment();
    controller.increment();

    controller.reset();

    expect(controller.count, 0);
    expect(controller.laps, 1);
  });
}
