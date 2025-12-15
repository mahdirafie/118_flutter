class LoginResponse {
  final String userType;
  final int userId;
  final Tokens tokens;

  LoginResponse({
    required this.userType,
    required this.userId,
    required this.tokens,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      userType: json['user_type'],
      userId: json['user_id'],
      tokens: Tokens.fromJson(json['tokens']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_type': userType,
      'user_id': userId,
      'tokens': tokens.toJson(),
    };
  }
}

class Tokens {
  final String accessToken;
  final String refreshToken;

  Tokens({
    required this.accessToken,
    required this.refreshToken,
  });

  factory Tokens.fromJson(Map<String, dynamic> json) {
    return Tokens(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
    };
  }
}
