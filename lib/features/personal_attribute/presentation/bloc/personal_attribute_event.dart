part of 'personal_attribute_bloc.dart';

sealed class PersonalAttributeEvent extends Equatable {
  const PersonalAttributeEvent();

  @override
  List<Object> get props => [];
}

final class GetPersonalAttributesEvent extends PersonalAttributeEvent {}
final class SetPersonalAttributeValuesEvent extends PersonalAttributeEvent {
  final List<Map<String, dynamic>> attributes;

  const SetPersonalAttributeValuesEvent({required this.attributes});
}