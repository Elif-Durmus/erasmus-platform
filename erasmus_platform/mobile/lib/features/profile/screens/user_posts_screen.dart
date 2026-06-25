import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_client.dart';
import '../../../core/utils/time_ago.dart';

class UserPostsScreen extends ConsumerStatefulWidget {
  final String username;
  const UserPostsScreen({super.key, required this.username});

  @override
  ConsumerState<UserPostsScreen> createState() => _UserPostsScreenState();
}

class _UserPostsScreenState extends ConsumerState<UserPostsScreen> {
  List<dynamic> _posts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res =
          await apiClient.dio.get('/users/${widget.username}/posts');
      if (mounted) {
        setState(() {
          _posts = res.data as List<dynamic>;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _typeLabel(String type) {
    const labels = {
      'experience': 'Deneyim',
      'advice': 'Tavsiye',
      'warning': 'Uyarı',
      'housing': 'Konut',
      'event': 'Etkinlik',
      'academic': 'Akademik',
    };
    return labels[type] ?? type;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paylaşımlar'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _posts.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.article_outlined,
                          size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Henüz paylaşım yok',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _posts.length,
                  itemBuilder: (ctx, i) {
                    final post = _posts[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(
                          post['title'] ?? post['content'] ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              post['content'] ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    _typeLabel(post['postType'] ?? ''),
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ),
                                const Spacer(),
                                Icon(Icons.favorite,
                                    size: 14, color: Colors.red.shade300),
                                const SizedBox(width: 2),
                                Text('${post['likeCount'] ?? 0}',
                                    style:
                                        Theme.of(context).textTheme.bodySmall),
                                const SizedBox(width: 8),
                                Text(
                                  timeAgo(post['createdAt']),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                        onTap: () => context.push('/posts/${post['id']}'),
                      ),
                    );
                  },
                ),
    );
  }
}