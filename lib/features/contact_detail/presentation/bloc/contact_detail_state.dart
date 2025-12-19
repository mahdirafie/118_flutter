part of 'contact_detail_bloc.dart';

sealed class ContactDetailState extends Equatable {
  const ContactDetailState();
  
  @override
  List<Object> get props => [];
}

final class GetContactDetailInitial extends ContactDetailState {}
final class GetContactDetailLoading extends ContactDetailState {}
final class GetContactDetailFailure extends ContactDetailState {
  final String message;

  const GetContactDetailFailure({required this.message});
}
final class GetContactDetailSuccess extends ContactDetailState {
  final ContactDetailDTO response;

  const GetContactDetailSuccess({required this.response});
}