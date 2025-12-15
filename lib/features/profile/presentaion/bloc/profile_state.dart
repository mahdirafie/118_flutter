part of 'profile_bloc.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();
  
  @override
  List<Object> get props => [];
}

final class GetProfileInitial extends ProfileState {}
final class GetProfileLoading extends ProfileState {} 
final class GetProfileFailure extends ProfileState {
  final String message;

  const GetProfileFailure({required this.message});
}
final class GetProfileSuccess extends ProfileState {
  final ProfileResponseDTO response;

  const GetProfileSuccess({required this.response});
}