import 'package:animations/animations.dart';
import 'package:basu_118/features/search/presentation/search_screen.dart';
import 'package:basu_118/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ApplicationAppBar extends StatelessWidget {
  const ApplicationAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.neutral[400],
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                Scaffold.of(context).openDrawer();
              },
              child: SvgPicture.asset(
                'assets/images/hamburger.svg',
                width: 24,
                height: 24,
              ),
            ),
            OpenContainer(
              transitionType: ContainerTransitionType.fadeThrough,
              transitionDuration: Duration(seconds: 1),
              closedBuilder: (context, action) {
                return Container(
                  width: 220,
                  height: 35,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: AppColors.neutral[50],
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    child: Row(
                      children: [
                        Icon(
                          CupertinoIcons.search,
                          color: AppColors.neutral[500],
                          size: 16,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'جستجو کنید...',
                          style: TextStyle(color: AppColors.neutral[500]),
                        ),
                      ],
                    ),
                  ),
                );
              },
              openBuilder: (context, action) {
                return SearchScreen();
              },
            ),
          ],
        ),
      ),
    );
  }
}
