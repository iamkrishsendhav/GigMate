import 'dart:async';
import 'package:flutter/material.dart';

class BreakReminderScreen extends StatefulWidget {
  const BreakReminderScreen({super.key});

  @override
  State<BreakReminderScreen> createState() => _BreakReminderScreenState();
}

class _BreakReminderScreenState extends State<BreakReminderScreen> {
  int secondsWorked = 0;
  Timer? timer;
  bool isWorking = false;

  // ⏰ 10 sec for testing (change to 7200 for 2 hours)
  final int breakTime = 10;

  void startWork() {
    isWorking = true;

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        secondsWorked++;
      });

      if (secondsWorked == breakTime) {
        showBreakDialog();
      }
    });
  }

  void stopWork() {
    timer?.cancel();
    setState(() {
      isWorking = false;
      secondsWorked = 0;
    });
  }

  void showBreakDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("⏱ Break Time!"),
        content: const Text("You have been working for long time.\nTake a break!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              stopWork();
            },
            child: const Text("Take Break"),
          ),
        ],
      ),
    );
  }

  String formatTime(int seconds) {
    int mins = seconds ~/ 60;
    int secs = seconds % 60;
    return "$mins:${secs.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Break Reminder")),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ⏱ TIMER CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF14B8A6), Color(0xFF0D9488)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text("Work Time",
                      style: TextStyle(color: Colors.white)),
                  const SizedBox(height: 10),
                  Text(
                    formatTime(secondsWorked),
                    style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ▶️ START BUTTON
            ElevatedButton(
              onPressed: isWorking ? null : startWork,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Start Work"),
            ),

            const SizedBox(height: 10),

            // ⏹ STOP BUTTON
            ElevatedButton(
              onPressed: isWorking ? stopWork : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Stop Work"),
            ),

            const SizedBox(height: 30),

            // 💡 INFO CARD
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 8)
                ],
              ),
              child: const Column(
                children: [
                  Text("💡 Health Tip",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Text(
                    "Take a short break every 2 hours to stay productive and healthy.",
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}