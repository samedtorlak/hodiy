import 'package:flutter_test/flutter_test.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:hodiy/features/hijri/domain/hijri_service.dart';

void main() {
  test('converts 1 March 2025 to a plausible Umm al-Qura date', () {
    final hijriDate = HijriCalendar.fromDate(DateTime(2025, 3, 1));

    // Umm al-Qura data and calendar calculation variants can differ by a
    // small number of days around month boundaries, so keep this tolerant.
    expect(hijriDate.hMonth, anyOf(8, 9));
    expect(hijriDate.hYear, anyOf(1446, 1447));
  });

  test('applies the day offset before converting to the Hijri calendar', () {
    final service = HijriService(clock: () => DateTime(2025, 3, 1));

    final currentDate = service.today();
    final nextDate = service.today(offsetDays: 1);

    final changed =
        currentDate.hDay != nextDate.hDay ||
        currentDate.hMonth != nextDate.hMonth ||
        currentDate.hYear != nextDate.hYear;
    expect(changed, isTrue);
    expect(currentDate.monthNameKey, 'hijriMonth${currentDate.hMonth}');
    expect(nextDate.monthNameKey, 'hijriMonth${nextDate.hMonth}');
  });
}
