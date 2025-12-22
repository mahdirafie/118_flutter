import 'package:basu_118/core/auth_service/auth_service.dart';
import 'package:basu_118/core/config/api_service.dart';
import 'package:basu_118/features/contact_detail/data/contact_repository_impl.dart';
import 'package:basu_118/features/contact_detail/presentation/bloc/contact_detail_bloc.dart';
import 'package:basu_118/features/favorites/data/favorite_repository_impl.dart';
import 'package:basu_118/features/favorites/presentation/bloc/favorite_bloc.dart';
import 'package:basu_118/features/filter/data/filter_repository_impl.dart';
import 'package:basu_118/features/filter/presentation/bloc/filter_api_bloc.dart';
import 'package:basu_118/features/filter/presentation/bloc/filter_bloc.dart';
import 'package:basu_118/features/group/data/group_repository_impl.dart';
import 'package:basu_118/features/group/presentation/bloc/group_bloc.dart';
import 'package:basu_118/features/group/presentation/bloc/group_member_bloc.dart';
import 'package:basu_118/features/home/data/home_repository_impl.dart';
import 'package:basu_118/features/home/presentation/bloc/home_bloc.dart';
import 'package:basu_118/features/personal_attribute/data/personal_attribute_repository_impl.dart';
import 'package:basu_118/features/personal_attribute/presentation/bloc/personal_attribute_bloc.dart';
import 'package:basu_118/features/profile/data/profile_repository_impl.dart';
import 'package:basu_118/features/profile/presentaion/bloc/profile_bloc.dart';
import 'package:basu_118/features/search/data/search_repository_impl.dart';
import 'package:basu_118/features/search/presentation/bloc/search_bloc.dart';
import 'package:basu_118/features/search/presentation/bloc/search_history_bloc.dart';
import 'package:basu_118/models/signup_data.dart';
import 'package:basu_118/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

// for web uncomment this:
// import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'router/app_router.dart';

void main() async {
  // for web uncomment this:
  // setUrlStrategy(PathUrlStrategy());

  WidgetsFlutterBinding.ensureInitialized();
  await AuthService().loadTokens();
  await AuthService().loadUserInfo();

  runApp(
    ChangeNotifierProvider(create: (_) => SignupData(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => HomeBloc(HomeRepositoryImpl(api: apiService)),
        ),
        BlocProvider(
          create:
              (_) =>
                  FavoriteBloc(FavoriteRepositoryImpl(api: apiService))
                    ..add(GetFavoriteCategories()),
        ),
        BlocProvider(
          create:
              (_) =>
                  ProfileBloc(ProfileRepositoryImpl(api: apiService))
                    ..add(GetProfile()),
        ),
        BlocProvider(create: (_) => FilterBloc()..add(FilterLoadEvent())),
        BlocProvider(
          create: (_) => FilterApiBloc(FilterRepositoryImpl(api: apiService)),
        ),
        BlocProvider(
          create: (_) => SearchBloc(SearchRepositoryImpl(api: apiService)),
        ),
        BlocProvider(
          create:
              (_) => SearchHistoryBloc(SearchRepositoryImpl(api: apiService)),
        ),
        BlocProvider(create: (_) => ContactDetailBloc(ContactRepositoryImpl(api: apiService))),
        BlocProvider(create: (_) => GroupBloc(GroupRepositoryImpl(api: ApiService()))),
        BlocProvider(create: (_) => GroupMemberBloc(GroupRepositoryImpl(api: apiService))),
        BlocProvider(create: (_) => PersonalAttributeBloc(PersonalAttributeRepositoryImpl(api: apiService)))
      ],
      child: MaterialApp.router(
        routerConfig: AppRouter.router,
        title: 'basu 118',
        debugShowCheckedModeBanner: false,

        theme: ThemeData(
          primarySwatch: AppColors.primary,
          fontFamily: 'IranSans',
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: AppColors.primary,
            accentColor: AppColors.info500,
            errorColor: AppColors.error500,
          ),
          textTheme: TextTheme(
            // Headlines
            headlineLarge: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ), // H1
            headlineMedium: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ), // H2 (DemiBold)
            // Subtitles
            titleLarge: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
            ), // Subtitle-lg
            titleMedium: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ), // Subtitle-md
            // Body
            bodyLarge: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ), // Body-lg
            bodyMedium: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ), // Body-md
            // Buttons
            labelLarge: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ), // Button-lg
            labelMedium: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ), // Button-md
            // Caption
            bodySmall: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ), // Caption
          ),
        ),

        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          );
        },
      ),
    );
  }
}
