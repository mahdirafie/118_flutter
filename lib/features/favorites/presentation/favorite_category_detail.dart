import 'package:flutter/material.dart';

class FavoriteCategoryDetail extends StatelessWidget {
  final String favoriteCategoryTitle;
  const FavoriteCategoryDetail({
    super.key,
    required this.favoriteCategoryTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(favoriteCategoryTitle),
      ),
      body: Container(),
    );
  }
}
