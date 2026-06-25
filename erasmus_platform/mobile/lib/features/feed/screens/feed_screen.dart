import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/feed_provider.dart';
import '../widgets/post_card.dart';
import '../../notifications/screens/notifications_screen.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(feedProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Erasmus Feed'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
          ),
          Consumer(
            builder: (context, ref, _) {
              final unreadAsync = ref.watch(unreadCountProvider);
              final count = unreadAsync.valueOrNull ?? 0;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () => context.push('/notifications'),
                  ),
                  if (count > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          '$count',
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => context.push('/posts/new'),
          ),
        ],
      ),
      body: feedAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Yüklenemedi: $e'),
              TextButton(onPressed: () => ref.refresh(feedProvider), child: const Text('Tekrar dene')),
            ],
          ),
        ),
        data: (posts) => RefreshIndicator(
          onRefresh: () async => ref.refresh(feedProvider),
          child: posts.isEmpty
              ? const Center(child: Text('Henüz paylaşım yok'))
              : ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (ctx, i) => PostCard(post: posts[i]),
                ),
        ),
      ),
    );
  }
}