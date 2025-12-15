import 'package:basu_118/features/signup/domain/signup_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'signup_event.dart';
import 'signup_state.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  final SignupRepository repo;

  SignupBloc(this.repo) : super(SendOtpInitial()) {
    // Handle OTP request
    on<RequestOtp>((event, emit) async {
      try {
        emit(SendOtpLoading());
        await repo.requestOtp(event.phone);
        emit(SendOtpSuccess());
      } on DioException catch (e) {
        debugPrint(e.toString());
        String userMessage = 'خطایی رخ داد';

        if (e.response?.data is Map &&
            (e.response!.data as Map).containsKey('message')) {
          userMessage = e.response!.data['message'];
        }
        emit(SendOtpFailure(userMessage));
      } catch (e) {
        emit(SendOtpFailure(e.toString()));
      }
    });

    // Handle OTP verification
    on<VerifyOtp>((event, emit) async {
      try {
        emit(VerifyOtpLoading());
        await repo.verifyOtp(event.phone, event.otpCode);
        emit(VerifyOtpSuccess());
      } on DioException catch (e) {
        String userMessage = 'خطایی رخ داد';

        if (e.response?.data is Map &&
            (e.response!.data as Map).containsKey('message')) {
          userMessage = e.response!.data['message'];
        }
        emit(VerifyOtpFailure(userMessage));
      } catch (e) {
        emit(VerifyOtpFailure(e.toString()));
      }
    });

    // Handle user creation
    on<CreateUser>((event, emit) async {
      try {
        emit(CreateUserLoading());
        await repo.createUser(event.name, event.lastName, event.password, event.phone);
        emit(CreateUserSuccess());
      } on DioException catch (e) {
        String userMessage = 'خطایی رخ داد';

        if (e.response?.data is Map &&
            (e.response!.data as Map).containsKey('message')) {
          userMessage = e.response!.data['message'];
        }
        
        emit(CreateUserFailure(userMessage));
      } catch (e) {
        emit(CreateUserFailure(e.toString()));
      }
    });
  }
}
