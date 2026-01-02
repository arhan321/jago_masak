import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/config/app_config.dart';
import '../core/storage/token_storage.dart';
import '../models/auth_models.dart';

class AuthService {
  AuthService._();
  static final instance = AuthService._();

  final http.Client _client = http.Client();

  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final res = await _client.post(
      AppConfig.apiUri('/register'), // ✅ JANGAN /api/register
      headers: _headersJson(),
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    final data = _decode(res);

    if (res.statusCode == 201 || res.statusCode == 200) {
      final auth = AuthResult.fromJson(data);
      await TokenStorage.instance.saveToken(auth.token);
      return auth;
    }

    throw Exception(
        _extractMessage(data) ?? 'Register gagal (${res.statusCode})');
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final res = await _client.post(
      AppConfig.apiUri('/login'), // ✅ JANGAN /api/login
      headers: _headersJson(),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final data = _decode(res);

    if (res.statusCode == 200) {
      final auth = AuthResult.fromJson(data);
      await TokenStorage.instance.saveToken(auth.token);
      return auth;
    }

    throw Exception(_extractMessage(data) ?? 'Login gagal (${res.statusCode})');
  }

  Map<String, String> _headersJson() => const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

  Map<String, dynamic> _decode(http.Response res) {
    try {
      final body = res.body.isEmpty ? '{}' : res.body;
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {};
    } catch (_) {
      return {};
    }
  }

  String? _extractMessage(Map<String, dynamic> data) {
    if (data['message'] is String) return data['message'] as String;

    final errors = data['errors'];
    if (errors is Map) {
      final keys = errors.keys.toList();
      if (keys.isNotEmpty) {
        final v = errors[keys.first];
        if (v is List && v.isNotEmpty) return v.first.toString();
      }
    }
    return null;
  }

  void dispose() {
    _client.close();
  }
}
