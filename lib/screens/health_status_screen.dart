import 'package:flutter/material.dart';
import 'dart:async';

class HealthStatusScreen extends StatefulWidget {
  const HealthStatusScreen({super.key});

  @override
  State<HealthStatusScreen> createState() => _HealthStatusScreenState();
}

class _HealthStatusScreenState extends State<HealthStatusScreen>
    with SingleTickerProviderStateMixin {

  double heartRate = 70;
  int steps = 4500;
  double hydration = 1.2;
  double fatigue = 0.3;
  double stress = 0.4;

  late Timer timer;

  @override
  void initState() {
    super.initState();

    /// 🔥 LIVE SIMULATION
    timer = Timer.periodic(Duration(seconds: 2), (_) {
      setState(() {
        heartRate += (2 - (4 * (DateTime.now().second % 2)));
        steps += 50;
        hydration += 0.01;
        fatigue += 0.01;
        stress += 0.01;

        if (fatigue > 1) fatigue = 0.2;
        if (stress > 1) stress = 0.3;
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  /// 🔥 HEALTH SCORE LOGIC
  String get healthStatus {
    if (fatigue < 0.4 && stress < 0.5) return "Excellent 💪";
    if (fatigue < 0.7) return "Good 🙂";
    return "Warning ⚠️";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F7FB),

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text("Health Dashboard"),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [

            /// 🔥 TOP CARD
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Overall Health",
                          style: TextStyle(color: Colors.white)),
                      SizedBox(height: 5),
                      Text(healthStatus,
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ],
                  ),
                  Icon(Icons.favorite, color: Colors.white, size: 40)
                ],
              ),
            ),

            SizedBox(height: 20),

            /// 🔥 STATS GRID
            LayoutBuilder(
              builder: (context, constraints) {
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _statCard("Heart Rate", "${heartRate.toInt()} bpm",
                        Icons.favorite),
                    _statCard("Steps", "$steps", Icons.directions_walk),
                    _statCard("Hydration", "${hydration.toStringAsFixed(2)} L",
                        Icons.water_drop),
                    _statCard("Calories", "420 kcal",
                        Icons.local_fire_department),
                  ],
                );
              },
            ),

            SizedBox(height: 25),

            /// 🔥 FATIGUE
            _progressCard("Fatigue Level", fatigue, Colors.green),

            SizedBox(height: 15),

            /// 🔥 STRESS
            _progressCard("Stress Level", stress, Colors.orange),

            SizedBox(height: 25),

            /// 🔥 BREAK ALERT
            if (fatigue > 0.7)
              _alertCard("⚠️ Take a break!", "You are getting tired"),

            SizedBox(height: 15),

            /// 🔥 WATER ALERT
            if (hydration < 1.5)
              _alertCard("💧 Drink Water", "Stay hydrated"),

            SizedBox(height: 25),

            /// 🔥 HEALTH TIPS
            _tipsCard(),
          ],
        ),
      ),
    );
  }

  /// 🔥 STAT CARD
  Widget _statCard(String title, String value, IconData icon) {
    return Container(
      width: MediaQuery.of(context).size.width / 2 - 22,
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        children: [
          Icon(icon, color: Color(0xFF0F766E), size: 30),
          SizedBox(height: 5),
          Text(title),
          Text(value,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  /// 🔥 PROGRESS CARD
  Widget _progressCard(String title, double value, Color color) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              color: color,
              backgroundColor: Colors.grey.shade200,
            ),
          ),
        ],
      ),
    );
  }

  /// 🔥 ALERT CARD
  Widget _alertCard(String title, String subtitle) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: Colors.red),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
              Text(subtitle),
            ],
          )
        ],
      ),
    );
  }

  /// 🔥 TIPS
  Widget _tipsCard() {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("💡 Smart Health Tips",
              style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text("• Take a break every 2 hours"),
          Text("• Drink at least 2L water"),
          Text("• Avoid long continuous driving"),
        ],
      ),
    );
  }
}