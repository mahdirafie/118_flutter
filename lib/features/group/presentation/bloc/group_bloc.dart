import 'package:basu_118/features/group/domain/group_repository.dart';
import 'package:basu_118/features/group/dto/group_response_dto.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'group_event.dart';
part 'group_state.dart';

class GroupBloc extends Bloc<GroupEvent, GroupState> {
  final GroupRepository repo;
  GroupBloc(this.repo) : super(GetGroupInitial()) {
    on<GetGroupsStarted>((event, emit) async{
      try {
        emit(GetGroupLoading());
        final response = await repo.getGroups(event.userId);
        emit(GetGroupSuccess(response: response));
      }on DioException catch(e) {
         String userMessage = 'خطایی رخ داد';

        if (e.response?.data is Map &&
            (e.response!.data as Map).containsKey('message')) {
          userMessage = e.response!.data['message'];
        }
        emit(GetGroupFailure(message: userMessage));
      }catch(e) {
        emit(GetGroupFailure(message: e.toString()));
      }
    });

    on<CreateGroupEvent>((event, emit) async{
      try {
        emit(CreateGroupLoading());
        await repo.createGroup(event.userId, event.groupName, event.template);
        emit(CreateGroupSuccess(message: "گروه با موفقیت ساخته شد!"));
      } on DioException catch(e) {
         String userMessage = 'خطایی رخ داد';

        if (e.response?.data is Map &&
            (e.response!.data as Map).containsKey('message')) {
          userMessage = e.response!.data['message'];
        }
        emit(CreateGroupFailure(message: userMessage));
      }catch(e) {
        emit(CreateGroupFailure(message: e.toString()));
      }
    });

    on<DeleteGroupEvent>((event, emit) async{
      try {
        emit(DeleteGroupLoading());
        await repo.deleteGroup(event.groupId);
        emit(DeleteGroupSuccess(message: "گروه با موفقیت حذف شد!"));
      } on DioException catch(e) {
        String userMessage = 'خطایی رخ داد';

        if (e.response?.data is Map &&
            (e.response!.data as Map).containsKey('message')) {
          userMessage = e.response!.data['message'];
        }
        emit(DeleteGroupFailure(message: userMessage));
      }catch(e) {
        emit(DeleteGroupFailure(message: e.toString()));
      }
    });
  }
}
