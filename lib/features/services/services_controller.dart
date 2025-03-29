import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:helpper/data/models/service_model.dart';
import 'package:helpper/features/auth/auth_controller.dart';
import 'package:helpper/features/profile/profile_controller.dart';

class ServicesController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final AuthController _authController = Get.find<AuthController>();

  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // Categorias disponíveis
  final List<String> categories = [
    'Limpeza',
    'Reformas',
    'Beleza',
    'Aulas',
    'Tecnologia',
    'Saúde',
    'Eventos',
    'Animais',
    'Consertos',
    'Jardinagem',
    'Delivery',
    'Transporte',
    'Outros',
  ];

  // Subcategorias por categoria
  final Map<String, List<String>> subcategories = {
    'Limpeza': [
      'Residencial',
      'Comercial',
      'Pós-obra',
      'Lavagem a seco',
      'Vidros',
      'Piscinas',
    ],
    'Reformas': [
      'Pintura',
      'Elétrica',
      'Hidráulica',
      'Alvenaria',
      'Marcenaria',
      'Gesso',
      'Pisos e Revestimentos',
    ],
    'Beleza': [
      'Cabeleireiro',
      'Manicure',
      'Maquiagem',
      'Depilação',
      'Massagem',
      'Estética',
    ],
    'Aulas': [
      'Idiomas',
      'Música',
      'Reforço Escolar',
      'Esportes',
      'Artes',
      'Informática',
    ],
    'Tecnologia': [
      'Desenvolvimento Web',
      'Aplicativos',
      'Assistência técnica',
      'Redes',
      'Design',
      'Marketing Digital',
    ],
    'Saúde': [
      'Enfermagem',
      'Fisioterapia',
      'Cuidador de Idosos',
      'Nutrição',
      'Psicologia',
    ],
    'Eventos': [
      'Fotografia',
      'Buffet',
      'DJ',
      'Decoração',
      'Animação',
      'Filmagem',
    ],
    'Animais': [
      'Passeador de Cães',
      'Banho e Tosa',
      'Veterinário',
      'Hospedagem',
      'Adestramento',
    ],
    'Consertos': [
      'Eletrodomésticos',
      'Eletrônicos',
      'Móveis',
      'Automóveis',
      'Bicicletas',
    ],
    'Jardinagem': [
      'Paisagismo',
      'Manutenção',
      'Poda',
      'Controle de Pragas',
      'Hortas',
    ],
    'Delivery': [
      'Alimentos',
      'Compras',
      'Documentos',
      'Medicamentos',
    ],
    'Transporte': [
      'Mudanças',
      'Fretes',
      'Viagens',
      'Escolar',
    ],
    'Outros': [
      'Diversos',
    ],
  };

  List<String> getSubcategories(String category) {
    return subcategories[category] ?? [];
  }

  Future<void> addService(Map<String, dynamic> serviceData, List<File> images) async {
    try {
      isLoading.value = true;
      error.value = '';

      final userId = _authController.firebaseUser.value!.uid;
      final userName = _authController.userModel.value!.name;

      // Criar documento no Firestore
      final docRef = _firestore.collection('services').doc();

      // Upload das imagens
      List<String> imageUrls = [];

      for (var i = 0; i < images.length; i++) {
        final path = 'services/${docRef.id}/image_$i.jpg';
        final ref = _storage.ref().child(path);

        final bytes = await images[i].readAsBytes();
        await ref.putData(
          bytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );

        final downloadURL = await ref.getDownloadURL();
        imageUrls.add(downloadURL);
      }

      // Criar objeto do serviço
      final serviceMap = {
        ...serviceData,
        'id': docRef.id,
        'providerId': userId,
        'providerName': userName,
        'images': imageUrls,
        'isActive': true,
        'rating': 0.0,
        'ratingCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Salvar no Firestore
      await docRef.set(serviceMap);

      // Atualizar contagem de serviços no perfil
      try {
        final profileController = Get.find<ProfileController>();
        profileController.fetchServices();
      } catch (_) {}

      isLoading.value = false;

      Get.back();
      Get.snackbar(
        'Sucesso',
        'Serviço adicionado com sucesso',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      isLoading.value = false;
      error.value = e.toString();

      Get.snackbar(
        'Erro',
        'Não foi possível adicionar o serviço',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> updateService(String serviceId, Map<String, dynamic> serviceData, List<File> newImages) async {
    try {
      isLoading.value = true;
      error.value = '';

      // Buscar o serviço atual
      final docSnapshot = await _firestore
          .collection('services')
          .doc(serviceId)
          .get();

      if (!docSnapshot.exists) {
        throw Exception('Serviço não encontrado');
      }

      final existingService = ServiceModel.fromFirestore(docSnapshot);

      // Upload de novas imagens, se houver
      List<String> imageUrls = List<String>.from(existingService.images);

      if (newImages.isNotEmpty) {
        for (var i = 0; i < newImages.length; i++) {
          final path = 'services/$serviceId/image_${existingService.images.length + i}.jpg';
          final ref = _storage.ref().child(path);

          final bytes = await newImages[i].readAsBytes();
          await ref.putData(
            bytes,
            SettableMetadata(contentType: 'image/jpeg'),
          );

          final downloadURL = await ref.getDownloadURL();
          imageUrls.add(downloadURL);
        }
      }

      // Atualizar o serviço
      final serviceMap = {
        ...serviceData,
        'images': imageUrls,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('services')
          .doc(serviceId)
          .update(serviceMap);

      // Atualizar os serviços no perfil
      try {
        final profileController = Get.find<ProfileController>();
        profileController.fetchServices();
      } catch (_) {}

      isLoading.value = false;

      Get.back();
      Get.snackbar(
        'Sucesso',
        'Serviço atualizado com sucesso',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      isLoading.value = false;
      error.value = e.toString();

      Get.snackbar(
        'Erro',
        'Não foi possível atualizar o serviço',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteImage(String serviceId, String imageUrl, int index) async {
    try {
      // Remover imagem do storage
      try {
        final ref = _storage.refFromURL(imageUrl);
        await ref.delete();
      } catch (e) {
        debugPrint('Erro ao excluir imagem do storage: $e');
      }

      // Atualizar a lista de imagens no Firestore
      await _firestore.collection('services').doc(serviceId).update({
        'images': FieldValue.arrayRemove([imageUrl]),
      });

      Get.snackbar(
        'Sucesso',
        'Imagem removida com sucesso',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Atualizar os serviços no perfil
      try {
        final profileController = Get.find<ProfileController>();
        profileController.fetchServices();
      } catch (_) {}

    } catch (e) {
      Get.snackbar(
        'Erro',
        'Não foi possível remover a imagem',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<List<ServiceModel>> searchServices(String query, String? category) async {
    try {
      Query serviceQuery = _firestore
          .collection('services')
          .where('isActive', isEqualTo: true);

      if (category != null && category.isNotEmpty) {
        serviceQuery = serviceQuery.where('category', isEqualTo: category);
      }

      final querySnapshot = await serviceQuery.get();

      final List<ServiceModel> services = [];

      for (var doc in querySnapshot.docs) {
        final service = ServiceModel.fromFirestore(doc);

        // Filtrar pelos termos de busca
        if (query.isEmpty ||
            service.title.toLowerCase().contains(query.toLowerCase()) ||
            service.description.toLowerCase().contains(query.toLowerCase())) {
          services.add(service);
        }
      }

      return services;
    } catch (e) {
      debugPrint('Erro na busca de serviços: $e');
      return [];
    }
  }

  Future<List<ServiceModel>> getServicesByCategory(String category) async {
    try {
      final querySnapshot = await _firestore
          .collection('services')
          .where('isActive', isEqualTo: true)
          .where('category', isEqualTo: category)
          .orderBy('rating', descending: true)
          .limit(10)
          .get();

      final List<ServiceModel> services = [];

      for (var doc in querySnapshot.docs) {
        services.add(ServiceModel.fromFirestore(doc));
      }

      return services;
    } catch (e) {
      debugPrint('Erro ao buscar serviços por categoria: $e');
      return [];
    }
  }

  Future<List<ServiceModel>> getRecommendedServices() async {
    try {
      final querySnapshot = await _firestore
          .collection('services')
          .where('isActive', isEqualTo: true)
          .orderBy('rating', descending: true)
          .limit(10)
          .get();

      final List<ServiceModel> services = [];

      for (var doc in querySnapshot.docs) {
        services.add(ServiceModel.fromFirestore(doc));
      }

      return services;
    } catch (e) {
      debugPrint('Erro ao buscar serviços recomendados: $e');
      return [];
    }
  }

  Future<List<ServiceModel>> getNearbyServices() async {
    try {
      // Em uma aplicação real, usaríamos geolocalização para buscar serviços próximos
      // Por simplicidade, vamos apenas retornar os serviços mais recentes

      final querySnapshot = await _firestore
          .collection('services')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      final List<ServiceModel> services = [];

      for (var doc in querySnapshot.docs) {
        services.add(ServiceModel.fromFirestore(doc));
      }

      return services;
    } catch (e) {
      debugPrint('Erro ao buscar serviços próximos: $e');
      return [];
    }
  }

  Future<ServiceModel?> getServiceDetails(String serviceId) async {
    try {
      final docSnapshot = await _firestore
          .collection('services')
          .doc(serviceId)
          .get();

      if (docSnapshot.exists) {
        return ServiceModel.fromFirestore(docSnapshot);
      }

      return null;
    } catch (e) {
      debugPrint('Erro ao buscar detalhes do serviço: $e');
      return null;
    }
  }

  Future<String> getProviderName(String providerId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(providerId)
          .get();

      if (doc.exists) {
        return doc.data()?['name'] ?? 'Prestador';
      }

      return 'Prestador';
    } catch (e) {
      debugPrint('Erro ao obter nome do provedor: $e');
      return 'Prestador';
    }
  }
}
