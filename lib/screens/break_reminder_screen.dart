import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/worker_wellness_service.dart';

class BreakReminderScreen extends StatefulWidget {
  const BreakReminderScreen({super.key});

  @override
  State<BreakReminderScreen> createState() => _BreakReminderScreenState();
}

class _BreakReminderScreenState extends State<BreakReminderScreen> {
  static const _primary = Color(0xFF0F766E);
  static const _bg = Color(0xFFF1F5F9);
  static const _textDark = Color(0xFF0F172A);
  static const _textMid = Color(0xFF64748B);
  static const _green = Color(0xFF10B981);
  static const _amber = Color(0xFFF59E0B);

  static const int _workGoalSeconds = 90 * 60;
  static const int _breakGoalSeconds = 300;

  final _wellnessService = WorkerWellnessService();
  Timer? _clockTimer;
  bool _breakPromptShown = false;
  bool _hydrated = false;
  bool _stretched = false;
  bool _eyesRested = false;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _startShift(WorkerWellnessSnapshot wellness) async {
    final uid = _uid;
    if (uid == null) return;
    await _wellnessService.startShift(uid, wellness);
    setState(() {
      _breakPromptShown = false;
      _hydrated = false;
      _stretched = false;
      _eyesRested = false;
    });
  }

  Future<void> _pauseShift(WorkerWellnessSnapshot wellness) async {
    final uid = _uid;
    if (uid == null) return;
    await _wellnessService.pauseShift(uid, wellness);
  }

  Future<void> _startBreak(WorkerWellnessSnapshot wellness) async {
    final uid = _uid;
    if (uid == null) return;
    _breakPromptShown = false;
    await _wellnessService.startBreak(uid, wellness);
    setState(() {
      _hydrated = false;
      _stretched = false;
      _eyesRested = false;
    });
  }

  Future<void> _finishBreak(WorkerWellnessSnapshot wellness) async {
    final uid = _uid;
    if (uid == null) return;
    await _wellnessService.finishBreak(uid, wellness);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Break completed. You are ready for the next run.'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _primary,
      ),
    );
  }

  void _showBreakDialog(WorkerWellnessSnapshot wellness) {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(22, 10, 22, 28),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  _iconBox(Icons.coffee_rounded, _amber),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Break recommended',
                          style: TextStyle(
                            color: _textDark,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Fatigue risk is rising. Take a short reset before continuing.',
                          style: TextStyle(color: _textMid, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _startBreak(wellness);
                  },
                  icon: const Icon(Icons.timer_rounded),
                  label: const Text('Start 5 min break'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = _uid;
    if (uid == null) {
      return const Scaffold(
        backgroundColor: _bg,
        body: Center(child: Text('Please login to continue')),
      );
    }

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: _textDark,
        title: const Text(
          'Break Planner',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<WorkerWellnessSnapshot>(
        stream: _wellnessService.stream(uid),
        builder: (context, snapshot) {
          final wellness = snapshot.data ?? WorkerWellnessSnapshot.empty();
          final progress = wellness.isOnBreak
              ? (wellness.currentBreakSeconds / _breakGoalSeconds)
                  .clamp(0.0, 1.0)
                  .toDouble()
              : (wellness.workedSeconds / _workGoalSeconds)
                  .clamp(0.0, 1.0)
                  .toDouble();
          final status = wellness.isOnBreak
              ? 'Recovery break'
              : wellness.isShiftRunning
                  ? 'Shift active'
                  : 'Ready to start';
          final time = wellness.isOnBreak
              ? _formatTime(wellness.currentBreakSeconds)
              : _formatTime(wellness.workedSeconds);

          if (!_breakPromptShown &&
              !wellness.isOnBreak &&
              wellness.isShiftRunning &&
              wellness.workedSeconds >= _workGoalSeconds) {
            _breakPromptShown = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _showBreakDialog(wellness);
            });
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            children: [
              _heroCard(
                wellness: wellness,
                status: status,
                time: time,
                progress: progress,
              ),
              const SizedBox(height: 16),
              _statsGrid(wellness),
              const SizedBox(height: 16),
              _breakPlanCard(),
              const SizedBox(height: 16),
              _readinessCard(),
              const SizedBox(height: 16),
              _tipCard(),
            ],
          );
        },
      ),
    );
  }

  Widget _heroCard({
    required WorkerWellnessSnapshot wellness,
    required String status,
    required String time,
    required double progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.22),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _softIcon(
                wellness.isOnBreak
                    ? Icons.spa_rounded
                    : Icons.delivery_dining_rounded,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      wellness.isOnBreak
                          ? 'Break timer keeps running until you finish it.'
                          : 'Track active time and prevent fatigue.',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 210,
                height: 210,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 13,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                children: [
                  Text(
                    time,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    wellness.isOnBreak ? 'break taken' : 'worked today',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: wellness.isOnBreak
                      ? () => _finishBreak(wellness)
                      : wellness.isShiftRunning
                          ? () => _pauseShift(wellness)
                          : () => _startShift(wellness),
                  icon: Icon(
                    wellness.isOnBreak
                        ? Icons.check_rounded
                        : wellness.isShiftRunning
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                  ),
                  label: Text(
                    wellness.isOnBreak
                        ? 'Finish break'
                        : wellness.isShiftRunning
                            ? 'Pause shift'
                            : 'Start shift',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: _primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              if (!wellness.isOnBreak)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _startBreak(wellness),
                    icon: const Icon(Icons.coffee_rounded),
                    label: const Text('Take break'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statsGrid(WorkerWellnessSnapshot wellness) {
    final breakMinutes = (wellness.totalBreakSeconds / 60).round();
    final fatigue = wellness.workedSeconds >= _workGoalSeconds ? 'High' : 'Low';
    return Row(
      children: [
        Expanded(
          child: _statCard(
              Icons.local_fire_department_rounded, 'Fatigue', fatigue),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            Icons.water_drop_rounded,
            'Hydration',
            '${(wellness.loggedWaterMl / 1000).toStringAsFixed(1)} L',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            Icons.coffee_rounded,
            'Break',
            breakMinutes == 0 ? '0m' : '${breakMinutes}m',
          ),
        ),
      ],
    );
  }

  Widget _breakPlanCard() {
    return _sectionCard(
      title: 'Recommended break plan',
      child: Column(
        children: [
          _planTile(
              Icons.air_rounded, '1 min breathing', 'Slow breathing reset'),
          _planTile(Icons.directions_walk_rounded, '2 min walk',
              'Relax legs and back'),
          _planTile(Icons.water_drop_outlined, 'Hydrate',
              'Drink water before next order'),
        ],
      ),
    );
  }

  Widget _readinessCard() {
    return _sectionCard(
      title: 'Resume checklist',
      trailing: Text(
        '${[
          _hydrated,
          _stretched,
          _eyesRested
        ].where((v) => v).length}/3 ready',
        style: const TextStyle(
          color: _primary,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
      child: Column(
        children: [
          _checkTile(
            value: _hydrated,
            title: 'Water taken',
            icon: Icons.water_drop_rounded,
            onChanged: (value) => setState(() => _hydrated = value),
          ),
          _checkTile(
            value: _stretched,
            title: 'Quick stretch done',
            icon: Icons.accessibility_new_rounded,
            onChanged: (value) => setState(() => _stretched = value),
          ),
          _checkTile(
            value: _eyesRested,
            title: 'Eyes rested',
            icon: Icons.visibility_rounded,
            onChanged: (value) => setState(() => _eyesRested = value),
          ),
        ],
      ),
    );
  }

  Widget _tipCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: const Row(
        children: [
          Icon(Icons.lightbulb_rounded, color: _amber),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'A short break every 90-120 minutes improves alertness and route safety.',
              style: TextStyle(color: Color(0xFF92400E), height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: _textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _statCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, color: _primary, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _textDark,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: _textMid, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _planTile(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          _iconBox(icon, _primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _textDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: _textMid, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _checkTile({
    required bool value,
    required String title,
    required IconData icon,
    required ValueChanged<bool> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            _iconBox(icon, value ? _green : _textMid),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: _textDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Checkbox(
              value: value,
              activeColor: _primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              onChanged: (newValue) => onChanged(newValue ?? false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconBox(IconData icon, Color color) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withOpacity(0.11),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: color, size: 21),
    );
  }

  Widget _softIcon(IconData icon) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Icon(icon, color: Colors.white, size: 26),
    );
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${secs.toString().padLeft(2, '0')}';
  }
}
