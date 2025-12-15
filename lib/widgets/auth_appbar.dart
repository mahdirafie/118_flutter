import 'package:basu_118/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class AuthAppbar extends StatelessWidget {
  const AuthAppbar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              context.pop();
            },
            child: SvgPicture.asset(
              'assets/images/arrow-right.svg',
              width: 30,
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'یونیتل',
                  style: TextStyle(
                    fontSize: 24,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 7),
                SvgPicture.asset('assets/images/call.svg', width: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
