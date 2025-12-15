import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:basu_118/theme/app_colors.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.neutral[0],
        selectedItemColor: AppColors.primary[600],
        unselectedItemColor: AppColors.neutral[500],
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 12,
        ),
        elevation: 8,
        items: [
          BottomNavigationBarItem(
            icon: _buildNavIcon('assets/images/home.svg', 0, context),
            activeIcon: _buildNavIcon('assets/images/home-fill.svg', 0, context, isSelected: true),
            label: 'خانه',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon('assets/images/heart.svg', 1, context),
            activeIcon: _buildNavIcon('assets/images/heart-fill.svg', 1, context, isSelected: true),
            label: 'محبوب ها',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon('assets/images/user-circle.svg', 2, context),
            activeIcon: _buildNavIcon('assets/images/user-circle-fill.svg', 2, context, isSelected: true),
            label: 'حساب کاربری',
          ),
        ],
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
      ),
    );
  }

  Widget _buildNavIcon(String assetPath, int index, BuildContext context, {bool isSelected = false}) {
    final currentIndex = _calculateSelectedIndex(context);
    final isCurrentSelected = currentIndex == index;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isCurrentSelected && isSelected 
            ? AppColors.primary[50] 
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SvgPicture.asset(
        assetPath,
        width: 24,
        height: 24,
        colorFilter: ColorFilter.mode(
          isCurrentSelected && isSelected 
              ? AppColors.primary[600]! 
              : AppColors.neutral[500]!,
          BlendMode.srcIn,
        ),
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    if (location == '/' || location.startsWith('/home')) return 0;
    if (location.startsWith('/favorites')) return 1;
    if (location.startsWith('/profile')) return 2;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/home');
        break;
      case 1:
        GoRouter.of(context).go('/favorites');
        break;
      case 2:
        GoRouter.of(context).go('/profile');
        break;
    }
  }
}

// Navigation extension for easier usage
extension GoRouterExtension on BuildContext {
  void pushNamed(
    String name, {
    Map<String, String>? pathParameters,
    Map<String, dynamic>? queryParameters,
  }) {
    GoRouter.of(this).pushNamed(
      name,
      pathParameters: pathParameters ?? {},
      queryParameters: queryParameters ?? {},
    );
  }

  void goNamed(
    String name, {
    Map<String, String>? pathParameters,
    Map<String, dynamic>? queryParameters,
  }) {
    GoRouter.of(this).goNamed(
      name,
      pathParameters: pathParameters ?? {},
      queryParameters: queryParameters ?? {},
    );
  }
}
