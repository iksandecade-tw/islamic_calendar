import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:islamic_calendar/main_ctrl.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  final controller = Get.put(Maincontroller());
  MainApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: InkWell(
            onTap: () => controller.loadHijriDate(),
            child: const Text('Hello World!')),
        ),
      ),
    );
  }
}
