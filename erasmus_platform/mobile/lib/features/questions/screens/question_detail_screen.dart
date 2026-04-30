import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';

final questionDetailProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>((ref, id) async {
  final res = await apiClient.dio.get('/questions/$id');
  return res.data as Map<String, dynamic>;
});

class QuestionDetailScreen extends ConsumerStatefulWidget {
  final String questionId;
  const QuestionDetailScreen({super.key, required this.questionId});

  @override
  ConsumerState<QuestionDetailScreen> createState() => _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends ConsumerState<QuestionDetailScreen> {
  final _answerCtrl = TextEditingController();
  bool _submitting = false;

  Future<void> _submitAnswer() async {
    if (_answerCtrl.text.trim().isEmpty) return;
    setState(() => _submitting = true);
    try {
      await apiClient.dio.post('/questions/${widget.questionId}/answers',
          data: {'content': _answerCtrl.text.trim()});
      _answerCtrl.clear();
      ref.refresh(questionDetailProvider(widget.questionId));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(questionDetailProvider(widget.questionId));

    return Scaffold(
      appBar: AppBar(title: const Text('Soru Detayı')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
        data: (q) => Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(q['title'] ?? '', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(q['content'] ?? ''),
                  const Divider(height: 32),
                  Text('Cevaplar (${(q['answers'] as List?)?.length ?? 0})',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ...((q['answers'] as List?) ?? []).map((a) => Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                CircleAvatar(radius: 14, child: Text(
                                  (a['user']?['profile']?['fullName'] as String?)?.substring(0, 1).toUpperCase() ?? '?',
                                )),
                                const SizedBox(width: 8),
                                Text(a['user']?['profile']?['fullName'] ?? 'Kullanıcı',
                                    style: const TextStyle(fontWeight: FontWeight.w600)),
                                if (a['isAccepted'] == true) ...[
                                  const Spacer(),
                                  const Icon(Icons.check_circle, color: Colors.green, size: 18),
                                  const SizedBox(width: 4),
                                  const Text('Kabul edildi', style: TextStyle(color: Colors.green, fontSize: 12)),
                                ],
                              ]),
                              const SizedBox(height: 8),
                              Text(a['content'] ?? ''),
                            ],
                          ),
                        ),
                      )),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, -2))],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _answerCtrl,
                      decoration: const InputDecoration(hintText: 'Cevabını yaz...', border: OutlineInputBorder()),
                      maxLines: 2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _submitting ? null : _submitAnswer,
                    icon: _submitting
                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}