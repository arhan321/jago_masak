import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/app_theme.dart';
import '../../../core/mock_db.dart';
import '../../../core/network/api_client.dart';
import '../../../core/routes.dart';
import '../../../models/recipe.dart';
import '../../../users/recipe/user_recipe_detail_page.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  final db = MockDb.instance;

  // ✅ resep yang gambarnya error -> disembunyikan
  final Set<int> _hiddenRecipeIds = {};

  // ✅ API state
  Dio get _dio => ApiClient.instance.dio;

  String _userName = '...';
  bool _loadingMe = true;

  bool _loadingRecipes = true;
  String? _errorRecipes;
  List<_ApiRecipeCard> _recipes = [];

  @override
  void initState() {
    super.initState();
    _fetchMe();
    _fetchRecipes();
  }

  /// ✅ Pull-to-refresh handler
  Future<void> _onRefresh() async {
    // reset yang hidden biar kalau gambar sudah bener bisa muncul lagi
    _hiddenRecipeIds.clear();

    // refresh data user + resep
    await Future.wait([
      _fetchMe(),
      _fetchRecipes(),
    ]);
  }

  Future<void> _fetchMe() async {
    if (!mounted) return;
    setState(() => _loadingMe = true);

    try {
      final res = await _dio.get('/me'); // ✅ auth:sanctum
      final data = res.data;

      if (data is Map) {
        final name = (data['name'] ?? '').toString().trim();
        if (!mounted) return;
        setState(() {
          _userName = name.isEmpty ? 'User' : name;
          _loadingMe = false;
        });
        return;
      }

      if (!mounted) return;
      setState(() {
        _userName = 'User';
        _loadingMe = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;

      if (e.response?.statusCode == 401) {
        Navigator.pushNamedAndRemoveUntil(context, Routes.login, (r) => false);
        return;
      }

      setState(() {
        _userName = 'User';
        _loadingMe = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _userName = 'User';
        _loadingMe = false;
      });
    }
  }

  Future<void> _fetchRecipes() async {
    if (!mounted) return;
    setState(() {
      _loadingRecipes = true;
      _errorRecipes = null;
    });

    try {
      final res = await _dio.get(
        '/recipes',
        queryParameters: const {'page': 1},
      );

      final data = res.data;
      final baseUrl = _dio.options.baseUrl;

      List<_ApiRecipeCard> parsed = [];

      if (data is Map && data['data'] is List) {
        final list = List.from(data['data'] as List);
        parsed = list
            .map((e) => e is Map
                ? _ApiRecipeCard.fromJson(
                    Map<String, dynamic>.from(e),
                    baseUrl: baseUrl,
                  )
                : null)
            .whereType<_ApiRecipeCard>()
            .toList();
      } else if (data is List) {
        parsed = data
            .map((e) => e is Map
                ? _ApiRecipeCard.fromJson(
                    Map<String, dynamic>.from(e),
                    baseUrl: baseUrl,
                  )
                : null)
            .whereType<_ApiRecipeCard>()
            .toList();
      } else {
        throw Exception('Format response /recipes tidak sesuai');
      }

      // ambil 6 rekomendasi
      parsed = parsed.take(6).toList();

      if (!mounted) return;
      setState(() {
        _recipes = parsed;
        _loadingRecipes = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;

      if (e.response?.statusCode == 401) {
        Navigator.pushNamedAndRemoveUntil(context, Routes.login, (r) => false);
        return;
      }

      setState(() {
        _loadingRecipes = false;
        _errorRecipes = (e.response?.data is Map)
            ? ((e.response?.data['message'] ?? 'Gagal memuat resep').toString())
            : 'Gagal memuat resep';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingRecipes = false;
        _errorRecipes = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final helloName = _loadingMe ? '...' : _userName;

    // ambil data, tapi skip yang sudah error image
    final recipes =
        _recipes.where((r) => !_hiddenRecipeIds.contains(r.id)).toList();

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Jago Masak'),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none),
            ),
          ],
        ),

        // ✅ RefreshIndicator di sini
        body: RefreshIndicator(
          color: AppTheme.navy,
          onRefresh: _onRefresh,
          child: Padding(
            padding: const EdgeInsets.all(16),

            // ✅ Important: AlwaysScrollableScrollPhysics biar bisa refresh walau konten sedikit
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Text(
                  'Halo, $helloName',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Ayo Cari Resep Makanan yang Mau Dibuat!',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () => Navigator.pushNamed(context, Routes.userSearch),
                  child: IgnorePointer(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Cari resep makanan disini!',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Masak Seadanya',
                    style: TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                InkWell(
                  onTap: () =>
                      Navigator.pushNamed(context, Routes.userMasakSeadanya),
                  child: const Text(
                    'Temukan resep cepat dan seadanya!',
                    style: TextStyle(color: AppTheme.navy, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Rekomendasi Untuk Anda',
                    style: TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                if (_loadingRecipes)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                else if (_errorRecipes != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.softBlue.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: AppTheme.navy.withOpacity(0.15)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.redAccent),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _errorRecipes!,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        TextButton(
                          onPressed: _fetchRecipes,
                          child: const Text('Coba lagi'),
                        ),
                      ],
                    ),
                  )
                else if (recipes.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      'Belum ada resep untuk ditampilkan.',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  )
                else
                  GridView.builder(
                    itemCount: recipes.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.88,
                    ),
                    itemBuilder: (_, i) {
                      final r = recipes[i];
                      final fav = db.isFavorite(r.id);

                      return InkWell(
                        onTap: () {
                          db.addToHistory(r.id);

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
                                  UserRecipeDetailPage(recipe: recipeModel),
                            ),
                          );

                          setState(() {});
                        },
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Image.network(
                                  r.imageUrl,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, progress) {
                                    if (progress == null) return child;
                                    return Container(
                                      color: Colors.black12,
                                      alignment: Alignment.center,
                                      child: const CircularProgressIndicator(
                                          strokeWidth: 2),
                                    );
                                  },
                                  errorBuilder: (_, __, ___) {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      if (mounted &&
                                          !_hiddenRecipeIds.contains(r.id)) {
                                        setState(
                                            () => _hiddenRecipeIds.add(r.id));
                                      }
                                    });
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ),
                              Positioned(
                                right: 8,
                                top: 8,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    db.toggleFavorite(r.id);
                                    setState(() {});
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Icon(
                                      fav
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: fav ? Colors.red : Colors.black54,
                                      size: 22,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  color: Colors.white.withOpacity(0.92),
                                  child: Text(
                                    r.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ApiRecipeCard {
  final int id;
  final String title;
  final String categoryName;
  final String description;
  final DateTime createdAt;
  final String imageUrl;

  _ApiRecipeCard({
    required this.id,
    required this.title,
    required this.categoryName,
    required this.description,
    required this.createdAt,
    required this.imageUrl,
  });

  factory _ApiRecipeCard.fromJson(
    Map<String, dynamic> json, {
    required String baseUrl,
  }) {
    String catName = '-';
    if (json['category'] is Map) {
      final c = Map<String, dynamic>.from(json['category'] as Map);
      catName = (c['name'] ?? '-').toString();
    } else if (json['category_name'] != null) {
      catName = json['category_name'].toString();
    }

    final createdAtIso = (json['created_at'] ?? '').toString();
    final createdAt = DateTime.tryParse(createdAtIso) ?? DateTime.now();

    final photoPath = (json['photo_path'] ?? '').toString();
    final imageUrl = _photoUrlFromPath(baseUrl, photoPath);

    return _ApiRecipeCard(
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

    if (photoPath.startsWith('http://') || photoPath.startsWith('https://')) {
      return photoPath;
    }

    final root = baseUrl.endsWith('/api')
        ? baseUrl.substring(0, baseUrl.length - 4)
        : baseUrl;

    return '$root/storage/$photoPath';
  }
}
