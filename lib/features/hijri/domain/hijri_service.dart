import 'package:hijri/hijri_calendar.dart';

class HijriDate {
  const HijriDate({
    required this.hDay,
    required this.hMonth,
    required this.hYear,
    required this.monthNameKey,
  });

  final int hDay;
  final int hMonth;
  final int hYear;
  final String monthNameKey;
}

class HijriService {
  HijriService({DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;

  HijriDate today({int offsetDays = 0}) {
    final gregorianDate = _clock().add(Duration(days: offsetDays));
    final hijriDate = HijriCalendar.fromDate(gregorianDate);

    return HijriDate(
      hDay: hijriDate.hDay,
      hMonth: hijriDate.hMonth,
      hYear: hijriDate.hYear,
      monthNameKey: 'hijriMonth${hijriDate.hMonth}',
    );
  }
}
