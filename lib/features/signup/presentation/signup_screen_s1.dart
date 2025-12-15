import 'package:basu_118/core/config/api_service.dart';
import 'package:basu_118/features/signup/data/signup_repository_impl.dart';
import 'package:basu_118/features/signup/domain/signup_repository.dart';
import 'package:basu_118/features/signup/presentation/bloc/signup_bloc.dart';
import 'package:basu_118/features/signup/presentation/bloc/signup_event.dart';
import 'package:basu_118/features/signup/presentation/bloc/signup_state.dart';
import 'package:basu_118/models/signup_data.dart';
import 'package:basu_118/widgets/auth_appbar.dart';
import 'package:basu_118/widgets/auth_button.dart';
import 'package:basu_118/widgets/input_field.dart';
import 'package:basu_118/theme/app_colors.dart';
import 'package:basu_118/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SignUpScreenS1 extends StatefulWidget {
  const SignUpScreenS1({super.key});

  @override
  State<SignUpScreenS1> createState() => _SignUpScreenS1State();
}

class _SignUpScreenS1State extends State<SignUpScreenS1> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  final iranPhoneRegex = RegExp(r'^(?:\+98|0)?9\d{9}$');

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final parentContext = context;

    return Scaffold(
      body: BlocProvider<SignupBloc>(
        create: (_) {
          final SignupRepository repo = SignupRepositoryImpl(apiService);
          return SignupBloc(repo);
        },
        child: BlocListener<SignupBloc, SignupState>(
          listener: (context, state) {
            if (state is SendOtpSuccess) {
              showAppSnackBar(
                context,
                message: 'کد تأیید ارسال شد.',
                type: AppSnackBarType.success,
              );
              context.go('/signup/step2');
            }

            if (state is SendOtpFailure) {
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
                    child: Form(
                      key: _formKey,
                      child: Container(
                        width: double.infinity,
                        alignment: Alignment.centerRight,
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ایجاد حساب کاربری',
                                style: theme.textTheme.headlineLarge,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'شماره تلفن همراه خود را وارد کنید.',
                                style: theme.textTheme.bodyLarge,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'شماره وارد شده باید به نام خودتان باشد. این شماره برای ارسال کد تأیید (OTP) و ایجاد حساب کاربری استفاده می‌شود.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.neutral[500],
                                ),
                              ),
                              SizedBox(height: 30),
                              InputField(
                                controller: _phoneController,
                                labelText: 'شماره تلفن همراه',
                                hintText:
                                    'شماره تلفن همراه خود را وارد کنید...',
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'شماره تلفن نمی‌تواند خالی باشد';
                                  }
                                  if (!iranPhoneRegex.hasMatch(value)) {
                                    return 'شماره وارد شده معتبر نیست';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 24),
                              BlocBuilder<SignupBloc, SignupState>(
                                builder: (innerContext, state) {
                                  return AuthButton(
                                    title: state is SendOtpLoading ? 'در حال ارسال...' : 'ادامه',
                                    onPressed: () {
                                      if (_formKey.currentState!
                                          .validate()) {
                                        final phone =
                                            _phoneController.text.trim();
                              
                                        parentContext
                                            .read<SignupData>()
                                            .setPhone(phone);
                                        innerContext.read<SignupBloc>().add(
                                          RequestOtp(phone),
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
