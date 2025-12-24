import 'package:basu_118/features/visible-info/domain/visible_info_repository.dart';
import 'package:basu_118/features/visible-info/dto/visible_info_response_dto.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'visible_info_event.dart';
part 'visible_info_state.dart';

class VisibleInfoBloc extends Bloc<VisibleInfoEvent, VisibleInfoState> {
  final VisibleInfoRepository repo;
  VisibleInfoBloc(this.repo) : super(VisibleInfoInitial()) {
    on<GetVisibleInfoEvent>((event, emit) async{
      try {
        emit(VisibleInfoLoading());
        final response = await repo.getVisibleInfo(event.empId);
        emit(VisibleInfoSuccess(response: response));
      } on DioException catch(e) {
        String userMessage = 'خطایی رخ داد';

        if (e.response?.data is Map &&
            (e.response!.data as Map).containsKey('message')) {
          userMessage = e.response!.data['message'];
        }
        emit(VisibleInfoFailure(message: userMessage));
      } catch(e) {
        emit(VisibleInfoFailure(message: e.toString()));
      }
    });
  }
}
