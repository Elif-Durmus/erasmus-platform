import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_client.dart';

final questionsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final res = await apiClient.dio.get('/questions');
  return res.data['questions'] as List<dynamic>;
});

class QuestionsScreen extends ConsumerWidget {
  const QuestionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(questionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Sorular')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/questions/new'),
        icon: const Icon(Icons.add),
        label: const Text('Soru Sor'),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
        data: (questions) => ListView.builder(
          itemCount: questions.length,
          itemBuilder: (ctx, i) {
            final q = questions[i];
            return ListTile(
              title: Text(q['title'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
              subtitle: Text('${q['answerCount'] ?? 0} cevap'),
              leading: const CircleAvatar(child: Icon(Icons.help_outline)),
              onTap: () => context.push('/questions/${q['id']}'),
            );
          },
        ),
      ),
    );
  }
}