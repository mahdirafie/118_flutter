import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:basu_118/theme/app_colors.dart';
import 'package:basu_118/core/auth_service/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller1;
  late final AnimationController _controller2;
  late final AnimationController _controller3;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _controller1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
      lowerBound: 0.8,
      upperBound: 1.2,
    )..repeat(reverse: true);

    _controller2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
      lowerBound: 0.8,
      upperBound: 1.2,
    )..repeat(reverse: true);

    _controller3 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
      lowerBound: 0.8,
      upperBound: 1.2,
    )..repeat(reverse: true);

    // Start navigation after delay
    _startNavigation();
  }

  void _startNavigation() {
    // Navigate after 3 seconds (or however long you want the splash to show)
    _navigationTimer = Timer(const Duration(seconds: 3), () {
      _navigateToNextScreen();
    });
  }

  void _navigateToNextScreen() {
    // Check authentication status
    final isLoggedIn = AuthService().isLoggedIn;

    // Navigate based on auth status
    if (isLoggedIn) {
      // If logged in, go to home screen
      if (mounted) {
        context.go('/home');
      }
    } else {
      // If not logged in, go to login screen
      if (mounted) {
        context.go('/login');
      }
    }
  }

  @override
  void dispose() {
    // Dispose all controllers and timer
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Container(color: AppColors.primary),

          // Biggest circle
          OverflowBox(
            maxWidth: double.infinity,
            maxHeight: double.infinity,
            child: ScaleTransition(
              scale: _controller1,
              child: Container(
                width: 469,
                height: 469,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.shade500,
                ),
              ),
            ),
          ),

          // Middle circle
          OverflowBox(
            maxWidth: double.infinity,
            maxHeight: double.infinity,
            child: ScaleTransition(
              scale: _controller2,
              child: Container(
                width: 357,
                height: 357,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.shade600,
                ),
              ),
            ),
          ),

          // Smallest circle with content
          ScaleTransition(
            scale: _controller3,
            child: Container(
              width: 245,
              height: 245,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.shade700,
              ),
            ),
          ),

          SizedBox(
            width: 245,
            height: 245,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.call, size: 40, color: Colors.white),
                SizedBox(height: 10),
                Text(
                  'یونیتل',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Version text
          const Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Text("نسخه 0.1", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
