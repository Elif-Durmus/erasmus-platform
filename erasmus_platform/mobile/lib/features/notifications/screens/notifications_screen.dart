import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_client.dart';

final notificationsProvider =
    FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final res = await apiClient.dio.get('/notifications');
  return res.data as List<dynamic>;
});

final unreadCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final res = await apiClient.dio.get('/notifications/unread-count');
  return res.data['count'] as int;
});

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  IconData _iconFor(String type) {
    switch (type) {
      case 'post_like': return Icons.favorite;
      case 'post_comment': return Icons.comment;
      case 'question_answer': return Icons.question_answer;
      case 'follow': return Icons.person_add;
      default: return Icons.notifications;
    }
  }

  Color _colorFor(String type) {
    switch (type) {
      case 'post_like': return Colors.red;
      case 'post_comment': return Colors.blue;
      case 'question_answer': return Colors.green;
      case 'follow': return Colors.purple;
      default: return Colors.grey;
    }
  }

  String _timeAgo(String dateStr) {
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays}g önce';
    if (diff.inHours > 0) return '${diff.inHours}sa önce';
    if (diff.inMinutes > 0) return '${diff.inMinutes}dk önce';
    return 'Az önce';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirimler'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/feed');
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await apiClient.dio.patch('/notifications/read-all');
              ref.refresh(notificationsProvider);
              ref.refresh(unreadCountProvider);
            },
            child: const Text('Tümünü okundu işaretle'),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
        data: (notifications) => notifications.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_none, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('Henüz bildirim yok',
                        style: TextStyle(color: Colors.grey, fontSize: 16)),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: () async {
                  ref.refresh(notificationsProvider);
                  ref.refresh(unreadCountProvider);
                },
                child: ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (ctx, i) {
                    final n = notifications[i];
                    final actor = n['actor']?['profile'] as Map<String, dynamic>?;
                    final isRead = n['isRead'] == true;
                    final type = n['notificationType'] ?? '';

                    return Container(
                      color: isRead
                          ? null
                          : Theme.of(context)
                              .colorScheme
                              .primaryContainer
                              .withOpacity(0.2),
                      child: ListTile(
                        leading: Stack(
                          children: [
                            CircleAvatar(
                              backgroundImage: actor?['profilePhotoUrl'] != null
                                  ? NetworkImage(actor!['profilePhotoUrl'])
                                  : null,
                              child: actor?['profilePhotoUrl'] == null
                                  ? Text(
                                      (actor?['fullName'] as String?)
                                              ?.substring(0, 1)
                                              .toUpperCase() ??
                                          '?',
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _iconFor(type),
                                  size: 14,
                                  color: _colorFor(type),
                                ),
                              ),
                            ),
                          ],
                        ),
                        title: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: actor?['fullName'] ?? 'Birisi',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: ' ${n['body'] ?? ''}'),
                            ],
                          ),
                        ),
                        subtitle: Text(_timeAgo(n['createdAt'] ?? '')),
                        onTap: () async {
                          if (!isRead) {
                            await apiClient.dio.patch('/notifications/${n['id']}/read');
                            ref.refresh(notificationsProvider);
                            ref.refresh(unreadCountProvider);
                          }
                          // İlgili içeriğe git
                          if (n['referenceType'] == 'post' && n['referenceId'] != null) {
                            if (context.mounted) context.push('/posts/${n['referenceId']}');
                          } else if (n['referenceType'] == 'question' && n['referenceId'] != null) {
                            if (context.mounted) context.push('/questions/${n['referenceId']}');
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}