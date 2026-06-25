import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_client.dart';

final conversationsProvider =
    FutureProvider.autoDispose<List<dynamic>>((ref) async {
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
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chat_bubble_outline,
                        size: 72, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Henüz mesajlaşma yok',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Bir kullanıcının profilinden mesaj başlatabilirsin',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: () async => ref.refresh(conversationsProvider),
                child: ListView.builder(
                  itemCount: convs.length,
                  itemBuilder: (ctx, i) {
                    final item = convs[i];
                    final conv = item['conversation'];
                    final otherUser =
                        item['otherUser'] as Map<String, dynamic>?;
                    final profile =
                        otherUser?['profile'] as Map<String, dynamic>?;

                    final fullName = profile?['fullName'] ?? 'Kullanıcı';
                    final username = profile?['username'];
                    final photoUrl = profile?['profilePhotoUrl'];

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            photoUrl != null ? NetworkImage(photoUrl) : null,
                        child: photoUrl == null
                            ? Text(
                                (fullName as String)
                                    .substring(0, 1)
                                    .toUpperCase(),
                              )
                            : null,
                      ),
                      title: Text(
                        fullName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: username != null ? Text('@$username') : null,
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/messages/${conv['id']}'),
                    );
                  },
                ),
              ),
      ),
    );
  }
}