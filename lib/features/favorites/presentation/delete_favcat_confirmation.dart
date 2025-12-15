import 'package:basu_118/features/favorites/presentation/bloc/favorite_bloc.dart';
import 'package:basu_118/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> showDeleteFavoriteCategoryDialog({
  required BuildContext context,
  required String categoryName,
  required int categoryId,
}) {
  return showDialog(
    context: context,
    builder: (context) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: BlocConsumer<FavoriteBloc, FavoriteState>(
          listener: (context, state) {
            if (state is DeleteFavoriteCategorySuccess) {
              Navigator.pop(context); // close dialog
              showAppSnackBar(
                context,
                message: 'دسته بندی با موفقیت حذف شد!',
                type: AppSnackBarType.success,
              );

              context.read<FavoriteBloc>().add(GetFavoriteCategories());
            }
            if (state is DeleteFavoriteCategoryFailure) {
              showAppSnackBar(
                context,
                message: state.message,
                type: AppSnackBarType.error,
              );
            }
          },
          builder: (context, state) {
            return AlertDialog(
              title: const Text("حذف دسته‌بندی علاقه‌مندی"),
              content: Text(
                "شما در حال حذف دسته‌بندی علاقه‌مندی \"$categoryName\" هستید.\n\n"
                "تمام موارد موجود در این دسته‌بندی نیز حذف خواهند شد و این عمل غیرقابل بازگشت است. آیا مایل به ادامه هستید؟",
                textAlign: TextAlign.justify,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("لغو"),
                ),
                TextButton(
                  onPressed:
                      state is DeleteFavoriteCategoryLoading
                          ? null
                          : () {
                            context.read<FavoriteBloc>().add(
                              DeleteFavoriteCategory(favCatId: categoryId),
                            );
                          },
                  child:
                      state is DeleteFavoriteCategoryLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text(
                            "حذف دسته‌بندی",
                            style: TextStyle(color: Colors.red),
                          ),
                ),
              ],
            );
          },
        ),
      );
    },
  );
}
