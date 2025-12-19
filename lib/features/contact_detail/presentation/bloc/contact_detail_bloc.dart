import 'package:basu_118/features/contact_detail/domain/contact_repository.dart';
import 'package:basu_118/features/contact_detail/dto/contact_detail_dto.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'contact_detail_event.dart';
part 'contact_detail_state.dart';

class ContactDetailBloc extends Bloc<ContactDetailEvent, ContactDetailState> {
  final ContactRepository repo;
  ContactDetailBloc(this.repo) : super(GetContactDetailInitial()) {
    on<GetContactDetailStarted>((event, emit) async{
     try {
      emit(GetContactDetailLoading());
      final response = await repo.getContactDetail(event.cid, event.uid);
      emit(GetContactDetailSuccess(response: response));
     } on DioException catch(e) {
      String userMessage = 'خطایی رخ داد';

        if (e.response?.data is Map &&
            (e.response!.data as Map).containsKey('message')) {
          userMessage = e.response!.data['message'];
        }
        emit(GetContactDetailFailure(message: userMessage));
     } catch (e) {
      emit(GetContactDetailFailure(message: e.toString()));
     }
    });
  }
}
