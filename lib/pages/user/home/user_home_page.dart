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
  final Set<int> _hiddenRecipeIds = {};

  Dio get _dio => ApiClient.instance.dio;

  int? _meId;
  String _userName = '...';
  bool _loadingMe = true;

  bool _loadingRecipes = true;
  String? _errorRecipes;
  List<_ApiRecipeCard> _recipes = [];

  // ✅ favorites state dari backend (yang menentukan icon hati)
  bool _loadingFavs = true;
  Set<int> _favoriteIds = {};

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _fetchMe();
    await Future.wait([
      _fetchRecipes(),
      _fetchFavoritesIds(), // ✅ penting
    ]);
  }

  Future<void> _onRefresh() async {
    _hiddenRecipeIds.clear();
    await _fetchMe();
    await Future.wait([
      _fetchRecipes(),
      _fetchFavoritesIds(),
    ]);
  }

  Future<void> _fetchMe() async {
    if (!mounted) return;
    setState(() => _loadingMe = true);

    try {
      final res = await _dio.get('/me'); // auth:sanctum
      final data = res.data;

      if (data is Map) {
        final name = (data['name'] ?? '').toString().trim();

        final rawId = data['id'];
        int? id;
        if (rawId is int) id = rawId;
        if (rawId is String) id = int.tryParse(rawId);
        if (rawId is num) id = rawId.toInt();

        if (!mounted) return;
        setState(() {
          _meId = id;
          _userName = name.isEmpty ? 'User' : name;
          _loadingMe = false;
        });
        return;
      }

      if (!mounted) return;
      setState(() {
        _meId = null;
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
        _meId = null;
        _userName = 'User';
        _loadingMe = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _meId = null;
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

  /// ✅ ambil daftar favorite dari backend untuk status icon
  Future<void> _fetchFavoritesIds() async {
    if (!mounted) return;
    setState(() => _loadingFavs = true);

    try {
      final res = await _dio.get('/me/favorites'); // auth:sanctum
      final data = res.data;

      final Set<int> ids = {};

      // controller: { success:true, data:[...] }
      if (data is Map && data['data'] is List) {
        for (final e in List.from(data['data'] as List)) {
          if (e is Map) {
            final raw = e['id'];
            int? id;
            if (raw is int) id = raw;
            if (raw is String) id = int.tryParse(raw);
            if (raw is num) id = raw.toInt();
            if (id != null) ids.add(id);
          }
        }
      } else if (data is List) {
        for (final e in data) {
          if (e is Map) {
            final raw = e['id'];
            int? id;
            if (raw is int) id = raw;
            if (raw is String) id = int.tryParse(raw);
            if (raw is num) id = raw.toInt();
            if (id != null) ids.add(id);
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _favoriteIds = ids;
        _loadingFavs = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;

      if (e.response?.statusCode == 401) {
        Navigator.pushNamedAndRemoveUntil(context, Routes.login, (r) => false);
        return;
      }

      // kalau error, jangan bikin page crash — cukup anggap kosong
      setState(() {
        _favoriteIds = {};
        _loadingFavs = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _favoriteIds = {};
        _loadingFavs = false;
      });
    }
  }

  /// ✅ toggle favorite ke backend
  Future<void> _toggleFavorite(_ApiRecipeCard r) async {
    // kalau belum punya session, lempar login
    if (_meId == null) {
      Navigator.pushNamedAndRemoveUntil(context, Routes.login, (x) => false);
      return;
    }

    final isFav = _favoriteIds.contains(r.id);

    // optimistic update biar UI responsif
    setState(() {
      if (isFav) {
        _favoriteIds.remove(r.id);
      } else {
        _favoriteIds.add(r.id);
      }
    });

    try {
      if (isFav) {
        await _dio.delete('/recipes/${r.id}/favorite');
      } else {
        // kalau backend kamu sudah pakai $request->user() di store,
        // kamu bisa kirim body kosong. Kalau masih minta user_id, kirim ini:
        await _dio.post('/recipes/${r.id}/favorite', data: {'user_id': _meId});
      }
    } on DioException catch (e) {
      // rollback kalau gagal
      if (!mounted) return;
      setState(() {
        if (isFav) {
          _favoriteIds.add(r.id);
        } else {
          _favoriteIds.remove(r.id);
        }
      });

      if (e.response?.statusCode == 401) {
        Navigator.pushNamedAndRemoveUntil(context, Routes.login, (x) => false);
        return;
      }

      final msg = (e.response?.data is Map)
          ? ((e.response?.data['message'] ?? 'Gagal update favorit').toString())
          : 'Gagal update favorit';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (_) {
      // rollback
      if (!mounted) return;
      setState(() {
        if (isFav) {
          _favoriteIds.add(r.id);
        } else {
          _favoriteIds.remove(r.id);
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal update favorit')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final helloName = _loadingMe ? '...' : _userName;

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
        body: RefreshIndicator(
          color: AppTheme.navy,
          onRefresh: _onRefresh,
          child: Padding(
            padding: const EdgeInsets.all(16),
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
                const Text('Rekomendasi Untuk Anda',
                    style: TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                if (_loadingRecipes)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
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

                      // ✅ icon pakai backend favorites
                      final fav = _favoriteIds.contains(r.id);
                      final favLoading = _loadingFavs; // optional

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

                              // ✅ tombol favorite ke API
                              Positioned(
                                right: 8,
                                top: 8,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: favLoading
                                      ? null
                                      : () => _toggleFavorite(r),
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
