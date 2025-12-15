import 'package:basu_118/core/auth_service/auth_service.dart';
import 'package:basu_118/core/config/api_service.dart';
import 'package:basu_118/features/profile/data/models/profile_dto.dart';
import 'package:basu_118/features/profile/domain/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ApiService api;

  ProfileRepositoryImpl({required this.api});

  @override
  Future<ProfileResponseDTO> getProfile() async{
    final response = await api.get('/profile/${AuthService().userInfo?.uid}');

    return ProfileResponseDTO.fromJson(response.data);
  }

}