import 'package:basu_118/features/search/data/dto/search_dto.dart';
import 'package:basu_118/features/search/domain/search_repository.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchRepository repo;
  SearchBloc(this.repo) : super(SearchInitial()) {
    on<SearchStarted>((event, emit) async {
      emit(SearchLoading());

      try {
        final response = await repo.search(
          query: event.query,
          facultyId: event.facultyId,
          departmentId: event.departmentId,
          workArea: event.workArea,
        );
        emit(SearchSuccess(response: response));
      } on DioException catch (e) {
        String userMessage = 'خطایی در جستجو رخ داد';

        if (e.response?.data is Map &&
            (e.response!.data as Map).containsKey('message')) {
          userMessage = e.response!.data['message'];
        }

        emit(SearchFailure(message: userMessage));
      } catch (e) {
        emit(SearchFailure(message: e.toString()));
      }
    });

    on<SearchReset>((event, emit) {
      emit(SearchInitial());
    });
  }
}
