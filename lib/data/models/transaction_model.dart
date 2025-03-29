import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String requestId;
  final String serviceId;
  final String serviceName;
  final String providerId;
  final String clientId;
  final double amount;
  final String status;
  final DateTime createdAt;
  final DateTime? completedAt;

  TransactionModel({
    required this.id,
    required this.requestId,
    required this.serviceId,
    required this.serviceName,
    required this.providerId,
    required this.clientId,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.completedAt,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] ?? '',
      requestId: map['requestId'] ?? '',
      serviceId: map['serviceId'] ?? '',
      serviceName: map['serviceName'] ?? '',
      providerId: map['providerId'] ?? '',
      clientId: map['clientId'] ?? '',
      amount: map['amount']?.toDouble() ?? 0.0,
      status: map['status'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      completedAt: map['completedAt'] != null ? (map['completedAt'] as Timestamp).toDate() : null,
    );
  }
}
