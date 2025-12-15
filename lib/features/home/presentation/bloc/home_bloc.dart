import 'package:basu_118/features/home/domain/home_repository.dart';
import 'package:basu_118/features/home/dto/employeef_dto.dart';
import 'package:basu_118/features/home/dto/employeen_dto.dart';
import 'package:basu_118/features/home/dto/user_home_dto.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository repo;
  HomeBloc(this.repo) : super(RelativeInfoInitial()) {
    // on<GetRelativeInfo>((event, emit) async {
    //   try {
    //     emit(RelativeInfoLoading());
    //     if (AuthService().userInfo != null) {
    //       if (AuthService().userInfo!.role! == "user") {
    //         final userhome = await repo.getUserHome();
    //         emit(RelativeInfoSuccess(userhome: userhome));
    //       } else if (AuthService().userInfo!.role! == "employee") {
    //         if (AuthService().userInfo!.empType! == "employee-f") {
    //           final empf = await repo.getEmployeeF();
    //           emit(RelativeInfoSuccess(empf: empf));
    //         } else if (AuthService().userInfo!.empType! == "employee-n") {
    //           final empn = await repo.getEmployeeN();
    //           emit(RelativeInfoSuccess(empn: empn));
    //         }
    //       }
    //     }
    //   } on DioException catch (e) {
    //     String userMessage = 'خطایی رخ داد';

    //     if (e.response?.data is Map &&
    //         (e.response!.data as Map).containsKey('message')) {
    //       userMessage = e.response!.data['message'];
    //     }

    //     emit(RelativeInfoFailure(message: userMessage));
    //   } catch (e) {
    //     emit(RelativeInfoFailure(message: e.toString()));
    //   }
    // }
    // );
  }
}
