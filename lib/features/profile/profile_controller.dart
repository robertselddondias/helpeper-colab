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

    // Carregar dados quando o usuário estiver disponível
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

    // Carregar dados imediatamente se o usuário já estiver disponível
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
        // Atualizar contadores
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
      debugPrint('Erro ao carregar dados do perfil: $e');
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
      debugPrint('Erro ao carregar serviços: $e');
    }
  }

  Future<void> fetchClientData() async {
    try {
      final userId = _authController.firebaseUser.value!.uid;

      // Carregar contagem de serviços contratados
      final hiredSnapshot = await _firestore
          .collection('requests')
          .where('clientId', isEqualTo: userId)
          .count()
          .get();

      hiredServicesCount.value = hiredSnapshot.count ?? 0;

      // Carregar contagem de serviços concluídos
      final completedSnapshot = await _firestore
          .collection('requests')
          .where('clientId', isEqualTo: userId)
          .where('status', isEqualTo: 'completed')
          .count()
          .get();

      // CORREÇÃO: AggregateQuerySnapshot.count() é um método, não uma propriedade
      completedRequestsCount.value = completedSnapshot.count ?? 0;

      // Carregar contagem de avaliações dadas
      final reviewsSnapshot = await _firestore
          .collection('reviews')
          .where('clientId', isEqualTo: userId)
          .count()
          .get();

      // CORREÇÃO: AggregateQuerySnapshot.count() é um método, não uma propriedade
      givenReviewsCount.value = reviewsSnapshot.count ?? 0;
    } catch (e) {
      debugPrint('Erro ao carregar dados do cliente: $e');
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

        // Mostrar diálogo de confirmação
        final result = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Atualizar foto de perfil'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Deseja usar esta imagem como sua foto de perfil?'),
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
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Confirmar'),
              ),
            ],
          ),
        );

        if (result == true) {
          await _uploadProfileImage(imageFile);
        }
      }
    } catch (e) {
      debugPrint('Erro ao selecionar imagem: $e');
      Get.snackbar(
        'Erro',
        'Não foi possível selecionar a imagem',
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

      // Carregar a imagem para o Firebase Storage
      final bytes = await imageFile.readAsBytes();
      final ref = _storage.ref().child('profile_images/$userId.jpg');
      await ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // Obter a URL da imagem
      final downloadURL = await ref.getDownloadURL();

      // Atualizar o perfil do usuário
      await _authRepository.updateUserProfile(
        userId,
        {'photoUrl': downloadURL},
      );

      // CORREÇÃO: A verificação de reloadUserData usando null não é correta porque
      // estamos verificando se existe um método, não se ele é nulo
      // Vamos reescrever esta parte:

      // Obter os dados atualizados do usuário do Firestore
      final updatedUser = await _authRepository.getUserFromFirestore(userId);
      if (updatedUser != null) {
        // Atualizar o modelo de usuário no controlador
        _authController.userModel.value = updatedUser;
      }

      Get.back(); // Fechar o diálogo de carregamento

      Get.snackbar(
        'Sucesso',
        'Foto de perfil atualizada',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.back(); // Fechar o diálogo de carregamento

      debugPrint('Erro ao fazer upload da imagem: $e');
      Get.snackbar(
        'Erro',
        'Não foi possível atualizar a foto de perfil',
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

      // Atualizar o serviço na lista local
      final index = services.indexWhere((s) => s.id == serviceId);
      if (index != -1) {
        services[index] = services[index].copyWith(isActive: !isActive);
      }

      Get.snackbar(
        'Sucesso',
        isActive ? 'Serviço desativado' : 'Serviço ativado',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint('Erro ao alterar status do serviço: $e');
      Get.snackbar(
        'Erro',
        'Não foi possível alterar o status do serviço',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteService(String serviceId) async {
    try {
      // Mostrar diálogo de confirmação
      final result = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Excluir serviço'),
          content: const Text(
            'Tem certeza que deseja excluir este serviço? Esta ação não pode ser desfeita.',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Excluir'),
            ),
          ],
        ),
      );

      if (result == true) {
        // Obter o serviço para remover as imagens
        final service = services.firstWhere((s) => s.id == serviceId);

        // Excluir as imagens do Storage
        for (var imageUrl in service.images) {
          try {
            final ref = _storage.refFromURL(imageUrl);
            await ref.delete();
          } catch (e) {
            debugPrint('Erro ao excluir imagem: $e');
          }
        }

        // Excluir o documento do Firestore
        await _firestore
            .collection('services')
            .doc(serviceId)
            .delete();

        // Remover o serviço da lista local
        services.removeWhere((s) => s.id == serviceId);
        servicesCount.value = services.length;

        Get.snackbar(
          'Sucesso',
          'Serviço excluído com sucesso',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Erro ao excluir serviço: $e');
      Get.snackbar(
        'Erro',
        'Não foi possível excluir o serviço',
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

      // Atualizar o perfil do usuário
      await _authRepository.updateUserProfile(
        userId,
        data,
      );

      // CORREÇÃO: Mesmo problema da verificação reloadUserData
      // Vamos simplificar e usar diretamente o método do repositório

      // Obter os dados atualizados do usuário do Firestore
      final updatedUser = await _authRepository.getUserFromFirestore(userId);
      if (updatedUser != null) {
        // Atualizar o modelo de usuário no controlador
        _authController.userModel.value = updatedUser;
      }

      Get.back(); // Fechar o diálogo de carregamento

      Get.snackbar(
        'Sucesso',
        'Perfil atualizado com sucesso',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.back(); // Fechar o diálogo de carregamento

      debugPrint('Erro ao atualizar perfil: $e');
      Get.snackbar(
        'Erro',
        'Não foi possível atualizar o perfil',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
