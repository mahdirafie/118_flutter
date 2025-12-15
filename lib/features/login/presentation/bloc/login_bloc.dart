import 'package:basu_118/features/login/data/models/login_response_dto.dart';
import 'package:basu_118/features/login/domain/login_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginRepository repo;

  LoginBloc(this.repo) : super(LoginInitial()) {
    on<UserLogin>((event, emit) async{
      try {
        emit(LoginLoading());
        final result = await repo.login(event.username, event.password);
        emit(LoginSuccess(result));
      } on DioException catch(e) {
        String userMessage = 'خطایی رخ داد';

        if (e.response?.data is Map &&
            (e.response!.data as Map).containsKey('message')) {
          userMessage = e.response!.data['message'];
        }

        emit(LoginFailure(userMessage));
      } catch(e) {
        emit(LoginFailure(e.toString()));
      }
    });
  }
}
