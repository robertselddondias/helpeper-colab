// Em lib/data/models/service_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceModel {
  final String id;
  final String providerId;
  final String title;
  final String description;
  final String category;
  final List<String> subCategories;
  final double price;
  final String priceType;
  final List<String> images;
  final bool isActive;
  final GeoPoint? location;
  final String? address;
  final double rating;
  final int ratingCount;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? providerName; // Adicionar este campo

  ServiceModel({
    required this.id,
    required this.providerId,
    required this.title,
    required this.description,
    required this.category,
    required this.subCategories,
    required this.price,
    required this.priceType,
    required this.images,
    required this.isActive,
    this.location,
    this.address,
    required this.rating,
    required this.ratingCount,
    required this.createdAt,
    this.updatedAt,
    this.providerName, // Adicionar no construtor
  });

  // Atualizar os métodos fromMap e toMap também
  Map<String, dynamic> toMap() {
    return {
      'providerId': providerId,
      'providerName': providerName,
    };
  }

  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    return ServiceModel(
      id: map['id'],
      providerId: map['providerId'],
      providerName: map['providerName'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      subCategories: [],
      category: '',
      price: map['price'] ?? 0.0,
      priceType: map['priceType'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      isActive: map['isActive'] ?? true,
      rating: map['rating'] ?? 0.0,
      ratingCount: map['ratingCount'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null ? (map['updatedAt'] as Timestamp).toDate() : null,
    );
  }

  // Incluir o novo campo também no método copyWith
  ServiceModel copyWith({
    // Campos existentes...
    String? providerName,
  }) {
    return ServiceModel(
      id: id,
      providerId: providerId,
      title: title,
      description: description,
      category: category,
      subCategories: subCategories,
      price: price,
      priceType: priceType,
      images: images,
      isActive: isActive,
      location: location,
      address: address,
      rating: rating,
      ratingCount: ratingCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
      providerName: providerName ?? this.providerName,
    );
  }
}
