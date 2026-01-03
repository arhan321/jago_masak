import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/app_theme.dart';
import '../../../core/network/api_client.dart';
import '../../../core/routes.dart';
import '../../../models/recipe.dart';
import '../../../users/recipe/user_recipe_detail_page.dart';

class UserHistoryPage extends StatefulWidget {
  const UserHistoryPage({super.key});

  @override
  State<UserHistoryPage> createState() => _UserHistoryPageState();
}

class _UserHistoryPageState extends State<UserHistoryPage> {
  Dio get _dio => ApiClient.instance.dio;

  int? _meId;
  bool _loadingMe = true;

  bool _loading = true;
  String? _error;
  List<_ApiHistoryItem> _items = [];

  final Set<int> _postingHistory = {};

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _fetchMe();
    if (_meId != null) {
      await _fetchHistory();
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

  Future<void> _fetchHistory() async {
    final uid = _meId;
    if (uid == null) return;

    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await _dio.get('/users/$uid/history');
      final data = res.data;
      final baseUrl = _dio.options.baseUrl;

      List<_ApiHistoryItem> parsed = [];

      if (data is Map && data['data'] is List) {
        final list = List.from(data['data'] as List);
        parsed = list
            .map((e) => e is Map
                ? _ApiHistoryItem.fromJson(
                    Map<String, dynamic>.from(e),
                    baseUrl: baseUrl,
                  )
                : null)
            .whereType<_ApiHistoryItem>()
            .toList();
      } else if (data is List) {
        parsed = data
            .map((e) => e is Map
                ? _ApiHistoryItem.fromJson(
                    Map<String, dynamic>.from(e),
                    baseUrl: baseUrl,
                  )
                : null)
            .whereType<_ApiHistoryItem>()
            .toList();
      } else {
        throw Exception('Format response /users/{id}/history tidak sesuai.');
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
            ? ((e.response?.data['message'] ?? 'Gagal memuat riwayat')
                .toString())
            : 'Gagal memuat riwayat';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _recordHistory(int recipeId) async {
    final uid = _meId;
    if (uid == null) return;

    if (_postingHistory.contains(recipeId)) return;
    _postingHistory.add(recipeId);

    try {
      await _dio.post(
        '/recipes/$recipeId/history',
        data: {'user_id': uid},
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 && mounted) {
        Navigator.pushNamedAndRemoveUntil(context, Routes.login, (r) => false);
        return;
      }
    } catch (_) {
      // ignore
    } finally {
      _postingHistory.remove(recipeId);
    }
  }

  Future<void> _deleteHistory(int recipeId) async {
    final uid = _meId;
    if (uid == null) return;

    try {
      await _dio.delete('/users/$uid/history/$recipeId');
      if (!mounted) return;

      setState(() => _items.removeWhere((x) => x.recipeId == recipeId));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Riwayat dihapus.')),
      );
    } on DioException catch (e) {
      if (!mounted) return;

      if (e.response?.statusCode == 401) {
        Navigator.pushNamedAndRemoveUntil(context, Routes.login, (r) => false);
        return;
      }

      final msg = (e.response?.data is Map)
          ? ((e.response?.data['message'] ?? 'Gagal menghapus riwayat')
              .toString())
          : 'Gagal menghapus riwayat';

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menghapus riwayat')),
      );
    }
  }

  Future<void> _onRefresh() async {
    await _fetchMe();
    if (_meId != null) {
      await _fetchHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Riwayat'),
          leading: const SizedBox(),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: _loadingMe
              ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
              : RefreshIndicator(
                  color: AppTheme.navy,
                  onRefresh: _onRefresh,
                  child: _loading
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 120),
                            Center(
                                child:
                                    CircularProgressIndicator(strokeWidth: 2)),
                          ],
                        )
                      : (_error != null)
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
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
                                        onPressed: _fetchHistory,
                                        child: const Text('Coba lagi'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : (_items.isEmpty)
                              ? ListView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  children: const [
                                    SizedBox(height: 120),
                                    Center(child: Text('Belum ada riwayat.')),
                                  ],
                                )
                              : ListView.separated(
                                  itemCount: _items.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 10),
                                  itemBuilder: (_, i) {
                                    final h = _items[i];
                                    final r = h.recipe;

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
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        subtitle: Text(
                                          '${r.categoryName.isEmpty ? '-' : r.categoryName} • Dilihat ${h.viewCount}x',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        onTap: () async {
                                          // ✅ buka detail + record view lagi
                                          unawaited(_recordHistory(h.recipeId));

                                          final recipeModel = Recipe(
                                            id: r.id,
                                            title: r.title,
                                            category: r.categoryName,
                                            description: r.description,
                                            createdAt: r.createdAt,
                                            imageUrl: r.imageUrl,
                                          );

                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  UserRecipeDetailPage(
                                                      recipe: recipeModel),
                                            ),
                                          );

                                          // refresh supaya view_count & urutan last_viewed_at update
                                          if (mounted) {
                                            await _fetchHistory();
                                          }
                                        },
                                        trailing: IconButton(
                                          tooltip: 'Hapus riwayat',
                                          icon: const Icon(Icons.delete_outline,
                                              color: Colors.red),
                                          onPressed: () =>
                                              _deleteHistory(h.recipeId),
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

class _ApiHistoryItem {
  final int userId;
  final int recipeId;
  final int viewCount;
  final DateTime lastViewedAt;
  final _ApiRecipeLite recipe;

  _ApiHistoryItem({
    required this.userId,
    required this.recipeId,
    required this.viewCount,
    required this.lastViewedAt,
    required this.recipe,
  });

  factory _ApiHistoryItem.fromJson(
    Map<String, dynamic> json, {
    required String baseUrl,
  }) {
    final rawUserId = json['user_id'];
    final rawRecipeId = json['recipe_id'];

    int userId = rawUserId is int ? rawUserId : int.tryParse('$rawUserId') ?? 0;
    int recipeId =
        rawRecipeId is int ? rawRecipeId : int.tryParse('$rawRecipeId') ?? 0;

    final rawViewCount = json['view_count'];
    int viewCount =
        rawViewCount is int ? rawViewCount : int.tryParse('$rawViewCount') ?? 0;

    final lastIso = (json['last_viewed_at'] ?? '').toString();
    final lastViewed = DateTime.tryParse(lastIso) ?? DateTime.now();

    final recipeJson = (json['recipe'] is Map)
        ? Map<String, dynamic>.from(json['recipe'])
        : <String, dynamic>{};

    return _ApiHistoryItem(
      userId: userId,
      recipeId: recipeId,
      viewCount: viewCount,
      lastViewedAt: lastViewed,
      recipe: _ApiRecipeLite.fromJson(recipeJson, baseUrl: baseUrl),
    );
  }
}

class _ApiRecipeLite {
  final int id;
  final String title;
  final String description;
  final String categoryName;
  final DateTime createdAt;
  final String imageUrl;

  _ApiRecipeLite({
    required this.id,
    required this.title,
    required this.description,
    required this.categoryName,
    required this.createdAt,
    required this.imageUrl,
  });

  factory _ApiRecipeLite.fromJson(
    Map<String, dynamic> json, {
    required String baseUrl,
  }) {
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

    return _ApiRecipeLite(
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
