import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:islamic_calendar/hijriah_helper/hijri_date.dart';
import 'package:islamic_calendar/hijriah_helper/hijri_date_manager.dart';

class Maincontroller extends GetxController {

  @override
  void onInit() {
    super.onInit();

    loadHijriDate();
    
  }

  void loadHijriDate() async {
    HijriDate todayHijri = await HijriDate.fromGregorian(DateTime(2024, 7, 7));
    print("Today Hijri Date: $todayHijri");
    List<HijriEvent> events = await HijriDateManager.getEventForMonth("Ramadhan", 1446);
    for (var event in events) {
      print(
          "${event.name} on ${event.islamicDay} ${event.islamicMonth} ${event.islamicYear} H");
    }
  }
}