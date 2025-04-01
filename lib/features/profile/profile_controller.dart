import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:helpper/data/models/service_model.dart';
import 'package:helpper/data/repositories/auth_repository.dart';
import 'package:helpper/features/auth/auth_controller.dart';

class ProfileController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final AuthRepository _authRepository = AuthRepository();
  final AuthController _authController = Get.find<AuthController>();

  final ImagePicker _imagePicker = ImagePicker();

  final RxList<ServiceModel> services = <ServiceModel>[].obs;
  final RxBool isLoadingServices = false.obs;
  final RxInt servicesCount = 0.obs;
  final RxInt reviewsCount = 0.obs;
  final RxInt hiredServicesCount = 0.obs;
  final RxInt completedRequestsCount = 0.obs;
  final RxInt givenReviewsCount = 0.obs;

  @override
  void onInit() {
    super.onInit();

    // Load data when user is available
    ever(_authController.userModel, (_) {
      if (_authController.userModel.value != null) {
        loadProfileData();
        if (_authController.userModel.value!.isProvider) {
          fetchServices();
        } else {
          fetchClientData();
        }
      }
    });

    // Load data immediately if user is already available
    if (_authController.userModel.value != null) {
      loadProfileData();
      if (_authController.userModel.value!.isProvider) {
        fetchServices();
      } else {
        fetchClientData();
      }
    }
  }

  Future<void> loadProfileData() async {
    try {
      final userId = _authController.firebaseUser.value!.uid;

      final docSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (docSnapshot.exists) {
        // Update counters
        final userData = docSnapshot.data()!;

        if (_authController.userModel.value!.isProvider) {
          final reviewsSnapshot = await _firestore
              .collection('reviews')
              .where('providerId', isEqualTo: userId)
              .get();

          reviewsCount.value = reviewsSnapshot.docs.length;
        }
      }
    } catch (e) {
      debugPrint('Error loading profile data: $e');
    }
  }

  Future<void> fetchServices() async {
    try {
      isLoadingServices.value = true;

      final userId = _authController.firebaseUser.value!.uid;

      final querySnapshot = await _firestore
          .collection('services')
          .where('providerId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      services.clear();

      for (var doc in querySnapshot.docs) {
        services.add(ServiceModel.fromFirestore(doc));
      }

      servicesCount.value = services.length;
      isLoadingServices.value = false;
    } catch (e) {
      isLoadingServices.value = false;
      debugPrint('Error loading services: $e');
    }
  }

  Future<void> fetchClientData() async {
    try {
      final userId = _authController.firebaseUser.value!.uid;

      // Get count of hired services
      final hiredQuery = await _firestore
          .collection('requests')
          .where('clientId', isEqualTo: userId)
          .get();

      hiredServicesCount.value = hiredQuery.docs.length;

      // Get count of completed services
      final completedQuery = await _firestore
          .collection('requests')
          .where('clientId', isEqualTo: userId)
          .where('status', isEqualTo: 'completed')
          .get();

      completedRequestsCount.value = completedQuery.docs.length;

      // Get count of given reviews
      final reviewsQuery = await _firestore
          .collection('reviews')
          .where('clientId', isEqualTo: userId)
          .get();

      givenReviewsCount.value = reviewsQuery.docs.length;
    } catch (e) {
      debugPrint('Error loading client data: $e');
    }
  }

  Future<void> pickProfileImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 800,
      );

      if (image != null) {
        File imageFile = File(image.path);

        // Show confirmation dialog
        final result = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Update profile photo'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Do you want to use this image as your profile photo?'),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.file(
                    imageFile,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Confirm'),
              ),
            ],
          ),
        );

        if (result == true) {
          await _uploadProfileImage(imageFile);
        }
      }
    } catch (e) {
      debugPrint('Error selecting image: $e');
      Get.snackbar(
        'Error',
        'Could not select the image',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _uploadProfileImage(File imageFile) async {
    try {
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      final userId = _authController.firebaseUser.value!.uid;

      // Upload image to Firebase Storage
      final bytes = await imageFile.readAsBytes();
      final ref = _storage.ref().child('profile_images/$userId.jpg');
      await ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // Get the image URL
      final downloadURL = await ref.getDownloadURL();

      // Update user profile
      await _authRepository.updateUserProfile(
        userId,
        {'photoUrl': downloadURL},
      );

      // Get updated user data from Firestore
      final updatedUser = await _authRepository.getUserFromFirestore(userId);
      if (updatedUser != null) {
        // Update user model in controller
        _authController.userModel.value = updatedUser;
      }

      Get.back(); // Close loading dialog

      Get.snackbar(
        'Success',
        'Profile photo updated',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.back(); // Close loading dialog

      debugPrint('Error uploading image: $e');
      Get.snackbar(
        'Error',
        'Could not update profile photo',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> toggleServiceStatus(String serviceId, bool isActive) async {
    try {
      await _firestore
          .collection('services')
          .doc(serviceId)
          .update({'isActive': !isActive});

      // Update service in local list
      final index = services.indexWhere((s) => s.id == serviceId);
      if (index != -1) {
        final updatedService = services[index].copyWith(isActive: !isActive);
        services[index] = updatedService;
      }

      Get.snackbar(
        'Success',
        isActive ? 'Service deactivated' : 'Service activated',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint('Error changing service status: $e');
      Get.snackbar(
        'Error',
        'Could not change service status',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteService(String serviceId) async {
    try {
      // Show confirmation dialog
      final result = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Delete service'),
          content: const Text(
            'Are you sure you want to delete this service? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (result == true) {
        // Get service to remove images
        final service = services.firstWhere((s) => s.id == serviceId);

        // Delete images from Storage
        for (var imageUrl in service.images) {
          try {
            final ref = _storage.refFromURL(imageUrl);
            await ref.delete();
          } catch (e) {
            debugPrint('Error deleting image: $e');
          }
        }

        // Delete document from Firestore
        await _firestore
            .collection('services')
            .doc(serviceId)
            .delete();

        // Remove service from local list
        services.removeWhere((s) => s.id == serviceId);
        servicesCount.value = services.length;

        Get.snackbar(
          'Success',
          'Service deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Error deleting service: $e');
      Get.snackbar(
        'Error',
        'Could not delete the service',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      final userId = _authController.firebaseUser.value!.uid;

      // Update user profile
      await _authRepository.updateUserProfile(
        userId,
        data,
      );

      // Get updated user data from Firestore
      final updatedUser = await _authRepository.getUserFromFirestore(userId);
      if (updatedUser != null) {
        // Update user model in controller
        _authController.userModel.value = updatedUser;
      }

      Get.back(); // Close loading dialog

      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.back(); // Close loading dialog

      debugPrint('Error updating profile: $e');
      Get.snackbar(
        'Error',
        'Could not update profile',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
