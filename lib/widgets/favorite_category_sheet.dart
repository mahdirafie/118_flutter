import 'package:basu_118/core/config/api_service.dart';
import 'package:basu_118/features/favorites/data/favorite_repository_impl.dart';
// import 'package:basu_118/features/favorites/dto/favorite_category_dto.dart';
import 'package:basu_118/features/favorites/presentation/bloc/favorite_bloc.dart';
import 'package:basu_118/theme/app_colors.dart';
import 'package:basu_118/widgets/app_bottom_sheet.dart';
import 'package:basu_118/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Assuming apiService is globally accessible as a constant or singleton
// (as inferred from your original code).
// final ApiService apiService = ...;

Future<void> showFavoriteCategorySheet({
  required BuildContext context,
  required int cid,
  VoidCallback? onAdded,
}) async {
  await showAppBottomSheet(
    context: context,
    title: 'انتخاب دسته بندی',
    child: _FavoriteCategorySheetBody(cid: cid, onAdded: onAdded),
  );
}

class _FavoriteCategorySheetBody extends StatefulWidget {
  final int cid;
  final VoidCallback? onAdded;
  const _FavoriteCategorySheetBody({required this.cid, this.onAdded});

  @override
  State<_FavoriteCategorySheetBody> createState() => _FavoriteCategorySheetBodyState();
}

class _FavoriteCategorySheetBodyState extends State<_FavoriteCategorySheetBody> {
  final Set<int> _selectedIds = {};
  
  late FavoriteBloc _favoriteBloc;

  @override
  void initState() {
    super.initState();
    _favoriteBloc = FavoriteBloc(FavoriteRepositoryImpl(api: apiService));

    _favoriteBloc.add(GetFavoriteCategories());
  }

  @override
  void dispose() {
    _favoriteBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _favoriteBloc,
      child: BlocConsumer<FavoriteBloc, FavoriteState>(
        listener: (context, state) {
          if (state is AddToFavoritesSuccess) {
            widget.onAdded?.call();
            if (mounted) context.pop();

            showAppSnackBar(context, type: AppSnackBarType.success, message: 'با موفقیت افزوده شد');
          }
          if (state is AddToFavoritesFailure) {
            showAppSnackBar(context, type: AppSnackBarType.error, message: 'خطا در افزودن: ${state.message}');
          }
        },
        builder: (context, state) {
          final isAdding = state is AddToFavoritesLoading;

          if (state is FavoriteCategoryLoading || state is FavoriteCategoryInitial) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          
          if (state is FavoriteCategoryFailure) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(state.message, style: TextStyle(color: AppColors.error800)),
              ),
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: (state as FavoriteCategorySuccess).response.favoriteCategories.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: AppColors.neutral[200],
                    indent: 16,
                    endIndent: 16,
                  ),
                  itemBuilder: (context, index) {
                    final cat = (state).response.favoriteCategories[index];
                    final isSelected = _selectedIds.contains(cat.favcatId);
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      title: Text(cat.title),
                      trailing: Icon(
                        isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: isSelected ? AppColors.primary : AppColors.neutral[400],
                      ),
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedIds.remove(cat.favcatId);
                          } else {
                            _selectedIds.add(cat.favcatId);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: AppColors.neutral[300],
                    ),
                    onPressed: isAdding || _selectedIds.isEmpty
                        ? null // Disabled
                        : () {
                            context.read<FavoriteBloc>().add(
                                  AddToFavorites(widget.cid, _selectedIds.toList()),
                                );
                          },
                    child: isAdding
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('افزودن'), // "Add"
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}