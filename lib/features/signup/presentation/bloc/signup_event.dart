import 'package:equatable/equatable.dart';

abstract class SignupEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class RequestOtp extends SignupEvent {
  final String phone;
  RequestOtp(this.phone);
  @override
  List<Object> get props => [phone];
}

class VerifyOtp extends SignupEvent {
  final String phone;
  final String otpCode;
  VerifyOtp(this.phone, this.otpCode);
  @override
  List<Object> get props => [phone, otpCode];
}

class CreateUser extends SignupEvent {
  final String name;
  final String lastName;
  final String password;
  final String phone;
  CreateUser(this.name, this.lastName, this.password, this.phone);
  @override
  List<Object> get props => [name, lastName, password, phone];
}