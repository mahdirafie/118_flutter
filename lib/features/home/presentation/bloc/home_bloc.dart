import 'package:basu_118/features/home/domain/home_repository.dart';
import 'package:basu_118/features/home/dto/home_response_dto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository repo;
  HomeBloc(this.repo) : super(RelativeInfoInitial()) {
    on<GetRelativeInfo>((event, emit) async {
      try {
        emit(RelativeInfoLoading());
        final response = await repo.getHome();
        emit(RelativeInfoSuccess(response: response));
      } on DioException catch (e) {
        String userMessage = 'خطایی رخ داد';

        if (e.response?.data is Map &&
            (e.response!.data as Map).containsKey('message')) {
          userMessage = e.response!.data['message'];
        }

        emit(RelativeInfoFailure(message: userMessage));
      } catch (e) {
        emit(RelativeInfoFailure(message: e.toString()));
      }
    }
    );
  }
}
