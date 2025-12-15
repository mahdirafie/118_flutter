import 'package:basu_118/features/profile/data/models/profile_dto.dart';
import 'package:basu_118/features/profile/domain/profile_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository repo;
  ProfileBloc(this.repo) : super(GetProfileInitial()) {
    on<GetProfile>((event, emit) async{
      try {
        emit(GetProfileLoading());
        final response = await repo.getProfile();
        emit(GetProfileSuccess(response: response));
      } on DioException catch(e) {
        String userMessage = 'خطایی رخ داد';

        if (e.response?.data is Map &&
            (e.response!.data as Map).containsKey('message')) {
          userMessage = e.response!.data['message'];
        }

        emit(GetProfileFailure(message: userMessage));
      } catch(e) {
        emit(GetProfileFailure(message: e.toString()));
      }
    });
  }
}
