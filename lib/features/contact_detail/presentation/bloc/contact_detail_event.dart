part of 'contact_detail_bloc.dart';

sealed class ContactDetailEvent extends Equatable {
  const ContactDetailEvent();

  @override
  List<Object> get props => [];
}

final class GetContactDetailStarted extends ContactDetailEvent {
  final int cid;

  const GetContactDetailStarted({required this.cid});
}