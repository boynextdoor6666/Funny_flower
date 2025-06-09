// lib/services/storage_service.dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImageFromGallery() async {
    // --- ✅ ГЛАВНОЕ ИЗМЕНЕНИЕ ДЛЯ УСКОРЕНИЯ ---
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,

      // 1. Устанавливаем МАКСИМАЛЬНУЮ ширину и высоту.
      // image_picker пропорционально уменьшит изображение, чтобы оно
      // вписывалось в квадрат 512x512, сохраняя соотношение сторон.
      maxWidth: 512,
      maxHeight: 512,

      // 2. Устанавливаем качество сжатия для итогового изображения.
      // 70-80 - хороший баланс для такого размера.
      imageQuality: 75,
    );

    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  Future<String> uploadProfilePicture(String userId, File image) async {
    try {
      final ref = _storage.ref().child('profile_pictures').child('$userId.jpg');
      await ref.putFile(image);
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (e) {
      print("Ошибка загрузки фото: $e");
      rethrow;
    }
  }

  Future<void> deleteProfilePicture(String userId) async {
    try {
      final ref = _storage.ref().child('profile_pictures').child('$userId.jpg');
      await ref.delete();
    } catch (e) {
      print("Ошибка удаления фото (возможно, его и не было): $e");
    }
  }
}