part of 'login_bloc.dart';

sealed class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}


final class UserLogin extends LoginEvent {
  final String username;
  final String password;

  const UserLogin(this.username, this.password);
}