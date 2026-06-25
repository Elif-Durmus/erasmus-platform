import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_client.dart';
import '../../../core/utils/time_ago.dart';

final questionDetailProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, String>((ref, id) async {
  final res = await apiClient.dio.get('/questions/$id');
  return res.data as Map<String, dynamic>;
});

class QuestionDetailScreen extends ConsumerStatefulWidget {
  final String questionId;
  const QuestionDetailScreen({super.key, required this.questionId});

  @override
  ConsumerState<QuestionDetailScreen> createState() =>
      _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends ConsumerState<QuestionDetailScreen> {
  final _answerCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _answerCtrl.dispose();
    super.dispose();
  }

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
      appBar: AppBar(
        title: const Text('Soru Detayı'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/questions');
            }
          },
        ),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
        data: (q) {
          final profile =
              q['user']?['profile'] as Map<String, dynamic>?;
          final isAnonymous = q['isAnonymous'] == true;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Soru başlığı
                    Text(
                      q['title'] ?? '',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    // Kullanıcı bilgisi
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundImage:
                              !isAnonymous && profile?['profilePhotoUrl'] != null
                                  ? NetworkImage(profile!['profilePhotoUrl'])
                                  : null,
                          child: isAnonymous
                              ? const Icon(Icons.person_outline, size: 16)
                              : profile?['profilePhotoUrl'] == null
                                  ? Text(
                                      (profile?['fullName'] as String?)
                                              ?.substring(0, 1)
                                              .toUpperCase() ??
                                          '?',
                                      style: const TextStyle(fontSize: 12),
                                    )
                                  : null,
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            if (!isAnonymous && profile?['username'] != null) {
                              context.push('/profile/${profile!['username']}');
                            }
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isAnonymous
                                    ? 'Anonim'
                                    : profile?['fullName'] ?? 'Kullanıcı',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                              if (!isAnonymous && profile?['username'] != null)
                                Text(
                                  '@${profile!['username']}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${(q['answers'] as List?)?.length ?? 0} cevap',
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Soru içeriği
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        q['content'] ?? '',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    const Divider(height: 32),
                    // Cevaplar başlığı
                    Text(
                      'Cevaplar (${(q['answers'] as List?)?.length ?? 0})',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    // Cevap listesi
                    ...((q['answers'] as List?) ?? []).map((a) {
                      final answerProfile =
                          a['user']?['profile'] as Map<String, dynamic>?;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundImage: answerProfile?[
                                                'profilePhotoUrl'] !=
                                            null
                                        ? NetworkImage(
                                            answerProfile!['profilePhotoUrl'])
                                        : null,
                                    child: answerProfile?['profilePhotoUrl'] ==
                                            null
                                        ? Text(
                                            (answerProfile?['fullName']
                                                        as String?)
                                                    ?.substring(0, 1)
                                                    .toUpperCase() ??
                                                '?',
                                            style: const TextStyle(fontSize: 10),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () {
                                      final username = answerProfile?['username'];
                                      if (username != null) {
                                        context.push('/profile/$username');
                                      }
                                    },
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          answerProfile?['fullName'] ?? 'Kullanıcı',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600, fontSize: 13),
                                        ),
                                        Row(
                                          children: [
                                            if (answerProfile?['username'] != null)
                                              Text(
                                                '@${answerProfile!['username']}',
                                                style: Theme.of(context).textTheme.bodySmall,
                                              ),
                                            if (a['createdAt'] != null) ...[
                                              Text(' · ',
                                                  style: Theme.of(context).textTheme.bodySmall),
                                              Text(
                                                timeAgo(a['createdAt']),
                                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                      color: Theme.of(context).colorScheme.outline,
                                                    ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (a['isAccepted'] == true) ...[
                                    const Spacer(),
                                    const Icon(Icons.check_circle,
                                        color: Colors.green, size: 18),
                                    const SizedBox(width: 4),
                                    const Text(
                                      'Kabul edildi',
                                      style: TextStyle(
                                          color: Colors.green, fontSize: 12),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(a['content'] ?? ''),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              // Cevap yazma alanı
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, -2))
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _answerCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Cevabını yaz...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: _submitting ? null : _submitAnswer,
                      icon: _submitting
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}