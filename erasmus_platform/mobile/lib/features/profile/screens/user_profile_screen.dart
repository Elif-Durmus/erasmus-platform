import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_client.dart';
import '../providers/profile_provider.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  final String username;
  const UserProfileScreen({super.key, required this.username});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  bool? _isFollowing;
  int _followers = 0;
  int _following = 0;
  int _postCount = 0;
  bool _statsLoaded = false;

  Future<void> _loadStats() async {
    try {
      final res =
          await apiClient.dio.get('/users/${widget.username}/follow-stats');
      // Paylaşım sayısını da çek
      int postCount = 0;
      try {
        final postsRes =
            await apiClient.dio.get('/users/${widget.username}/posts');
        postCount = (postsRes.data as List).length;
      } catch (_) {}

      if (mounted) {
        setState(() {
          _followers = res.data['followers'] ?? 0;
          _following = res.data['following'] ?? 0;
          _isFollowing = res.data['isFollowing'] ?? false;
          _postCount = postCount;
          _statsLoaded = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _statsLoaded = true);
    }
  }

  Future<void> _toggleFollow() async {
    if (_isFollowing == null) return;
    final wasFollowing = _isFollowing!;
    setState(() {
      _isFollowing = !wasFollowing;
      _followers += wasFollowing ? -1 : 1;
    });

    try {
      if (wasFollowing) {
        await apiClient.dio.delete('/users/${widget.username}/follow');
      } else {
        await apiClient.dio.post('/users/${widget.username}/follow');
      }
    } catch (_) {
      // Hata olursa geri al
      if (mounted) {
        setState(() {
          _isFollowing = wasFollowing;
          _followers += wasFollowing ? 1 : -1;
        });
      }
    }
  }

  Future<void> _startConversation(String targetUserId) async {
    try {
      final res = await apiClient.dio.post(
        '/messages/conversations/direct',
        data: {'userId': targetUserId},
      );
      final conversationId = res.data['id'];
      if (mounted && conversationId != null) {
        context.push('/messages/$conversationId');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Mesajlaşma başlatılamadı: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider(widget.username));

    if (!_statsLoaded) {
      _loadStats();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('@${widget.username}'),
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
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Kullanıcı bulunamadı: $e')),
        data: (profile) => SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundImage: profile['profilePhotoUrl'] != null
                          ? NetworkImage(profile['profilePhotoUrl'])
                          : null,
                      child: profile['profilePhotoUrl'] == null
                          ? Text(
                              (profile['fullName'] as String?)
                                      ?.substring(0, 1)
                                      .toUpperCase() ??
                                  '?',
                              style: const TextStyle(fontSize: 36),
                            )
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      profile['fullName'] ?? '',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      '@${profile['username'] ?? ''}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    if (profile['bio'] != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        profile['bio'],
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatItem(
                          label: 'Takipçi',
                          value: '$_followers',
                          onTap: () => context.push('/profile/${widget.username}/followers'),
                        ),
                        _StatItem(
                          label: 'Takip',
                          value: '$_following',
                          onTap: () => context.push('/profile/${widget.username}/following'),
                        ),
                        _StatItem(
                          label: 'Paylaşım',
                          value: '$_postCount',
                          onTap: () => context.push('/profile/${widget.username}/posts'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Takip butonu
                    if (_isFollowing != null)
                      Row(
                        children: [
                          Expanded(
                            child: _isFollowing!
                                ? OutlinedButton.icon(
                                    onPressed: _toggleFollow,
                                    icon: const Icon(Icons.person_remove),
                                    label: const Text('Takibi Bırak'),
                                  )
                                : FilledButton.icon(
                                    onPressed: _toggleFollow,
                                    icon: const Icon(Icons.person_add),
                                    label: const Text('Takip Et'),
                                  ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                final targetUserId =
                                    profile['userId'] ?? profile['user']?['id'];
                                if (targetUserId != null) {
                                  _startConversation(targetUserId);
                                }
                              },
                              icon: const Icon(Icons.chat_bubble_outline),
                              label: const Text('Mesaj'),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const Divider(),
              if (profile['department'] != null)
                ListTile(
                  leading: const Icon(Icons.school_outlined),
                  title: Text(profile['department']),
                  subtitle: const Text('Bölüm'),
                ),
              if (profile['studyLevel'] != null)
                ListTile(
                  leading: const Icon(Icons.workspace_premium_outlined),
                  title: Text(profile['studyLevel']),
                  subtitle: const Text('Eğitim seviyesi'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;
  const _StatItem({required this.label, required this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          children: [
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}