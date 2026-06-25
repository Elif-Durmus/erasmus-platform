import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/upload_service.dart';
import '../providers/profile_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _fullNameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _departmentCtrl = TextEditingController();
  final _studyLevelCtrl = TextEditingController();
  bool _loading = false;
  bool _initialized = false;
  File? _imageFile;
  bool _uploadingPhoto = false;
  String? _selectedDepartment;
  String? _selectedStudyLevel;
  bool _isOtherDepartment = false;

  final List<String> _departments = [
    'Bilgisayar Mühendisliği',
    'Elektrik-Elektronik Mühendisliği',
    'Makine Mühendisliği',
    'Endüstri Mühendisliği',
    'İnşaat Mühendisliği',
    'Mimarlık',
    'İşletme',
    'İktisat',
    'Hukuk',
    'Tıp',
    'Psikoloji',
    'Mütercim-Tercümanlık',
    'Uluslararası İlişkiler',
    'İletişim / Medya',
    'Eğitim Bilimleri',
    'Güzel Sanatlar',
    'Diğer',
  ];

  final List<String> _studyLevels = [
    'Ön Lisans',
    'Lisans',
    'Yüksek Lisans',
    'Doktora',
  ];

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _bioCtrl.dispose();
    _departmentCtrl.dispose();
    _studyLevelCtrl.dispose();
    super.dispose();
  }

  void _initFields(Map<String, dynamic> profile) {
    if (_initialized) return;
    _fullNameCtrl.text = profile['fullName'] ?? '';
    _bioCtrl.text = profile['bio'] ?? '';

    // Bölüm
    final dept = profile['department'] as String?;
    if (dept != null && dept.isNotEmpty) {
      if (_departments.contains(dept)) {
        _selectedDepartment = dept;
      } else {
        _selectedDepartment = 'Diğer';
        _isOtherDepartment = true;
        _departmentCtrl.text = dept;
      }
    }

    // Eğitim seviyesi
    final level = profile['studyLevel'] as String?;
    if (level != null && _studyLevels.contains(level)) {
      _selectedStudyLevel = level;
    }

    _initialized = true;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 500,
      maxHeight: 500,
    );
    if (picked == null) return;

    setState(() {
      _imageFile = File(picked.path);
      _uploadingPhoto = true;
    });

    final url = await UploadService.uploadProfilePhoto(_imageFile!);

    if (mounted) {
      setState(() => _uploadingPhoto = false);
      if (url != null) {
        ref.refresh(myProfileProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fotoğraf güncellendi')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fotoğraf yüklenemedi')),
        );
      }
    }
  }

  Future<void> _save() async {
    if (_fullNameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ad Soyad boş olamaz')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await apiClient.dio.patch('/users/me', data: {
        'fullName': _fullNameCtrl.text.trim(),
        'bio': _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
        'department': _selectedDepartment == 'Diğer'
            ? (_departmentCtrl.text.trim().isEmpty
                ? null
                : _departmentCtrl.text.trim())
            : _selectedDepartment,
        'studyLevel': _selectedStudyLevel,
      });
      ref.refresh(myProfileProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil güncellendi')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(myProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profili Düzenle'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _loading ? null : _save,
            child: _loading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Kaydet'),
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
        data: (profile) {
          _initFields(profile);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!) as ImageProvider
                            : profile['profilePhotoUrl'] != null
                                ? NetworkImage(profile['profilePhotoUrl'])
                                : null,
                        child: _imageFile == null &&
                                profile['profilePhotoUrl'] == null
                            ? Text(
                                (profile['fullName'] as String?)
                                        ?.substring(0, 1)
                                        .toUpperCase() ??
                                    '?',
                                style: const TextStyle(fontSize: 36),
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _uploadingPhoto ? null : _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: _uploadingPhoto
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.camera_alt,
                                    size: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _fullNameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Ad Soyad',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _bioCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Hakkımda',
                    prefixIcon: Icon(Icons.info_outline),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 16),
                // Bölüm dropdown
                DropdownButtonFormField<String>(
                  value: _selectedDepartment,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Bölüm',
                    prefixIcon: Icon(Icons.school_outlined),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Seçiniz')),
                    ..._departments.map((d) => DropdownMenuItem(
                          value: d,
                          child: Text(d, overflow: TextOverflow.ellipsis),
                        )),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _selectedDepartment = val;
                      _isOtherDepartment = val == 'Diğer';
                      if (!_isOtherDepartment) _departmentCtrl.clear();
                    });
                  },
                ),
                // "Diğer" seçilince serbest metin kutusu
                if (_isOtherDepartment) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _departmentCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Bölümünüzü yazın',
                      prefixIcon: Icon(Icons.edit_outlined),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                // Eğitim seviyesi dropdown
                DropdownButtonFormField<String>(
                  value: _selectedStudyLevel,
                  decoration: const InputDecoration(
                    labelText: 'Eğitim Seviyesi',
                    prefixIcon: Icon(Icons.workspace_premium_outlined),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Seçiniz')),
                    ..._studyLevels.map((l) => DropdownMenuItem(
                          value: l,
                          child: Text(l),
                        )),
                  ],
                  onChanged: (val) => setState(() => _selectedStudyLevel = val),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}