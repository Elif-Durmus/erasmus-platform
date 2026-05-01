import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_client.dart';

final postDetailProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>((ref, id) async {
  final res = await apiClient.dio.get('/posts/$id');
  return res.data as Map<String, dynamic>;
});

class PostDetailScreen extends ConsumerStatefulWidget {
  final String postId;
  const PostDetailScreen({super.key, required this.postId});

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  final _commentCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<List<dynamic>> _fetchComments() async {
    final res = await apiClient.dio.get('/posts/${widget.postId}/comments');
    return res.data as List<dynamic>;
  }

  Future<void> _submitComment() async {
    if (_commentCtrl.text.trim().isEmpty) return;
    setState(() => _submitting = true);
    try {
      await apiClient.dio.post(
        '/posts/${widget.postId}/comments',
        data: {'content': _commentCtrl.text.trim()},
      );
      _commentCtrl.clear();
      ref.refresh(postDetailProvider(widget.postId));
      setState(() {}); // yorumları yenile
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
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
    final postAsync = ref.watch(postDetailProvider(widget.postId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Detayı'),
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
      ),
      body: postAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
        data: (post) {
          final profile = post['user']?['profile'] as Map<String, dynamic>?;
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Kullanıcı bilgisi
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: profile?['profilePhotoUrl'] != null
                                ? NetworkImage(profile!['profilePhotoUrl'])
                                : null,
                            child: profile?['profilePhotoUrl'] == null
                                ? Text(
                                    (profile?['fullName'] as String?)
                                            ?.substring(0, 1)
                                            .toUpperCase() ??
                                        '?',
                                  )
                                : null,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile?['fullName'] ?? 'Kullanıcı',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                              Text(
                                '@${profile?['username'] ?? ''}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
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
                              _typeLabel(post['postType'] ?? ''),
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
                      const SizedBox(height: 16),
                      // Başlık
                      if (post['title'] != null) ...[
                        Text(
                          post['title'],
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                      ],
                      // İçerik
                      Text(
                        post['content'] ?? '',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 16),
                      // Beğeni ve yorum sayısı
                      Row(
                        children: [
                          _LikeButton(postId: widget.postId, post: post),
                          const SizedBox(width: 16),
                          Icon(Icons.comment_outlined,
                              size: 20,
                              color: Theme.of(context).colorScheme.outline),
                          const SizedBox(width: 4),
                          Text('${post['commentCount'] ?? 0} yorum'),
                        ],
                      ),
                      const Divider(height: 32),
                      // Yorumlar başlığı
                      Text(
                        'Yorumlar',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      // Yorum listesi
                      FutureBuilder<List<dynamic>>(
                        future: _fetchComments(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Text(
                                'Henüz yorum yok, ilk yorumu sen yap!');
                          }
                          return Column(
                            children: snapshot.data!.map((comment) {
                              final commentProfile = comment['user']
                                  ?['profile'] as Map<String, dynamic>?;
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      child: Text(
                                        (commentProfile?['fullName'] as String?)
                                                ?.substring(0, 1)
                                                .toUpperCase() ??
                                            '?',
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                commentProfile?['fullName'] ??
                                                    'Kullanıcı',
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                '@${commentProfile?['username'] ?? ''}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(comment['content'] ?? ''),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              // Yorum yazma alanı
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, -2),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Yorum yaz...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: _submitting ? null : _submitComment,
                      icon: _submitting
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
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

class _LikeButton extends ConsumerStatefulWidget {
  final String postId;
  final Map<String, dynamic> post;
  const _LikeButton({required this.postId, required this.post});

  @override
  ConsumerState<_LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends ConsumerState<_LikeButton> {
  bool _liked = false;
  late int _count;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _count = widget.post['likeCount'] ?? 0;
    _checkLiked();
  }

  Future<void> _checkLiked() async {
    try {
      final res = await apiClient.dio.get('/posts/${widget.postId}/liked');
      if (mounted) {
        setState(() {
          _liked = res.data['liked'] ?? false;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggle() async {
    if (_loading) return;
    try {
      if (_liked) {
        await apiClient.dio.delete('/posts/${widget.postId}/like');
        setState(() {
          _liked = false;
          _count--;
        });
      } else {
        await apiClient.dio.post('/posts/${widget.postId}/like');
        setState(() {
          _liked = true;
          _count++;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: Row(
        children: [
          _loading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  _liked ? Icons.favorite : Icons.favorite_border,
                  size: 20,
                  color: _liked
                      ? Colors.red
                      : Theme.of(context).colorScheme.outline,
                ),
          const SizedBox(width: 4),
          Text('$_count beğeni'),
        ],
      ),
    );
  }
}