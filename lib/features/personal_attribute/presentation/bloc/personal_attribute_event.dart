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
final class SetVisibleAttributes extends PersonalAttributeEvent {
  final int id;
  final String type;
  final List<Map<String, dynamic>> attVals;

  const SetVisibleAttributes({required this.id, required this.type, required this.attVals});
}

final class GetPersonalAttributeValuesWithVisibility extends PersonalAttributeEvent {
  final int receiverId;
  final String type;

  const GetPersonalAttributeValuesWithVisibility({required this.receiverId, required this.type});
}