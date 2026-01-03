import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/network/api_client.dart';
import '../../core/routes.dart';
import '../../models/recipe.dart';
import '../../widgets/admin_drawer.dart';
import 'add_edit_recipe_page.dart';

class ManageRecipesPage extends StatefulWidget {
  const ManageRecipesPage({super.key});

  @override
  State<ManageRecipesPage> createState() => _ManageRecipesPageState();
}

class _ManageRecipesPageState extends State<ManageRecipesPage> {
  final _searchCtrl = TextEditingController();
  final ScrollController _hCtrl = ScrollController();

  bool _loading = true;
  String? _error;

  String query = '';
  Timer? _debounce;

  // data dari API
  List<_ApiRecipeRow> _recipes = [];

  // pagination (optional)
  int _page = 1;
  int _lastPage = 1;

  Dio get _dio => ApiClient.instance.dio;

  @override
  void initState() {
    super.initState();
    _fetchRecipes(page: 1);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _hCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String v) {
    query = v.trim();
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _fetchRecipes(page: 1);
    });
  }

  Future<void> _fetchRecipes({required int page}) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await _dio.get(
        '/admin/recipes', // ⚠️ sesuaikan jika endpoint kamu beda
        queryParameters: {
          'page': page,
          if (query.isNotEmpty) 'search': query,
        },
      );

      final data = res.data;

      // Laravel paginate: { data: [...], last_page: N, current_page: N, ... }
      if (data is Map && data['data'] is List) {
        final list = List.from(data['data'] as List);

        final parsed = list
            .map((e) => e is Map
                ? _ApiRecipeRow.fromJson(
                    Map<String, dynamic>.from(e),
                    baseUrl: _dio.options.baseUrl,
                  )
                : null)
            .whereType<_ApiRecipeRow>()
            .toList();

        if (!mounted) return;
        setState(() {
          _recipes = parsed;
          _page = (data['current_page'] is int)
              ? data['current_page'] as int
              : int.tryParse('${data['current_page']}') ?? 1;
          _lastPage = (data['last_page'] is int)
              ? data['last_page'] as int
              : int.tryParse('${data['last_page']}') ?? 1;
          _loading = false;
        });
        return;
      }

      // Kalau backend return List langsung
      if (data is List) {
        final parsed = data
            .map((e) => e is Map
                ? _ApiRecipeRow.fromJson(
                    Map<String, dynamic>.from(e),
                    baseUrl: _dio.options.baseUrl,
                  )
                : null)
            .whereType<_ApiRecipeRow>()
            .toList();

        if (!mounted) return;
        setState(() {
          _recipes = parsed;
          _page = 1;
          _lastPage = 1;
          _loading = false;
        });
        return;
      }

      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Format response tidak sesuai';
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
            ? ((e.response?.data['message'] ?? 'Gagal memuat resep').toString())
            : 'Gagal memuat resep';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Gagal memuat resep';
      });
    }
  }

  Future<void> _confirmDelete(_ApiRecipeRow r) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Resep'),
        content: Text('Yakin mau hapus "${r.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      await _dio.delete('/recipes/${r.id}');

      if (!mounted) return;
      _snack('Resep dihapus.');
      _fetchRecipes(page: 1);
    } on DioException catch (e) {
      if (!mounted) return;

      if (e.response?.statusCode == 401) {
        Navigator.pushNamedAndRemoveUntil(context, Routes.login, (r) => false);
        return;
      }

      final msg = (e.response?.data is Map)
          ? ((e.response?.data['message'] ?? 'Gagal hapus resep').toString())
          : 'Gagal hapus resep';

      _snack(msg);
    } catch (_) {
      if (!mounted) return;
      _snack('Gagal hapus resep');
    }
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _openAdd() async {
    final created = await Navigator.push<bool?>(
      context,
      MaterialPageRoute(
        builder: (_) => const AddEditRecipePage(mode: FormMode.add),
      ),
    );

    if (created == true && mounted) {
      _fetchRecipes(page: 1);
      _snack('Resep berhasil ditambahkan!');
    }
  }

  Future<void> _openEdit(_ApiRecipeRow r) async {
    // ✅ FIX: model Recipe butuh imageUrl => isi dari API (photo_path -> url)
    final recipe = Recipe(
      id: r.id,
      title: r.title,
      category: r.categoryName,
      description: r.description ?? '',
      createdAt: DateTime.tryParse(r.createdAtIso ?? '') ?? DateTime.now(),
      imageUrl: r.imageUrl ?? '', // ✅ INI YANG BIKIN ERROR HILANG
    );

    final updated = await Navigator.push<bool?>(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditRecipePage(mode: FormMode.edit, recipe: recipe),
      ),
    );

    if (updated == true && mounted) {
      _fetchRecipes(page: 1);
      _snack('Resep berhasil diperbarui!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jago Masak')),
      drawer: const AdminDrawer(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.navy,
        onPressed: _openAdd,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Kelola Resep',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _searchCtrl,
              onChanged: _onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'Cari resep makanan disini!',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : (_error != null)
                            ? _ErrorBox(
                                message: _error!,
                                onRetry: () => _fetchRecipes(page: 1),
                              )
                            : Column(
                                children: [
                                  Expanded(
                                    child: Scrollbar(
                                      controller: _hCtrl,
                                      thumbVisibility: true,
                                      trackVisibility: true,
                                      scrollbarOrientation:
                                          ScrollbarOrientation.bottom,
                                      child: SingleChildScrollView(
                                        controller: _hCtrl,
                                        scrollDirection: Axis.horizontal,
                                        child: ConstrainedBox(
                                          constraints: const BoxConstraints(
                                              minWidth: 900),
                                          child: DataTable(
                                            headingRowHeight: 48,
                                            dataRowHeight: 56,
                                            columnSpacing: 28,
                                            horizontalMargin: 16,
                                            dividerThickness: 0.8,
                                            headingRowColor:
                                                MaterialStatePropertyAll(
                                              AppTheme.navy.withOpacity(0.92),
                                            ),
                                            headingTextStyle: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w800,
                                            ),
                                            columns: const [
                                              DataColumn(
                                                label: SizedBox(
                                                    width: 50,
                                                    child: Text('No')),
                                              ),
                                              DataColumn(
                                                label: SizedBox(
                                                    width: 260,
                                                    child: Text('Nama Resep')),
                                              ),
                                              DataColumn(
                                                label: SizedBox(
                                                    width: 160,
                                                    child: Text('Kategori')),
                                              ),
                                              DataColumn(
                                                label: SizedBox(
                                                    width: 180,
                                                    child: Text(
                                                        'Terakhir dibuat')),
                                              ),
                                              DataColumn(
                                                label: SizedBox(
                                                    width: 120,
                                                    child: Text('Aksi')),
                                              ),
                                            ],
                                            rows: List.generate(_recipes.length,
                                                (i) {
                                              final r = _recipes[i];
                                              return DataRow(
                                                cells: [
                                                  DataCell(SizedBox(
                                                      width: 50,
                                                      child:
                                                          Text('${i + 1}.'))),
                                                  DataCell(
                                                    SizedBox(
                                                      width: 260,
                                                      child: InkWell(
                                                        onTap: () =>
                                                            _openEdit(r),
                                                        child: Text(
                                                          r.title,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                            color:
                                                                AppTheme.navy,
                                                            decoration:
                                                                TextDecoration
                                                                    .underline,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(SizedBox(
                                                    width: 160,
                                                    child: Text(r.categoryName),
                                                  )),
                                                  DataCell(SizedBox(
                                                    width: 180,
                                                    child:
                                                        Text(r.createdAtText),
                                                  )),
                                                  DataCell(
                                                    SizedBox(
                                                      width: 120,
                                                      child: Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: IconButton(
                                                          tooltip: 'Hapus',
                                                          icon: const Icon(
                                                            Icons.delete,
                                                            color: Colors.red,
                                                          ),
                                                          onPressed: () =>
                                                              _confirmDelete(r),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (_lastPage > 1)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text('$_page / $_lastPage',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w700)),
                                          const SizedBox(width: 10),
                                          IconButton(
                                            onPressed: (_page <= 1)
                                                ? null
                                                : () => _fetchRecipes(
                                                    page: _page - 1),
                                            icon:
                                                const Icon(Icons.chevron_left),
                                          ),
                                          IconButton(
                                            onPressed: (_page >= _lastPage)
                                                ? null
                                                : () => _fetchRecipes(
                                                    page: _page + 1),
                                            icon:
                                                const Icon(Icons.chevron_right),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ApiRecipeRow {
  final int id;
  final String title;
  final String categoryName;
  final String createdAtText;

  // optional buat edit
  final String? description;
  final String? createdAtIso;

  // ✅ untuk memenuhi Recipe.imageUrl
  final String? imageUrl;

  _ApiRecipeRow({
    required this.id,
    required this.title,
    required this.categoryName,
    required this.createdAtText,
    this.description,
    this.createdAtIso,
    this.imageUrl,
  });

  factory _ApiRecipeRow.fromJson(
    Map<String, dynamic> json, {
    required String baseUrl,
  }) {
    final createdAt = (json['created_at'] ?? '').toString();

    // category bisa relasi: {category: {name: ...}}
    String catName = '-';
    if (json['category'] is Map) {
      final c = Map<String, dynamic>.from(json['category'] as Map);
      catName = (c['name'] ?? '-').toString();
    } else if (json['category_name'] != null) {
      catName = json['category_name'].toString();
    } else if (json['category_id'] != null) {
      catName = 'ID ${json['category_id']}';
    }

    // ✅ photo_path dari Laravel public disk: "recipes/xxx.jpg"
    final photoPath = (json['photo_path'] ?? '').toString();
    final imgUrl = _photoUrlFromPath(baseUrl, photoPath);

    return _ApiRecipeRow(
      id: (json['id'] ?? 0) is int
          ? (json['id'] as int)
          : int.tryParse('${json['id']}') ?? 0,
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      categoryName: catName,
      createdAtIso: createdAt,
      createdAtText: _formatCreatedAt(createdAt),
      imageUrl: imgUrl,
    );
  }

  static String _photoUrlFromPath(String baseUrl, String photoPath) {
    if (photoPath.trim().isEmpty) return '';

    // kalau backend sudah kirim full url
    if (photoPath.startsWith('http://') || photoPath.startsWith('https://')) {
      return photoPath;
    }

    // baseUrl kamu biasanya .../api
    // jadi kita ambil origin-nya untuk /storage/...
    final root = baseUrl.endsWith('/api')
        ? baseUrl.substring(0, baseUrl.length - 4)
        : baseUrl;

    return '$root/storage/$photoPath';
  }

  static String _formatCreatedAt(String iso) {
    if (iso.isEmpty) return '-';
    final s = iso.replaceAll('T', ' ');
    final noMs = s.split('.').first;
    final noZ = noMs.replaceAll('Z', '');
    return noZ.length >= 16 ? noZ.substring(0, 16) : noZ;
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBox({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
