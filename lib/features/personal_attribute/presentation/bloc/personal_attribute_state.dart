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

final class SetVisibleAttributesLoading extends PersonalAttributeState {}
final class SetVisibleAttributesFailure extends PersonalAttributeState {
  final String message;

  const SetVisibleAttributesFailure({required this.message});
}
final class SetVisibleAttributesSuccess extends PersonalAttributeState {
  final String message;

  const SetVisibleAttributesSuccess({required this.message});
}

final class GetPersonalAttributeValuesWithVisibilityLoading extends PersonalAttributeState {}
final class GetPersonalAttributeValuesWithVisibilityFailure extends PersonalAttributeState {
  final String message;

  const GetPersonalAttributeValuesWithVisibilityFailure({required this.message});
}
final class GetPersonalAttributeValuesWithVisibilitySuccess extends PersonalAttributeState {
  final AttributeValueVisibleDTO response;

  const GetPersonalAttributeValuesWithVisibilitySuccess({required this.response});
}