import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/feed/screens/feed_screen.dart';
import '../../features/feed/screens/create_post_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/questions/screens/questions_screen.dart';
import '../../features/questions/screens/question_detail_screen.dart';
import '../../features/messages/screens/conversations_screen.dart';
import '../../features/messages/screens/chat_screen.dart';
import '../../shared/screens/main_shell.dart';
import '../../features/auth/providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: authState.isAuthenticated ? '/feed' : '/login',
    redirect: (context, state) {
      final isAuth = authState.isAuthenticated;
      final isLoginPage = state.matchedLocation == '/login' || state.matchedLocation == '/register';
      if (!isAuth && !isLoginPage) return '/login';
      if (isAuth && isLoginPage) return '/feed';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      ShellRoute(
        builder: (ctx, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/feed', builder: (_, __) => const FeedScreen()),
          GoRoute(path: '/questions', builder: (_, __) => const QuestionsScreen()),
          GoRoute(path: '/messages', builder: (_, __) => const ConversationsScreen()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        ],
      ),
      GoRoute(path: '/posts/new', builder: (_, __) => const CreatePostScreen()),
      GoRoute(path: '/questions/new', builder: (_, __) => const QuestionDetailScreen(questionId: 'new')),
      GoRoute(
        path: '/questions/:id',
        builder: (_, state) => QuestionDetailScreen(questionId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/messages/:id',
        builder: (_, state) => ChatScreen(conversationId: state.pathParameters['id']!),
      ),
    ],
  );
});