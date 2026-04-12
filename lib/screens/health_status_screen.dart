import 'package:flutter/material.dart';

class HealthStatusScreen extends StatelessWidget {
  const HealthStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Health Dashboard")),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ❤️ TOP SUMMARY CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0D9488), Color(0xFF14B8A6)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Overall Health",
                          style: TextStyle(color: Colors.white)),
                      SizedBox(height: 5),
                      Text("Good 😊",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ],
                  ),
                  Icon(Icons.favorite, color: Colors.white, size: 40)
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 📊 STATS GRID
            Row(
              children: [
                Expanded(child: _healthCard("Heart Rate", "72 bpm", Icons.favorite)),
                const SizedBox(width: 10),
                Expanded(child: _healthCard("Steps", "5200", Icons.directions_walk)),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(child: _healthCard("Calories", "350 kcal", Icons.local_fire_department)),
                const SizedBox(width: 10),
                Expanded(child: _healthCard("Hydration", "1.5 L", Icons.water_drop)),
              ],
            ),

            const SizedBox(height: 25),

            // 🧠 FATIGUE LEVEL
            _progressCard("Fatigue Level", 0.3, Colors.green),

            const SizedBox(height: 15),

            _progressCard("Stress Level", 0.5, Colors.orange),

            const SizedBox(height: 25),

            // 💡 HEALTH TIPS
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("💡 Health Tips",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 10),
                  Text("• Drink water regularly 💧"),
                  Text("• Take short breaks ⏱️"),
                  Text("• Avoid long continuous driving 🚚"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 📊 CARD
  Widget _healthCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8)
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF0D9488), size: 30),
          const SizedBox(height: 5),
          Text(title),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  // 📈 PROGRESS BAR
  Widget _progressCard(String title, double value, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: value,
            color: color,
            backgroundColor: Colors.grey.shade200,
          ),
        ],
      ),
    );
  }
}