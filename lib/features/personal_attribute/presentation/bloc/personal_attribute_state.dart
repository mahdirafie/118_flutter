part of 'personal_attribute_bloc.dart';

sealed class PersonalAttributeState extends Equatable {
  const PersonalAttributeState();
  
  @override
  List<Object> get props => [];
}

final class PersonalAttributeInitial extends PersonalAttributeState {}
final class PersonalAttributeLoading extends PersonalAttributeState {}
final class PersonalAttributeFailure extends PersonalAttributeState {
  final String message;

  const PersonalAttributeFailure({required this.message});
}
final class PersonalAttributeSuccess extends PersonalAttributeState {
  final PersonalAttributeResponseDTO response;

  const PersonalAttributeSuccess({required this.response});
}

final class SetPersonalAttributeValuesLoading extends PersonalAttributeState {}
final class SetPersonalAttributeValuesFailure extends PersonalAttributeState {
  final String message;

  const SetPersonalAttributeValuesFailure({required this.message});
}
final class SetPersonalAttributeValuesSuccess extends PersonalAttributeState {
  final String message;

  const SetPersonalAttributeValuesSuccess({required this.message});
}