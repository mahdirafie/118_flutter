// lib/router/app_router.dart
import 'package:basu_118/core/auth_service/auth_service.dart';
import 'package:basu_118/features/error_screen.dart';
import 'package:basu_118/features/favorites/presentation/favorite_category_detail.dart';
import 'package:basu_118/features/favorites/presentation/favorites_screen.dart';
import 'package:basu_118/features/home/presentation/home_screen.dart';
import 'package:basu_118/features/profile/presentaion/profile_screen.dart';
import 'package:basu_118/widgets/scaffold_with_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// Import your screens
import '../features/login/presentation/login_screen.dart';
import '../features/signup/presentation/signup_screen_s1.dart';
import '../features/signup/presentation/signup_screen_s2.dart';
import '../features/signup/presentation/signup_screen_s3.dart';

// Define route names as constants
class AppRoutes {
  static const String home = '/home';
  static const String login = '/login';
  static const String signup = '/signup';
}

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  static final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'shell');

  // Main router configuration
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.login,

    // Debug logging (disable in production)
    debugLogDiagnostics: true,

    // Error handling
    errorBuilder: (context, state) => ErrorScreen(error: state.error!.message),

    // Optional: Redirect logic for authentication
    // redirect: (context, state) {
    //   final bool isLoggedIn = _checkAuthStatus(); // Your auth logic
    //   final bool isOnLoginPage = state.matchedLocation == AppRoutes.login;
    //   final bool isOnSignupPage = state.matchedLocation == AppRoutes.signup;

    //   // Redirect to login if not authenticated
    //   if (!isLoggedIn && !isOnLoginPage && !isOnSignupPage) {
    //     return AppRoutes.login;
    //   }

    //   // Redirect to home if already logged in and on login page or signup page
    //   if (isLoggedIn && (isOnLoginPage || isOnSignupPage)) {
    //     return AppRoutes.home;
    //   }

    //   return null; // No redirect needed
    // },

    routes: [
      GoRoute(
        path: AppRoutes.signup,
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

      // Shell route for bottom navigation (optional)
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return ScaffoldWithNavBar(child: child);
        },
        routes: [
          GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/favorites',
            builder: (context, state) => const FavoritesScreen(),
            routes: [
              GoRoute(
                path: 'favorite-category-detail/:favoriteCategoryTitle',
                name: 'favoriteCategoryDetail',
                builder:
                    (context, state) => FavoriteCategoryDetail(
                      favoriteCategoryTitle:
                          state.pathParameters['favoriteCategoryTitle'] ?? '',
                    ),
              ),
            ],
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );

  // Helper method to check authentication status
  // ignore: unused_element
  static bool _checkAuthStatus() {
    return AuthService().isLoggedIn;
  }
}
