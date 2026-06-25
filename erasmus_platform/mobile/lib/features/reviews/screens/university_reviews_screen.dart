import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_client.dart';

final universityReviewsProvider = FutureProvider.autoDispose
    .family<List<dynamic>, String>((ref, universityId) async {
  final res = await apiClient.dio.get('/reviews/university/$universityId');
  return res.data as List<dynamic>;
});

final universityAveragesProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, String>((ref, universityId) async {
  final res = await apiClient.dio.get('/reviews/university/$universityId/averages');
  return res.data as Map<String, dynamic>;
});

class UniversityReviewsScreen extends ConsumerWidget {
  final String universityId;
  final String universityName;

  const UniversityReviewsScreen({
    super.key,
    required this.universityId,
    required this.universityName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(universityReviewsProvider(universityId));
    final averagesAsync = ref.watch(universityAveragesProvider(universityId));

    return Scaffold(
      appBar: AppBar(
        title: Text(universityName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.refresh(universityReviewsProvider(universityId));
          ref.refresh(universityAveragesProvider(universityId));
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Ortalama puanlar
            averagesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => const SizedBox(),
              data: (data) {
                final averages = data['averages'] as Map<String, dynamic>?;
                final count = data['count'] ?? 0;
                if (averages == null) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('Henüz değerlendirme yok ($count)'),
                    ),
                  );
                }
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ortalama Puanlar ($count değerlendirme)',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 12),
                        _RatingBar(label: 'Akademik', score: averages['academic']),
                        _RatingBar(label: 'Sosyal Yaşam', score: averages['social']),
                        _RatingBar(label: 'Konaklama', score: averages['housing']),
                        _RatingBar(label: 'Ulaşım', score: averages['transport']),
                        _RatingBar(label: 'Güvenlik', score: averages['safety']),
                        _RatingBar(label: 'Yaşam Maliyeti', score: averages['cost']),
                        _RatingBar(label: 'Destek', score: averages['support']),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Text('Değerlendirmeler',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            // Değerlendirme listesi
            reviewsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Hata: $e'),
              data: (reviews) => reviews.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: Text('İlk değerlendirmeyi sen yap!',
                            style: TextStyle(color: Colors.grey)),
                      ),
                    )
                  : Column(
                      children: reviews.map<Widget>((r) {
                        final profile = r['user']?['profile'] as Map<String, dynamic>?;
                        final isAnonymous = r['isAnonymous'] == true;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      child: isAnonymous
                                          ? const Icon(Icons.person_outline, size: 16)
                                          : Text(
                                              (profile?['fullName'] as String?)
                                                      ?.substring(0, 1)
                                                      .toUpperCase() ??
                                                  '?',
                                            ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isAnonymous
                                          ? 'Anonim'
                                          : profile?['fullName'] ?? 'Kullanıcı',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                if (r['title'] != null) ...[
                                  const SizedBox(height: 8),
                                  Text(r['title'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ],
                                const SizedBox(height: 4),
                                Text(r['content'] ?? ''),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(
          '/reviews/university/$universityId/new',
          extra: universityName,
        ),
        icon: const Icon(Icons.rate_review),
        label: const Text('Değerlendir'),
      ),
    );
  }
}

class _RatingBar extends StatelessWidget {
  final String label;
  final dynamic score;

  const _RatingBar({required this.label, required this.score});

  @override
  Widget build(BuildContext context) {
    final value = score is num ? score.toDouble() : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(fontSize: 13))),
          Expanded(
            child: LinearProgressIndicator(
              value: value != null ? value / 5 : 0,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 30,
            child: Text(
              value != null ? value.toStringAsFixed(1) : '-',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}