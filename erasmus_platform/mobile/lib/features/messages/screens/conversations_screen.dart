import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_client.dart';

final conversationsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final res = await apiClient.dio.get('/messages/conversations');
  return res.data as List<dynamic>;
});

class ConversationsScreen extends ConsumerWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(conversationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mesajlar')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
        data: (convs) => convs.isEmpty
            ? const Center(child: Text('Henüz mesajlaşma yok'))
            : ListView.builder(
                itemCount: convs.length,
                itemBuilder: (ctx, i) {
                  final c = convs[i]['conversation'];
                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.chat_bubble_outline)),
                    title: Text(c?['id']?.toString().substring(0, 8) ?? 'Konuşma'),
                    onTap: () => context.push('/messages/${c['id']}'),
                  );
                },
              ),
      ),
    );
  }
}