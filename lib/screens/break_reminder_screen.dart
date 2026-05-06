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

  // ⏰ Testing ke liye 30 sec (Real app mein 7200 seconds for 2 hours)
  final int breakGoalSeconds = 30;

  void startWork() {
    setState(() => isWorking = true);
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        secondsWorked++;
      });

      if (secondsWorked >= breakGoalSeconds) {
        timer.cancel();
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
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      pageBuilder: (ctx, a1, a2) => Container(),
      transitionBuilder: (ctx, a1, a2, child) {
        return Transform.scale(
          scale: a1.value,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            title: const Row(
              children: [
                Icon(Icons.timer_outlined, color: Color(0xFF0F766E)),
                SizedBox(width: 10),
                Text("Time for a Break!"),
              ],
            ),
            content: const Text(
              "You've been active for a while. Refresh your mind to stay safe on the road.",
              style: TextStyle(color: Colors.black54),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F766E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  stopWork();
                },
                child: const Text("I'm Taking a Break", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }

  String formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int mins = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;
    return "${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double progress = secondsWorked / breakGoalSeconds;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: const BackButton(color: Color(0xFF0F172A)),
        title: const Text("Shift Tracker", style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // --- PRO PROGRESS RING ---
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 240,
                      width: 240,
                      child: CircularProgressIndicator(
                        value: isWorking ? progress : 0,
                        strokeWidth: 12,
                        backgroundColor: Colors.grey.withOpacity(0.1),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF14B8A6)),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Column(
                      children: [
                        Icon(
                          isWorking ? Icons.directions_bike_rounded : Icons.pause_circle_filled_rounded,
                          size: 40,
                          color: const Color(0xFF0F766E),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          formatTime(secondsWorked),
                          style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w900, letterSpacing: 1),
                        ),
                        const Text("Shift Duration", style: TextStyle(color: Colors.black45, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // --- STATUS CARD ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(Icons.bolt, "Efficiency", "94%"),
                    Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.2)),
                    _buildStatItem(Icons.local_fire_department, "Target", "6h 30m"),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // --- ACTION BUTTONS ---
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: isWorking ? stopWork : startWork,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isWorking ? Colors.white : const Color(0xFF0F766E),
                    foregroundColor: isWorking ? Colors.red : Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: isWorking ? const BorderSide(color: Colors.red, width: 2) : BorderSide.none,
                    ),
                  ),
                  child: Text(
                    isWorking ? "STOP SHIFT" : "START NEW SHIFT",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1.2),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // --- HEALTH TIP SECTION ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0EA5E9).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF0EA5E9).withOpacity(0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lightbulb_rounded, color: Color(0xFF0EA5E9)),
                    SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        "Drink water and stretch your legs during your break to avoid fatigue.",
                        style: TextStyle(color: Color(0xFF0369A1), fontSize: 13, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF14B8A6)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(color: Colors.black38, fontSize: 12)),
      ],
    );
  }
}