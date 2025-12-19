import 'package:basu_118/features/favorites/presentation/update_favcat_dialog.dart';
import 'package:basu_118/router/app_router.dart';
import 'package:basu_118/widgets/app_snackbar.dart';
import 'package:basu_118/widgets/custom_drawer.dart';
import 'package:basu_118/features/favorites/presentation/delete_favcat_confirmation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:basu_118/features/favorites/presentation/bloc/favorite_bloc.dart';
import 'package:basu_118/theme/app_colors.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger GetFavoriteCategories on screen startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoriteBloc>().add(GetFavoriteCategories());
    });
  }

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
                    Text(
                      'محبوب ها',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 10),

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
                      return const Center(child: CupertinoActivityIndicator());
                    }
                    if (state is FavoriteCategoryFailure) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.exclamationmark_circle,
                              size: 48,
                              color: AppColors.neutral[400],
                            ),
                            SizedBox(height: 16),
                            Text(
                              state.message,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.neutral[600]),
                            ),
                            SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () {
                                context.read<FavoriteBloc>().add(
                                  GetFavoriteCategories(),
                                );
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
                      final items = state.response.favoriteCategories;
                      if (items.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.heart,
                                size: 64,
                                color: AppColors.neutral[300],
                              ),
                              SizedBox(height: 16),
                              Text(
                                'هیچ دسته‌بندی‌ای وجود ندارد',
                                style: TextStyle(
                                  color: AppColors.neutral[500],
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'برای شروع روی دکمه + کلیک کنید',
                                style: TextStyle(
                                  color: AppColors.neutral[400],
                                  fontSize: 14,
                                ),
                              ),
                            ],
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
                              AppRouter.goToFavCategoryDetail(context, favcatId: item.favcatId, title: item.title);
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

                    // Initial state - show loading
                    return const Center(child: CupertinoActivityIndicator());
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

            // Refresh the list
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
