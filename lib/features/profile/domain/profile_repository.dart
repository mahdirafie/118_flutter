import 'package:basu_118/features/profile/data/models/profile_dto.dart';

abstract class ProfileRepository {
  Future<ProfileResponseDTO> getProfile();
}