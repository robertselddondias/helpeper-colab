import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helpper/data/models/transaction_model.dart';
import 'package:helpper/features/auth/auth_controller.dart';

class PaymentsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = Get.find<AuthController>();

  final RxList<TransactionModel> transactions = <TransactionModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // Summary data
  final RxDouble totalEarnings = 0.0.obs;
  final RxDouble currentMonthEarnings = 0.0.obs;
  final RxDouble lastMonthEarnings = 0.0.obs;
  final RxDouble pendingPayments = 0.0.obs;

  // Statistics
  final RxInt completedServices = 0.obs;
  final RxInt canceledServices = 0.obs;
  final RxDouble averageAmount = 0.0.obs;

  Future<void> loadEarnings() async {
    try {
      isLoading.value = true;
      error.value = '';

      final userId = _authController.firebaseUser.value?.uid;

      if (userId == null) {
        isLoading.value = false;
        return;
      }

      await loadTransactions(userId);
      calculateStatistics();

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      error.value = e.toString();
      debugPrint('Error loading earnings: $e');
    }
  }

  Future<void> loadTransactions(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('transactions')
          .where('providerId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      transactions.clear();
      for (var doc in querySnapshot.docs) {
        transactions.add(TransactionModel.fromMap({
          'id': doc.id,
          ...doc.data(),
        }));
      }
    } catch (e) {
      debugPrint('Error loading transactions: $e');
    }
  }

  void calculateStatistics() {
    if (transactions.isEmpty) {
      return;
    }

    double total = 0;
    double currentMonth = 0;
    double lastMonth = 0;
    double pending = 0;
    int completed = 0;
    int canceled = 0;

    final now = DateTime.now();
    final currentMonthStart = DateTime(now.year, now.month, 1);
    final lastMonthStart = DateTime(now.year, now.month - 1, 1);
    final lastMonthEnd = DateTime(now.year, now.month, 0, 23, 59, 59);

    for (var transaction in transactions) {
      // Total earnings (only completed)
      if (transaction.status == 'completed') {
        total += transaction.amount;
        completed++;
      }

      // Current month earnings (only completed)
      if (transaction.status == 'completed' &&
          transaction.createdAt.isAfter(currentMonthStart)) {
        currentMonth += transaction.amount;
      }

      // Last month earnings (only completed)
      if (transaction.status == 'completed' &&
          transaction.createdAt.isAfter(lastMonthStart) &&
          transaction.createdAt.isBefore(lastMonthEnd)) {
        lastMonth += transaction.amount;
      }

      // Pending payments
      if (transaction.status == 'pending') {
        pending += transaction.amount;
      }

      // Canceled services
      if (transaction.status == 'cancelled') {
        canceled++;
      }
    }

    // Set values
    totalEarnings.value = total;
    currentMonthEarnings.value = currentMonth;
    lastMonthEarnings.value = lastMonth;
    pendingPayments.value = pending;
    completedServices.value = completed;
    canceledServices.value = canceled;

    // Calculate average amount
    if (completed > 0) {
      averageAmount.value = total / completed;
    } else {
      averageAmount.value = 0;
    }
  }

  // Add method to fetch pending payments from requests
  Future<void> loadPendingPayments() async {
    try {
      final userId = _authController.firebaseUser.value?.uid;

      if (userId == null) {
        return;
      }

      final querySnapshot = await _firestore
          .collection('requests')
          .where('providerId', isEqualTo: userId)
          .where('status', isEqualTo: 'completed')
          .where('paymentStatus', isEqualTo: 'pending')
          .get();

      double pendingTotal = 0;

      for (var doc in querySnapshot.docs) {
        final amount = doc.data()['amount'] ?? 0.0;
        pendingTotal += (amount is double) ? amount : (amount as num).toDouble();
      }

      pendingPayments.value = pendingTotal;
    } catch (e) {
      debugPrint('Error loading pending payments: $e');
    }
  }

  // Method to get transaction by ID
  Future<TransactionModel?> getTransactionById(String transactionId) async {
    try {
      final docSnapshot = await _firestore
          .collection('transactions')
          .doc(transactionId)
          .get();

      if (docSnapshot.exists) {
        return TransactionModel.fromMap({
          'id': docSnapshot.id,
          ...docSnapshot.data()!,
        });
      }

      return null;
    } catch (e) {
      debugPrint('Error getting transaction: $e');
      return null;
    }
  }

  // Method to update transaction status
  Future<void> updateTransactionStatus(String transactionId, String status) async {
    try {
      await _firestore
          .collection('transactions')
          .doc(transactionId)
          .update({
        'status': status,
        'completedAt': status == 'completed' ? FieldValue.serverTimestamp() : null,
      });

      // Update local transaction if it exists in the list
      final index = transactions.indexWhere((t) => t.id == transactionId);
      if (index != -1) {
        // We need to reload the transaction to get the updated timestamp
        final updated = await getTransactionById(transactionId);
        if (updated != null) {
          transactions[index] = updated;
        }
      }

      Get.snackbar(
        'Success',
        'Transaction status updated',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint('Error updating transaction status: $e');
      Get.snackbar(
        'Error',
        'Could not update transaction status',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Method to get earning summary
  Future<Map<String, dynamic>> getEarningsSummary() async {
    try {
      final userId = _authController.firebaseUser.value?.uid;

      if (userId == null) {
        return {
          'totalEarnings': 0.0,
          'completedServices': 0,
          'pendingPayments': 0.0,
        };
      }

      await loadTransactions(userId);
      await loadPendingPayments();
      calculateStatistics();

      return {
        'totalEarnings': totalEarnings.value,
        'currentMonthEarnings': currentMonthEarnings.value,
        'lastMonthEarnings': lastMonthEarnings.value,
        'completedServices': completedServices.value,
        'canceledServices': canceledServices.value,
        'pendingPayments': pendingPayments.value,
        'averageAmount': averageAmount.value,
      };
    } catch (e) {
      debugPrint('Error getting earnings summary: $e');
      return {
        'totalEarnings': 0.0,
        'completedServices': 0,
        'pendingPayments': 0.0,
      };
    }
  }
}
