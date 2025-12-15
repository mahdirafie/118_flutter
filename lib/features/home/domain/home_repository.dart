import 'package:basu_118/features/home/dto/employeef_dto.dart';
import 'package:basu_118/features/home/dto/employeen_dto.dart';
import 'package:basu_118/features/home/dto/user_home_dto.dart';

abstract class HomeRepository {
  Future<EmployeeFDTO> getEmployeeF();
  Future<EmployeeNDTO> getEmployeeN();
  Future<UserHomeDTO> getUserHome();
}