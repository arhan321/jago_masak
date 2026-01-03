import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../core/routes.dart';
import '../../../core/app_theme.dart';
import '../../../models/recipe.dart';
import '../../../users/recipe/user_recipe_detail_page.dart';

class UserFavoritePage extends StatefulWidget {
  const UserFavoritePage({super.key});

  @override
  State<UserFavoritePage> createState() => _UserFavoritePageState();
}

class _UserFavoritePageState extends State<UserFavoritePage> {
  Dio get _dio => ApiClient.instance.dio;

  int? _meId;
  bool _loadingMe = true;

  bool _loading = true;
  String? _error;
  List<_ApiFavoriteRecipe> _items = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _fetchMe();
    if (_meId != null) {
      await _fetchFavorites();
    } else {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Gagal mengambil session user.';
      });
    }
  }

  Future<void> _fetchMe() async {
    if (!mounted) return;
    setState(() => _loadingMe = true);

    try {
      final res = await _dio.get('/me'); // auth:sanctum
      final data = res.data;

      if (data is Map) {
        final rawId = data['id'];
        int? id;
        if (rawId is int) id = rawId;
        if (rawId is String) id = int.tryParse(rawId);
        if (rawId is num) id = rawId.toInt();

        if (!mounted) return;
        setState(() {
          _meId = id;
          _loadingMe = false;
        });
        return;
      }

      if (!mounted) return;
      setState(() {
        _meId = null;
        _loadingMe = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;

      if (e.response?.statusCode == 401) {
        Navigator.pushNamedAndRemoveUntil(context, Routes.login, (r) => false);
        return;
      }

      setState(() {
        _meId = null;
        _loadingMe = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _meId = null;
        _loadingMe = false;
      });
    }
  }

  Future<void> _fetchFavorites() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await _dio.get('/me/favorites'); // auth:sanctum
      final data = res.data;
      final baseUrl = _dio.options.baseUrl;

      List<_ApiFavoriteRecipe> parsed = [];

      // controller kamu: { success:true, data:[...] }
      if (data is Map && data['data'] is List) {
        final list = List.from(data['data'] as List);
        parsed = list
            .map((e) => e is Map
                ? _ApiFavoriteRecipe.fromJson(
                    Map<String, dynamic>.from(e),
                    baseUrl: baseUrl,
                  )
                : null)
            .whereType<_ApiFavoriteRecipe>()
            .toList();
      } else if (data is List) {
        parsed = data
            .map((e) => e is Map
                ? _ApiFavoriteRecipe.fromJson(
                    Map<String, dynamic>.from(e),
                    baseUrl: baseUrl,
                  )
                : null)
            .whereType<_ApiFavoriteRecipe>()
            .toList();
      } else {
        throw Exception('Format response /me/favorites tidak sesuai.');
      }

      if (!mounted) return;
      setState(() {
        _items = parsed;
        _loading = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;

      if (e.response?.statusCode == 401) {
        Navigator.pushNamedAndRemoveUntil(context, Routes.login, (r) => false);
        return;
      }

      setState(() {
        _loading = false;
        _error = (e.response?.data is Map)
            ? ((e.response?.data['message'] ?? 'Gagal memuat favorit')
                .toString())
            : 'Gagal memuat favorit';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _unfavorite(int recipeId) async {
    try {
      await _dio.delete('/recipes/$recipeId/favorite'); // auth:sanctum
      if (!mounted) return;
      setState(() => _items.removeWhere((x) => x.id == recipeId));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Favorit dihapus.')),
      );
    } on DioException catch (e) {
      if (!mounted) return;

      if (e.response?.statusCode == 401) {
        Navigator.pushNamedAndRemoveUntil(context, Routes.login, (r) => false);
        return;
      }

      final msg = (e.response?.data is Map)
          ? ((e.response?.data['message'] ?? 'Gagal menghapus favorit')
              .toString())
          : 'Gagal menghapus favorit';

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menghapus favorit')),
      );
    }
  }

  /// Kalau kamu butuh tombol "favorite" di halaman lain:
  /// POST /recipes/{recipe}/favorite butuh user_id dari /me
  Future<void> favorite(int recipeId) async {
    final uid = _meId;
    if (uid == null) return;

    await _dio.post(
      '/recipes/$recipeId/favorite',
      data: {'user_id': uid},
    );
  }

  Future<void> _onRefresh() async {
    // optional: refresh session juga
    await _fetchMe();
    if (_meId != null) {
      await _fetchFavorites();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Favorit'),
          leading: const SizedBox(), // biar mirip prototype (tanpa back)
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: _loadingMe
              ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
              : RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: _loading
                      ? ListView(
                          children: const [
                            SizedBox(height: 120),
                            Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ],
                        )
                      : (_error != null)
                          ? ListView(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.softBlue.withOpacity(0.35),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppTheme.navy.withOpacity(0.15),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.error_outline,
                                          color: Colors.redAccent),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          _error!,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: _fetchFavorites,
                                        child: const Text('Coba lagi'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : (_items.isEmpty)
                              ? ListView(
                                  children: const [
                                    SizedBox(height: 120),
                                    Center(child: Text('Belum ada favorit.')),
                                  ],
                                )
                              : ListView.separated(
                                  itemCount: _items.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 10),
                                  itemBuilder: (_, i) {
                                    final r = _items[i];

                                    return Card(
                                      child: ListTile(
                                        leading: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Container(
                                            width: 56,
                                            height: 56,
                                            color: Colors.black12,
                                            child: (r.imageUrl.trim().isEmpty)
                                                ? const Icon(
                                                    Icons.image_outlined,
                                                    color: Colors.black38)
                                                : Image.network(
                                                    r.imageUrl,
                                                    width: 56,
                                                    height: 56,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (_, __, ___) =>
                                                            const Icon(
                                                      Icons
                                                          .image_not_supported_outlined,
                                                      color: Colors.black38,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                        title: Text(
                                          r.title,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w800),
                                        ),
                                        subtitle: Text(
                                          r.categoryName.isEmpty
                                              ? '-'
                                              : r.categoryName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        onTap: () {
                                          final recipeModel = Recipe(
                                            id: r.id,
                                            title: r.title,
                                            category: r.categoryName,
                                            description: r.description,
                                            createdAt: r.createdAt,
                                            imageUrl: r.imageUrl,
                                          );

                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  UserRecipeDetailPage(
                                                recipe: recipeModel,
                                              ),
                                            ),
                                          );
                                        },
                                        trailing: IconButton(
                                          tooltip: 'Hapus dari favorit',
                                          icon: const Icon(Icons.favorite,
                                              color: Colors.red),
                                          onPressed: () => _unfavorite(r.id),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                ),
        ),
      ),
    );
  }
}

class _ApiFavoriteRecipe {
  final int id;
  final String title;
  final String description;
  final String categoryName;
  final DateTime createdAt;
  final String imageUrl;

  _ApiFavoriteRecipe({
    required this.id,
    required this.title,
    required this.description,
    required this.categoryName,
    required this.createdAt,
    required this.imageUrl,
  });

  factory _ApiFavoriteRecipe.fromJson(
    Map<String, dynamic> json, {
    required String baseUrl,
  }) {
    // category relasi
    String catName = '';
    if (json['category'] is Map) {
      final c = Map<String, dynamic>.from(json['category'] as Map);
      catName = (c['name'] ?? '').toString();
    } else if (json['category_name'] != null) {
      catName = json['category_name'].toString();
    }

    final createdAtIso = (json['created_at'] ?? '').toString();
    final createdAt = DateTime.tryParse(createdAtIso) ?? DateTime.now();

    final photoPath = (json['photo_path'] ?? '').toString();
    final imageUrl = _photoUrlFromPath(baseUrl, photoPath);

    return _ApiFavoriteRecipe(
      id: (json['id'] ?? 0) is int
          ? (json['id'] as int)
          : int.tryParse('${json['id']}') ?? 0,
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      categoryName: catName,
      createdAt: createdAt,
      imageUrl: imageUrl,
    );
  }

  static String _photoUrlFromPath(String baseUrl, String photoPath) {
    if (photoPath.trim().isEmpty) return '';

    // kalau backend sudah kirim full url
    if (photoPath.startsWith('http://') || photoPath.startsWith('https://')) {
      return photoPath;
    }

    // baseUrl biasanya .../api
    final root = baseUrl.endsWith('/api')
        ? baseUrl.substring(0, baseUrl.length - 4)
        : baseUrl;

    return '$root/storage/$photoPath';
  }
}
