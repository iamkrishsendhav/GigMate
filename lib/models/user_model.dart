import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  admin,
  worker,
}

UserRole userRoleFromString(String role) {
  switch (role) {
    case "admin":
      return UserRole.admin;
    case "worker":
      return UserRole.worker;
    default:
      return UserRole.worker;
  }
}

String userRoleToString(UserRole role) {
  switch (role) {
    case UserRole.admin:
      return "admin";
    case UserRole.worker:
      return "worker";
  }
}

/// 🔥 MAIN MODEL
class UserModel {
  final String uid;
  final String name;
  final String email;

  final UserRole role;

  final bool isOnline;
  final String? currentOrderId;

  final double? lat;
  final double? lng;

  final double rating;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.isOnline,
    this.currentOrderId,
    this.lat,
    this.lng,
    required this.rating,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromMap(
    String uid,
    Map<String, dynamic> data,
  ) {
    return UserModel(
      uid: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: userRoleFromString(data['role'] ?? 'worker'),
      isOnline: data['isOnline'] ?? false,
      currentOrderId: data['currentOrderId'],
      lat: (data['lat'] != null) ? (data['lat'] as num).toDouble() : null,
      lng: (data['lng'] != null) ? (data['lng'] as num).toDouble() : null,
      rating: (data['rating'] ?? 0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "email": email,
      "role": userRoleToString(role),
      "isOnline": isOnline,
      "currentOrderId": currentOrderId,
      "lat": lat,
      "lng": lng,
      "rating": rating,
      "createdAt": createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      "updatedAt": FieldValue.serverTimestamp(),
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    UserRole? role,
    bool? isOnline,
    String? currentOrderId,
    double? lat,
    double? lng,
    double? rating,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      isOnline: isOnline ?? this.isOnline,
      currentOrderId: currentOrderId ?? this.currentOrderId,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }


  bool get isAdmin => role == UserRole.admin;
  bool get isWorker => role == UserRole.worker;

  bool get isBusy => currentOrderId != null;

  String get roleText {
    switch (role) {
      case UserRole.admin:
        return "Admin";
      case UserRole.worker:
        return "Worker";
    }
  }

  String get statusText {
    if (!isOnline) return "Offline";
    if (isBusy) return "On Delivery";
    return "Online";
  }
}