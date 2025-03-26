import 'package:islamic_calendar/hijriah_helper/hijri_date.dart';

class HijriDateManager {
  /// Generates the Hijri calendar for a given [islamicYear] and [islamicMonth].
  /// Returns a list of weeks, where each week contains seven [HijriDate] objects.
  /// Empty days are represented as `HijriDate(day: 0, month: "", year: 0)`.
  static Future<List<List<HijriDate>>> generateHijriCalendar(int islamicYear, String islamicMonth) async {
    List<HijriDateData> hijriDates = await HijriDate.getHijriList();

    /// Find the HijriDateData for the requested month and year.
    HijriDateData? hijriData = hijriDates.firstWhere((date) => date.islamicMonth == islamicMonth && date.islamicYear == islamicYear,
    orElse: () => throw Exception('Month and year not found'),);

    DateTime start = hijriData.gregorianStartDate;
    int totalDays = hijriData.islamicTotalDates;
    int startWeekday = start.weekday; // 1 = Monday, 7 = Sunday

    List<List<HijriDate>> calendar = [];
    List<HijriDate> week = List.filled(7, HijriDate(day: 0, month: "", year: 0));
    int dayCounter = 1;

    /// Fill the first week with the initial days of the month.
    for (int i = startWeekday - 1; i < 7; i++) {
      week[i] = HijriDate(day: dayCounter, month: hijriData.islamicMonth, year: hijriData.islamicYear);
      dayCounter++;
    }
    calendar.add(List.from(week));

    /// Fill the remaining weeks.
    while (dayCounter <= totalDays) {
      week = [];
      for (int i = 0; i < 7; i++) {
        if (dayCounter <= totalDays) {
          week.add(HijriDate(day: dayCounter, month: hijriData.islamicMonth, year: hijriData.islamicYear));
          dayCounter++;
        } else {
          week.add(HijriDate(day: 0, month: "", year:  0));
        }
      }
      calendar.add(List.from(week));
    }

    return calendar;
  }

  /// Returns the Hijri events for a given month and year.
  static Future<List<HijriEvent>> getEventForMonth(String islamicMonth, int islamicYear) async {
    List<HijriEvent> hijriEvents = await HijriDate.getEventList();
    return hijriEvents.where((event) => event.islamicMonth == islamicMonth && event.islamicYear == islamicYear).toList();
  }

  /// Prints the full Hijri calendar for a given [islamicYear].
  /// Iterates through each month, generates its calendar, and prints it.
  static Future<void> printFullHijriCalendar(int islamicYear) async {
    List<HijriDateData> hijriDates = await HijriDate.getHijriList();
    List<String> m = hijriDates.map((e) => e.islamicMonth,).toList();
    for (String month in m) {
      print("\n$month $islamicYear H");
      List<List<HijriDate>> calendar = await generateHijriCalendar(islamicYear, month);
      for (var week in calendar) {
        print(week.map((day) => day.day == 0 ? "" : day.day, ).toList());
      }
    }
  }
}


