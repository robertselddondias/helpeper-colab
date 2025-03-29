import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? photoUrl;
  final String? fcmToken;
  final String? bio;
  final String? address;
  final GeoPoint? location;
  final bool isProvider;
  final bool isVerified;
  final List<String> skills;
  final double? rating;
  final int completedJobs;
  final DateTime createdAt;
  final DateTime? lastActive;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.photoUrl,
    this.fcmToken,
    this.bio,
    this.address,
    this.location,
    required this.isProvider,
    required this.isVerified,
    required this.skills,
    this.rating,
    required this.completedJobs,
    required this.createdAt,
    this.lastActive,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'fcmToken': fcmToken,
      'bio': bio,
      'address': address,
      'location': location,
      'isProvider': isProvider,
      'isVerified': isVerified,
      'skills': skills,
      'rating': rating,
      'completedJobs': completedJobs,
      'createdAt': createdAt,
      'lastActive': lastActive,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      photoUrl: map['photoUrl'],
      fcmToken: map['fcmToken'],
      bio: map['bio'],
      address: map['address'],
      location: map['location'],
      isProvider: map['isProvider'] ?? false,
      isVerified: map['isVerified'] ?? false,
      skills: List<String>.from(map['skills'] ?? []),
      rating: map['rating']?.toDouble(),
      completedJobs: map['completedJobs'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      lastActive: map['lastActive'] != null ? (map['lastActive'] as Timestamp).toDate() : null,
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel.fromMap({
      'id': doc.id,
      ...data,
    });
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
    String? fcmToken,
    String? bio,
    String? address,
    GeoPoint? location,
    bool? isProvider,
    bool? isVerified,
    List<String>? skills,
    double? rating,
    int? completedJobs,
    DateTime? createdAt,
    DateTime? lastActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      fcmToken: fcmToken ?? this.fcmToken,
      bio: bio ?? this.bio,
      address: address ?? this.address,
      location: location ?? this.location,
      isProvider: isProvider ?? this.isProvider,
      isVerified: isVerified ?? this.isVerified,
      skills: skills ?? this.skills,
      rating: rating ?? this.rating,
      completedJobs: completedJobs ?? this.completedJobs,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }
}
