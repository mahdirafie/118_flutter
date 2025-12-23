import 'package:basu_118/features/personal_attribute/domain/personal_attribute_repository.dart';
import 'package:basu_118/features/personal_attribute/dto/personal_attribute_dto.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'personal_attribute_event.dart';
part 'personal_attribute_state.dart';

class PersonalAttributeBloc
    extends Bloc<PersonalAttributeEvent, PersonalAttributeState> {
      final PersonalAttributeRepository repo;
  PersonalAttributeBloc(this.repo) : super(PersonalAttributeInitial()) {
    on<GetPersonalAttributesEvent>((event, emit) async {
      try {
        emit(PersonalAttributeLoading());
        final response = await repo.getAllAttribute();
        emit(PersonalAttributeSuccess(response: response));
      } on DioException catch (e) {
        String userMessage = 'خطایی رخ داد';

        if (e.response?.data is Map &&
            (e.response!.data as Map).containsKey('message')) {
          userMessage = e.response!.data['message'];
        }
        emit(PersonalAttributeFailure(message: userMessage));
      } catch (e) {
        emit(PersonalAttributeFailure(message: e.toString()));
      }
    });

    on<SetPersonalAttributeValuesEvent>((event, emit) async{
      try {
        emit(SetPersonalAttributeValuesLoading());
        await repo.setAttributeValues(event.attributes);
        emit(SetPersonalAttributeValuesSuccess(message: "مقادیر با موفقیت به روز رسانی شدند!"));
      } on DioException catch(e) {
        String userMessage = 'خطایی رخ داد';

        if (e.response?.data is Map &&
            (e.response!.data as Map).containsKey('message')) {
          userMessage = e.response!.data['message'];
        }
        emit(PersonalAttributeFailure(message: userMessage));
      } catch(e) {
        emit(SetPersonalAttributeValuesFailure(message: e.toString()));
      }
    });
  }
}
