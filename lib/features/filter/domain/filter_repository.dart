import 'package:basu_118/features/filter/dto/department_dto.dart';
import 'package:basu_118/features/filter/dto/faculty_dto.dart';
import 'package:basu_118/features/filter/dto/workarea_dto.dart';

abstract class FilterRepository {
  Future<FacultiesResponse> getAllFaculties();
  Future<DepartmentsResponse> getAllFacultyDepartments(int facultyId);
  Future<WorkAreasResponse> getAllWorkareas();
}