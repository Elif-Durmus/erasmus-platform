import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_client.dart';

final universitiesListProvider =
    FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final res = await apiClient.dio.get('/users/universities');
  return res.data as List<dynamic>;
});

class ReviewsHomeScreen extends ConsumerStatefulWidget {
  const ReviewsHomeScreen({super.key});

  @override
  ConsumerState<ReviewsHomeScreen> createState() => _ReviewsHomeScreenState();
}

class _ReviewsHomeScreenState extends ConsumerState<ReviewsHomeScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(universitiesListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Değerlendirmeler'),
      ),
      body: Column(
        children: [
          // Arama çubuğu
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Üniversite ara...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
              onChanged: (val) => setState(() => _query = val.toLowerCase()),
            ),
          ),
          // Üniversite listesi
          Expanded(
            child: async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Hata: $e')),
              data: (universities) {
                // Arama filtresi
                final filtered = _query.isEmpty
                    ? universities
                    : universities.where((u) {
                        final name =
                            (u['name'] as String? ?? '').toLowerCase();
                        final shortName =
                            (u['shortName'] as String? ?? '').toLowerCase();
                        return name.contains(_query) ||
                            shortName.contains(_query);
                      }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off,
                            size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          _query.isEmpty
                              ? 'Üniversite bulunamadı'
                              : '"$_query" için sonuç yok',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) {
                    final u = filtered[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          child: const Icon(Icons.school),
                        ),
                        title: Text(
                          u['name'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle:
                            u['shortName'] != null ? Text(u['shortName']) : null,
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push(
                          '/reviews/university/${u['id']}',
                          extra: u['name'],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}