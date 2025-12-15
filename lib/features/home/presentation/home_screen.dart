import 'package:basu_118/widgets/application_appbar.dart';
import 'package:basu_118/features/filter/presentation/filter.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(body: Column(
      children: [
        const ApplicationAppBar(),
        const FilterWidget()
      ],
    )));
  }
}
