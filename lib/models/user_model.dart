// lib/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  String displayName; // Имя, которое можно менять
  String? photoUrl;   // URL фото, может быть null

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
  });

  // Преобразование в Map для записи в Firestore
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
    };
  }

  // Создание объекта из документа Firestore
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: data['uid'],
      email: data['email'],
      displayName: data['displayName'] ?? '', // Если имени нет, ставим пустую строку
      photoUrl: data['photoUrl'],
    );
  }
}