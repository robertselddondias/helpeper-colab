import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
}
