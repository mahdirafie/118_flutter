import 'package:basu_118/features/group/domain/group_repository.dart';
import 'package:basu_118/features/group/dto/group_members_response_dto.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'group_member_event.dart';
part 'group_member_state.dart';

class GroupMemberBloc extends Bloc<GroupMemberEvent, GroupMemberState> {
  final GroupRepository repo;
  GroupMemberBloc(this.repo) : super(GetGroupMembersInitial()) {
    on<GetGroupMembersEvent>((event, emit) async{
      try {
        emit(GetGroupMembersLoading());
        final response = await repo.getGroupMembers(event.groupId);
        emit(GetGroupMembersSuccess(response: response));
      } on DioException catch(e) {
        String userMessage = 'خطایی رخ داد';

        if (e.response?.data is Map &&
            (e.response!.data as Map).containsKey('message')) {
          userMessage = e.response!.data['message'];
        }
        emit(GetGroupMembersFailure(message: userMessage));
      } catch(e) {
        emit(GetGroupMembersFailure(message: e.toString()));
      }
    });

    on<DeleteGroupMemberEvent>((event, emit) async{
      try {
        emit(DeleteGroupMemberLoading());
        await repo.removeGroupMember(event.groupId, event.empId);
        emit(DeleteGroupMemberSuccess(message: "کاربر با موفقیت حذف شد!"));
      } on DioException catch(e) {
        String userMessage = 'خطایی رخ داد';

        if (e.response?.data is Map &&
            (e.response!.data as Map).containsKey('message')) {
          userMessage = e.response!.data['message'];
        }
        emit(DeleteGroupmemberFailure(message: userMessage));
      }catch(e) {
        emit(DeleteGroupmemberFailure(message: e.toString()));
      }
    });

    on<AddToGroupEvent>((event, emit) async{
      try {
        emit(AddToGroupLoading());
        await repo.addEmployeeToGroup(event.groupId, event.empId);
        emit(AddToGroupSuccess(message: "با موفقیت به گروه اضافه شد!"));
      } on DioException catch(e) {
        String userMessage = 'خطایی رخ داد';

        if (e.response?.data is Map &&
            (e.response!.data as Map).containsKey('message')) {
          userMessage = e.response!.data['message'];
        }
        emit(AddToGroupFailure(message: userMessage));
      } catch(e) {
        emit(AddToGroupFailure(message: e.toString()));
      }
    });
  }
}
