// favorite_category_detail.dart
import 'package:basu_118/core/auth_service/auth_service.dart';
import 'package:basu_118/features/favorites/dto/favorite_category_favorites_dto.dart';
import 'package:basu_118/features/favorites/presentation/bloc/favorite_bloc.dart';
import 'package:basu_118/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class FavoriteCategoryDetail extends StatefulWidget {
  final int favcatId;
  final String title;

  const FavoriteCategoryDetail({
    super.key,
    required this.favcatId,
    required this.title,
  });

  @override
  State<FavoriteCategoryDetail> createState() => _FavoriteCategoryDetailState();
}

class _FavoriteCategoryDetailState extends State<FavoriteCategoryDetail> {
  bool _isLoading = true;
  Set<int> _deletingItems = {}; // Track items being deleted

  @override
  void initState() {
    super.initState();

    // Fetch favorites on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchFavorites();
    });
  }

  void _fetchFavorites() {
    final userId = AuthService().userInfo?.uid;
    if (userId != null && widget.favcatId > 0) {
      context.read<FavoriteBloc>().add(
        GetFavoriteCategoryFavorites(favcatId: widget.favcatId),
      );
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'employee':
        return CupertinoIcons.person_fill;
      case 'post':
        return CupertinoIcons.briefcase_fill;
      case 'space':
        return CupertinoIcons.building_2_fill;
      default:
        return CupertinoIcons.question_circle_fill;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'employee':
        return Colors.blue;
      case 'post':
        return Colors.green;
      case 'space':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _showDeleteConfirmation(BuildContext context, FavoriteItemFavCatFavs favorite) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'حذف از علاقه‌مندی‌ها',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade800,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'آیا مطمئنید که می‌خواهید این مورد را از این دسته‌بندی حذف کنید؟',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _getTypeColor(favorite.type).withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getTypeIcon(favorite.type),
                          size: 18,
                          color: _getTypeColor(favorite.type),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              favorite.name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade800,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Text(
                              _getTypeLabel(favorite.type),
                              style: TextStyle(
                                fontSize: 12,
                                color: _getTypeColor(favorite.type),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(
                  'لغو',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  _deleteFavorite(favorite);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'حذف',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteFavorite(FavoriteItemFavCatFavs favorite) {
      showAppSnackBar(
        context,
        message: 'خطا در شناسایی کاربر',
        type: AppSnackBarType.error,
      );

    // Add to deleting items set
    setState(() {
      _deletingItems.add(favorite.cid);
    });

    // Dispatch delete event
    context.read<FavoriteBloc>().add(
      DeleteFromFavorites(cid: favorite.cid),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: Colors.grey.shade700),
          onPressed: () {
            context.pop();
            context.read<FavoriteBloc>().add(GetFavoriteCategories());
          },
        ),
        centerTitle: true,
        title: Text(
          widget.title,
          style: TextStyle(
            color: Colors.grey.shade800,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: BlocConsumer<FavoriteBloc, FavoriteState>(
        listener: (context, state) {
          if (state is GetFavoriteCategoryFavoritesFailure) {
            showAppSnackBar(
              context,
              message: state.message,
              type: AppSnackBarType.error,
            );
            setState(() {
              _isLoading = false;
            });
          }

          if (state is GetFavoriteCategoryFavoritesSuccess) {
            setState(() {
              _isLoading = false;
            });
          }

          // Handle delete success
          if (state is DeleteFromFavoritesSuccess) {
            // Clear deleting items
            setState(() {
              _deletingItems.clear();
            });
            
            // Show success message
            showAppSnackBar(
              context,
              message: 'با موفقیت حذف شد',
              type: AppSnackBarType.success,
            );
            
            // Refresh the list
            _fetchFavorites();
          }

          // Handle delete failure
          if (state is DeleteFromFavoritesFailure) {
            // Clear deleting items
            setState(() {
              _deletingItems.clear();
            });
            
            // Show error message
            showAppSnackBar(
              context,
              message: state.message,
              type: AppSnackBarType.error,
            );
          }
        },
        builder: (context, state) {
          return _buildBody(state);
        },
      ),
    );
  }

  Widget _buildBody(FavoriteState state) {
    if (_isLoading || state is GetFavoriteCategoryFavoritesLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoActivityIndicator(radius: 16),
            SizedBox(height: 16),
            Text(
              'در حال دریافت علاقه‌مندی‌ها...',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (state is GetFavoriteCategoryFavoritesFailure) {
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
                'خطا در دریافت اطلاعات',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchFavorites,
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

    if (state is GetFavoriteCategoryFavoritesSuccess) {
      final favorites = state.response.favorites;

      if (favorites.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.heart, size: 64, color: Colors.grey.shade300),
              SizedBox(height: 16),
              Text(
                'هنوز هیچ علاقه‌مندی در این دسته‌بندی وجود ندارد',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
              ),
              SizedBox(height: 8),
              Text(
                'می‌توانید از صفحه اصلی موارد را به این دسته‌بندی اضافه کنید',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          _fetchFavorites();
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final favorite = favorites[index];
              return _buildFavoriteCard(favorite);
            },
          ),
        ),
      );
    }

    // Initial state
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.heart, size: 48, color: Colors.grey.shade300),
          SizedBox(height: 16),
          Text(
            'در حال بارگذاری...',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteCard(FavoriteItemFavCatFavs favorite) {
    final icon = _getTypeIcon(favorite.type);
    final color = _getTypeColor(favorite.type);
    final typeLabel = _getTypeLabel(favorite.type);
    final isDeleting = _deletingItems.contains(favorite.cid);

    return GestureDetector(
      onTap: isDeleting
          ? null
          : () {
              // Navigate to contact detail
              context.push('/contact-detail/${favorite.cid}/${favorite.name}');
            },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDeleting ? Colors.grey.shade300 : Colors.grey.shade200,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDeleting ? 0.02 : 0.05),
                  blurRadius: 8,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon section
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: color.withOpacity(isDeleting ? 0.05 : 0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: color.withOpacity(isDeleting ? 0.1 : 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: isDeleting
                          ? CupertinoActivityIndicator(
                              radius: 14,
                              color: color,
                            )
                          : Icon(icon, size: 28, color: color),
                    ),
                  ),
                ),

                // Content section
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Title
                        Text(
                          favorite.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDeleting
                                ? Colors.grey.shade400
                                : Colors.black87,
                            height: 1.4,
                          ),
                        ),

                        // Type label
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(isDeleting ? 0.05 : 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            typeLabel,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDeleting
                                  ? Colors.grey.shade400
                                  : color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Remove icon button
          if (!isDeleting)
            Positioned(
              top: 8,
              left: 8,
              child: GestureDetector(
                onTap: () {
                  _showDeleteConfirmation(context, favorite);
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        spreadRadius: 0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    CupertinoIcons.trash,
                    size: 16,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'employee':
        return 'کارمند';
      case 'post':
        return 'پست';
      case 'space':
        return 'فضا';
      default:
        return 'ناشناس';
    }
  }
}