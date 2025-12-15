import 'package:equatable/equatable.dart';

abstract class SignupState extends Equatable {
  @override
  List<Object> get props => [];
}

class SendOtpInitial extends SignupState {}
class SendOtpLoading extends SignupState {}
class SendOtpSuccess extends SignupState {}
class SendOtpFailure extends SignupState {
  final String message;
  SendOtpFailure(this.message);
  @override
  List<Object> get props => [message];
}

class VerifyOtpLoading extends SignupState {}
class VerifyOtpSuccess extends SignupState {}
class VerifyOtpFailure extends SignupState {
  final String message;
  VerifyOtpFailure(this.message);
  @override
  List<Object> get props => [message];
}

class CreateUserLoading extends SignupState {}
class CreateUserSuccess extends SignupState {}
class CreateUserFailure extends SignupState {
  final String message;
  CreateUserFailure(this.message);
  @override
  List<Object> get props => [message];
}