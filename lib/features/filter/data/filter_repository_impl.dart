import 'package:basu_118/core/config/api_service.dart';
import 'package:basu_118/features/filter/domain/filter_repository.dart';
import 'package:basu_118/features/filter/dto/department_dto.dart';
import 'package:basu_118/features/filter/dto/faculty_dto.dart';
import 'package:basu_118/features/filter/dto/workarea_dto.dart';

class FilterRepositoryImpl implements FilterRepository {
  final ApiService api;

  FilterRepositoryImpl({required this.api});

  @override
  Future<FacultiesResponse> getAllFaculties() async{
    final response = await api.get('/faculty/get-all');
    return FacultiesResponse.fromJson(response.data);
  }

  @override
  Future<DepartmentsResponse> getAllFacultyDepartments(int facultyId) async{
    final response = await api.get('/faculty/get-faculty-departments/$facultyId');
    return DepartmentsResponse.fromJson(response.data);
  }

  @override
  Future<WorkAreasResponse> getAllWorkareas() async{
    final response = await api.get('/employee/workareas');
    return WorkAreasResponse.fromJson(response.data);
  }
}