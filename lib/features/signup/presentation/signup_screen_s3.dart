import 'package:basu_118/core/common/password_validator.dart';
import 'package:basu_118/core/config/api_service.dart';
import 'package:basu_118/features/signup/data/signup_repository_impl.dart';
import 'package:basu_118/features/signup/presentation/bloc/signup_bloc.dart';
import 'package:basu_118/features/signup/presentation/bloc/signup_event.dart';
import 'package:basu_118/features/signup/presentation/bloc/signup_state.dart';
import 'package:basu_118/models/signup_data.dart';
import 'package:basu_118/router/app_router.dart';
import 'package:basu_118/widgets/app_snackbar.dart';
import 'package:basu_118/widgets/auth_appbar.dart';
import 'package:basu_118/widgets/auth_button.dart';
import 'package:basu_118/widgets/input_field.dart';
import 'package:basu_118/widgets/password_field.dart';
import 'package:basu_118/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SignupScreenS3 extends StatefulWidget {
  const SignupScreenS3({super.key});

  @override
  State<SignupScreenS3> createState() => _SignupScreenS3State();
}

class _SignupScreenS3State extends State<SignupScreenS3> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final signupData = context.watch<SignupData>();

    final theme = Theme.of(context);
    return Scaffold(
      body: BlocProvider<SignupBloc>(
        create: (context) => SignupBloc(SignupRepositoryImpl(apiService)),
        child: BlocListener<SignupBloc, SignupState>(
          listener: (context, state) {
            if (state is CreateUserSuccess) {
              showAppSnackBar(
                context,
                message: 'حساب کاربری شما ایجاد شد.',
                type: AppSnackBarType.success,
              );
              context.go(AppRoutes.login);
            } else if (state is CreateUserFailure) {
              showAppSnackBar(
                context,
                message: state.message,
                type: AppSnackBarType.error,
              );
            }
          },
          child: SafeArea(
            child: Column(
              children: [
                // Appbar
                AuthAppbar(),

                // Body
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.centerRight,
                      child: SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'اطلاعات حساب کاربری',
                                style: theme.textTheme.headlineLarge,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'حساب خود را تکمیل کنید.',
                                style: theme.textTheme.bodyLarge,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'لطفاً نام، نام خانوادگی و یک رمز عبور امن وارد کنید تا حساب کاربری شما ایجاد شود.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.neutral[500],
                                ),
                              ),
                              SizedBox(height: 30),
                              InputField(
                                labelText: 'نام',
                                hintText: 'نام خود را وارد کنید...',
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'نام نمی‌تواند خالی باشد';
                                  }
                                  return null;
                                },
                                controller: _nameController,
                              ),
                              SizedBox(height: 20),
                              InputField(
                                labelText: 'نام خانوادگی',
                                hintText: 'نام خانوادگی خود را وارد کنید...',
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'نام خانوادگی نمی‌تواند خالی باشد';
                                  }
                                  return null;
                                },
                                controller: _lastNameController,
                              ),
                              SizedBox(height: 20),
                              PasswordField(
                                validator: passwordValidator,
                                controller: _passwordController,
                              ),
                              SizedBox(height: 24),
                              BlocBuilder<SignupBloc, SignupState>(
                                builder: (context, state) {
                                  return AuthButton(
                                    title: state is CreateUserLoading ? 'در حال ایجاد...' : 'ورود به برنامه',
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        context.read<SignupBloc>().add(
                                          CreateUser(
                                            _nameController.text,
                                            _lastNameController.text,
                                            _passwordController.text,
                                            signupData.phone,
                                          ),
                                        );
                                      }
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
