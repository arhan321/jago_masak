import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';

class RecipeApi {
  RecipeApi._();
  static final RecipeApi instance = RecipeApi._();

  Dio get _dio => ApiClient.instance.dio;

  /// POST /recipes
  ///
  /// Laravel validate expects:
  /// - title
  /// - description (nullable)
  /// - category_id (nullable)
  /// - photo (nullable, multipart file)
  ///
  /// NOTE: category_id harus int (id kategori), BUKAN string nama kategori.
  Future<Map<String, dynamic>> createRecipe({
    required String title,
    required String description,
    int? categoryId, // ✅ ini yang dipakai sekarang
    File? imageFile, // mobile
    Uint8List? imageBytes, // web
    String? imageFileName,
  }) async {
    final formData = FormData();

    formData.fields
      ..add(MapEntry('title', title))
      ..add(MapEntry('description', description));

    // ✅ kirim category_id kalau ada
    if (categoryId != null) {
      formData.fields.add(MapEntry('category_id', categoryId.toString()));
    }

    // ✅ file harus bernama "photo" (sesuai Laravel: hasFile('photo'))
    final photo = await _buildPhotoMultipart(
      imageFile: imageFile,
      imageBytes: imageBytes,
      imageFileName: imageFileName,
    );
    if (photo != null) {
      formData.files.add(MapEntry('photo', photo));
    }

    final res = await _dio.post(
      '/recipes',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    final data = res.data;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);

    throw Exception('Response create recipe tidak valid');
  }

  /// PUT /recipes/{id}
  ///
  /// Kalau backend kamu pakai resource route (PUT/PATCH),
  /// ini aman karena pakai X-HTTP-Method-Override: PUT via POST.
  Future<Map<String, dynamic>> updateRecipe({
    required int id,
    required String title,
    required String description,
    int? categoryId,
    File? imageFile,
    Uint8List? imageBytes,
    String? imageFileName,
  }) async {
    final formData = FormData();

    formData.fields
      ..add(MapEntry('title', title))
      ..add(MapEntry('description', description));

    if (categoryId != null) {
      formData.fields.add(MapEntry('category_id', categoryId.toString()));
    }

    final photo = await _buildPhotoMultipart(
      imageFile: imageFile,
      imageBytes: imageBytes,
      imageFileName: imageFileName,
    );
    if (photo != null) {
      formData.files.add(MapEntry('photo', photo));
    }

    final res = await _dio.post(
      '/recipes/$id',
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
        headers: const {
          'X-HTTP-Method-Override': 'PUT',
        },
      ),
    );

    final data = res.data;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);

    throw Exception('Response update recipe tidak valid');
  }

  /// Helper bikin MultipartFile "photo"
  Future<MultipartFile?> _buildPhotoMultipart({
    File? imageFile,
    Uint8List? imageBytes,
    String? imageFileName,
  }) async {
    if (imageFile == null && imageBytes == null) return null;

    final filename = (imageFileName != null && imageFileName.trim().isNotEmpty)
        ? imageFileName.trim()
        : 'photo.jpg';

    if (imageFile != null) {
      return MultipartFile.fromFile(
        imageFile.path,
        filename: filename,
      );
    }

    return MultipartFile.fromBytes(
      imageBytes!,
      filename: filename,
    );
  }
}
