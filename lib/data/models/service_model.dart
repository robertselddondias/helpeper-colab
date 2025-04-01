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
  final String? providerName;

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
    this.providerName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'providerId': providerId,
      'providerName': providerName,
      'title': title,
      'description': description,
      'category': category,
      'subCategories': subCategories,
      'price': price,
      'priceType': priceType,
      'images': images,
      'isActive': isActive,
      'location': location,
      'address': address,
      'rating': rating,
      'ratingCount': ratingCount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    return ServiceModel(
      id: map['id'] ?? '',
      providerId: map['providerId'] ?? '',
      providerName: map['providerName'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      subCategories: List<String>.from(map['subCategories'] ?? []),
      price: (map['price'] ?? 0.0).toDouble(),
      priceType: map['priceType'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      isActive: map['isActive'] ?? true,
      location: map['location'],
      address: map['address'],
      rating: (map['rating'] ?? 0.0).toDouble(),
      ratingCount: map['ratingCount'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null ? (map['updatedAt'] as Timestamp).toDate() : null,
    );
  }

  ServiceModel copyWith({
    String? id,
    String? providerId,
    String? providerName,
    String? title,
    String? description,
    String? category,
    List<String>? subCategories,
    double? price,
    String? priceType,
    List<String>? images,
    bool? isActive,
    GeoPoint? location,
    String? address,
    double? rating,
    int? ratingCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      subCategories: subCategories ?? this.subCategories,
      price: price ?? this.price,
      priceType: priceType ?? this.priceType,
      images: images ?? this.images,
      isActive: isActive ?? this.isActive,
      location: location ?? this.location,
      address: address ?? this.address,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ServiceModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ServiceModel(
      id: doc.id,
      providerId: data['providerId'] ?? '',
      providerName: data['providerName'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      subCategories: List<String>.from(data['subCategories'] ?? []),
      price: (data['price'] ?? 0.0).toDouble(),
      priceType: data['priceType'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      isActive: data['isActive'] ?? true,
      location: data['location'],
      address: data['address'],
      rating: (data['rating'] ?? 0.0).toDouble(),
      ratingCount: data['ratingCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null ? (data['updatedAt'] as Timestamp).toDate() : null,
    );
  }
}
