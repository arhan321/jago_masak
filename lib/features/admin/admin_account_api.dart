import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';

class AdminAccountApi {
  AdminAccountApi._();
  static final AdminAccountApi instance = AdminAccountApi._();

  Dio get _dio => ApiClient.instance.dio;

  Future<Map<String, dynamic>> me() async {
    final res = await _dio.get('/me');
    final data = res.data;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw Exception('Response /me tidak valid');
  }

  Future<Map<String, dynamic>> updateById({
    required int id,
    String? name,
    String? email,
    String? nomorTelfon,
    String? password,
  }) async {
    final payload = <String, dynamic>{};

    // kirim hanya yang diisi (sesuai rule "sometimes")
    if (name != null) payload['name'] = name;
    if (email != null) payload['email'] = email;
    if (nomorTelfon != null) payload['nomor_telfon'] = nomorTelfon;

    // password: kalau kosong jangan kirim (biar tidak ke-validate min:8)
    if (password != null && password.trim().isNotEmpty) {
      payload['password'] = password.trim();
    }

    final res = await _dio.patch('/users/$id', data: payload);
    final data = res.data;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw Exception('Response update user tidak valid');
  }
}
