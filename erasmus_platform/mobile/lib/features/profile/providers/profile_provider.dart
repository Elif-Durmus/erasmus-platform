import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';

final myProfileProvider = FutureProvider.autoDispose((ref) async {
  final res = await apiClient.dio.get('/users/me');
  return res.data as Map<String, dynamic>;
});

final userProfileProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>((ref, username) async {
  final res = await apiClient.dio.get('/users/$username');
  return res.data as Map<String, dynamic>;
});