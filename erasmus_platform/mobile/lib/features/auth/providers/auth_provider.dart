import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/storage/token_storage.dart';

class AuthState {
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;
  final bool isInitializing;
  final Map<String, dynamic>? user;

  const AuthState({
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
    this.isInitializing = true,
    this.user,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
    bool? isInitializing,
    Map<String, dynamic>? user,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isInitializing: isInitializing ?? this.isInitializing,
      user: user ?? this.user,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _checkToken();
  }

  Future<void> _checkToken() async {
    // Splash'ın görünmesi için minik bir gecikme (en az 1.5 sn)
    await Future.delayed(const Duration(milliseconds: 1500));
    final has = await TokenStorage.hasToken();
    state = state.copyWith(
      isAuthenticated: has,
      isInitializing: false,
    );
  }

  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    required String username,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await apiClient.dio.post('/auth/register', data: {
        'email': email,
        'password': password,
        'fullName': fullName,
        'username': username,
      });
      await TokenStorage.saveToken(res.data['token']);
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        isInitializing: false,
        user: res.data['user'],
      );
      return true;
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Kayıt başarısız';
      state = state.copyWith(
        isLoading: false,
        error: msg is List ? msg.join(', ') : msg.toString(),
      );
      return false;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await apiClient.dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      await TokenStorage.saveToken(res.data['token']);
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        isInitializing: false,
        user: res.data['user'],
      );
      return true;
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Giriş başarısız';
      state = state.copyWith(isLoading: false, error: msg.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await TokenStorage.deleteToken();
    state = const AuthState(isAuthenticated: false, isInitializing: false);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);