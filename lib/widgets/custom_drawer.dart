import 'dart:async';
import 'package:basu_118/core/auth_service/auth_service.dart';
import 'package:basu_118/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:basu_118/widgets/confirm_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:shamsi_date/shamsi_date.dart';

class FullWidthDrawer extends StatefulWidget {
  const FullWidthDrawer({super.key});

  @override
  State<FullWidthDrawer> createState() => _FullWidthDrawerState();
}

class _FullWidthDrawerState extends State<FullWidthDrawer> {
  late Timer _timer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _jalaliDate() {
    final j = Jalali.fromDateTime(_now);
    final f = j.formatter;
    return '${f.wN} ${f.d}${f.mN} ${f.yyyy}';
  }

  String _timeOnly() =>
      '${_now.hour.toString().padLeft(2, '0')}:${_now.minute.toString().padLeft(2, '0')}:${_now.second.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero, // << remove the default radius
      ),
      width: width,
      backgroundColor: AppColors.neutral[50],
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date & time header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: AppColors.neutral[0],
              child: Row(
                children: [
                  Image.asset('assets/images/buali.png', width: 56),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'بوعلی سینا',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.neutral[900],
                        ),
                      ),
                      const SizedBox(height: 8),

                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 18,
                            color: Colors.black54,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _jalaliDate(),
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.neutral[500],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 18,
                            color: Colors.black54,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _timeOnly(), // new helper for time only
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.neutral[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            Container(
              color: AppColors.neutral[0],
              child: Column(
                children: [
                  MenuItem(
                    title: 'یادآور تماس',
                    iconPath: 'assets/images/remind.svg',
                    onTap: () {},
                  ),
                  MenuItem(
                    title: 'گروه بندی',
                    iconData: CupertinoIcons.group,
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            InkWell(
              onTap: () {
                showConfirmDialog(
                  context: context,
                  title: 'خروج از حساب',
                  description: 'آیا از خروج اطمینان دارید؟ با این کار از حساب خارج می‌شوید.',
                  confirmText: 'خروج',
                  cancelText: 'انصراف',
                  onConfirm: () async{
                    await AuthService().clearUserInfo();
                    await AuthService().clearTokens();

                    if(!context.mounted) return;
                    context.go('/login');
                  },
                );
              },
              child: Container(
                padding: EdgeInsets.all(20),
                color: AppColors.neutral[0],
                child: Row(
                  children: [
                    Icon(Icons.logout, color: AppColors.error800, size: 20),
                    SizedBox(width: 15,),
                    Text('خروج', style: TextStyle(color: AppColors.error800),)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class MenuItem extends StatelessWidget {
  final String title;
  void Function()? onTap;
  final String? iconPath;
  final IconData? iconData;

  MenuItem({
    super.key,
    required this.title,
    this.iconPath,
    this.onTap,
    this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Row(
          children: [
            iconData != null && iconPath == null
                ? Icon(iconData, color: AppColors.neutral[700])
                : SvgPicture.asset(iconPath!, width: 16, height: 16),
            SizedBox(width: 15),
            Text(title, style: TextStyle(color: AppColors.neutral[900])),
            Expanded(
              child: Container(
                alignment: Alignment.centerLeft,
                child: SvgPicture.asset(
                  'assets/images/forward.svg',
                  width: 16,
                  height: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
