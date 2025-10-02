// lib/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  String displayName; // Имя, которое можно менять
  String? photoUrl;   // URL фото, может быть null


  final int experiencePoints;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.experiencePoints = 0,
  });

  /// Преобразование объекта UserModel в Map для записи в Firestore.
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'experiencePoints': experiencePoints,
    };
  }

  /// Создание объекта UserModel из документа Firestore.
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      // uid берем из ID документа для надежности
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? 'Пользователь',
      photoUrl: data['photoUrl'],
      experiencePoints: (data['experiencePoints'] as int?) ?? 0,
    );
  }
}