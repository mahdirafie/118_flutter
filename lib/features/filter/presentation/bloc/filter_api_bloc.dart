import 'package:basu_118/features/filter/domain/filter_repository.dart';
import 'package:basu_118/features/filter/dto/department_dto.dart';
import 'package:basu_118/features/filter/dto/faculty_dto.dart';
import 'package:basu_118/features/filter/dto/workarea_dto.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'filter_api_event.dart';
part 'filter_api_state.dart';

class FilterApiBloc extends Bloc<FilterApiEvent, FilterApiState> {
  final FilterRepository repo;
  FilterApiBloc(this.repo) : super(GetAllFacultiesInitial()) {
    on<GetAllFaculties>((event, emit) async{
      try {
        emit(GetAllFacultiesLoading());
        final response = await repo.getAllFaculties();
        emit(GetAllFacultiesSuccess(response: response));
      } on DioException catch(e) {
        String userMessage = 'خطایی رخ داد';

        if (e.response?.data is Map &&
            (e.response!.data as Map).containsKey('message')) {
          userMessage = e.response!.data['message'];
        }

        emit(GetAllFacultiesFailure(message: userMessage));
      } catch (e) {
        emit(GetAllFacultiesFailure(message: e.toString()));
      }
    });

    on<GetAllFacultyDepartments>((event, emit) async{
      try {
        emit(GetAllFacultyDepartmentsLoading());
        final response = await repo.getAllFacultyDepartments(event.facultyId);
        emit(GetAllFacultyDepartmentsSuccess(response: response));
      }on DioException catch(e) {
        String userMessage = 'خطایی رخ داد';

        if (e.response?.data is Map &&
            (e.response!.data as Map).containsKey('message')) {
          userMessage = e.response!.data['message'];
        }
        emit(GetAllFacultyDepartmentsFailure(message: userMessage));
      } catch(e) {
        emit(GetAllFacultyDepartmentsFailure(message: e.toString()));
      }
    });

    on<GetAllWorkareas>((event, emit) async {
      try {
        emit(GetAllWorkareasLoading());
        final response = await repo.getAllWorkareas();
        emit(GetAllWorkareasSuccess(response: response));
      } on DioException catch(e) {
        String userMessage = 'خطایی رخ داد';

        if (e.response?.data is Map &&
            (e.response!.data as Map).containsKey('message')) {
          userMessage = e.response!.data['message'];
        }
        emit(GetAllWorkareasFailure(message: userMessage));
      } catch(e) {
        emit(GetAllWorkareasFailure(message: e.toString()));
      }
    });
  }
}
