import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _workers =>
      _db.collection('workers');

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  Future<void> createUser({
    required String uid,
    required String name,
    required String email,
    required String role,
  }) async {
    final data = {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'isOnline': false,
      'currentOrderId': null,
      'lat': null,
      'lng': null,
      'rating': 4.8,
      'totalOrders': 0,
      'totalDays': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (role == 'worker') {
      await _workers.doc(uid).set({
        ...data,
        'phone': '',
        'vehicleNo': '',
        'vehicleType': 'Bike',
        'address': '',
        'photoUrl': '',
        'status': 'Active',
      }, SetOptions(merge: true));
    }

    await _users.doc(uid).set(data, SetOptions(merge: true));
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUser(String uid) async {
    final workerDoc = await _workers.doc(uid).get();
    if (workerDoc.exists) return workerDoc;
    return _users.doc(uid).get();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> streamUser(String uid) {
    return _workers.doc(uid).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllWorkers() {
    return _workers.orderBy('name').snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getOnlineWorkers() {
    return _workers.where('isOnline', isEqualTo: true).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAvailableWorkers() {
    return _workers
        .where('isOnline', isEqualTo: true)
        .where('currentOrderId', isEqualTo: null)
        .snapshots();
  }

  Future<void> updateOnlineStatus({
    required String uid,
    required bool isOnline,
  }) async {
    final data = {
      'isOnline': isOnline,
      'lastSeen': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await _workers.doc(uid).set(data, SetOptions(merge: true));
    await _users.doc(uid).set(data, SetOptions(merge: true));
  }

  Future<void> updateLocation({
    required String uid,
    required double lat,
    required double lng,
  }) async {
    final data = {
      'lat': lat,
      'lng': lng,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await _workers.doc(uid).set(data, SetOptions(merge: true));
    await _users.doc(uid).set(data, SetOptions(merge: true));
  }

  Future<void> setCurrentOrder({
    required String uid,
    required String orderId,
  }) async {
    final data = {
      'currentOrderId': orderId,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await _workers.doc(uid).set(data, SetOptions(merge: true));
    await _users.doc(uid).set(data, SetOptions(merge: true));
  }

  Future<void> clearCurrentOrder(String uid) async {
    final data = {
      'currentOrderId': null,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await _workers.doc(uid).set(data, SetOptions(merge: true));
    await _users.doc(uid).set(data, SetOptions(merge: true));
  }

  Future<void> updateRating({
    required String uid,
    required double rating,
  }) async {
    await _workers.doc(uid).set({
      'rating': rating,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> deleteUser(String uid) async {
    await _workers.doc(uid).delete();
    await _users.doc(uid).delete();
  }
}
