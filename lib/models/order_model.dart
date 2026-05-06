import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String pickup;
  final String drop;
  final double distance;
  final double eta;
  final String status;
  final String? assignedWorkerId;
  final String? acceptedBy;
  final String? workerResponse;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? acceptedAt;
  final DateTime? deliveredAt;

  const OrderModel({
    required this.id,
    required this.pickup,
    required this.drop,
    required this.distance,
    required this.eta,
    required this.status,
    this.assignedWorkerId,
    this.acceptedBy,
    this.workerResponse,
    required this.createdAt,
    this.updatedAt,
    this.acceptedAt,
    this.deliveredAt,
  });

  factory OrderModel.fromMap(String id, Map<String, dynamic> data) {
    return OrderModel(
      id: id,
      pickup: (data['pickup'] ?? '').toString(),
      drop: (data['drop'] ?? '').toString(),
      distance:
          data['distance'] is num ? (data['distance'] as num).toDouble() : 0.0,
      eta: data['eta'] is num ? (data['eta'] as num).toDouble() : 0.0,
      status: (data['status'] ?? 'pending').toString(),
      assignedWorkerId:
          (data['assignedWorkerId'] ?? data['workerId'])?.toString(),
      acceptedBy: data['acceptedBy']?.toString(),
      workerResponse: data['workerResponse']?.toString(),
      createdAt: _dateFrom(data['createdAt']) ?? DateTime.now(),
      updatedAt: _dateFrom(data['updatedAt']),
      acceptedAt: _dateFrom(data['acceptedAt']),
      deliveredAt: _dateFrom(data['deliveredAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pickup': pickup,
      'drop': drop,
      'distance': distance,
      'eta': eta,
      'status': status,
      'assignedWorkerId': assignedWorkerId,
      'acceptedBy': acceptedBy,
      'workerResponse': workerResponse,
      'createdAt': Timestamp.fromDate(createdAt),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
      if (acceptedAt != null) 'acceptedAt': Timestamp.fromDate(acceptedAt!),
      if (deliveredAt != null) 'deliveredAt': Timestamp.fromDate(deliveredAt!),
    };
  }

  String? get workerId => assignedWorkerId ?? acceptedBy;

  bool get isAssignedRequest => status == 'assigned';
  bool get isAccepted => status == 'accepted';
  bool get isActiveDelivery =>
      status == 'accepted' || status == 'picked' || status == 'on_the_way';
  bool get isCompleted => status == 'delivered';
  bool get isRejected => status == 'rejected';

  String get statusText {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'assigned':
        return 'Assigned';
      case 'accepted':
        return 'Accepted';
      case 'picked':
        return 'Picked';
      case 'on_the_way':
        return 'On the way';
      case 'delivered':
        return 'Delivered';
      case 'rejected':
        return 'Rejected';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  double get progress {
    switch (status) {
      case 'assigned':
        return 0.12;
      case 'accepted':
        return 0.28;
      case 'picked':
        return 0.55;
      case 'on_the_way':
        return 0.82;
      case 'delivered':
        return 1.0;
      default:
        return 0.0;
    }
  }

  OrderModel copyWith({
    String? pickup,
    String? drop,
    double? distance,
    double? eta,
    String? status,
    String? assignedWorkerId,
    String? acceptedBy,
    String? workerResponse,
    DateTime? updatedAt,
    DateTime? acceptedAt,
    DateTime? deliveredAt,
  }) {
    return OrderModel(
      id: id,
      pickup: pickup ?? this.pickup,
      drop: drop ?? this.drop,
      distance: distance ?? this.distance,
      eta: eta ?? this.eta,
      status: status ?? this.status,
      assignedWorkerId: assignedWorkerId ?? this.assignedWorkerId,
      acceptedBy: acceptedBy ?? this.acceptedBy,
      workerResponse: workerResponse ?? this.workerResponse,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
    );
  }

  static DateTime? _dateFrom(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
