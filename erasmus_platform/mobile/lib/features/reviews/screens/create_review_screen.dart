import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_client.dart';

class CreateReviewScreen extends ConsumerStatefulWidget {
  final String universityId;
  final String universityName;

  const CreateReviewScreen({
    super.key,
    required this.universityId,
    required this.universityName,
  });

  @override
  ConsumerState<CreateReviewScreen> createState() => _CreateReviewScreenState();
}

class _CreateReviewScreenState extends ConsumerState<CreateReviewScreen> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  bool _isAnonymous = false;
  bool _saving = false;

  final Map<String, double> _scores = {
    'academicScore': 3,
    'socialScore': 3,
    'housingScore': 3,
    'transportScore': 3,
    'safetyScore': 3,
    'costScore': 3,
    'supportScore': 3,
  };

  final Map<String, String> _labels = {
    'academicScore': 'Akademik',
    'socialScore': 'Sosyal Yaşam',
    'housingScore': 'Konaklama',
    'transportScore': 'Ulaşım',
    'safetyScore': 'Güvenlik',
    'costScore': 'Yaşam Maliyeti',
    'supportScore': 'Destek',
  };

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_contentCtrl.text.trim().length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Değerlendirme en az 10 karakter olmalı')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await apiClient.dio.post('/reviews', data: {
        'reviewTargetType': 'university',
        'universityId': widget.universityId,
        'title': _titleCtrl.text.trim().isEmpty ? null : _titleCtrl.text.trim(),
        'content': _contentCtrl.text.trim(),
        'isAnonymous': _isAnonymous,
        'ratings': _scores.map((k, v) => MapEntry(k, v.round())),
      });
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.universityName} - Değerlendir'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : _submit,
            child: _saving
                ? const SizedBox(
                    height: 18, width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Gönder'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titleCtrl,
            decoration: const InputDecoration(
              labelText: 'Başlık (opsiyonel)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _contentCtrl,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Deneyimini anlat',
              hintText: 'Bu üniversitedeki deneyimin nasıldı?',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 24),
          Text('Puanlama', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ..._scores.keys.map((key) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(_labels[key]!, style: const TextStyle(fontSize: 14)),
                      const Spacer(),
                      Text('${_scores[key]!.round()}/5',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  Slider(
                    value: _scores[key]!,
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: '${_scores[key]!.round()}',
                    onChanged: (val) => setState(() => _scores[key] = val),
                  ),
                ],
              )),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Anonim değerlendir'),
            value: _isAnonymous,
            onChanged: (val) => setState(() => _isAnonymous = val),
          ),
        ],
      ),
    );
  }
}