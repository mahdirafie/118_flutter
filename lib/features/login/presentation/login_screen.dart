import 'package:basu_118/core/auth_service/auth_service.dart';
import 'package:basu_118/core/common/password_validator.dart';
import 'package:basu_118/core/config/api_service.dart';
import 'package:basu_118/core/storage/local_storage.dart';
import 'package:basu_118/features/login/data/login_repository_impl.dart';
import 'package:basu_118/features/login/presentation/bloc/login_bloc.dart';
import 'package:basu_118/router/app_router.dart';
import 'package:basu_118/widgets/app_snackbar.dart';
import 'package:basu_118/widgets/auth_button.dart';
import 'package:basu_118/widgets/input_field.dart';
import 'package:basu_118/widgets/password_field.dart';
import 'package:basu_118/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.neutral[50],
      body: BlocProvider<LoginBloc>(
        create: (context) => LoginBloc(LoginRepositoryImpl(apiService)),
        child: BlocListener<LoginBloc, LoginState>(
          listener: (context, state) async {
            if (state is LoginSuccess) {
              await LocalStorage.saveLoginInfo(
                accessToken: state.loginResponse.tokens.accessToken,
                refreshToken: state.loginResponse.tokens.refreshToken,
                uid: state.loginResponse.userId,
                userType: state.loginResponse.userType
              );
              await AuthService().loadTokens();
              await AuthService().loadUserInfo();

              if (!context.mounted) return;
              showAppSnackBar(
                context,
                message: 'ورود موفق!',
                type: AppSnackBarType.success,
              );
              context.go(AppRoutes.home);
            } else if (state is LoginFailure) {
              showAppSnackBar(
                context,
                message: state.message,
                type: AppSnackBarType.error,
              );
            }
          },
          child: SafeArea(
            child: Container(
              alignment: Alignment.center,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 24),

                            // App logo (phone icon + یونیتل wordmark as a single image)
                            Column(
                              children: [
                                Icon(
                                  Icons.call,
                                  color: AppColors.primary,
                                  size: 40,
                                ),
                                Text(
                                  "یونیتل",
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 40,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),
                            // Title and description
                            Text(
                              'ورود',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: AppColors.neutral[900],
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.right,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'برای ورود، نام کاربری و رمز عبور خود را وارد کنید.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.neutral[600],
                                height: 1.5,
                              ),
                              textAlign: TextAlign.right,
                            ),

                            const SizedBox(height: 24),

                            // Username / id field
                            InputField(
                              controller: _usernameController,
                              labelText: 'نام کاربری',
                              hintText: 'نام کاربری خود را وارد کنید...',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'نام نمی‌تواند خالی باشد';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 24),

                            // Password field with visibility toggle
                            PasswordField(
                              controller: _passwordController,
                              validator: passwordValidator,
                            ),

                            const SizedBox(height: 24),

                            // Submit button
                            BlocBuilder<LoginBloc, LoginState>(
                              builder: (context, state) {
                                return AuthButton(
                                  title:
                                      state is LoginLoading
                                          ? 'در حال ورود...'
                                          : 'ورود',
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      context.read<LoginBloc>().add(
                                        UserLogin(
                                          _usernameController.text,
                                          _passwordController.text,
                                        ),
                                      );
                                    }
                                  },
                                );
                              },
                            ),

                            const SizedBox(height: 12),

                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                text: 'ورود/ثبت نام شما به معنای پذیرش',
                                style: TextStyle(
                                  fontFamily: 'IranSans',
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.neutral[500],
                                ),
                                children: [
                                  TextSpan(
                                    text: ' قوانین',
                                    style: TextStyle(color: AppColors.info500),
                                  ),
                                  TextSpan(
                                    text: ' و',
                                    style: TextStyle(
                                      color: AppColors.neutral[500],
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' سیاست های حریم خصوصی',
                                    style: TextStyle(color: AppColors.info500),
                                  ),
                                  TextSpan(
                                    text: ' ایسواچی است',
                                    style: TextStyle(
                                      color: AppColors.neutral[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    InkWell(
                      onTap: () {
                        context.push('/signup');
                      },
                      child: Center(
                        child: RichText(
                          text: TextSpan(
                            text: 'حساب کاربری ندارید؟',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.neutral[700],
                              fontSize: 15,
                            ),
                            children: [
                              TextSpan(
                                text: ' ایجاد حساب',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
