part of 'login_bloc.dart';

sealed class LoginState extends Equatable {
  const LoginState();
  
  @override
  List<Object> get props => [];
}

final class LoginInitial extends LoginState {}
final class LoginLoading extends LoginState {}
final class LoginSuccess extends LoginState {
  final LoginResponse loginResponse;

  const LoginSuccess(this.loginResponse);
}
final class LoginFailure extends LoginState {
  final String message;

  const LoginFailure(this.message);
}