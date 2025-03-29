import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:helpper/data/models/review_model.dart';
import 'package:helpper/features/auth/auth_controller.dart';

class ReviewsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = Get.find<AuthController>();

  final RxList<ReviewModel> reviews = <ReviewModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  Future<void> loadReviews(String serviceId) async {
    try {
      isLoading.value = true;
      error.value = '';

      final querySnapshot = await _firestore
          .collection('reviews')
          .where('serviceId', isEqualTo: serviceId)
          .orderBy('createdAt', descending: true)
          .get();

      reviews.clear();
      for (var doc in querySnapshot.docs) {
        reviews.add(ReviewModel.fromMap({
          'id': doc.id,
          ...doc.data(),
        }));
      }

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      error.value = e.toString();
      debugPrint('Error loading reviews: $e');
    }
  }

  Future<void> addReview(Map<String, dynamic> reviewData) async {
    try {
      isLoading.value = true;
      error.value = '';

      // Create document in Firestore
      final docRef = _firestore.collection('reviews').doc();

      // Add review data
      final reviewMap = {
        ...reviewData,
        'id': docRef.id,
        'clientId': _authController.firebaseUser.value!.uid,
        'clientName': _authController.userModel.value!.name,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Save to Firestore
      await docRef.set(reviewMap);

      // Update service rating
      await updateServiceRating(reviewData['serviceId']);

      // Update request as rated
      if (reviewData['requestId'] != null) {
        await _firestore
            .collection('requests')
            .doc(reviewData['requestId'])
            .update({
          'isRated': true,
          'rating': reviewData['rating'],
          'review': reviewData['comment'],
        });
      }

      isLoading.value = false;

      Get.back();
      Get.snackbar(
        'Sucesso',
        'Avaliação enviada com sucesso',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      isLoading.value = false;
      error.value = e.toString();
      debugPrint('Error adding review: $e');

      Get.snackbar(
        'Erro',
        'Não foi possível enviar a avaliação',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> updateServiceRating(String serviceId) async {
    try {
      // Get all reviews for this service
      final querySnapshot = await _firestore
          .collection('reviews')
          .where('serviceId', isEqualTo: serviceId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return;
      }

      // Calculate average rating
      double totalRating = 0;
      for (var doc in querySnapshot.docs) {
        totalRating += doc.data()['rating'] as double;
      }

      final averageRating = totalRating / querySnapshot.docs.length;

      // Update service rating
      await _firestore.collection('services').doc(serviceId).update({
        'rating': averageRating,
        'ratingCount': querySnapshot.docs.length,
      });

      // Also update the provider rating
      final serviceDoc = await _firestore.collection('services').doc(serviceId).get();
      if (serviceDoc.exists) {
        final providerId = serviceDoc.data()?['providerId'];

        if (providerId != null) {
          await updateProviderRating(providerId);
        }
      }
    } catch (e) {
      debugPrint('Error updating service rating: $e');
    }
  }

  Future<void> updateProviderRating(String providerId) async {
    try {
      // Get all reviews for this provider
      final querySnapshot = await _firestore
          .collection('reviews')
          .where('providerId', isEqualTo: providerId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return;
      }

      // Calculate average rating
      double totalRating = 0;
      for (var doc in querySnapshot.docs) {
        totalRating += doc.data()['rating'] as double;
      }

      final averageRating = totalRating / querySnapshot.docs.length;

      // Update provider rating
      await _firestore.collection('users').doc(providerId).update({
        'rating': averageRating,
      });
    } catch (e) {
      debugPrint('Error updating provider rating: $e');
    }
  }
}
