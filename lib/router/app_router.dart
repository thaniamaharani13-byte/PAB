import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../blocs/auth/auth_bloc.dart';
import '../models/models.dart';
import '../screens/admin_screen.dart';
import '../screens/article_detail_screen.dart';
import '../screens/article_screen.dart';
import '../screens/edit_profile_screen.dart';
import '../screens/feedback_screen.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/register_screen.dart';
import '../screens/result_screen.dart';
import '../screens/shell_screen.dart';
import 'go_router_refresh_stream.dart';

class AppRouter {
  AppRouter(this.authBloc);

  final AuthBloc authBloc;

  late final GoRouter router = GoRouter(
    initialLocation: '/home',
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: _redirect,
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => ShellScreen(
          location: state.uri.path,
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/articles',
            builder: (context, state) => const ArticleScreen(),
            routes: [
              GoRoute(
                path: ':articleId',
                builder: (context, state) {
                  final id = state.pathParameters['articleId']!;
                  final fromExtra = state.extra is ArticleItem
                      ? state.extra as ArticleItem
                      : null;
                  return ArticleDetailScreen(
                    articleId: id,
                    initialArticle: fromExtra,
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'edit',
                builder: (context, state) => const EditProfileScreen(),
              ),
              GoRoute(
                path: 'feedback',
                builder: (context, state) => const FeedbackScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/result',
        builder: (context, state) {
          final result = state.extra is BmiResult ? state.extra as BmiResult : null;
          return ResultScreen(result: result);
        },
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminScreen(),
      ),
    ],
  );

  String? _redirect(BuildContext context, GoRouterState state) {
    final auth = authBloc.state;
    final location = state.uri.path;
    final isLogin = location == '/login';
    final isRegister = location == '/register';
    final needsUserAuth = location.startsWith('/profile');
    final needsAdminAuth = location.startsWith('/admin');

    if (auth.status == AuthStatus.initial || auth.status == AuthStatus.loading) {
      return null;
    }

    if (needsAdminAuth && !auth.isAdmin) {
      return '/login?redirect=${Uri.encodeComponent(state.uri.toString())}';
    }

    if (needsUserAuth && !auth.isAuthenticated) {
      return '/login?redirect=${Uri.encodeComponent(state.uri.toString())}';
    }

    if (isLogin && (auth.isAuthenticated || auth.isAdmin)) {
      final redirect = state.uri.queryParameters['redirect'];
      if (auth.isAdmin) {
        return redirect != null && redirect.startsWith('/admin')
            ? redirect
            : '/admin';
      }
      return redirect != null && redirect.isNotEmpty ? redirect : '/home';
    }

    if (isRegister && (auth.isAuthenticated || auth.isAdmin)) {
      return auth.isAdmin ? '/admin' : '/home';
    }

    return null;
  }
}
