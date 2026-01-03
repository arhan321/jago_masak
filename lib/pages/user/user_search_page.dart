import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/app_theme.dart';
import '../../../core/network/api_client.dart';
import '../../../core/routes.dart';
import '../../../models/recipe.dart';
import '../../../users/recipe/user_recipe_detail_page.dart';

class UserSearchPage extends StatefulWidget {
  const UserSearchPage({super.key});

  @override
  State<UserSearchPage> createState() => _UserSearchPageState();
}

class _UserSearchPageState extends State<UserSearchPage> {
  Dio get _dio => ApiClient.instance.dio;

  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  Timer? _debounce;

  // ===== state query & filter =====
  String _query = '';
  ApiCategory? _selectedCat;

  // ===== categories =====
  bool _loadingCats = true;
  String? _catError;
  List<ApiCategory> _cats = [];

  // ===== recipes =====
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;
  List<_ApiRecipeSearchItem> _recipes = [];

  int _page = 1;
  int _lastPage = 1;

  @override
  void initState() {
    super.initState();

    _fetchCategories();
    _fetchRecipes(page: 1);

    _searchCtrl.addListener(_onSearchChanged);

    _scrollCtrl.addListener(() {
      // load more ketika mendekati bawah
      final pos = _scrollCtrl.position;
      if (pos.pixels >= pos.maxScrollExtent - 180) {
        if (!_loadingMore && !_loading && _page < _lastPage) {
          _fetchRecipes(page: _page + 1, append: true);
        }
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final v = _searchCtrl.text.trim();
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      setState(() => _query = v);
      _fetchRecipes(page: 1);
    });
  }

  Future<void> _fetchCategories() async {
    if (!mounted) return;
    setState(() {
      _loadingCats = true;
      _catError = null;
    });

    try {
      final res = await _dio.get('/cat');
      final data = res.data;

      List list = [];
      if (data is List) {
        list = data;
      } else if (data is Map && data['data'] is List) {
        list = List.from(data['data'] as List);
      }

      final cats = list
          .whereType<Map>()
          .map((e) => ApiCategory.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      if (!mounted) return;
      setState(() {
        _cats = cats;
        _loadingCats = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;

      if (e.response?.statusCode == 401) {
        Navigator.pushNamedAndRemoveUntil(context, Routes.login, (r) => false);
        return;
      }

      setState(() {
        _loadingCats = false;
        _catError = (e.response?.data is Map)
            ? ((e.response?.data['message'] ?? 'Gagal memuat kategori')
                .toString())
            : 'Gagal memuat kategori';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingCats = false;
        _catError = 'Gagal memuat kategori';
      });
    }
  }

  Future<void> _fetchRecipes({required int page, bool append = false}) async {
    if (!mounted) return;

    setState(() {
      _error = null;
      if (append) {
        _loadingMore = true;
      } else {
        _loading = true;
        _page = 1;
        _lastPage = 1;
        _recipes = [];
      }
    });

    try {
      final qp = <String, dynamic>{
        'page': page,
        if (_query.isNotEmpty) 'search': _query,
        if (_selectedCat != null) 'category_id': _selectedCat!.id,
      };

      final res = await _dio.get('/recipes', queryParameters: qp);
      final data = res.data;
      final baseUrl = _dio.options.baseUrl;

      List<_ApiRecipeSearchItem> parsed = [];
      int newPage = page;
      int newLast = 1;

      // Laravel paginate: { data: [...], current_page, last_page, ... }
      if (data is Map && data['data'] is List) {
        final list = List.from(data['data'] as List);

        parsed = list
            .map((e) => e is Map
                ? _ApiRecipeSearchItem.fromJson(
                    Map<String, dynamic>.from(e),
                    baseUrl: baseUrl,
                  )
                : null)
            .whereType<_ApiRecipeSearchItem>()
            .toList();

        newPage = (data['current_page'] is int)
            ? data['current_page'] as int
            : int.tryParse('${data['current_page']}') ?? page;

        newLast = (data['last_page'] is int)
            ? data['last_page'] as int
            : int.tryParse('${data['last_page']}') ?? 1;
      } else if (data is List) {
        parsed = data
            .map((e) => e is Map
                ? _ApiRecipeSearchItem.fromJson(
                    Map<String, dynamic>.from(e),
                    baseUrl: baseUrl,
                  )
                : null)
            .whereType<_ApiRecipeSearchItem>()
            .toList();
        newPage = 1;
        newLast = 1;
      } else {
        throw Exception('Format response /recipes tidak sesuai');
      }

      if (!mounted) return;
      setState(() {
        _page = newPage;
        _lastPage = newLast;
        if (append) {
          _recipes.addAll(parsed);
          _loadingMore = false;
        } else {
          _recipes = parsed;
          _loading = false;
        }
      });
    } on DioException catch (e) {
      if (!mounted) return;

      if (e.response?.statusCode == 401) {
        Navigator.pushNamedAndRemoveUntil(context, Routes.login, (r) => false);
        return;
      }

      setState(() {
        if (append) {
          _loadingMore = false;
        } else {
          _loading = false;
        }
        _error = (e.response?.data is Map)
            ? ((e.response?.data['message'] ?? 'Gagal memuat resep').toString())
            : 'Gagal memuat resep';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        if (append) {
          _loadingMore = false;
        } else {
          _loading = false;
        }
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _onRefresh() async {
    await _fetchRecipes(page: 1);
  }

  void _selectCategory(ApiCategory? c) {
    setState(() => _selectedCat = c);
    _fetchRecipes(page: 1);
  }

  @override
  Widget build(BuildContext context) {
    final subtitle =
        _selectedCat == null ? 'Semua kategori' : _selectedCat!.name;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ===== search bar =====
            TextField(
              controller: _searchCtrl,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Cari resep makanan disini!',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ===== category filter =====
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.softBlue.withOpacity(0.25),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.navy.withOpacity(0.12)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.category_outlined, color: AppTheme.navy),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  if (_loadingCats)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    TextButton(
                      onPressed: _catError != null
                          ? _fetchCategories
                          : () async {
                              final chosen =
                                  await showModalBottomSheet<ApiCategory?>(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.white,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(16)),
                                ),
                                builder: (_) => _CategorySheet(
                                  cats: _cats,
                                  selected: _selectedCat,
                                ),
                              );
                              // chosen bisa null (user klik “Semua kategori” atau tutup)
                              _selectCategory(chosen);
                            },
                      child: Text(_catError != null ? 'Retry' : 'Pilih'),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ===== results =====
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                child: _loading
                    ? ListView(
                        // ❌ jangan const (biar aman)
                        children: const [
                          SizedBox(height: 140),
                          Center(
                              child: CircularProgressIndicator(strokeWidth: 2)),
                        ],
                      )
                    : (_error != null)
                        ? ListView(
                            children: [
                              const SizedBox(height: 80),
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
                                      onPressed: () => _fetchRecipes(page: 1),
                                      child: const Text('Coba lagi'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : (_recipes.isEmpty)
                            ? ListView(
                                children: const [
                                  SizedBox(height: 90),
                                  Center(
                                    child: Text(
                                      'Resep tidak ditemukan.',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ],
                              )
                            : ListView.separated(
                                controller: _scrollCtrl,
                                itemCount:
                                    _recipes.length + (_loadingMore ? 1 : 0),
                                separatorBuilder: (_, __) =>
                                    const Divider(height: 1),
                                itemBuilder: (ctx, i) {
                                  if (_loadingMore && i == _recipes.length) {
                                    return const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 14),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      ),
                                    );
                                  }

                                  final r = _recipes[i];

                                  return ListTile(
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        width: 52,
                                        height: 52,
                                        color: Colors.black12,
                                        child: r.imageUrl.trim().isEmpty
                                            ? const Icon(Icons.image_outlined,
                                                color: Colors.black38)
                                            : Image.network(
                                                r.imageUrl,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
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
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Text(
                                      r.categoryName,
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
                                          builder: (_) => UserRecipeDetailPage(
                                              recipe: recipeModel),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ===== category bottom sheet =====
class _CategorySheet extends StatelessWidget {
  final List<ApiCategory> cats;
  final ApiCategory? selected;

  const _CategorySheet({required this.cats, required this.selected});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 12),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Pilih Kategori',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ),
            const SizedBox(height: 10),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: cats.length + 1,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  // item pertama = Semua kategori
                  if (i == 0) {
                    final isAll = selected == null;
                    return ListTile(
                      title: Text(
                        'Semua Kategori',
                        style: TextStyle(
                          fontWeight: isAll ? FontWeight.w900 : FontWeight.w700,
                        ),
                      ),
                      trailing: isAll
                          ? const Icon(Icons.check, color: Colors.green)
                          : null,
                      onTap: () => Navigator.pop<ApiCategory?>(context, null),
                    );
                  }

                  final c = cats[i - 1];
                  final isSelected = selected?.id == c.id;

                  return ListTile(
                    title: Text(
                      c.name,
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.w900 : FontWeight.w700,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: Colors.green)
                        : null,
                    onTap: () => Navigator.pop<ApiCategory?>(context, c),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ===== model category dari backend =====
class ApiCategory {
  final int id;
  final String name;

  ApiCategory({required this.id, required this.name});

  factory ApiCategory.fromJson(Map<String, dynamic> json) {
    return ApiCategory(
      id: (json['id'] ?? 0) is int
          ? (json['id'] as int)
          : int.tryParse('${json['id']}') ?? 0,
      name: (json['name'] ?? '').toString(),
    );
  }
}

class _ApiRecipeSearchItem {
  final int id;
  final String title;
  final String categoryName;
  final String description;
  final DateTime createdAt;
  final String imageUrl;

  _ApiRecipeSearchItem({
    required this.id,
    required this.title,
    required this.categoryName,
    required this.description,
    required this.createdAt,
    required this.imageUrl,
  });

  factory _ApiRecipeSearchItem.fromJson(
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

    return _ApiRecipeSearchItem(
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
