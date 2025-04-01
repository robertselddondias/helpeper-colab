import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helpper/data/models/request_model.dart';
import 'package:helpper/features/auth/auth_controller.dart';
import 'package:helpper/routes/app_routes.dart';

class RequestsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = Get.find<AuthController>();

  final RxList<RequestModel> providerRequests = <RequestModel>[].obs;
  final RxList<RequestModel> clientRequests = <RequestModel>[].obs;
  final Rx<RequestModel?> currentRequest = Rx<RequestModel?>(null);

  final RxBool isLoading = false.obs;
  final RxBool isLoadingDetail = false.obs;
  final RxString error = ''.obs;

  final RxString selectedTab = 'pending'.obs;

  @override
  void onInit() {
    super.onInit();
    ever(_authController.userModel, (_) => loadRequests());
  }

  Future<void> loadRequests() async {
    try {
      isLoading.value = true;
      error.value = '';

      final userId = _authController.firebaseUser.value?.uid;
      final isProvider = _authController.userModel.value?.isProvider ?? false;

      if (userId == null) {
        isLoading.value = false;
        return;
      }

      // Load requests based on user type (provider or client)
      if (isProvider) {
        await loadProviderRequests(userId);
      } else {
        await loadClientRequests(userId);
      }

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      error.value = e.toString();
      debugPrint('Error loading requests: $e');
    }
  }

  Future<void> loadProviderRequests(String providerId) async {
    try {
      // Get all requests for this provider
      final querySnapshot = await _firestore
          .collection('requests')
          .where('providerId', isEqualTo: providerId)
          .orderBy('createdAt', descending: true)
          .get();

      providerRequests.clear();
      for (var doc in querySnapshot.docs) {
        providerRequests.add(RequestModel.fromFirestore(doc));
      }
    } catch (e) {
      debugPrint('Error loading provider requests: $e');
      throw Exception('Failed to load provider requests: $e');
    }
  }

  Future<void> loadClientRequests(String clientId) async {
    try {
      // Get all requests for this client
      final querySnapshot = await _firestore
          .collection('requests')
          .where('clientId', isEqualTo: clientId)
          .orderBy('createdAt', descending: true)
          .get();

      clientRequests.clear();
      for (var doc in querySnapshot.docs) {
        clientRequests.add(RequestModel.fromFirestore(doc));
      }
    } catch (e) {
      debugPrint('Error loading client requests: $e');
      throw Exception('Failed to load client requests: $e');
    }
  }

  Future<void> loadRequestDetail(String requestId) async {
    try {
      isLoadingDetail.value = true;
      error.value = '';

      final docSnapshot = await _firestore
          .collection('requests')
          .doc(requestId)
          .get();

      if (docSnapshot.exists) {
        currentRequest.value = RequestModel.fromFirestore(docSnapshot);
      } else {
        error.value = 'Request not found';
      }

      isLoadingDetail.value = false;
    } catch (e) {
      isLoadingDetail.value = false;
      error.value = e.toString();
      debugPrint('Error loading request details: $e');
    }
  }

  Future<void> createRequest(Map<String, dynamic> requestData) async {
    try {
      isLoading.value = true;
      error.value = '';

      if (_authController.firebaseUser.value == null) {
        error.value = 'User not authenticated';
        isLoading.value = false;
        return;
      }

      final userId = _authController.firebaseUser.value!.uid;
      final userName = _authController.userModel.value!.name;

      // Create document in Firestore
      final docRef = _firestore.collection('requests').doc();

      // Add request data
      final requestMap = {
        ...requestData,
        'id': docRef.id,
        'clientId': userId,
        'clientName': userName,
        'status': 'pending',
        'isRated': false,
        'paymentStatus': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Save to Firestore
      await docRef.set(requestMap);

      // Send notification to the provider
      await _sendRequestNotification(
        requestMap['providerId'],
        'New service request',
        '$userName requested your service ${requestMap['serviceName']}',
        {
          'type': 'request',
          'requestId': docRef.id,
        },
      );

      isLoading.value = false;

      // Navigate to the request detail screen
      Get.offNamed(
        AppRoutes.REQUEST_DETAIL,
        arguments: docRef.id,
      );

      Get.snackbar(
        'Success',
        'Request sent successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      isLoading.value = false;
      error.value = e.toString();
      debugPrint('Error creating request: $e');

      Get.snackbar(
        'Error',
        'Could not send the request',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> updateRequestStatus(String requestId, String status) async {
    try {
      isLoading.value = true;
      error.value = '';

      final Map<String, dynamic> updateData = {
        'status': status,
      };

      // Add timestamp based on status
      switch (status) {
        case 'accepted':
          updateData['acceptedAt'] = FieldValue.serverTimestamp();
          break;
        case 'completed':
          updateData['completedAt'] = FieldValue.serverTimestamp();
          break;
        case 'cancelled':
          updateData['cancelledAt'] = FieldValue.serverTimestamp();
          break;
      }

      // Update in Firestore
      await _firestore
          .collection('requests')
          .doc(requestId)
          .update(updateData);

      // Update completed jobs count if status is 'completed'
      final currentReq = currentRequest.value;
      if (status == 'completed' && currentReq != null) {
        await _firestore
            .collection('users')
            .doc(currentReq.providerId)
            .update({
          'completedJobs': FieldValue.increment(1),
        });

        // Send notification to client
        await _sendRequestNotification(
          currentReq.clientId,
          'Service completed',
          'The service ${currentReq.serviceName} has been marked as completed',
          {
            'type': 'request',
            'requestId': requestId,
          },
        );
      } else if (status == 'accepted' && currentReq != null) {
        // Send notification to client
        await _sendRequestNotification(
          currentReq.clientId,
          'Request accepted',
          'Your request for ${currentReq.serviceName} has been accepted',
          {
            'type': 'request',
            'requestId': requestId,
          },
        );
      }

      // Reload request
      await loadRequestDetail(requestId);
      await loadRequests(); // Refresh the lists

      isLoading.value = false;

      Get.snackbar(
        'Success',
        _getStatusUpdateMessage(status),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      isLoading.value = false;
      error.value = e.toString();
      debugPrint('Error updating request status: $e');

      Get.snackbar(
        'Error',
        'Could not update status',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  String _getStatusUpdateMessage(String status) {
    switch (status) {
      case 'accepted':
        return 'Request accepted successfully';
      case 'completed':
        return 'Service marked as completed';
      case 'cancelled':
        return 'Request cancelled';
      default:
        return 'Status updated successfully';
    }
  }

  Future<void> cancelRequest(String requestId, String reason) async {
    try {
      isLoading.value = true;
      error.value = '';

      if (reason.isEmpty) {
        error.value = 'Cancellation reason is required';
        isLoading.value = false;
        return;
      }

      await _firestore
          .collection('requests')
          .doc(requestId)
          .update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
        'cancellationReason': reason,
      });

      // Send notification about cancellation
      final currentReq = currentRequest.value;
      if (currentReq != null) {
        final isProvider = _authController.userModel.value?.isProvider ?? false;
        final recipientId = isProvider ? currentReq.clientId : currentReq.providerId;

        await _sendRequestNotification(
          recipientId,
          'Request cancelled',
          'The request for ${currentReq.serviceName} has been cancelled',
          {
            'type': 'request',
            'requestId': requestId,
          },
        );
      }

      // Reload request
      await loadRequestDetail(requestId);
      await loadRequests(); // Refresh the lists

      isLoading.value = false;

      Get.snackbar(
        'Success',
        'Request cancelled successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      isLoading.value = false;
      error.value = e.toString();
      debugPrint('Error cancelling request: $e');

      Get.snackbar(
        'Error',
        'Could not cancel the request',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> updatePaymentStatus(String requestId, String status) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _firestore
          .collection('requests')
          .doc(requestId)
          .update({
        'paymentStatus': status,
      });

      // Reload request details
      await loadRequestDetail(requestId);

      isLoading.value = false;

      Get.snackbar(
        'Success',
        'Payment status updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      isLoading.value = false;
      error.value = e.toString();
      debugPrint('Error updating payment status: $e');

      Get.snackbar(
        'Error',
        'Could not update payment status',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> createTransaction(String requestId) async {
    try {
      isLoading.value = true;
      error.value = '';

      final request = currentRequest.value;
      if (request == null) {
        isLoading.value = false;
        error.value = 'Request not found';
        return;
      }

      // Create transaction document
      final transactionDoc = _firestore.collection('transactions').doc();

      final transaction = {
        'id': transactionDoc.id,
        'requestId': requestId,
        'serviceId': request.serviceId,
        'serviceName': request.serviceName,
        'providerId': request.providerId,
        'clientId': request.clientId,
        'amount': request.amount,
        'status': 'completed',
        'createdAt': FieldValue.serverTimestamp(),
        'completedAt': FieldValue.serverTimestamp(),
      };

      // Save transaction to Firestore
      await transactionDoc.set(transaction);

      // Update request payment status
      await _firestore
          .collection('requests')
          .doc(requestId)
          .update({
        'paymentStatus': 'paid',
      });

      // Send notification to provider
      await _sendRequestNotification(
        request.providerId,
        'Payment received',
        'You received a payment of R\$ ${request.amount.toStringAsFixed(2)} for ${request.serviceName}',
        {
          'type': 'payment',
          'requestId': requestId,
          'paymentId': transactionDoc.id,
        },
      );

      // Reload request details
      await loadRequestDetail(requestId);

      isLoading.value = false;

      Get.snackbar(
        'Success',
        'Payment processed successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      isLoading.value = false;
      error.value = e.toString();
      debugPrint('Error creating transaction: $e');

      Get.snackbar(
        'Error',
        'Could not process payment',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _sendRequestNotification(
      String userId,
      String title,
      String body,
      Map<String, dynamic> data,
      ) async {
    try {
      // Create notification document
      final notificationDoc = _firestore.collection('notifications').doc();

      final notification = {
        'id': notificationDoc.id,
        'userId': userId,
        'title': title,
        'body': body,
        'type': data['type'],
        'data': data,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Save notification to Firestore
      await notificationDoc.set(notification);

      // You would also trigger a push notification here using FCM
      // This would be handled by a cloud function or your backend
    } catch (e) {
      debugPrint('Error sending notification: $e');
    }
  }

  List<RequestModel> getFilteredRequests() {
    final isProvider = _authController.userModel.value?.isProvider ?? false;
    final requests = isProvider ? providerRequests : clientRequests;

    switch (selectedTab.value) {
      case 'pending':
        return requests.where((req) => req.status == 'pending').toList();
      case 'accepted':
        return requests.where((req) => req.status == 'accepted').toList();
      case 'completed':
        return requests.where((req) => req.status == 'completed').toList();
      case 'cancelled':
        return requests.where((req) => req.status == 'cancelled').toList();
      default:
        return requests;
    }
  }

  Future<void> createRequestWithProvider(Map<String, dynamic> requestData) async {
    try {
      isLoading.value = true;
      error.value = '';

      // Get provider name
      final providerId = requestData['providerId'];
      final providerDoc = await _firestore.collection('users').doc(providerId).get();

      if (providerDoc.exists) {
        requestData['providerName'] = providerDoc.data()?['name'] ?? 'Provider';
      } else {
        requestData['providerName'] = 'Provider';
      }

      // Continue with request creation
      await createRequest(requestData);
    } catch (e) {
      isLoading.value = false;
      error.value = e.toString();
      debugPrint('Error creating request with provider: $e');

      Get.snackbar(
        'Error',
        'Could not send the request',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
