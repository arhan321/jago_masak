import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../../core/routes.dart';
import '../../widgets/admin_drawer.dart';

class ManageCategoriesPage extends StatefulWidget {
  const ManageCategoriesPage({super.key});

  @override
  State<ManageCategoriesPage> createState() => _ManageCategoriesPageState();
}

class _ManageCategoriesPageState extends State<ManageCategoriesPage> {
  Dio get _dio => ApiClient.instance.dio;

  final _nameCtrl = TextEditingController();

  bool _loading = true;
  bool _busy = false;
  String? _error;

  List<_ApiCategory> _cats = [];

  static const Duration _kTimeout = Duration(seconds: 15);

  @override
  void initState() {
    super.initState();
    _fetchCats();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _snack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void _log(String text) {
    // ignore: avoid_print
    print(text);
  }

  String _dioErrorToText(DioException e) {
    final code = e.response?.statusCode;
    final type = e.type;
    final msg = e.message ?? '';
    final data = e.response?.data;
    return 'type=$type code=$code msg=$msg data=$data';
  }

  Options _optJson() => Options(
        headers: const {'Accept': 'application/json'},
        followRedirects: false,
        validateStatus: (s) => s != null && s < 600,
      );

  Future<Response<T>> _req<T>(Future<Response<T>> Function() fn) async {
    try {
      return await fn().timeout(_kTimeout);
    } on TimeoutException {
      throw Exception(
          'Request timeout (${_kTimeout.inSeconds}s). Cek server/API.');
    }
  }

  // =========================
  // FETCH LIST
  // =========================
  Future<void> _fetchCats() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      _log('🧾 [Category] GET /cat');
      final res = await _req(() => _dio.get('/cat', options: _optJson()));
      _log('🧾 [Category] RESPONSE ${res.statusCode} => ${res.data}');

      final data = res.data;

      List<_ApiCategory> parsed = [];

      if (data is Map && data['data'] is List) {
        final list = List.from(data['data'] as List);
        parsed = list
            .whereType<Map>()
            .map((e) => _ApiCategory.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } else if (data is List) {
        parsed = data
            .whereType<Map>()
            .map((e) => _ApiCategory.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } else {
        throw Exception('Format response /cat tidak sesuai');
      }

      if (!mounted) return;
      setState(() {
        _cats = parsed;
        _loading = false;
      });
    } on DioException catch (e) {
      _log('❌ [Category] GET ERROR => ${_dioErrorToText(e)}');
      if (!mounted) return;

      if (e.response?.statusCode == 401) {
        Navigator.pushNamedAndRemoveUntil(context, Routes.login, (r) => false);
        return;
      }

      setState(() {
        _loading = false;
        _error = (e.response?.data is Map)
            ? ((e.response?.data['message'] ?? 'Gagal memuat kategori')
                .toString())
            : 'Gagal memuat kategori';
      });
    } catch (e) {
      _log('❌ [Category] GET ERROR => $e');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  // =========================
  // ADD
  // =========================
  Future<void> _addCategory() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      _snack('Nama kategori wajib diisi.');
      return;
    }
    if (_busy) return;

    setState(() => _busy = true);

    try {
      _log('🧾 [Category] POST /categories => name=$name');

      final res = await _req(() => _dio.post(
            '/categories',
            data: {'name': name},
            options: _optJson(),
          ));

      _log('🧾 [Category] RESPONSE ${res.statusCode} => ${res.data}');

      if (res.statusCode == 201 || res.statusCode == 200) {
        if (!mounted) return;
        _snack('Kategori berhasil ditambahkan ✅');
        _nameCtrl.clear();
        await _fetchCats();
        return;
      }

      throw Exception(
          'Gagal menambah kategori (${res.statusCode}): ${res.data}');
    } on DioException catch (e) {
      _log('❌ [Category] POST ERROR => ${_dioErrorToText(e)}');
      if (!mounted) return;

      if (e.response?.statusCode == 401) {
        Navigator.pushNamedAndRemoveUntil(context, Routes.login, (r) => false);
        return;
      }

      final msg = (e.response?.data is Map)
          ? ((e.response?.data['message'] ?? 'Gagal menambah kategori')
              .toString())
          : 'Gagal menambah kategori';
      _snack(msg);
    } catch (e) {
      _log('❌ [Category] POST ERROR => $e');
      if (!mounted) return;
      _snack(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // =========================
  // EDIT (FIXED: controller hidup di dialog)
  // =========================
  Future<void> _editCategory(_ApiCategory cat) async {
    if (_busy) return;

    final newName = await showDialog<String>(
      context: context,
      builder: (_) => _EditCategoryDialog(initialName: cat.name),
    );

    if (newName == null) return;

    final trimmed = newName.trim();
    if (trimmed.isEmpty) {
      _snack('Nama kategori tidak boleh kosong.');
      return;
    }

    setState(() => _busy = true);

    try {
      _log('🧾 [Category] PATCH /categories/${cat.id} => name=$trimmed');

      final res = await _req(() => _dio.patch(
            '/categories/${cat.id}',
            data: {'name': trimmed},
            options: _optJson(),
          ));

      _log('🧾 [Category] RESPONSE ${res.statusCode} => ${res.data}');

      if (res.statusCode == 200) {
        if (!mounted) return;
        _snack('Kategori berhasil diupdate ✅');
        await _fetchCats();
        return;
      }

      throw Exception('Gagal update (${res.statusCode}): ${res.data}');
    } on DioException catch (e) {
      _log('❌ [Category] PATCH ERROR => ${_dioErrorToText(e)}');
      if (!mounted) return;

      if (e.response?.statusCode == 401) {
        Navigator.pushNamedAndRemoveUntil(context, Routes.login, (r) => false);
        return;
      }

      final msg = (e.response?.data is Map)
          ? ((e.response?.data['message'] ?? 'Gagal update kategori')
              .toString())
          : 'Gagal update kategori';
      _snack(msg);
    } catch (e) {
      _log('❌ [Category] PATCH ERROR => $e');
      if (!mounted) return;
      _snack(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // =========================
  // DELETE
  // =========================
  Future<void> _deleteCategory(_ApiCategory cat) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Hapus Kategori'),
        content: Text('Yakin hapus kategori "${cat.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (ok != true) return;
    if (_busy) return;

    setState(() => _busy = true);

    try {
      _log('🧾 [Category] DELETE /categories/${cat.id}');

      final res = await _req(() => _dio.delete(
            '/categories/${cat.id}',
            options: _optJson(),
          ));

      _log('🧾 [Category] RESPONSE ${res.statusCode} => ${res.data}');

      if (res.statusCode == 200) {
        if (!mounted) return;
        _snack('Kategori dihapus ✅');
        setState(() => _cats.removeWhere((x) => x.id == cat.id));
        return;
      }

      throw Exception('Gagal hapus (${res.statusCode}): ${res.data}');
    } on DioException catch (e) {
      _log('❌ [Category] DELETE ERROR => ${_dioErrorToText(e)}');
      if (!mounted) return;

      if (e.response?.statusCode == 401) {
        Navigator.pushNamedAndRemoveUntil(context, Routes.login, (r) => false);
        return;
      }

      final msg = (e.response?.data is Map)
          ? ((e.response?.data['message'] ?? 'Gagal menghapus kategori')
              .toString())
          : 'Gagal menghapus kategori';
      _snack(msg);
    } catch (e) {
      _log('❌ [Category] DELETE ERROR => $e');
      if (!mounted) return;
      _snack(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(title: const Text('Jago Masak')),
          drawer: const AdminDrawer(),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Kelola Kategori',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _nameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Nama Kategori',
                            hintText: 'Contoh: Makanan Berat',
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _busy ? null : _addCategory,
                          child: const Text('Tambah Kategori'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _loading
                      ? const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : (_error != null)
                          ? ListView(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.red.withOpacity(0.25),
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
                                        onPressed: _fetchCats,
                                        child: const Text('Coba lagi'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : (_cats.isEmpty)
                              ? ListView(
                                  children: const [
                                    SizedBox(height: 80),
                                    Center(child: Text('Belum ada kategori.')),
                                  ],
                                )
                              : RefreshIndicator(
                                  onRefresh: _fetchCats,
                                  child: ListView.separated(
                                    itemCount: _cats.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 8),
                                    itemBuilder: (_, i) {
                                      final c = _cats[i];
                                      return Card(
                                        child: ListTile(
                                          leading: const Icon(
                                              Icons.category_outlined),
                                          title: Text(
                                            c.name,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w800),
                                          ),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                tooltip: 'Edit',
                                                icon: const Icon(
                                                    Icons.edit_outlined),
                                                onPressed: _busy
                                                    ? null
                                                    : () => _editCategory(c),
                                              ),
                                              IconButton(
                                                tooltip: 'Hapus',
                                                icon: const Icon(
                                                  Icons.delete_outline,
                                                  color: Colors.red,
                                                ),
                                                onPressed: _busy
                                                    ? null
                                                    : () => _deleteCategory(c),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                ),
              ],
            ),
          ),
        ),
        if (_busy)
          Positioned.fill(
            child: AbsorbPointer(
              absorbing: true,
              child: Container(
                color: Colors.black.withOpacity(0.18),
                alignment: Alignment.center,
                child: const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text('Memproses...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _EditCategoryDialog extends StatefulWidget {
  final String initialName;
  const _EditCategoryDialog({required this.initialName});

  @override
  State<_EditCategoryDialog> createState() => _EditCategoryDialogState();
}

class _EditCategoryDialogState extends State<_EditCategoryDialog> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Kategori'),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        decoration: const InputDecoration(hintText: 'Nama kategori'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _ctrl.text),
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}

class _ApiCategory {
  final int id;
  final String name;

  _ApiCategory({required this.id, required this.name});

  factory _ApiCategory.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    int id = rawId is int ? rawId : int.tryParse('$rawId') ?? 0;

    return _ApiCategory(
      id: id,
      name: (json['name'] ?? '').toString(),
    );
  }
}
