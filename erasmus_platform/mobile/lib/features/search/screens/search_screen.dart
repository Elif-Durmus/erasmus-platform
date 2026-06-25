import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_client.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchCtrl = TextEditingController();

  List<dynamic> _users = [];
  List<dynamic> _posts = [];
  List<dynamic> _questions = [];
  bool _loading = false;
  String _lastQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().length < 2) {
      setState(() {
        _users = [];
        _posts = [];
        _questions = [];
      });
      return;
    }

    if (query == _lastQuery) return;
    _lastQuery = query;

    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        apiClient.dio
            .get('/users/search', queryParameters: {'q': query})
            .catchError((e) => e.response ?? (throw e)),
        apiClient.dio
            .get('/posts/search', queryParameters: {'q': query})
            .catchError((e) => e.response ?? (throw e)),
        apiClient.dio
            .get('/questions/search', queryParameters: {'q': query})
            .catchError((e) => e.response ?? (throw e)),
      ]);

      if (mounted) {
        setState(() {
          _users = results[0].data is List ? results[0].data as List : [];
          _posts = results[1].data is List ? results[1].data as List : [];
          _questions = results[2].data is List ? results[2].data as List : [];
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        title: TextField(
          controller: _searchCtrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Kullanıcı, post veya soru ara...',
            border: InputBorder.none,
            suffixIcon: _searchCtrl.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchCtrl.clear();
                      setState(() {
                        _users = [];
                        _posts = [];
                        _questions = [];
                        _lastQuery = '';
                      });
                    },
                  )
                : null,
          ),
          onChanged: (val) {
            setState(() {});
            Future.delayed(const Duration(milliseconds: 500), () {
              if (_searchCtrl.text == val) _search(val);
            });
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Kullanıcılar (${_users.length})'),
            Tab(text: 'Postlar (${_posts.length})'),
            Tab(text: 'Sorular (${_questions.length})'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _UserResults(users: _users),
                _PostResults(posts: _posts),
                _QuestionResults(questions: _questions),
              ],
            ),
    );
  }
}

class _UserResults extends StatelessWidget {
  final List<dynamic> users;
  const _UserResults({required this.users});

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Kullanıcı bulunamadı', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (ctx, i) {
        final user = users[i];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: user['profilePhotoUrl'] != null
                ? NetworkImage(user['profilePhotoUrl'])
                : null,
            child: user['profilePhotoUrl'] == null
                ? Text((user['fullName'] as String?)
                        ?.substring(0, 1)
                        .toUpperCase() ??
                    '?')
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
    );
  }
}

class _PostResults extends StatelessWidget {
  final List<dynamic> posts;
  const _PostResults({required this.posts});

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
    if (posts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Post bulunamadı', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (ctx, i) {
        final post = posts[i];
        final profile = post['user']?['profile'] as Map<String, dynamic>?;
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            title: Text(
              post['title'] ?? post['content'] ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${profile?['fullName'] ?? ''} • ${_typeLabel(post['postType'] ?? '')}',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/posts/${post['id']}'),
          ),
        );
      },
    );
  }
}

class _QuestionResults extends StatelessWidget {
  final List<dynamic> questions;
  const _QuestionResults({required this.questions});

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.help_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Soru bulunamadı', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: questions.length,
      itemBuilder: (ctx, i) {
        final q = questions[i];
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.help_outline)),
          title: Text(
            q['title'] ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text('${q['answerCount'] ?? 0} cevap'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push('/questions/${q['id']}'),
        );
      },
    );
  }
}