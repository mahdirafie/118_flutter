import 'package:basu_118/features/favorites/presentation/bloc/favorite_bloc.dart';
import 'package:basu_118/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> showUpdateFavoriteCategoryDialog({
  required BuildContext context,
  required String currentCategoryName,
  required int categoryId,
}) {
  final TextEditingController controller = TextEditingController(
    text: currentCategoryName,
  );

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: BlocConsumer<FavoriteBloc, FavoriteState>(
          listener: (context, state) {
            if (state is UpdateFavoriteCategorySuccess) {
              Navigator.pop(context);

              showAppSnackBar(
                context,
                message: 'دسته‌بندی با موفقیت ویرایش شد!',
                type: AppSnackBarType.success,
              );

              context.read<FavoriteBloc>().add(GetFavoriteCategories());
            }

            if (state is UpdateFavoriteCategoryFailure) {
              showAppSnackBar(
                context,
                message: state.message,
                type: AppSnackBarType.error,
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is UpdateFavoriteCategoryLoading;

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),

              title: const Text(
                "ویرایش دسته‌بندی علاقه‌مندی",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),

              content: Form(
                key: formKey,
                child: TextFormField(
                  controller: controller,
                  enabled: !isLoading,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    labelText: "نام دسته‌بندی",
                    labelStyle: const TextStyle(fontSize: 14),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),

                    // Always show outline border even when not focused
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 1.8,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  validator: (value) {
                    final val = value?.trim() ?? "";
                    if (val.isEmpty) {
                      return "نام دسته‌بندی الزامی است";
                    }
                    if (val == currentCategoryName) {
                      return "نام جدید باید متفاوت از نام قبلی باشد";
                    }
                    return null;
                  },
                ),
              ),

              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: Text(
                    "لغو",
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
                              context.read<FavoriteBloc>().add(
                                UpdateFavoriteCategory(
                                  favCatId: categoryId,
                                  newTitle: controller.text.trim(),
                                ),
                              );
                            }
                          },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor:
                        isLoading
                            ? Colors.grey
                            : Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 12,
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
                            "ذخیره",
                            style: TextStyle(color: Colors.white, fontSize: 14),
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
