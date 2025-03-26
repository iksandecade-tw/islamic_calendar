import 'dart:convert';

import 'package:flutter/services.dart';

class HijriDate {
  int day;
  String month;
  int year;

  /// Stores the loaded Hijri data to avoid reloading [_loadHijriDates] multiple times.
  static List<HijriDateData> _cachedHijriDates = [];
  static List<HijriEvent> _cachedHijriEvents = [];
  
  /// Returns the Hijri data, loading it only once from [_loadHijriDates].
  static Future<List<HijriDateData>> get _hijriDates async {
    /// If the cache is empty, load the Hijri data.
    if (_cachedHijriDates.isEmpty) {
      _cachedHijriDates = await _loadHijriDates();
    }
    return _cachedHijriDates;
  }

  /// Returns the Hijri events, loading them only once.
  static Future<List<HijriEvent>> get _hijriEvents async {
    if (_cachedHijriEvents.isEmpty) {
      _cachedHijriEvents = await _loadHijriEvents();
    }
    return _cachedHijriEvents;
  }


  HijriDate({required this.day, required this.month, required this.year});

  /// Returns the loaded Hijri data as a public method.
  static Future<List<HijriDateData>> getHijriList() async {
    return await _hijriDates;
  }

  /// Returns the loaded Hijri data as a public method.
  static Future<List<HijriEvent>> getEventList() async {
    return await _hijriEvents;
  }

  /// Returns the Hijri date corresponding to today's Gregorian date.
  static Future<HijriDate> today() {
    return HijriDate.fromGregorian(DateTime.now());
  }

  /// Converts a Gregorian date to a Hijri date.
  static Future<HijriDate> fromGregorian(DateTime gregorianDate) async {
    List<HijriDateData> hijriDates = await _hijriDates;
    for (var hijriDate in hijriDates) {
      /// Get the starting Gregorian date for the Hijri month.
      DateTime start = hijriDate.gregorianStartDate;
      /// Calculate the last Gregorian date of the Hijri month.
      /// Subtracting 1 ensures that if the month has 29 days, the last day is 29, not 30.
      DateTime end = start.add(Duration(days: hijriDate.islamicTotalDates - 1));

      /// Check if the given Gregorian date falls within the Hijri month range.
      if (gregorianDate.isAfter(start.subtract(const Duration(days: 1))) && gregorianDate.isBefore(end.add(const Duration(days: 1)))) {
        /// Calculate the Hijri day by finding the difference from the start date.
        int hijriDay = gregorianDate.difference(start).inDays + 1;
        return HijriDate(day: hijriDay, month: hijriDate.islamicMonth, year: hijriDate.islamicYear);
      }
    }
    throw Exception("Gregorian date not found in Hijri mapping");
  }

  /// Converts the Hijri date to a corresponding Gregorian date.
  Future<DateTime> toGregorian() async {
    List<HijriDateData> hijriDates = await _hijriDates;
    
    /// Find the HijriDateData entry that matches the month and year.
    HijriDateData? hijriDate = hijriDates.firstWhere((date) => date.islamicMonth == month && date.islamicYear == year,
    orElse: () => throw Exception("Month and year not found"),);

    /// Find the HijriDateData entry that matches the month and year.
    if (day < 1 || day > hijriDate.islamicTotalDates) {
      throw Exception("Invalid Hijri day");
    }

    /// Calculate the Gregorian equivalent by adding the Hijri day offset to the start date.
    return hijriDate.gregorianStartDate.add(Duration(days: day - 1));
  }

  /// Overrides [toString] to return a formatted Hijri date string.
  @override
  String toString() {
    return "$day $month $year H";
  }

  /// Loads Hijri data from a local asset file.
  /// Future enhancement: Add API support for dynamic updates.
  static Future<List<HijriDateData>> _loadHijriDates()  async {
    /// Load JSON data from the local assets folder.
    String data = await rootBundle.loadString("assets/data.json");
    /// Decode the JSON data into a Dart map.
    final Map<String, dynamic> jsonDataMap = json.decode(data);
    /// Extract the list of Hijri years from the JSON data.
    final List<dynamic> yearsData = jsonDataMap["data"];
    List<HijriDateData> allDates = [];

     /// Iterate through each Hijri year and parse the month data.
    for (var yearData in yearsData) {
      int year = int.parse(yearData['islamic_year'].replaceAll('H', ''));
      final hijriData = yearData['data'] as List;
      allDates.addAll(hijriData.map((e) => HijriDateData.fromJson(e, year)));
    }

    return allDates;
  }

  /// Loads Hijri events from a local asset file.
  static Future<List<HijriEvent>> _loadHijriEvents() async {
    String data = await rootBundle.loadString("assets/data.json");
    final Map<String, dynamic> jsonDataMap = json.decode(data);
    final List<dynamic> yearsData = jsonDataMap["data"];
    List<HijriEvent> allEvents = [];

    for (var yearData in yearsData) {
      int year = int.parse(yearData['islamic_year'].replaceAll('H', ''));
      final List<dynamic> events = yearData['events'] ?? [];
      allEvents.addAll(events.map((e) => HijriEvent.fromJson(e, year)));
    }

    return allEvents;
  }
}

class HijriDateData {
  final String islamicMonth;
  final int islamicTotalDates;
  final DateTime gregorianStartDate;
  final int islamicYear;

  HijriDateData({required this.islamicMonth, required this.islamicTotalDates, required this.gregorianStartDate, required this.islamicYear});

  factory HijriDateData.fromJson(Map<String, dynamic> json, int year) {
    return HijriDateData(
      islamicMonth: json["islamic_month"], 
      islamicTotalDates: json["islamic_total_dates"], 
      gregorianStartDate: DateTime(
        json["gregorian_start_date"]["year"],
        json["gregorian_start_date"]["month"],
        json["gregorian_start_date"]["date"]), 
        islamicYear: year);
  }
}

class HijriEvent {
  final String name;
  final String islamicMonth;
  final int islamicDay;
  final int islamicYear;

  HijriEvent({
    required this.name,
    required this.islamicMonth,
    required this.islamicDay,
    required this.islamicYear,
  });

  factory HijriEvent.fromJson(Map<String, dynamic> json, int year) {
    final List<String> islamicDateParts = json['islamic_dates'].split(' ');
    return HijriEvent(
      name: json['event'] ?? json['events'],
      islamicMonth: islamicDateParts[1],
      islamicDay: int.parse(islamicDateParts[0]),
      islamicYear: year,
    );
  }
}