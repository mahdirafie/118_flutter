// app_router.dart - Complete corrected version
import 'package:basu_118/core/auth_service/auth_service.dart';
import 'package:basu_118/features/contact_detail/presentation/contact_detail_screen.dart';
import 'package:basu_118/features/error_screen.dart';
import 'package:basu_118/features/favorites/presentation/favorite_category_detail.dart';
import 'package:basu_118/features/favorites/presentation/favorites_screen.dart';
import 'package:basu_118/features/home/presentation/home_screen.dart';
import 'package:basu_118/features/profile/presentaion/profile_screen.dart';
import 'package:basu_118/features/splash_screen.dart';
import 'package:basu_118/widgets/scaffold_with_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/login/presentation/login_screen.dart';
import '../features/signup/presentation/signup_screen_s1.dart';
import '../features/signup/presentation/signup_screen_s2.dart';
import '../features/signup/presentation/signup_screen_s3.dart';

class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String favorites = '/favorites';
  static const String profile = '/profile';
  static const String contactDetail = '/contact-detail/:cid';
  static const String favCategoryDetail = '/favorite-category/:favcatId/:title';
}

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  static final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'shell');

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,

    errorBuilder: (context, state) => ErrorScreen(error: state.error!.message),

    redirect: (context, state) {
      final bool isLoggedIn = AuthService().isLoggedIn;
      final bool isOnSplashPage = state.matchedLocation == AppRoutes.splash;
      final bool isOnLoginPage = state.matchedLocation == AppRoutes.login;
      final bool isOnSignupPage = state.matchedLocation.startsWith(
        AppRoutes.signup,
      );

      // If on splash screen, show it briefly then redirect
      if (isOnSplashPage) {
        return null;
      }

      // For contact detail, allow access even if not logged in?
      // Or require login? Let's require login:
      if (!isLoggedIn && !isOnLoginPage && !isOnSignupPage) {
        return AppRoutes.login;
      }

      // Redirect to home if already logged in and on login/signup pages
      if (isLoggedIn && (isOnLoginPage || isOnSignupPage)) {
        return AppRoutes.home;
      }

      return null;
    },

    routes: [
      // Splash Screen
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Signup Flow
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignUpScreenS1(),
        routes: [
          GoRoute(
            path: 'step2',
            name: 'step2',
            builder: (context, state) => const SignupScreenS2(),
          ),
          GoRoute(
            path: 'step3',
            name: 'step3',
            builder: (context, state) => const SignupScreenS3(),
          ),
        ],
      ),

      // Authentication route
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Contact Detail Route (outside ShellRoute for full screen)
      GoRoute(
        path: AppRoutes.contactDetail,
        name: 'contactDetail',
        builder: (context, state) {
          final cid = int.tryParse(state.pathParameters['cid'] ?? '0') ?? 0;
          return ContactDetailScreen(cid: cid);
        },
      ),

      // Favorite Category Detail Route (outside ShellRoute for full screen)
      GoRoute(
        path: AppRoutes.favCategoryDetail,
        name: 'favCategoryDetail',
        builder: (context, state) {
          final favcatId =
              int.tryParse(state.pathParameters['favcatId'] ?? '0') ?? 0;
          final title = state.pathParameters['title'] ?? '';
          return FavoriteCategoryDetail(favcatId: favcatId, title: title);
        },
      ),

      // Shell route for bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return ScaffoldWithNavBar(child: child);
        },
        routes: [
          // Home Screen
          GoRoute(
            path: '/',
            name: 'homeShell',
            builder: (context, state) => const HomeScreen(),
          ),

          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),

          GoRoute(
            path: AppRoutes.favorites,
            name: 'favorites',
            builder: (context, state) => const FavoritesScreen(),
          ),

          GoRoute(
            path: AppRoutes.profile,
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );

  static void goToHome(BuildContext context) {
    context.go(AppRoutes.home);
  }

  static void goToLogin(BuildContext context) {
    context.go(AppRoutes.login);
  }

  static void goToContactDetail(BuildContext context, {required int cid}) {
    context.go('/contact-detail/$cid');
  }

  static void goToFavCategoryDetail(
    BuildContext context, {
    required int favcatId,
    required String title,
  }) {
    context.go('/favorite-category/$favcatId/${Uri.encodeComponent(title)}');
  }
}
