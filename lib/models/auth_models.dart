class ApiUser {
  final int id;
  final String name;
  final String email;
  final String role;

  ApiUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory ApiUser.fromJson(Map<String, dynamic> json) {
    return ApiUser(
      id: int.tryParse((json['id'] ?? 0).toString()) ?? 0,
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      role: (json['role'] ?? 'user').toString(),
    );
  }
}

class AuthResult {
  final ApiUser user;
  final String token;

  AuthResult({required this.user, required this.token});

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    final userJson = (json['user'] as Map?)?.cast<String, dynamic>() ?? {};
    return AuthResult(
      user: ApiUser.fromJson(userJson),
      token: (json['token'] ?? '').toString(),
    );
  }
}
