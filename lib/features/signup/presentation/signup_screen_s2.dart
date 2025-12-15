import 'package:basu_118/core/config/api_service.dart';
import 'package:basu_118/features/signup/data/signup_repository_impl.dart';
import 'package:basu_118/features/signup/presentation/bloc/signup_bloc.dart';
import 'package:basu_118/features/signup/presentation/bloc/signup_event.dart';
import 'package:basu_118/features/signup/presentation/bloc/signup_state.dart';
import 'package:basu_118/models/signup_data.dart';
import 'package:basu_118/widgets/app_snackbar.dart';
import 'package:basu_118/widgets/auth_appbar.dart';
import 'package:basu_118/widgets/auth_button.dart';
import 'package:basu_118/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:go_router/go_router.dart';

class SignupScreenS2 extends StatefulWidget {
  const SignupScreenS2({super.key});

  @override
  State<SignupScreenS2> createState() => _SignupScreenS2State();
}

class _SignupScreenS2State extends State<SignupScreenS2> {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(text: ''),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  final List<FocusNode> _keyFocusNodes = List.generate(4, (_) => FocusNode());

  bool _isTimerFinished = false;

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    for(final k in _keyFocusNodes) {
      k.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.length == 1) {
      // Digit entered - move to next field if not last
      if (index < _focusNodes.length - 1) {
        FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
      } else {
        // Last field - unfocus keyboard
        _focusNodes[index].unfocus();
      }
    } else if (value.isEmpty) {
      if (_controllers[index].text.isEmpty && index > 0) {
        FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
      }
    }
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  @override
  Widget build(BuildContext context) {
    final signupData = context.watch<SignupData>();

    final theme = Theme.of(context);
    return Scaffold(
      body: BlocProvider<SignupBloc>(
        create: (context) => SignupBloc(SignupRepositoryImpl(apiService)),
        child: BlocListener<SignupBloc, SignupState>(
          listener: (context, state) {
            if (state is SendOtpSuccess) {
              showAppSnackBar(
                context,
                message: 'کد تأیید ارسال شد.',
                type: AppSnackBarType.success,
              );
              setState(() {
                _isTimerFinished = false;
              });
            } else if (state is SendOtpFailure) {
              showAppSnackBar(
                context,
                message: state.message,
                type: AppSnackBarType.error,
              );
            } else if (state is VerifyOtpFailure) {
              showAppSnackBar(
                context,
                message: state.message,
                type: AppSnackBarType.error,
              );
            } else if (state is VerifyOtpSuccess) {
              showAppSnackBar(
                context,
                message: 'تایید شد.',
                type: AppSnackBarType.success,
              );
              context.go('/signup/step3');
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'کد تایید',
                              style: theme.textTheme.headlineLarge,
                            ),
                            SizedBox(height: 12),
                            RichText(
                              text: TextSpan(
                                text: 'کد ارسال شده به شماره ',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: AppColors.neutral[700],
                                ),
                                children: [
                                  TextSpan(
                                    text: signupData.phone,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(text: 'را وارد کنید.'),
                                ],
                              ),
                            ),
                            SizedBox(height: 24),

                            // OTP
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: List.generate(4, (index) {
                                  return SizedBox(
                                    width: 56,
                                    height: 56,
                                    child: KeyboardListener(
                                      focusNode: _keyFocusNodes[index],
                                      onKeyEvent: (KeyEvent event) {
                                        if (event is KeyDownEvent &&
                                            event.logicalKey ==
                                                LogicalKeyboardKey.backspace) {
                                          if (_controllers[index]
                                                  .text
                                                  .isEmpty &&
                                              index > 0) {
                                            FocusScope.of(context).requestFocus(
                                              _focusNodes[index - 1],
                                            );
                                          }
                                        }
                                      },
                                      child: TextField(
                                        controller: _controllers[index],
                                        focusNode: _focusNodes[index],
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(fontSize: 24),
                                        keyboardType: TextInputType.number,
                                        maxLength: 1,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.zero,
                                          counterText: '',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                            borderSide: BorderSide(
                                              color: AppColors.neutral[500]!,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                            borderSide: BorderSide(
                                              color: AppColors.neutral[500]!,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                            borderSide: BorderSide(
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                        onChanged:
                                            (value) => _onChanged(value, index),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),

                            SizedBox(height: 12),
                            _isTimerFinished
                                ? BlocBuilder<SignupBloc, SignupState>(
                                  builder: (context, state) {
                                    if (state is SendOtpLoading) {
                                      return Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                    return GestureDetector(
                                      onTap: () {
                                        context.read<SignupBloc>().add(
                                          RequestOtp(signupData.phone),
                                        );
                                      },
                                      child: Center(
                                        child: Text(
                                          'ارسال مجدد کد',
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                )
                                : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('ارسال مجدد کد تا '),
                                    Directionality(
                                      textDirection: TextDirection.ltr,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        child: TimerCountdown(
                                          spacerWidth: 1,
                                          timeTextStyle: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                          enableDescriptions: false,
                                          format:
                                              CountDownTimerFormat
                                                  .minutesSeconds,
                                          endTime: DateTime.now().add(
                                            Duration(minutes: 2),
                                          ),
                                          onEnd: () {
                                            setState(() {
                                              _isTimerFinished = true;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                    Text('دیگر'),
                                  ],
                                ),
                            SizedBox(height: 24),
                            BlocBuilder<SignupBloc, SignupState>(
                              builder: (context, state) {
                                return AuthButton(
                                  title:
                                      state is VerifyOtpLoading
                                          ? 'در حال بررسی...'
                                          : 'تایید',
                                  onPressed: () {
                                    for (var controller in _controllers) {
                                      if (controller.text.isEmpty) {
                                        showAppSnackBar(
                                          context,
                                          message:
                                              'همه فیلدها باید تکمیل شوند.',
                                          type: AppSnackBarType.error,
                                        );
                                        break;
                                      }
                                    }

                                    context.read<SignupBloc>().add(
                                      VerifyOtp(signupData.phone, _otpCode),
                                    );
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
