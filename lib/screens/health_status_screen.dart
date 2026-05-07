import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HealthStatusScreen extends StatefulWidget {
  const HealthStatusScreen({super.key});

  @override
  State<HealthStatusScreen> createState() => _HealthStatusScreenState();
}

class _HealthStatusScreenState extends State<HealthStatusScreen> {
  static const _primary = Color(0xFF0F766E);
  static const _bg = Color(0xFFF4F7FB);
  static const _textDark = Color(0xFF0F172A);
  static const _textMid = Color(0xFF475569);
  static const _textLight = Color(0xFF94A3B8);
  static const _green = Color(0xFF10B981);
  static const _amber = Color(0xFFF59E0B);
  static const _red = Color(0xFFEF4444);
  static const _blue = Color(0xFF3B82F6);

  final _random = Random();
  Timer? _timer;

  double heartRate = 74;
  int steps = 4700;
  double hydration = 1.24;
  double fatigue = 0.34;
  double stress = 0.28;
  double sleepHours = 6.8;
  double activeHours = 1.75;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      setState(() {
        heartRate =
            (heartRate + _random.nextInt(5) - 2).clamp(62, 104).toDouble();
        steps += 35 + _random.nextInt(45);
        hydration = (hydration + 0.015).clamp(0.8, 3.2).toDouble();
        fatigue = (fatigue + 0.015).clamp(0.12, 0.92).toDouble();
        stress = (stress + (_random.nextBool() ? 0.01 : -0.01))
            .clamp(0.12, 0.88)
            .toDouble();
        activeHours = (activeHours + 0.02).clamp(0.2, 8.5).toDouble();
      });
      _syncHealthSnapshot();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  int get score {
    final fatigueScore = (1 - fatigue) * 35;
    final stressScore = (1 - stress) * 25;
    final hydrationScore = (hydration / 2.5).clamp(0, 1) * 20;
    final movementScore = (steps / 8000).clamp(0, 1) * 20;
    return (fatigueScore + stressScore + hydrationScore + movementScore).round();
  }

  String get status {
    if (score >= 82) return 'Excellent';
    if (score >= 68) return 'Good';
    if (score >= 52) return 'Monitor';
    return 'Needs break';
  }

  Color get statusColor {
    if (score >= 82) return _green;
    if (score >= 68) return _primary;
    if (score >= 52) return _amber;
    return _red;
  }

  Future<void> _syncHealthSnapshot() async {
    final uid = _uid;
    if (uid == null) return;
    await FirebaseFirestore.instance.collection('workers').doc(uid).set({
      'health': status,
      'healthScore': score,
      'heartRate': heartRate.round(),
      'steps': steps,
      'hydration': hydration,
      'fatigue': fatigue,
      'stress': stress,
      'activeHours': activeHours,
      'healthUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 900;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _textDark,
        elevation: 0,
        title: const Text('Health Dashboard',
            style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          IconButton(
            tooltip: 'Log water',
            onPressed: () => setState(() =>
                hydration = (hydration + 0.25).clamp(0.8, 3.5).toDouble()),
            icon: const Icon(Icons.water_drop_outlined),
          ),
          IconButton(
            tooltip: 'Start break',
            onPressed: _startBreak,
            icon: const Icon(Icons.self_improvement_rounded),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isWide ? 24 : 16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1180),
            child: Column(
              children: [
                _heroCard(),
                const SizedBox(height: 16),
                _metricsGrid(isWide),
                const SizedBox(height: 16),
                isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _readinessCard()),
                          const SizedBox(width: 16),
                          Expanded(child: _recommendationsCard()),
                        ],
                      )
                    : Column(
                        children: [
                          _readinessCard(),
                          const SizedBox(height: 16),
                          _recommendationsCard(),
                        ],
                      ),
                const SizedBox(height: 16),
                _alertsCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _heroCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Overall Health',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 8),
                Text(status,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: score / 100,
                    minHeight: 9,
                    color: Colors.white,
                    backgroundColor: Colors.white24,
                  ),
                ),
                const SizedBox(height: 8),
                Text('$score/100 readiness score',
                    style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.favorite_rounded,
                color: Colors.white, size: 42),
          ),
        ],
      ),
    );
  }

  Widget _metricsGrid(bool isWide) {
    final cards = [
      _Metric('Heart Rate', '${heartRate.round()} bpm', 'Normal range',
          Icons.favorite_rounded, _red),
      _Metric('Steps', '$steps', 'Goal 8,000', Icons.directions_walk_rounded,
          _primary),
      _Metric('Hydration', '${hydration.toStringAsFixed(2)} L', 'Goal 2.5 L',
          Icons.water_drop_rounded, _blue),
      _Metric('Calories', '${(steps * 0.045).round()} kcal', 'Estimated burn',
          Icons.local_fire_department_rounded, _amber),
      _Metric('Active Time', '${activeHours.toStringAsFixed(1)} h',
          'Today online', Icons.timer_rounded, _primary),
      _Metric('Sleep', '${sleepHours.toStringAsFixed(1)} h', 'Last night',
          Icons.bedtime_rounded, _blue),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isWide ? 3 : 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: isWide ? 2.2 : 1.45,
      ),
      itemBuilder: (_, index) => _metricCard(cards[index]),
    );
  }

  Widget _metricCard(_Metric metric) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(color: Color(0x07000000), blurRadius: 14, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: metric.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(metric.icon, color: metric.color, size: 22),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(metric.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _textMid, fontSize: 12)),
              const SizedBox(height: 4),
              Text(metric.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: _textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.w900)),
              Text(metric.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _textLight, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _readinessCard() {
    return _card(
      title: 'Fatigue & Stress',
      icon: Icons.monitor_heart_rounded,
      child: Column(
        children: [
          _progressRow('Fatigue', fatigue, fatigue > 0.7 ? _red : _green),
          const SizedBox(height: 14),
          _progressRow('Stress', stress, stress > 0.65 ? _red : _amber),
          const SizedBox(height: 14),
          _progressRow(
              'Hydration goal', (hydration / 2.5).clamp(0, 1).toDouble(), _blue),
        ],
      ),
    );
  }

  Widget _recommendationsCard() {
    final tips = [
      _Tip(Icons.water_drop_rounded, 'Hydration', hydration < 1.8
          ? 'Drink 250 ml water before the next delivery.'
          : 'Hydration is on track. Keep sipping.'),
      _Tip(Icons.self_improvement_rounded, 'Break plan', fatigue > 0.65
          ? 'Take a 10 minute recovery break now.'
          : 'Plan a short break after the next route.'),
      _Tip(Icons.route_rounded, 'Route safety',
          'Avoid continuous riding beyond 2 hours without pause.'),
    ];

    return _card(
      title: 'Smart Recommendations',
      icon: Icons.auto_awesome_rounded,
      child: Column(
        children: tips
            .map((tip) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: _primary.withOpacity(0.1),
                    child: Icon(tip.icon, color: _primary, size: 20),
                  ),
                  title: Text(tip.title,
                      style: const TextStyle(fontWeight: FontWeight.w900)),
                  subtitle: Text(tip.text,
                      style: const TextStyle(color: _textMid, fontSize: 12)),
                ))
            .toList(),
      ),
    );
  }

  Widget _alertsCard() {
    final alerts = <_Tip>[];
    if (fatigue > 0.7) {
      alerts.add(const _Tip(Icons.warning_rounded, 'Fatigue alert',
          'High fatigue detected. Pause assignments and recover.'));
    }
    if (hydration < 1.5) {
      alerts.add(const _Tip(Icons.water_drop_rounded, 'Hydration alert',
          'Water intake is low for today.'));
    }
    if (heartRate > 96) {
      alerts.add(const _Tip(Icons.favorite_rounded, 'Heart rate alert',
          'Heart rate is elevated. Slow down and breathe.'));
    }

    return _card(
      title: 'Live Safety Alerts',
      icon: Icons.health_and_safety_rounded,
      child: alerts.isEmpty
          ? const Text('No critical alerts. You are clear for assignments.',
              style: TextStyle(color: _textMid))
          : Column(
              children: alerts
                  .map((alert) => _alertRow(alert.title, alert.text))
                  .toList(),
            ),
    );
  }

  Widget _card({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _primary, size: 20),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      color: _textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _progressRow(String title, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(title,
                  style: const TextStyle(
                      color: _textMid, fontWeight: FontWeight.w800)),
            ),
            Text('${(value * 100).round()}%',
                style: const TextStyle(
                    color: _textDark, fontWeight: FontWeight.w900)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: value.clamp(0, 1).toDouble(),
            minHeight: 9,
            color: color,
            backgroundColor: const Color(0xFFE2E8F0),
          ),
        ),
      ],
    );
  }

  Widget _alertRow(String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _red.withOpacity(0.16)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_rounded, color: _red),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: _textDark, fontWeight: FontWeight.w900)),
                Text(subtitle,
                    style: const TextStyle(color: _textMid, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _startBreak() {
    setState(() {
      fatigue = max(0.12, fatigue - 0.18);
      stress = max(0.12, stress - 0.12);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recovery break logged')),
    );
    _syncHealthSnapshot();
  }
}

class _Metric {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _Metric(this.title, this.value, this.subtitle, this.icon, this.color);
}

class _Tip {
  final IconData icon;
  final String title;
  final String text;

  const _Tip(this.icon, this.title, this.text);
}
