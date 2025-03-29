import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:helpper/data/models/notification_model.dart';
import 'package:helpper/features/auth/auth_controller.dart';
import 'package:helpper/routes/app_routes.dart';

class NotificationsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = Get.find<AuthController>();

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  Future<void> loadNotifications() async {
    try {
      isLoading.value = true;
      error.value = '';

      final userId = _authController.firebaseUser.value?.uid;

      if (userId == null) {
        isLoading.value = false;
        return;
      }

      final querySnapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      notifications.clear();
      for (var doc in querySnapshot.docs) {
        notifications.add(NotificationModel.fromMap({
          'id': doc.id,
          ...doc.data(),
        }));
      }

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      error.value = e.toString();
      debugPrint('Error loading notifications: $e');
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({
        'isRead': true,
      });

      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        notifications[index] = notifications[index].copyWith(isRead: true);
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final userId = _authController.firebaseUser.value?.uid;

      if (userId == null) {
        return;
      }

      final batch = _firestore.batch();
      final querySnapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      for (var doc in querySnapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();

      // Update local notifications
      for (var i = 0; i < notifications.length; i++) {
        if (!notifications[i].isRead) {
          notifications[i] = notifications[i].copyWith(isRead: true);
        }
      }

      Get.snackbar(
        'Sucesso',
        'Todas as notificações foram marcadas como lidas',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  void handleNotificationTap(NotificationModel notification) {
    // Mark notification as read first
    if (!notification.isRead) {
      markAsRead(notification.id);
    }

    // Navigate based on notification data
    if (notification.data != null) {
      switch (notification.type) {
      case 'request':
      if (notification.data!['requestId'] != null) {
      Get.toNamed(
      AppRoutes.REQUEST_DETAIL,
      arguments: notification.data!['requestId'],
      );
      }
      break;
      case 'message':
      if (notification.data!['chatId'] != null) {
      Get.toNamed(
      AppRoutes.CHAT_DETAIL,
      arguments: notification.data!['chatId'],
      );
      }
      break;
        case 'payment':
          if (notification.data!['paymentId'] != null) {
            Get.toNamed(
              AppRoutes.EARNINGS,
              arguments: notification.data!['paymentId'],
            );
          }
          break;
        default:
        // For system notifications, just mark as read
          break;
      }
    }
  }
}

