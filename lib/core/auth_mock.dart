enum UserRole { admin, user }

class AuthResult {
  final bool ok;
  final String message;
  final UserRole? role;
  final String? name;
  final String? email;

  const AuthResult({
    required this.ok,
    required this.message,
    this.role,
    this.name,
    this.email,
  });
}

class AuthMock {
  /// Dummy account:
  /// admin / admin123  -> role admin
  /// user  / user123   -> role user
  static Future<AuthResult> login({
    required String username,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));

    final u = username.trim().toLowerCase();
    final p = password.trim();

    if (u == 'admin' && p == 'admin123') {
      return const AuthResult(
        ok: true,
        message: 'Login admin berhasil',
        role: UserRole.admin,
        name: 'Admin',
        email: 'admin@jagomasak.com',
      );
    }

    if (u == 'user' && p == 'user123') {
      return const AuthResult(
        ok: true,
        message: 'Login user berhasil',
        role: UserRole.user,
        name: 'Sarminah',
        email: 'sarminah@gmail.com',
      );
    }

    return const AuthResult(
      ok: false,
      message: 'Username / password salah (dummy)',
    );
  }
}
