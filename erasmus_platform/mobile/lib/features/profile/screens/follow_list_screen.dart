import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_client.dart';

class FollowListScreen extends ConsumerStatefulWidget {
  final String username;
  final String type; // 'followers' veya 'following'

  const FollowListScreen({
    super.key,
    required this.username,
    required this.type,
  });

  @override
  ConsumerState<FollowListScreen> createState() => _FollowListScreenState();
}

class _FollowListScreenState extends ConsumerState<FollowListScreen> {
  List<dynamic> _users = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await apiClient.dio
          .get('/users/${widget.username}/${widget.type}');
      if (mounted) {
        setState(() {
          _users = res.data as List<dynamic>;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.type == 'followers' ? 'Takipçiler' : 'Takip Edilenler';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.type == 'followers'
                            ? Icons.people_outline
                            : Icons.person_outline,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.type == 'followers'
                            ? 'Henüz takipçi yok'
                            : 'Henüz kimse takip edilmiyor',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _users.length,
                  itemBuilder: (ctx, i) {
                    final user = _users[i];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: user['profilePhotoUrl'] != null
                            ? NetworkImage(user['profilePhotoUrl'])
                            : null,
                        child: user['profilePhotoUrl'] == null
                            ? Text(
                                (user['fullName'] as String?)
                                        ?.substring(0, 1)
                                        .toUpperCase() ??
                                    '?',
                              )
                            : null,
                      ),
                      title: Text(
                        user['fullName'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text('@${user['username'] ?? ''}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/profile/${user['username']}'),
                    );
                  },
                ),
    );
  }
}