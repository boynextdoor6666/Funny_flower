// lib/services/storage_service.dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
// ✅ 1. НОВЫЕ ИМПОРТЫ
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  /// Шаг 1: Просто выбирает изображение из галереи, без сжатия.
  Future<File?> pickImageFromGallery() async {
    // Убираем параметры сжатия отсюда, чтобы метод делал только одну вещь.
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  /// ✅ 2. НОВЫЙ приватный метод, отвечающий только за сжатие.
  Future<File?> _compressImage(File file) async {
    // Получаем путь для временного файла
    final tempDir = await getTemporaryDirectory();
    final targetPath = '${tempDir.absolute.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

    // Сжимаем файл с помощью flutter_image_compress
    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      minWidth: 800,  // Аватарке не нужно больше
      minHeight: 800,
      quality: 85,    // Отличное качество при малом весе
    );

    if (result != null) {
      print('Размер до сжатия: ${file.lengthSync()} байт');
      print('Размер после сжатия: ${File(result.path).lengthSync()} байт');
      return File(result.path);
    }
    return null;
  }

  /// Шаг 2: Загружает изображение в Firebase. Теперь он сначала сжимает его.
  Future<String> uploadProfilePicture(String userId, File imageFile) async {
    try {

      final compressedFile = await _compressImage(imageFile);


      final fileToUpload = compressedFile ?? imageFile;

      final ref = _storage.ref().child('profile_pictures').child('$userId.jpg');
      await ref.putFile(fileToUpload); // Загружаем сжатый (или оригинальный) файл

      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;

    } on FirebaseException catch (e) {
      print("Ошибка загрузки фото: $e");
      rethrow; // Перебрасываем ошибку, чтобы ее можно было поймать в UI
    }
  }


  Future<void> deleteProfilePicture(String userId) async {
    final ref = _storage.ref().child('profile_pictures').child('$userId.jpg');
    try {
      await ref.delete();
    } on FirebaseException catch (e) {
      // Если файл уже удален, это не ошибка. Просто логируем и идем дальше.
      if (e.code == 'object-not-found') {
        print('Фото для удаления не найдено (возможно, его и не было).');
      } else {
        print("Ошибка удаления фото: $e");
        rethrow; // Другие ошибки стоит показать
      }
    }
  }
}