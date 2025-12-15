import 'package:basu_118/features/favorites/presentation/update_favcat_dialog.dart';
import 'package:basu_118/widgets/app_snackbar.dart';
import 'package:basu_118/widgets/custom_drawer.dart';
import 'package:basu_118/features/favorites/presentation/delete_favcat_confirmation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:basu_118/features/favorites/presentation/bloc/favorite_bloc.dart';
// import 'package:basu_118/features/favorites/data/favorite_repository_impl.dart';
// import 'package:basu_118/core/config/api_service.dart';
import 'package:basu_118/theme/app_colors.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddCategoryDialog(
            BlocProvider.of<FavoriteBloc>(context),
            context,
          );
        },
        child: const Icon(Icons.add),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      drawer: const FullWidthDrawer(),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(53, 37, 100, 235),
                      blurRadius: 6,
                      spreadRadius: 0,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon(CupertinoIcons.back),
                    Text(
                      'محبوب ها',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    // Icon(CupertinoIcons.ellipsis_vertical),
                  ],
                ),
              ),

              SizedBox(height: 10,),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'دسته بندی ها',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
              Expanded(
                child: BlocBuilder<FavoriteBloc, FavoriteState>(
                  builder: (context, state) {
                    if (state is FavoriteCategoryLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is FavoriteCategoryFailure) {
                      return Center(
                        child: Text(
                          state.message,
                          style: TextStyle(color: AppColors.error800),
                        ),
                      );
                    }
                    if (state is FavoriteCategorySuccess) {
                      final items = state.response.favoriteCategories;
                      if (items.isEmpty) {
                        return Center(
                          child: Text(
                            'موردی یافت نشد',
                            style: TextStyle(color: AppColors.neutral[600]),
                          ),
                        );
                      }
                      return GridView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 3 / 2,
                            ),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return InkWell(
                            onTap: () {
                              context.push(
                                '/favorites/favorite-category-detail/${Uri.encodeComponent(item.title)}',
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.neutral[0],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.neutral[200]!,
                                  width: 1,
                                ),
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _timeAgo(
                                          DateTime.parse(item.createdAt),
                                        ),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.neutral[600],
                                        ),
                                      ),
                                      if (item.title != 'همه')
                                        GestureDetector(
                                          behavior: HitTestBehavior.opaque,
                                          onTap: () {
                                            showUpdateFavoriteCategoryDialog(
                                              context: context,
                                              currentCategoryName: item.title,
                                              categoryId: item.favcatId,
                                            );
                                          },
                                          child: Icon(
                                            CupertinoIcons.pen,
                                            size: 20,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        item.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.neutral[900],
                                        ),
                                      ),
                                      if (item.title != 'همه')
                                        GestureDetector(
                                          behavior: HitTestBehavior.opaque,
                                          onTap: () {
                                            showDeleteFavoriteCategoryDialog(
                                              context: context,
                                              categoryName: item.title,
                                              categoryId: item.favcatId,
                                            );
                                          },
                                          child: Icon(
                                            CupertinoIcons.delete,
                                            size: 20,
                                            color: Colors.red,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddCategoryDialog(FavoriteBloc bloc, BuildContext rootContext) {
    final titleController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: rootContext,
      barrierDismissible: false,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: bloc,
          child: _buildDialog(dialogContext, titleController, formKey),
        );
      },
    );
  }

  Widget _buildDialog(
    BuildContext dialogContext,
    TextEditingController titleController,
    GlobalKey<FormState> formKey,
  ) {
    final favoriteBloc = dialogContext.read<FavoriteBloc>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocConsumer<FavoriteBloc, FavoriteState>(
        listener: (context, state) {
          if (state is CreateFavoriteCategorySuccess) {
            Navigator.of(dialogContext).pop();

            showAppSnackBar(
              context,
              message: 'دسته بندی با موفقیت ایجاد شد!',
              type: AppSnackBarType.success,
            );

            favoriteBloc.add(GetFavoriteCategories());
          }

          if (state is CreateFavoriteCategoryFailure) {
            showAppSnackBar(
              context,
              message: state.message,
              type: AppSnackBarType.error,
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is CreateFavoriteCategoryLoading;

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),

            title: const Text(
              'افزودن دسته بندی جدید',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),

            content: Form(
              key: formKey,
              child: TextFormField(
                controller: titleController,
                enabled: !isLoading,
                decoration: InputDecoration(
                  labelText: 'نام دسته‌بندی',
                  labelStyle: const TextStyle(fontSize: 14),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),

                  // Always outlined
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(dialogContext).colorScheme.primary,
                      width: 1.8,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'لطفا نام دسته بندی را وارد کنید';
                  }
                  return null;
                },
              ),
            ),

            actions: [
              TextButton(
                onPressed:
                    isLoading ? null : () => Navigator.of(dialogContext).pop(),
                child: Text(
                  'لغو',
                  style: TextStyle(
                    color: isLoading ? Colors.grey : Colors.red,
                    fontSize: 14,
                  ),
                ),
              ),

              ElevatedButton(
                onPressed:
                    isLoading
                        ? null
                        : () {
                          if (formKey.currentState!.validate()) {
                            favoriteBloc.add(
                              CreateFavoriteCategory(
                                categoryTitle: titleController.text.trim(),
                              ),
                            );
                          }
                        },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor:
                      isLoading
                          ? Colors.grey
                          : Theme.of(dialogContext).primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child:
                    isLoading
                        ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Text(
                          'ذخیره',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
              ),
            ],
          );
        },
      ),
    );
  }
}

String _timeAgo(DateTime date) {
  final now = DateTime.now();
  final diff = now.difference(date);
  if (diff.inSeconds < 60) return 'چند لحظه پیش';
  if (diff.inMinutes < 60) return '${diff.inMinutes} دقیقه پیش';
  if (diff.inHours < 24) return '${diff.inHours} ساعت پیش';
  if (diff.inDays < 7) return '${diff.inDays} روز پیش';
  final weeks = (diff.inDays / 7).floor();
  if (weeks < 4) return '$weeks هفته پیش';
  final months = (diff.inDays / 30).floor();
  if (months < 12) return '$months ماه پیش';
  final years = (diff.inDays / 365).floor();
  return '$years سال پیش';
}
