// home_screen.dart
// ignore_for_file: use_build_context_synchronously

import 'package:basu_118/core/auth_service/auth_service.dart';
import 'package:basu_118/features/favorites/presentation/favorite_category_bottom_sheet.dart';
import 'package:basu_118/features/favorites/presentation/bloc/favorite_bloc.dart';
import 'package:basu_118/features/filter/presentation/filter.dart';
import 'package:basu_118/features/home/dto/home_response_dto.dart';
import 'package:basu_118/widgets/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:basu_118/features/home/presentation/bloc/home_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:basu_118/widgets/application_appbar.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Track loading states for each item
  final Map<String, bool> _favoriteLoadingStates = {};
  final Map<String, bool> _deleteLoadingStates = {};

  // Track which item is currently being processed
  // ignore: unused_field
  String? _currentFavoriteItemKey;
  String? _currentDeleteItemKey;

  @override
  void initState() {
    super.initState();
    // Trigger the event when home screen starts up
    WidgetsBinding.instance.addPostFrameCallback((_) {

      context.read<HomeBloc>().add(GetRelativeInfo());
    });
  }

  String _getItemKey(String type, int cid) {
    return '$type-$cid';
  }

  void _startFavoriteLoading(String key) {
    setState(() {
      _favoriteLoadingStates[key] = true;
    });
  }

  void _stopFavoriteLoading(String key) {
    setState(() {
      _favoriteLoadingStates.remove(key);
    });
  }

  void _startDeleteLoading(String key) {
    setState(() {
      _deleteLoadingStates[key] = true;
    });
  }

  void _stopDeleteLoading(String key) {
    setState(() {
      _deleteLoadingStates.remove(key);
    });
  }

  bool _isFavoriteLoading(String key) => _favoriteLoadingStates[key] == true;
  bool _isDeleteLoading(String key) => _deleteLoadingStates[key] == true;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<FavoriteBloc, FavoriteState>(
          listener: (context, state) {
            // Handle delete operations only
            if (state is DeleteFromFavoritesSuccess) {
              // Clear loading state for the specific item
              if (_currentDeleteItemKey != null) {
                _stopDeleteLoading(_currentDeleteItemKey!);
                _currentDeleteItemKey = null;
              }

              // Refresh home data when favorite is deleted
                context.read<HomeBloc>().add(GetRelativeInfo());
            }

            if (state is DeleteFromFavoritesFailure) {
              if (_currentDeleteItemKey != null) {
                _stopDeleteLoading(_currentDeleteItemKey!);
                _currentDeleteItemKey = null;
              }
            }

            // Note: AddToFavorites events are handled by the bottom sheet,
            // not by the home screen directly
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        drawer: const FullWidthDrawer(),
        body: SafeArea(
          child: Column(
            children: [
              // Custom AppBar
              const ApplicationAppBar(),

              // Filter Widget
              const FilterWidget(),

              // Main Content
              Expanded(
                child: BlocBuilder<HomeBloc, HomeState>(
                  builder: (context, state) {
                    return _buildContent(state);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(HomeState state) {
    if (state is RelativeInfoLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoActivityIndicator(radius: 16),
            SizedBox(height: 16),
            Text(
              'در حال دریافت اطلاعات...',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (state is RelativeInfoFailure) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.exclamationmark_circle,
              size: 48,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                state.message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                  context.read<HomeBloc>().add(GetRelativeInfo());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('تلاش مجدد'),
            ),
          ],
        ),
      );
    }

    if (state is RelativeInfoSuccess) {
      final response = state.response;
      final hasEmployees = response.employees.isNotEmpty;
      final hasPosts = response.posts.isNotEmpty;
      final hasSpaces = response.spaces.isNotEmpty;

      if (!hasEmployees && !hasPosts && !hasSpaces) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.person,
                size: 48,
                color: Colors.grey.shade300,
              ),
              SizedBox(height: 16),
              Text(
                'هیچ اطلاعاتی موجود نیست',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
            context.read<HomeBloc>().add(GetRelativeInfo());
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          children: [
            // Employees Section
            if (hasEmployees) ...[
              _buildSectionTitle('کارمندان'),
              const SizedBox(height: 12),
              ...response.employees.map(
                (employee) => _buildEmployeeItem(employee),
              ),
              const SizedBox(height: 24),
            ],

            // Posts Section
            if (hasPosts) ...[
              _buildSectionTitle('پست‌ها'),
              const SizedBox(height: 12),
              ...response.posts.map((post) => _buildPostItem(post)),
              const SizedBox(height: 24),
            ],

            // Spaces Section
            if (hasSpaces) ...[
              _buildSectionTitle('فضاها'),
              const SizedBox(height: 12),
              ...response.spaces.map((space) => _buildSpaceItem(space)),
              const SizedBox(height: 24),
            ],
          ],
        ),
      );
    }

    // Initial state
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.home, size: 48, color: Colors.grey.shade300),
          SizedBox(height: 16),
          Text(
            'در حال بارگذاری اطلاعات...',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade800,
      ),
    );
  }

  Widget _buildEmployeeItem(EmployeeHomeDTO employee) {
    final itemKey = _getItemKey('employee', employee.cid);
    final isFavoriteLoading = _isFavoriteLoading(itemKey);
    final isDeleteLoading = _isDeleteLoading(itemKey);
    final isLoading = isFavoriteLoading || isDeleteLoading;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap:
              isLoading
                  ? null
                  : () {
                    // Navigate to employee details
                    context.push(
                      '/contact-detail/${employee.cid}/${employee.fullName}',
                    );
                  },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200, width: 1),
            ),
            child: Row(
              children: [
                // Person Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    CupertinoIcons.person_fill,
                    size: 20,
                    color: Colors.blue.shade700,
                  ),
                ),

                SizedBox(width: 12),

                // Name and Post
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Employee Name (Bold)
                      Text(
                        employee.fullName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Employee Post (Caption style)
                      if (employee.post != null && employee.post!.isNotEmpty)
                        Text(
                          employee.post!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            height: 1.4,
                          ),
                        ),
                    ],
                  ),
                ),

                // Favorite Icon with loading state
                SizedBox(
                  width: 32,
                  height: 32,
                  child: _buildFavoriteButton(
                    itemKey: itemKey,
                    isFavorite: employee.isFavorite,
                    cid: employee.cid,
                    type: 'employee',
                    color: Colors.blue,
                    isLoading: isLoading,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPostItem(PostHomeDTO post) {
    final itemKey = _getItemKey('post', post.cid);
    final isFavoriteLoading = _isFavoriteLoading(itemKey);
    final isDeleteLoading = _isDeleteLoading(itemKey);
    final isLoading = isFavoriteLoading || isDeleteLoading;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap:
              isLoading
                  ? null
                  : () {
                    // Navigate to post details
                    context.push('/contact-detail/${post.cid}/${post.pname}');
                  },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200, width: 1),
            ),
            child: Row(
              children: [
                // Post Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    CupertinoIcons.briefcase_fill,
                    size: 20,
                    color: Colors.green.shade700,
                  ),
                ),

                SizedBox(width: 12),

                // Post Name and Employee
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Post Name (Bold)
                      Text(
                        post.pname,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Employee Name (Caption style)
                      if (post.employee != null && post.employee!.isNotEmpty)
                        Text(
                          post.employee!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            height: 1.4,
                          ),
                        ),
                    ],
                  ),
                ),

                // Favorite Icon with loading state
                SizedBox(
                  width: 32,
                  height: 32,
                  child: _buildFavoriteButton(
                    itemKey: itemKey,
                    isFavorite: post.isFavorite,
                    cid: post.cid,
                    type: 'post',
                    color: Colors.green,
                    isLoading: isLoading,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpaceItem(SpaceHomeDTO space) {
    final itemKey = _getItemKey('space', space.cid);
    final isFavoriteLoading = _isFavoriteLoading(itemKey);
    final isDeleteLoading = _isDeleteLoading(itemKey);
    final isLoading = isFavoriteLoading || isDeleteLoading;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap:
              isLoading
                  ? null
                  : () {
                    // Navigate to space details
                    context.push('/contact-detail/${space.cid}/${space.sname}');
                  },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200, width: 1),
            ),
            child: Row(
              children: [
                // Space Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    CupertinoIcons.building_2_fill,
                    size: 20,
                    color: Colors.orange.shade700,
                  ),
                ),

                SizedBox(width: 12),

                // Space Name and Post
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Space Name (Bold)
                      Text(
                        space.sname,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Post Name (Caption style)
                      if (space.post != null && space.post!.isNotEmpty)
                        Text(
                          space.post!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            height: 1.4,
                          ),
                        ),
                    ],
                  ),
                ),

                // Favorite Icon with loading state
                SizedBox(
                  width: 32,
                  height: 32,
                  child: _buildFavoriteButton(
                    itemKey: itemKey,
                    isFavorite: space.isFavorite,
                    cid: space.cid,
                    type: 'space',
                    color: Colors.orange,
                    isLoading: isLoading,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFavoriteButton({
    required String itemKey,
    required bool isFavorite,
    required int cid,
    required String type,
    required Color color,
    required bool isLoading,
  }) {
    if (isLoading) {
      return Center(
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      );
    }

    return InkWell(
      onTap: () async {
        if (isFavorite) {
          // Delete from favorites - handled by home screen
          _startDeleteLoading(itemKey);
          _currentDeleteItemKey = itemKey;

          final userId = AuthService().userInfo?.uid;
          if (userId != null) {
            context.read<FavoriteBloc>().add(
              DeleteFromFavorites(cid: cid),
            );
          } else {
            _stopDeleteLoading(itemKey);
            _currentDeleteItemKey = null;
          }
        } else {
          // Add to favorites - show bottom sheet only
          _startFavoriteLoading(itemKey);
          _currentFavoriteItemKey = itemKey;

          // Show bottom sheet and wait for result
          final selectedIds = await FavoriteCategoryBottomSheet.show(
            context: context,
            cid: cid,
          );

          // Stop loading regardless of result
          _stopFavoriteLoading(itemKey);
          _currentFavoriteItemKey = null;

          // If user selected categories, refresh home data
          if (selectedIds != null && selectedIds.isNotEmpty) {
              // Wait a bit to allow bottom sheet to close completely
              await Future.delayed(const Duration(milliseconds: 300));
              context.read<HomeBloc>().add(GetRelativeInfo());
          }
          // If selectedIds is null, user cancelled - no action needed
          // If selectedIds is empty array, user selected "none" - still need to refresh
          else if (selectedIds != null && selectedIds.isEmpty) {
              await Future.delayed(const Duration(milliseconds: 300));
              context.read<HomeBloc>().add(GetRelativeInfo());
          }
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(4),
        child: Icon(
          isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
          size: 20,
          color: isFavorite ? color : Colors.grey.shade400,
        ),
      ),
    );
  }
}
