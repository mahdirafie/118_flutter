import 'package:basu_118/features/personal_attribute/domain/personal_attribute_repository.dart';
import 'package:basu_118/features/personal_attribute/dto/personal_attribute_dto.dart';
import 'package:basu_118/features/personal_attribute/dto/personal_attribute_visible_dto.dart';
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

    on<SetPersonalAttributeValuesEvent>((event, emit) async {
      try {
        emit(SetPersonalAttributeValuesLoading());
        await repo.setAttributeValues(event.attributes);
        emit(
          SetPersonalAttributeValuesSuccess(
            message: "مقادیر با موفقیت به روز رسانی شدند!",
          ),
        );
      } on DioException catch (e) {
        String userMessage = 'خطایی رخ داد';

        if (e.response?.data is Map &&
            (e.response!.data as Map).containsKey('message')) {
          userMessage = e.response!.data['message'];
        }
        emit(PersonalAttributeFailure(message: userMessage));
      } catch (e) {
        emit(SetPersonalAttributeValuesFailure(message: e.toString()));
      }
    });

    on<SetVisibleAttributes>((event, emit) async {
      try {
        emit(SetVisibleAttributesLoading());
        await repo.setVisibleAtts(event.id, event.type, event.attVals);
        emit(
          SetVisibleAttributesSuccess(
            message: "اطلاعات با موفقیت تنظیم شدند!",
          ),
        );
      } on DioException catch (e) {
        String userMessage = 'خطایی رخ داد';

        if (e.response?.data is Map &&
            (e.response!.data as Map).containsKey('message')) {
          userMessage = e.response!.data['message'];
        }
        emit(SetVisibleAttributesFailure(message: userMessage));
      } catch (e) {
        emit(SetVisibleAttributesFailure(message: e.toString()));
      }
    });

    on<GetPersonalAttributeValuesWithVisibility>((event, emit) async {
      try {
        emit(GetPersonalAttributeValuesWithVisibilityLoading());
        final response = await repo.getAttributeValuesWithVisibility(
          event.receiverId,
          event.type,
        );
        emit(
          GetPersonalAttributeValuesWithVisibilitySuccess(response: response),
        );
      } on DioException catch (e) {
        String userMessage = 'خطایی رخ داد';

        if (e.response?.data is Map &&
            (e.response!.data as Map).containsKey('message')) {
          userMessage = e.response!.data['message'];
        }
        emit(
          GetPersonalAttributeValuesWithVisibilityFailure(message: userMessage),
        );
      } catch (e) {
        emit(
          GetPersonalAttributeValuesWithVisibilityFailure(
            message: e.toString(),
          ),
        );
      }
    });
  }
}
