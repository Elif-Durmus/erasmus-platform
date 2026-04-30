import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/feed_provider.dart';
import '../widgets/post_card.dart';

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