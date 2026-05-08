import 'package:cloud_firestore/cloud_firestore.dart';

class WorkerWellnessSnapshot {
  final bool isShiftRunning;
  final bool isOnBreak;
  final DateTime? shiftStartedAt;
  final DateTime? breakStartedAt;
  final int shiftAccumulatedSeconds;
  final int lastBreakSeconds;
  final int savedTotalBreakSeconds;
  final int loggedWaterMl;
  final int manualSteps;
  final double sleepHours;
  final String healthStatus;
  final int healthScore;

  const WorkerWellnessSnapshot({
    required this.isShiftRunning,
    required this.isOnBreak,
    this.shiftStartedAt,
    this.breakStartedAt,
    required this.shiftAccumulatedSeconds,
    required this.lastBreakSeconds,
    required this.savedTotalBreakSeconds,
    required this.loggedWaterMl,
    required this.manualSteps,
    required this.sleepHours,
    required this.healthStatus,
    required this.healthScore,
  });

  factory WorkerWellnessSnapshot.empty() {
    return const WorkerWellnessSnapshot(
      isShiftRunning: false,
      isOnBreak: false,
      shiftAccumulatedSeconds: 0,
      lastBreakSeconds: 0,
      savedTotalBreakSeconds: 0,
      loggedWaterMl: 0,
      manualSteps: 0,
      sleepHours: 6.8,
      healthStatus: 'Good',
      healthScore: 72,
    );
  }

  factory WorkerWellnessSnapshot.fromWorkerData(Map<String, dynamic>? data) {
    final map = data ?? const <String, dynamic>{};
    final isShiftRunning = map['isShiftRunning'] == true;
    final isOnBreak = map['isOnBreak'] == true;
    final shiftStartedAt = _dateFrom(map['shiftStartedAt']);
    final breakStartedAt = _dateFrom(map['breakStartedAt']);
    final accumulatedWork = _intFrom(map['shiftAccumulatedSeconds']);
    final savedBreakTotal = _intFrom(map['totalBreakSecondsToday']);
    final savedBreak = _intFrom(map['lastBreakSeconds']);

    return WorkerWellnessSnapshot(
      isShiftRunning: isShiftRunning,
      isOnBreak: isOnBreak,
      shiftStartedAt: shiftStartedAt,
      breakStartedAt: breakStartedAt,
      shiftAccumulatedSeconds: accumulatedWork,
      lastBreakSeconds: savedBreak,
      savedTotalBreakSeconds: savedBreakTotal,
      loggedWaterMl: _intFrom(map['loggedWaterMl'] ?? map['waterMl']),
      manualSteps: _intFrom(map['manualSteps'] ?? map['steps']),
      sleepHours: _doubleFrom(map['sleepHours'], fallback: 6.8),
      healthStatus: (map['health'] ?? 'Good').toString(),
      healthScore: _intFrom(map['healthScore'], fallback: 72),
    );
  }

  int get workedSeconds {
    final runningWork = isShiftRunning && !isOnBreak && shiftStartedAt != null
        ? DateTime.now()
            .difference(shiftStartedAt!)
            .inSeconds
            .clamp(0, 86400)
            .toInt()
        : 0;
    return shiftAccumulatedSeconds + runningWork;
  }

  int get currentBreakSeconds {
    if (!isOnBreak || breakStartedAt == null) return lastBreakSeconds;
    return DateTime.now()
        .difference(breakStartedAt!)
        .inSeconds
        .clamp(0, 86400)
        .toInt();
  }

  int get totalBreakSeconds {
    return savedTotalBreakSeconds + (isOnBreak ? currentBreakSeconds : 0);
  }

  static DateTime? _dateFrom(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  static int _intFrom(dynamic value, {int fallback = 0}) {
    if (value is num) return value.round();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static double _doubleFrom(dynamic value, {double fallback = 0}) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }
}

class WorkerWellnessService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<WorkerWellnessSnapshot> stream(String uid) {
    return _db.collection('workers').doc(uid).snapshots().map(
          (doc) => WorkerWellnessSnapshot.fromWorkerData(doc.data()),
        );
  }

  Future<void> startShift(String uid, WorkerWellnessSnapshot current) {
    return _db.collection('workers').doc(uid).set({
      'isShiftRunning': true,
      'isOnBreak': false,
      'status': 'Active',
      'shiftStartedAt': FieldValue.serverTimestamp(),
      'breakStartedAt': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> pauseShift(String uid, WorkerWellnessSnapshot current) {
    return _db.collection('workers').doc(uid).set({
      'isShiftRunning': false,
      'shiftAccumulatedSeconds': current.workedSeconds,
      'shiftStartedAt': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> startBreak(String uid, WorkerWellnessSnapshot current) {
    return _db.collection('workers').doc(uid).set({
      'isShiftRunning': false,
      'isOnBreak': true,
      'status': 'break',
      'shiftAccumulatedSeconds': current.workedSeconds,
      'shiftStartedAt': FieldValue.delete(),
      'breakStartedAt': FieldValue.serverTimestamp(),
      'lastBreakSeconds': 0,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> finishBreak(String uid, WorkerWellnessSnapshot current) {
    return _db.collection('workers').doc(uid).set({
      'isOnBreak': false,
      'status': 'Active',
      'breakStartedAt': FieldValue.delete(),
      'lastBreakSeconds': current.currentBreakSeconds,
      'totalBreakSecondsToday': current.totalBreakSeconds,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> logWater(String uid, int amountMl) {
    return _db.collection('workers').doc(uid).set({
      'loggedWaterMl': FieldValue.increment(amountMl),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> saveHealthSnapshot({
    required String uid,
    required String status,
    required int score,
    required int steps,
    required double hydrationLitres,
    required double fatigue,
    required double stress,
    required double activeHours,
    required int calories,
  }) {
    return _db.collection('workers').doc(uid).set({
      'health': status,
      'healthScore': score,
      'steps': steps,
      'hydration': hydrationLitres,
      'fatigue': fatigue,
      'stress': stress,
      'activeHours': activeHours,
      'calories': calories,
      'healthUpdatedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
