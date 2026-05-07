import 'package:cloud_firestore/cloud_firestore.dart';

class OrderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _orders =>
      _db.collection('orders');

  CollectionReference<Map<String, dynamic>> get _workers =>
      _db.collection('workers');

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  Future<String> createOrder({
    required String pickup,
    required String drop,
    double? distance,
    int? eta,
    double? deliveryCharge,
    double? tip,
    double? bonus,
    double? deduction,
  }) async {
    final safeDistance = distance ?? 0;
    final calculatedCharge =
        deliveryCharge ?? _calculateDeliveryCharge(safeDistance);
    final docRef = await _orders.add({
      'pickup': pickup,
      'drop': drop,
      'status': 'pending',
      'assignedWorkerId': null,
      'acceptedBy': null,
      'workerResponse': null,
      'distance': safeDistance,
      'eta': eta ?? 0,
      'deliveryCharge': calculatedCharge,
      'tip': tip ?? 0,
      'bonus': bonus ?? 0,
      'deduction': deduction ?? 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  Future<void> assignWorker({
    required String orderId,
    required String workerId,
  }) async {
    final orderRef = _orders.doc(orderId);

    await _db.runTransaction((transaction) async {
      final orderSnap = await transaction.get(orderRef);
      if (!orderSnap.exists) throw Exception('Order not found');

      final data = orderSnap.data() ?? {};
      final status = data['status'];
      if (status == 'delivered' || status == 'cancelled') {
        throw Exception('Completed orders cannot be assigned');
      }

      transaction.update(orderRef, {
        'assignedWorkerId': workerId,
        'acceptedBy': null,
        'workerResponse': 'pending',
        'status': 'assigned',
        'assignedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> acceptOrder({
    required String orderId,
    required String workerId,
  }) async {
    final orderRef = _orders.doc(orderId);
    final workerRef = _workers.doc(workerId);
    final userRef = _users.doc(workerId);

    await _db.runTransaction((transaction) async {
      final orderSnap = await transaction.get(orderRef);
      final workerSnap = await transaction.get(workerRef);

      if (!orderSnap.exists) throw Exception('Order not found');

      final orderData = orderSnap.data() ?? {};
      final assignedWorkerId = orderData['assignedWorkerId'];
      final acceptedBy = orderData['acceptedBy'];

      if (assignedWorkerId != workerId) {
        throw Exception('This order is assigned to another worker');
      }

      if (acceptedBy != null && acceptedBy != workerId) {
        throw Exception('Order already accepted');
      }

      if (workerSnap.exists) {
        final currentOrderId = workerSnap.data()?['currentOrderId'];
        if (currentOrderId != null && currentOrderId != orderId) {
          throw Exception('Worker already has an active order');
        }
      }

      transaction.set(
          workerRef,
          {
            'currentOrderId': orderId,
            'isOnline': true,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true));

      transaction.set(
          userRef,
          {
            'currentOrderId': orderId,
            'isOnline': true,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true));

      transaction.update(orderRef, {
        'status': 'accepted',
        'acceptedBy': workerId,
        'workerResponse': 'accepted',
        'acceptedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> rejectOrder({
    required String orderId,
    required String workerId,
  }) async {
    final orderRef = _orders.doc(orderId);

    await _db.runTransaction((transaction) async {
      final orderSnap = await transaction.get(orderRef);
      if (!orderSnap.exists) throw Exception('Order not found');

      final data = orderSnap.data() ?? {};
      if (data['assignedWorkerId'] != workerId) {
        throw Exception('This order is assigned to another worker');
      }

      transaction.update(orderRef, {
        'status': 'rejected',
        'workerResponse': 'rejected',
        'rejectedBy': FieldValue.arrayUnion([workerId]),
        'rejectedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    final orderRef = _orders.doc(orderId);
    final previousSnap = await orderRef.get();
    final previousData = previousSnap.data() ?? {};
    final wasDelivered = previousData['status'] == 'delivered';
    if (status == 'delivered' && wasDelivered) return;

    final data = <String, dynamic>{
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (status == 'picked') {
      data['pickedAt'] = FieldValue.serverTimestamp();
    } else if (status == 'on_the_way') {
      data['startedAt'] = FieldValue.serverTimestamp();
    } else if (status == 'delivered') {
      data['deliveredAt'] = FieldValue.serverTimestamp();
    }

    await orderRef.update(data);

    if (status == 'delivered') {
      final orderSnap = await orderRef.get();
      final orderData = orderSnap.data() ?? {};
      final workerId =
          (orderData['acceptedBy'] ?? orderData['assignedWorkerId'])
              ?.toString();

      if (workerId != null && workerId.isNotEmpty) {
        await _workers.doc(workerId).set({
          'currentOrderId': null,
          'totalOrders': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        await _users.doc(workerId).set({
          'currentOrderId': null,
          'totalOrders': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        final amount = _earningAmount(orderData);
        await _db.collection('earnings').doc(orderId).set({
          'workerId': workerId,
          'orderId': orderId,
          'amount': amount,
          'deliveryCharge': _num(orderData['deliveryCharge']),
          'tip': _num(orderData['tip']),
          'bonus': _num(orderData['bonus']),
          'deduction': _num(orderData['deduction']),
          'type': 'delivery',
          'createdAt': orderData['deliveredAt'] ?? FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllOrders() {
    return _orders.orderBy('createdAt', descending: true).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getWorkerOrders(String workerId) {
    return _orders.where('assignedWorkerId', isEqualTo: workerId).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getWorkerOpenOrders(
    String workerId,
  ) {
    return _orders
        .where('assignedWorkerId', isEqualTo: workerId)
        .where('status', whereIn: [
      'assigned',
      'accepted',
      'picked',
      'on_the_way',
    ]).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getActiveOrders() {
    return _orders.where('status', whereIn: [
      'assigned',
      'accepted',
      'picked',
      'on_the_way',
    ]).snapshots();
  }

  Future<void> deleteOrder(String orderId) async {
    await _orders.doc(orderId).delete();
  }

  double _calculateDeliveryCharge(double distance) {
    const basePay = 35.0;
    const perKm = 8.0;
    final distancePay = distance > 0 ? distance * perKm : 15.0;
    return double.parse((basePay + distancePay).toStringAsFixed(2));
  }

  double _earningAmount(Map<String, dynamic> data) {
    final charge = _num(data['deliveryCharge'] ?? data['charge'] ?? data['amount']);
    final tip = _num(data['tip']);
    final bonus = _num(data['bonus']);
    final deduction = _num(data['deduction']);
    return double.parse((charge + tip + bonus - deduction).toStringAsFixed(2));
  }

  double _num(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }
}
