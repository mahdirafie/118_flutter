import 'package:flutter/material.dart';
import 'package:basu_118/theme/app_colors.dart';
import 'package:go_router/go_router.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String description;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.description,
    required this.onConfirm,
    this.confirmText = 'تایید',
    this.cancelText = 'انصراف',
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Directionality(
        textDirection: Directionality.of(context),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    splashRadius: 20,
                    icon: const Icon(Icons.close),
                    color: AppColors.neutral[700],
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutral[900],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Divider(height: 1, color: AppColors.neutral[200]),
              const SizedBox(height: 12),
              Text(
                description,
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.neutral[600],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.neutral[300]!),
                        foregroundColor: AppColors.neutral[800],
                        backgroundColor: AppColors.neutral[0],
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => context.pop(),
                      child: Text(cancelText),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error50,
                        foregroundColor: AppColors.error800,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: AppColors.error800, width: 2),
                        ),
                      ),
                      onPressed: onConfirm,
                      child: Text(confirmText),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

Future<T?> showConfirmDialog<T>({
  required BuildContext context,
  required String title,
  required String description,
  required VoidCallback onConfirm,
  String confirmText = 'تایید',
  String cancelText = 'انصراف',
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: false,
    builder: (_) => ConfirmDialog(
      title: title,
      description: description,
      onConfirm: onConfirm,
      confirmText: confirmText,
      cancelText: cancelText,
    ),
  );
}


