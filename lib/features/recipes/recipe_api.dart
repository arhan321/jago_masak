import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';

class RecipeApi {
  final Dio _dio = ApiClient.instance.dio;

  Future<Map<String, dynamic>> listPublic({
    String? search,
    int? categoryId,
    int page = 1,
  }) async {
    final res = await _dio.get('/recipes',
        queryParameters: {
          'search': search,
          'category_id': categoryId,
          'page': page,
        }..removeWhere(
            (k, v) => v == null || (v is String && v.trim().isEmpty)));

    return res.data as Map<String, dynamic>; // paginate object
  }

  Future<Map<String, dynamic>> detail(int id) async {
    final res = await _dio.get('/recipes/$id');
    return res.data as Map<String, dynamic>;
  }
}
