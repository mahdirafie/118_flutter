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
    Key? key,
    required this.favcatId,
    required this.title,
  }) : super(key: key);

  @override
  State<FavoriteCategoryDetail> createState() => _FavoriteCategoryDetailState();
}

class _FavoriteCategoryDetailState extends State<FavoriteCategoryDetail> {
  bool _isLoading = true;

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
        GetFavoriteCategoryFavorites(favcatId: widget.favcatId, userId: userId),
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

    return GestureDetector(
      onTap: () {
        // Navigate to contact detail
        context.go('/contact-detail/${favorite.cid}');
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
                color: color.withOpacity(0.1),
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
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 28, color: color),
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
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
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
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        typeLabel,
                        style: TextStyle(
                          fontSize: 11,
                          color: color,
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
