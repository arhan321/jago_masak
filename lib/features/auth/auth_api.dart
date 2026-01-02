import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/token_storage.dart';

class AuthApi {
  final Dio _dio = ApiClient.instance.dio;
  final TokenStorage _tokenStorage = TokenStorage.instance; // ✅ FIX

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final res = await _dio.post('/register', data: {
      'name': name,
      'email': email,
      'password': password,
    });

    final data = Map<String, dynamic>.from(res.data as Map);
    final token = data['token'] as String?;
    if (token != null) await _tokenStorage.saveToken(token);
    return data;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await _dio.post('/login', data: {
      'email': email,
      'password': password,
    });

    final data = Map<String, dynamic>.from(res.data as Map);
    final token = data['token'] as String?;
    if (token != null) await _tokenStorage.saveToken(token);
    return data;
  }

  Future<void> logout() async {
    try {
      await _dio.post('/logout');
    } finally {
      await _tokenStorage.clearToken();
    }
  }

  Future<Map<String, dynamic>> me() async {
    final res = await _dio.get('/me');
    return Map<String, dynamic>.from(res.data as Map);
  }
}
