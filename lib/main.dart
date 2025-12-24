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
import 'package:basu_118/features/visible-info/data/visible_info_repository_impl.dart';
import 'package:basu_118/features/visible-info/presentation/bloc/visible_info_bloc.dart';
import 'package:basu_118/models/signup_data.dart';
import 'package:basu_118/services/hive/hive_models/reminder_model.dart';
import 'package:basu_118/services/hive/hive_service.dart';
import 'package:basu_118/services/notification/notification_helper.dart';
import 'package:basu_118/services/notification/notification_service.dart';
import 'package:basu_118/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:provider/provider.dart';

// for web uncomment this:
// import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Auth first
  await AuthService().loadTokens();
  await AuthService().loadUserInfo();

  // 2. Initialize Hive
  await Hive.initFlutter();

  // 3. Register adapter BEFORE opening the box
  Hive.registerAdapter(ReminderAdapter());

  try {
    // 4. Try to open the box
    await Hive.openBox<Reminder>('reminders');
  } catch (e) {
    print('⚠️ Error opening reminders box: $e');
    print('🗑️ Clearing box due to adapter mismatch...');

    // If there's an error, delete the box and create a fresh one
    await Hive.deleteBoxFromDisk('reminders');
    await Hive.openBox<Reminder>('reminders');
  }

  // 5. Initialize Notification Service
  final notificationService = NotificationService();
  await notificationService.initialize();

  // 6. Request permission (optional, can be lazy-loaded)
  await NotificationHelper.requestPermission();

  // 7. Reschedule reminders
  final hiveService = HiveService();
  final allReminders = hiveService.getAllReminders();
  await notificationService.rescheduleAllReminders(allReminders);

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
          create: (_) => FavoriteBloc(FavoriteRepositoryImpl(api: apiService)),
        ),
        BlocProvider(
          create: (_) => ProfileBloc(ProfileRepositoryImpl(api: apiService)),
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
        BlocProvider(
          create:
              (_) => ContactDetailBloc(ContactRepositoryImpl(api: apiService)),
        ),
        BlocProvider(
          create: (_) => GroupBloc(GroupRepositoryImpl(api: ApiService())),
        ),
        BlocProvider(
          create: (_) => GroupMemberBloc(GroupRepositoryImpl(api: apiService)),
        ),
        BlocProvider(
          create:
              (_) => PersonalAttributeBloc(
                PersonalAttributeRepositoryImpl(api: apiService),
              ),
        ),
        BlocProvider(
          create:
              (_) =>
                  VisibleInfoBloc(VisibleInfoRepositoryImpl(api: apiService)),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: AppRouter.router,
        title: 'basu 118',
        debugShowCheckedModeBanner: false,
        locale: const Locale("fa", "IR"),
        supportedLocales: const [Locale("fa", "IR"), Locale("en", "US")],
        localizationsDelegates: const [
          // Add Localization
          PersianMaterialLocalizations.delegate,
          PersianCupertinoLocalizations.delegate,
          // DariMaterialLocalizations.delegate, Dari
          // DariCupertinoLocalizations.delegate,
          // PashtoMaterialLocalizations.delegate, Pashto
          // PashtoCupertinoLocalizations.delegate,
          // SoraniMaterialLocalizations.delegate, Kurdish
          // SoraniCupertinoLocalizations.delegate,
        ],
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
