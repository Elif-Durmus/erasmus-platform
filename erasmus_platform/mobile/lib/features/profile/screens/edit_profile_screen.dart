import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_client.dart';
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
    _departmentCtrl.text = profile['department'] ?? '';
    _studyLevelCtrl.text = profile['studyLevel'] ?? '';
    _initialized = true;
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
        'department': _departmentCtrl.text.trim().isEmpty ? null : _departmentCtrl.text.trim(),
        'studyLevel': _studyLevelCtrl.text.trim().isEmpty ? null : _studyLevelCtrl.text.trim(),
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
                // Profil fotoğrafı placeholder
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundImage: profile['profilePhotoUrl'] != null
                            ? NetworkImage(profile['profilePhotoUrl'])
                            : null,
                        child: profile['profilePhotoUrl'] == null
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
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt,
                              size: 18, color: Colors.white),
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
                TextFormField(
                  controller: _departmentCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Bölüm',
                    prefixIcon: Icon(Icons.school_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _studyLevelCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Eğitim Seviyesi (Lisans, Yüksek Lisans...)',
                    prefixIcon: Icon(Icons.workspace_premium_outlined),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}