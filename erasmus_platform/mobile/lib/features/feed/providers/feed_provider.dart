// lib/features/feed/providers/feed_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';

final feedProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final res = await apiClient.dio.get('/posts', queryParameters: {'page': 1, 'limit': 20});
  return res.data['posts'] as List<dynamic>;
});