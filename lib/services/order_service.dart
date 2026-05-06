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
  }) async {
    final docRef = await _orders.add({
      'pickup': pickup,
      'drop': drop,
      'status': 'pending',
      'assignedWorkerId': null,
      'acceptedBy': null,
      'workerResponse': null,
      'distance': distance ?? 0,
      'eta': eta ?? 0,
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
        await _db.collection('earnings').add({
          'workerId': workerId,
          'orderId': orderId,
          'amount': 50,
          'createdAt': FieldValue.serverTimestamp(),
        });
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
}
