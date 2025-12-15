import 'package:flutter/material.dart';
import 'package:basu_118/theme/app_colors.dart';

enum AppSnackBarType { success, error, info, warning }

void showAppSnackBar(
  BuildContext context, {
  required String message,
  required AppSnackBarType type,
}) {
  final Color bg;
  final Color border;
  final Color textColor;

  switch (type) {
    case AppSnackBarType.success:
      bg = AppColors.success50;
      border = AppColors.success500;
      textColor = AppColors.success800;
      break;
    case AppSnackBarType.error:
      bg = AppColors.error50;
      border = AppColors.error500;
      textColor = AppColors.error800;
      break;
    case AppSnackBarType.info:
      bg = AppColors.info50;
      border = AppColors.info500;
      textColor = AppColors.info800;
      break;
    case AppSnackBarType.warning:
      bg = AppColors.warning50;
      border = AppColors.warning500;
      textColor = AppColors.warning800;
      break;
  }

  final snack = SnackBar(
    behavior: SnackBarBehavior.floating,
    elevation: 0,
    backgroundColor: Colors.transparent,
    content: _SnackContent(
      background: bg,
      border: border,
      textColor: textColor,
      message: message,
    ),
  );

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(snack);
}

class _SnackContent extends StatelessWidget {
  final Color background;
  final Color border;
  final Color textColor;
  final String message;

  const _SnackContent({
    required this.background,
    required this.border,
    required this.textColor,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
            child: Icon(Icons.close, size: 20, color: textColor),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


