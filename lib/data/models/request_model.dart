import 'package:cloud_firestore/cloud_firestore.dart';

class RequestModel {
  final String id;
  final String serviceId;
  final String serviceName;
  final String providerId;
  final String providerName;
  final String clientId;
  final String clientName;
  final String status;
  final String description;
  final GeoPoint location;
  final String address;
  final DateTime scheduledDate;
  final String scheduledTime;
  final double amount;
  final String? paymentMethod;
  final String? paymentStatus;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final bool isRated;
  final double? rating;
  final String? review;

  RequestModel({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.providerId,
    required this.providerName,
    required this.clientId,
    required this.clientName,
    required this.status,
    required this.description,
    required this.location,
    required this.address,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.amount,
    this.paymentMethod,
    this.paymentStatus,
    required this.createdAt,
    this.acceptedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
    required this.isRated,
    this.rating,
    this.review,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'providerId': providerId,
      'providerName': providerName,
      'clientId': clientId,
      'clientName': clientName,
      'status': status,
      'description': description,
      'location': location,
      'address': address,
      'scheduledDate': scheduledDate,
      'scheduledTime': scheduledTime,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'createdAt': createdAt,
      'acceptedAt': acceptedAt,
      'completedAt': completedAt,
      'cancelledAt': cancelledAt,
      'cancellationReason': cancellationReason,
      'isRated': isRated,
      'rating': rating,
      'review': review,
    };
  }

  factory RequestModel.fromMap(Map<String, dynamic> map) {
    return RequestModel(
      id: map['id'] ?? '',
      serviceId: map['serviceId'] ?? '',
      serviceName: map['serviceName'] ?? '',
      providerId: map['providerId'] ?? '',
      providerName: map['providerName'] ?? '',
      clientId: map['clientId'] ?? '',
      clientName: map['clientName'] ?? '',
      status: map['status'] ?? 'pending',
      description: map['description'] ?? '',
      location: map['location'] ?? const GeoPoint(0, 0),
      address: map['address'] ?? '',
      scheduledDate: (map['scheduledDate'] as Timestamp).toDate(),
      scheduledTime: map['scheduledTime'] ?? '',
      amount: map['amount']?.toDouble() ?? 0.0,
      paymentMethod: map['paymentMethod'],
      paymentStatus: map['paymentStatus'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      acceptedAt: map['acceptedAt'] != null ? (map['acceptedAt'] as Timestamp).toDate() : null,
      completedAt: map['completedAt'] != null ? (map['completedAt'] as Timestamp).toDate() : null,
      cancelledAt: map['cancelledAt'] != null ? (map['cancelledAt'] as Timestamp).toDate() : null,
      cancellationReason: map['cancellationReason'],
      isRated: map['isRated'] ?? false,
      rating: map['rating']?.toDouble(),
      review: map['review'],
    );
  }

  factory RequestModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return RequestModel.fromMap({
      'id': doc.id,
      ...data,
    });
  }

  RequestModel copyWith({
    String? id,
    String? serviceId,
    String? serviceName,
    String? providerId,
    String? providerName,
    String? clientId,
    String? clientName,
    String? status,
    String? description,
    GeoPoint? location,
    String? address,
    DateTime? scheduledDate,
    String? scheduledTime,
    double? amount,
    String? paymentMethod,
    String? paymentStatus,
    DateTime? createdAt,
    DateTime? acceptedAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
    String? cancellationReason,
    bool? isRated,
    double? rating,
    String? review,
  }) {
    return RequestModel(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      status: status ?? this.status,
      description: description ?? this.description,
      location: location ?? this.location,
      address: address ?? this.address,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      isRated: isRated ?? this.isRated,
      rating: rating ?? this.rating,
      review: review ?? this.review,
    );
  }
}
