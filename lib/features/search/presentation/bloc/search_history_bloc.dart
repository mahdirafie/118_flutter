import 'package:basu_118/features/search/data/dto/search_history_dto.dart';
import 'package:basu_118/features/search/domain/search_repository.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'search_history_event.dart';
part 'search_history_state.dart';

class SearchHistoryBloc extends Bloc<SearchHistoryEvent, SearchHistoryState> {
  final SearchRepository repo;
  SearchHistoryBloc(this.repo) : super(GetSearchHistoryInitial()) {
    on<GetSearchHistoryStarted>((event, emit) async{
      try {
        emit(GetSearchHistoryLoading());
        final response = await repo.searchHistories(event.userId);
        emit(GetSearchHistorySuccess(response: response));
      }on DioException catch(e) {
        String userMessage = 'خطایی رخ داد';

        if (e.response?.data is Map &&
            (e.response!.data as Map).containsKey('message')) {
          userMessage = e.response!.data['message'];
        }
        emit(GetSearchHistoryFailure(message: userMessage));
      }catch(e) {
        emit(GetSearchHistoryFailure(message: e.toString()));
      }
    });

    on<DeleteSearchHistory>((event, emit) async{
      try {
        emit(DeleteSearchHistoryLoading());
        await repo.deleteSearchHistory(event.shId);
        emit(DeleteSearchHistorySuccess(message: "تاریخچه با موفقیت حذف شد!"));
      }on DioException catch(e) {
        String userMessage = 'خطایی رخ داد';

        if (e.response?.data is Map &&
            (e.response!.data as Map).containsKey('message')) {
          userMessage = e.response!.data['message'];
        }
        emit(DeleteSearchHistoryFailure(message: userMessage));
      }catch(e) {
        emit(DeleteSearchHistoryFailure(message: e.toString()));
      }
    });

    on<CreateSearchHistory>((event, emit) async{
      try {
        emit(CreateSearchHistoryLoading());
        await repo.createSearchHistory(event.query, event.uid);
        emit(CreateSearchHistorySuccess(message: "تاریخچه با موفقیت ساخته شد!"));
      }on DioException catch(e) {
        String userMessage = 'خطایی رخ داد';

        if (e.response?.data is Map &&
            (e.response!.data as Map).containsKey('message')) {
          userMessage = e.response!.data['message'];
        }
        emit(CreateSearchHistoryFailure(message: userMessage));
      }catch(e) {
        emit(CreateSearchHistoryFailure(message: e.toString()));
      }
    });
  }
}
