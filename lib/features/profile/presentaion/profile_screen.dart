import 'package:animations/animations.dart';
import 'package:basu_118/core/auth_service/auth_service.dart';
import 'package:basu_118/features/personal_attribute/presentation/personal_attribute_screen.dart';
import 'package:basu_118/features/profile/presentaion/bloc/profile_bloc.dart';
import 'package:basu_118/theme/app_colors.dart';
import 'package:basu_118/widgets/readonly_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger GetFavoriteCategories on screen startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileBloc>().add(GetProfile());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is GetProfileFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        Widget bodyContent;

        if (state is GetProfileLoading) {
          bodyContent = Expanded(
            child: Center(child: Text('در حال دریافت اطلاعات ...')),
          );
        } else if (state is GetProfileFailure) {
          bodyContent = Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.exclamationmark_triangle,
                    size: 64,
                    color: Colors.orange,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'خطا در دریافت اطلاعات',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.neutral[900],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.neutral[600]),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProfileBloc>().add(GetProfile());
                    },
                    child: Text('تلاش مجدد'),
                  ),
                ],
              ),
            ),
          );
        } else if (state is GetProfileSuccess) {
          final employee = state.response.user.employee;
          bodyContent = Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    SizedBox(height: 20),

                    // Profile Card
                    if (AuthService().userInfo!.userType == "employee")
                      OpenContainer(
                        transitionType: ContainerTransitionType.fadeThrough,
                        transitionDuration: Duration(milliseconds: 1500),
                        closedBuilder: (context, action) {
                          return Container(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.neutral[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(32),
                                    child: Image.asset(
                                      'assets/images/profile_placeholder.png',
                                      width: 64,
                                      height: 64,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  state.response.user.fullName.isNotEmpty
                                      ? state.response.user.fullName
                                      : 'نام تعیین نشده',
                                  style: TextStyle(
                                    color: AppColors.neutral[900],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  employee != null ? 'کارمند' : 'کاربر عادی',
                                  style: TextStyle(
                                    color: AppColors.neutral[600],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        openBuilder: (context, action) {
                          return PersonalAttributeScreen();
                        },
                      )
                    else
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.neutral[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(32),
                                child: Image.asset(
                                  'assets/images/profile_placeholder.png',
                                  width: 64,
                                  height: 64,
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              state.response.user.fullName.isNotEmpty
                                  ? state.response.user.fullName
                                  : 'نام تعیین نشده',
                              style: TextStyle(
                                color: AppColors.neutral[900],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              employee != null ? 'کارمند' : 'کاربر عادی',
                              style: TextStyle(color: AppColors.neutral[600]),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(height: 20),

                    // Profile Fields
                    ReadonlyTextField(
                      title: 'نام و نام خانوادگی',
                      value: state.response.user.fullName,
                      prefixIcon: CupertinoIcons.person,
                    ),

                    SizedBox(height: 20),

                    ReadonlyTextField(
                      title: 'شماره تماس',
                      value: state.response.user.phone,
                      prefixIcon: CupertinoIcons.phone,
                    ),

                    if (employee != null)
                      Column(
                        children: [
                          SizedBox(height: 20),

                          ReadonlyTextField(
                            title: 'شماره پرسونلی',
                            value: employee.personnelNo,
                            prefixIcon: CupertinoIcons.number,
                          ),

                          SizedBox(height: 20),

                          ReadonlyTextField(
                            title: 'کد ملی',
                            value: employee.nationalCode,
                            prefixIcon: CupertinoIcons.doc_text,
                          ),

                          if (employee.facultyMember != null)
                            Column(
                              children: [
                                SizedBox(height: 20),
                                ReadonlyTextField(
                                  title: 'دانشکده',
                                  value:
                                      employee
                                          .facultyMember!
                                          .department!
                                          .faculty!
                                          .fname,
                                  prefixIcon: CupertinoIcons.building_2_fill,
                                ),

                                SizedBox(height: 20),
                                ReadonlyTextField(
                                  title: 'دپارتمان',
                                  value:
                                      employee.facultyMember!.department!.dname,
                                  prefixIcon: CupertinoIcons.group,
                                ),
                              ],
                            ),

                          if (employee.facultyMember == null &&
                              employee.nonFacultyMember != null)
                            Column(
                              children: [
                                SizedBox(height: 20),
                                ReadonlyTextField(
                                  title: 'محل کار',
                                  value: employee.nonFacultyMember!.workarea,
                                ),
                              ],
                            ),

                          SizedBox(height: 10),
                          // button that takes user to personal attribute screen
                          GestureDetector(
                            onTap: () {
                              context.push('/personal-att');
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 10),
                              width: double.infinity,
                              alignment: Alignment.center,
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'تنظیم اطلاعات بیشتر',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          );
        } else {
          // Initial state
          bodyContent = Expanded(
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        return SafeArea(
          child: Scaffold(
            body: Column(
              children: [
                // App Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(53, 37, 100, 235),
                        blurRadius: 6,
                        spreadRadius: 0,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon(CupertinoIcons.back),
                      Text(
                        'حساب کاربری',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      // Icon(CupertinoIcons.ellipsis_vertical),
                    ],
                  ),
                ),

                // State-dependent content
                bodyContent,
              ],
            ),
          ),
        );
      },
    );
  }
}
