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
import '../../features/feed/screens/post_detail_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/questions/screens/create_question_screen.dart';
import '../../features/profile/screens/exchange_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/profile/screens/user_profile_screen.dart';
import '../../features/reviews/screens/reviews_home_screen.dart';
import '../../features/reviews/screens/university_reviews_screen.dart';
import '../../features/reviews/screens/create_review_screen.dart';
import '../../features/search/screens/search_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/profile/screens/follow_list_screen.dart';
import '../../features/profile/screens/user_posts_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isInitializing = authState.isInitializing;
      final isAuth = authState.isAuthenticated;
      final loc = state.matchedLocation;

      // Henüz token kontrol ediliyor → splash'ta kal
      if (isInitializing) {
        return loc == '/splash' ? null : '/splash';
      }

      // Kontrol bitti, splash'tan çık
      final isLoginPage = loc == '/login' || loc == '/register';
      if (loc == '/splash') {
        return isAuth ? '/feed' : '/login';
      }

      if (!isAuth && !isLoginPage) return '/login';
      if (isAuth && isLoginPage) return '/feed';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
      ShellRoute(
        builder: (ctx, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/feed', builder: (_, _) => const FeedScreen()),
          GoRoute(path: '/questions', builder: (_, _) => const QuestionsScreen()),
          GoRoute(path: '/messages', builder: (_, _) => const ConversationsScreen()),
          GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
          GoRoute(path: '/reviews', builder: (_, _) => const ReviewsHomeScreen()),
        ],
      ),
      GoRoute(path: '/posts/new', builder: (_, _) => const CreatePostScreen()),
      GoRoute(path: '/questions/new', builder: (_, _) => const CreateQuestionScreen()),      
      GoRoute(
        path: '/questions/:id',
        builder: (_, state) => QuestionDetailScreen(questionId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/messages/:id',
        builder: (_, state) => ChatScreen(conversationId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/posts/:id',
        builder: (_, state) => PostDetailScreen(postId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (_, _) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/profile/exchanges',
        builder: (_, _) => const ExchangeScreen(),
      ),
      GoRoute(
        path: '/profile/:username/followers',
        builder: (_, state) => FollowListScreen(
          username: state.pathParameters['username']!,
          type: 'followers',
        ),
      ),
      GoRoute(
        path: '/profile/:username/following',
        builder: (_, state) => FollowListScreen(
          username: state.pathParameters['username']!,
          type: 'following',
        ),
      ),
      GoRoute(
        path: '/profile/:username/posts',
        builder: (_, state) => UserPostsScreen(
          username: state.pathParameters['username']!,
        ),
      ),
      // Sonra dinamik :username
      GoRoute(
        path: '/profile/:username',
        builder: (_, state) => UserProfileScreen(username: state.pathParameters['username']!),
      ),
      GoRoute(
        path: '/notifications',
        builder: (_, _) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (_, _) => const SearchScreen(),
      ),
      GoRoute(
        path: '/reviews/university/:id',
        builder: (_, state) => UniversityReviewsScreen(
          universityId: state.pathParameters['id']!,
          universityName: state.extra as String? ?? 'Üniversite',
        ),
      ),
      GoRoute(
        path: '/reviews/university/:id/new',
        builder: (_, state) => CreateReviewScreen(
          universityId: state.pathParameters['id']!,
          universityName: state.extra as String? ?? 'Üniversite',
        ),
      ),
    ],
  );
});