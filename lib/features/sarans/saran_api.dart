import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';

class SaranApi {
  SaranApi._();
  static final SaranApi instance = SaranApi._();

  Dio get _dio => ApiClient.instance.dio;

  /// GET /sarans
  /// Response Laravel kamu:
  /// { success: true, message: "...", data: [ {id,name,pesan,created_at}, ... ] }
  Future<List<Map<String, dynamic>>> fetchSarans() async {
    final res = await _dio.get('/sarans');
    final data = res.data;

    if (data is Map && data['data'] is List) {
      final list = List.from(data['data'] as List);
      return list
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    // fallback kalau backend sewaktu-waktu return list langsung
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    throw Exception('Format response /sarans tidak sesuai');
  }
}
