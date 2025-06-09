// lib/screens/edit_profile_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:funny_flower/models/user_model.dart';
import 'package:funny_flower/services/firestore_service.dart';
import 'package:funny_flower/services/storage_service.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;
  const EditProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  File? _imageFile;
  bool _isLoading = false;

  // --- ✅ 1. НОВАЯ ПЕРЕМЕННАЯ ДЛЯ СТАТУСА ---
  String _loadingStatus = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.displayName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final storageService = StorageService();
    final image = await storageService.pickImageFromGallery();
    if (image != null) {
      setState(() {
        _imageFile = image;
      });
    }
  }

  Future<void> _deleteImage(FirestoreService firestoreService, StorageService storageService) async {
    setState(() {
      _isLoading = true;
      _loadingStatus = 'Удаление фото...';
    });
    try {
      await storageService.deleteProfilePicture(widget.user.uid);
      await firestoreService.updateUserProfile(widget.user.uid, {'photoUrl': null});
      setState(() {
        widget.user.photoUrl = null;
        _imageFile = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Фото удалено')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка удаления: $e')));
    } finally {
      if(mounted) {
        setState(() {
          _isLoading = false;
          _loadingStatus = '';
        });
      }
    }
  }

  // --- ✅ 2. ОБНОВЛЕННЫЙ МЕТОД СОХРАНЕНИЯ С УСТАНОВКОЙ СТАТУСОВ ---
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _loadingStatus = 'Подготовка...'; // Начальный статус
    });

    final firestoreService = context.read<FirestoreService>();
    final storageService = context.read<StorageService>();
    final messenger = ScaffoldMessenger.of(context);

    try {
      String? newPhotoUrl = widget.user.photoUrl;

      // Если выбрано новое изображение, загружаем его
      if (_imageFile != null) {
        setState(() {
          _loadingStatus = 'Загрузка фото...'; // Статус перед самой долгой операцией
        });
        newPhotoUrl = await storageService.uploadProfilePicture(widget.user.uid, _imageFile!);
      }

      setState(() {
        _loadingStatus = 'Сохранение профиля...'; // Статус перед финальной операцией
      });
      final Map<String, dynamic> updatedData = {
        'displayName': _nameController.text,
        'photoUrl': newPhotoUrl,
      };

      await firestoreService.updateUserProfile(widget.user.uid, updatedData);

      messenger.showSnackBar(const SnackBar(content: Text('Профиль успешно обновлен!'), backgroundColor: Colors.green));
      if (mounted) context.pop();

    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Ошибка сохранения: $e')));
    } finally {
      if(mounted) {
        setState(() {
          _isLoading = false;
          _loadingStatus = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = context.read<FirestoreService>();
    final storageService = context.read<StorageService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Редактировать профиль')),
      // --- ✅ 3. ОБНОВЛЕННЫЙ BODY С ОТОБРАЖЕНИЕМ СТАТУСА ---
      body: _isLoading
          ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                _loadingStatus,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          )
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : (widget.user.photoUrl != null && widget.user.photoUrl!.isNotEmpty ? NetworkImage(widget.user.photoUrl!) : null) as ImageProvider?,
                    child: (widget.user.photoUrl == null || widget.user.photoUrl!.isEmpty) && _imageFile == null
                        ? const Icon(Icons.person, size: 60)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.white),
                        onPressed: _pickImage,
                      ),
                    ),
                  ),
                  if (widget.user.photoUrl != null || _imageFile != null)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: CircleAvatar(
                        backgroundColor: Colors.red.withOpacity(0.8),
                        child: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.white),
                          onPressed: () => _deleteImage(firestoreService, storageService),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 32),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Имя'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Пожалуйста, введите имя';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                initialValue: widget.user.email,
                decoration: const InputDecoration(labelText: 'Email'),
                readOnly: true,
              ),
              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                child: const Text('Сохранить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}