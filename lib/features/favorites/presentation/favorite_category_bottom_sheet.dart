// favorite_category_bottom_sheet.dart
import 'package:basu_118/core/auth_service/auth_service.dart';
import 'package:basu_118/features/home/presentation/bloc/home_bloc.dart';
import 'package:basu_118/widgets/app_snackbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:basu_118/features/favorites/presentation/bloc/favorite_bloc.dart';

class FavoriteCategoryBottomSheet {
  static Future<List<int>?> show({
    required BuildContext context,
    required int cid, // Added cid parameter
    List<int>? initiallySelectedIds,
  }) async {
    return await showModalBottomSheet<List<int>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return BlocProvider.value(
          value: BlocProvider.of<FavoriteBloc>(context),
          child: _FavoriteCategoryBottomSheetContent(
            cid: cid,
            initiallySelectedIds: initiallySelectedIds ?? [],
          ),
        );
      },
    );
  }
}

class _FavoriteCategoryBottomSheetContent extends StatefulWidget {
  final int cid; // Added cid
  final List<int> initiallySelectedIds;

  const _FavoriteCategoryBottomSheetContent({
    required this.cid,
    required this.initiallySelectedIds,
  });

  @override
  State<_FavoriteCategoryBottomSheetContent> createState() =>
      __FavoriteCategoryBottomSheetContentState();
}

class __FavoriteCategoryBottomSheetContentState
    extends State<_FavoriteCategoryBottomSheetContent> {
  late List<int> _selectedIds;
  bool _isNoneSelected = false;
  bool _isAdding = false;
  bool _hasHandledSuccess = false; // Add this flag

  @override
  void initState() {
    super.initState();
    _selectedIds = List.from(widget.initiallySelectedIds);
    _isNoneSelected = _selectedIds.isEmpty;

    // Trigger fetch on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoriteBloc>().add(GetFavoriteCategories());
    });
  }

  void _toggleSelection(int favcatId, String title) {
    setState(() {
      final isNoneCategory = _getDisplayTitle(title) == 'هیچکدام';

      if (isNoneCategory) {
        // If selecting "هیچکدام", clear all other selections
        _selectedIds.clear();
        _isNoneSelected = true;
      } else {
        // If selecting a regular category, unselect "هیچکدام" if selected
        _isNoneSelected = false;

        if (_selectedIds.contains(favcatId)) {
          _selectedIds.remove(favcatId);
        } else {
          _selectedIds.add(favcatId);
        }
      }
    });
  }

  bool _isSelected(int favcatId, String title) {
    if (_getDisplayTitle(title) == 'هیچکدام') {
      return _isNoneSelected;
    }
    return _selectedIds.contains(favcatId);
  }

  String _getDisplayTitle(String originalTitle) {
    return originalTitle == 'همه' ? 'هیچکدام' : originalTitle;
  }

  void _handleAdd(BuildContext context) {
    if (_isAdding) return; // Prevent multiple clicks

    // Reset the success flag
    _hasHandledSuccess = false;

    // If "هیچکدام" is selected, send empty list
    final List<int> favcatIds = _isNoneSelected ? [] : _selectedIds;

    // Dispatch the AddToFavorites event
    context.read<FavoriteBloc>().add(AddToFavorites(widget.cid, favcatIds));

    setState(() {
      _isAdding = true;
    });
  }

  void _handleStateChange(BuildContext context, FavoriteState state) {
    // Handle AddToFavorites success - only once
    if (state is AddToFavoritesSuccess && !_hasHandledSuccess) {
      _hasHandledSuccess = true;
      
      // Close the bottom sheet
      Navigator.of(context).pop(_selectedIds);
      
      // Refresh home data
      context.read<HomeBloc>().add(GetRelativeInfo(userId: AuthService().userInfo!.uid!));
      
      // Show success message
      showAppSnackBar(context, message: 'با موفقیت اضافه شد!', type: AppSnackBarType.success);
      
      // Reset adding state
      if (mounted) {
        setState(() {
          _isAdding = false;
        });
      }
    }

    // Handle AddToFavorites failure
    if (state is AddToFavoritesFailure) {
      // Show error message
      // TODO: FIX THIS
      showAppSnackBar(
        context,
        message: state.message,
        type: AppSnackBarType.error,
      );
      
      // Reset adding state
      if (mounted) {
        setState(() {
          _isAdding = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FavoriteBloc, FavoriteState>(
      listener: _handleStateChange,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          _buildHeader(),

          // Content area with BlocBuilder for categories
          BlocBuilder<FavoriteBloc, FavoriteState>(
            buildWhen: (previous, current) {
              // Only rebuild for these states
              return current is FavoriteCategoryLoading ||
                  current is FavoriteCategorySuccess ||
                  current is FavoriteCategoryFailure ||
                  current is AddToFavoritesLoading;
            },
            builder: (context, state) {
              return Flexible(
                fit: FlexFit.loose,
                child: SizedBox(
                  height: 400, // Fixed height or use constraints
                  child: _buildContent(state),
                ),
              );
            },
          ),

          // Buttons (always visible but can be disabled)
          _buildButtons(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'انتخاب دسته‌بندی',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade800,
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.grey.shade600, size: 24),
            onPressed: () {
              if (!_isAdding) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContent(FavoriteState state) {
    if (state is AddToFavoritesLoading) {
      return _buildAddingLoader();
    }

    if (state is FavoriteCategoryLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('در حال دریافت دسته‌بندی‌ها...'),
          ],
        ),
      );
    }

    if (state is FavoriteCategoryFailure) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                state.message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<FavoriteBloc>().add(GetFavoriteCategories());
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

    if (state is FavoriteCategorySuccess) {
      final categories = state.response.favoriteCategories;

      if (categories.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.category, size: 48, color: Colors.grey.shade300),
              SizedBox(height: 16),
              Text(
                'دسته‌بندی‌ای وجود ندارد',
                style: TextStyle(color: Colors.grey.shade500),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final displayTitle = _getDisplayTitle(category.title);
          final isSelected = _isSelected(category.favcatId, category.title);

          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isSelected ? Colors.blue : Colors.grey.shade200,
                width: 1,
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color:
                      isSelected ? Colors.blue.shade50 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  displayTitle == 'هیچکدام' ? Icons.block : Icons.category,
                  size: 20,
                  color: isSelected ? Colors.blue : Colors.grey.shade600,
                ),
              ),
              title: Text(
                displayTitle,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? Colors.blue : Colors.grey.shade800,
                ),
              ),
              trailing:
                  isSelected
                      ? Icon(Icons.check_circle, color: Colors.blue, size: 24)
                      : null,
              onTap:
                  _isAdding
                      ? null // Disable taps when adding
                      : () =>
                          _toggleSelection(category.favcatId, category.title),
            ),
          );
        },
      );
    }

    return Container(); // Initial state
  }

  Widget _buildAddingLoader() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'در حال افزودن به علاقه‌مندی‌ها...',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
        color: Colors.white,
      ),
      child: Row(
        children: [
          // Cancel Button
          Expanded(
            child: OutlinedButton(
              onPressed:
                  _isAdding
                      ? null
                      : () {
                        Navigator.of(context).pop();
                      },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'انصراف',
                style: TextStyle(
                  color:
                      _isAdding ? Colors.grey.shade400 : Colors.grey.shade700,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Add Button
          Expanded(
            child: ElevatedButton(
              onPressed: _isAdding ? null : () => _handleAdd(context),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isAdding ? Colors.grey.shade400 : Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child:
                  _isAdding
                      ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CupertinoActivityIndicator(),
                      )
                      : Text(
                        'افزودن',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }
}