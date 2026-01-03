import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';

import '../../core/routes.dart';
import '../../core/network/api_client.dart';
import '../../features/recipes/recipe_api.dart';
import '../../models/recipe.dart';

enum FormMode { add, edit }

// ===== model category dari backend =====
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

class AddEditRecipePage extends StatefulWidget {
  final FormMode mode;
  final Recipe? recipe;

  const AddEditRecipePage({super.key, required this.mode, this.recipe});

  @override
  State<AddEditRecipePage> createState() => _AddEditRecipePageState();
}

class _AddEditRecipePageState extends State<AddEditRecipePage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _catCtrl; // hanya untuk tampilan (name)
  late final TextEditingController _descCtrl;

  bool _loading = false;

  // ===== category state =====
  bool _loadingCats = true;
  String? _catError;
  List<ApiCategory> _cats = [];
  ApiCategory? _selectedCat; // ini yang dipakai kirim category_id

  // untuk upload gambar
  final _picker = ImagePicker();
  File? _imageFile; // mobile
  Uint8List? _imageBytes; // web
  String? _imageName;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.recipe?.title ?? '');
    _catCtrl = TextEditingController(text: widget.recipe?.category ?? '');
    _descCtrl = TextEditingController(text: widget.recipe?.description ?? '');

    _fetchCategories();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _catCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  // ===== fetch categories dari GET /cat =====
  Future<void> _fetchCategories() async {
    if (!mounted) return;
    setState(() {
      _loadingCats = true;
      _catError = null;
    });

    try {
      final dio = ApiClient.instance.dio;
      final res = await dio.get('/cat'); // baseUrl sudah .../api

      final data = res.data;

      List list;
      if (data is List) {
        list = data;
      } else if (data is Map && data['data'] is List) {
        // kalau backend ternyata paginate/wrap data
        list = List.from(data['data'] as List);
      } else {
        list = [];
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

      // kalau mode edit & kamu punya category name di recipe, coba auto pilih by name
      if (_selectedCat == null &&
          _catCtrl.text.trim().isNotEmpty &&
          cats.isNotEmpty) {
        final match = cats.where(
            (c) => c.name.toLowerCase() == _catCtrl.text.trim().toLowerCase());
        if (match.isNotEmpty) {
          setState(() => _selectedCat = match.first);
        }
      }
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

  // ===== buka picker kategori (UI tetap nyambung) =====
  Future<void> _openCategoryPicker() async {
    if (_loadingCats) return;

    if (_catError != null) {
      // kalau error, kasih opsi retry
      final retry = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Kategori'),
          content: Text(_catError!),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Tutup'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );

      if (retry == true) {
        await _fetchCategories();
      }
      return;
    }

    if (_cats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kategori belum tersedia.')),
      );
      return;
    }

    final chosen = await showModalBottomSheet<ApiCategory>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
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
                    itemCount: _cats.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final c = _cats[i];
                      final selected = _selectedCat?.id == c.id;

                      return ListTile(
                        title: Text(
                          c.name,
                          style: TextStyle(
                            fontWeight:
                                selected ? FontWeight.w800 : FontWeight.w600,
                          ),
                        ),
                        trailing: selected
                            ? const Icon(Icons.check, color: Colors.green)
                            : null,
                        onTap: () => Navigator.pop(context, c),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (chosen == null) return;

    setState(() {
      _selectedCat = chosen;
      _catCtrl.text = chosen.name; // tampil di field
    });
  }

  Future<void> _pickImage() async {
    try {
      final x = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (x == null) return;

      final bytes = await x.readAsBytes();
      final sizeInMb = bytes.length / (1024 * 1024);
      if (sizeInMb > 2) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ukuran gambar maksimal 2MB.')),
        );
        return;
      }

      if (!mounted) return;
      setState(() {
        _imageName = x.name;
        if (kIsWeb) {
          _imageBytes = bytes;
          _imageFile = null;
        } else {
          _imageFile = File(x.path);
          _imageBytes = null;
        }
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image picker tidak tersedia.')),
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // ===== kategori wajib dipilih =====
    if (_selectedCat == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih kategori.')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final title = _nameCtrl.text.trim();
      final description = _descCtrl.text.trim();
      final categoryId = _selectedCat!.id;

      if (widget.mode == FormMode.add) {
        await RecipeApi.instance.createRecipe(
          title: title,
          categoryId: categoryId, // ✅ kirim id
          description: description,
          imageFile: _imageFile,
          imageBytes: _imageBytes,
          imageFileName: _imageName,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resep berhasil ditambahkan.')),
        );
        Navigator.pop(context, true);
      } else {
        final id = widget.recipe?.id;
        if (id == null) throw Exception('ID resep tidak ditemukan.');

        await RecipeApi.instance.updateRecipe(
          id: id,
          title: title,
          categoryId: categoryId, // ✅ kirim id
          description: description,
          imageFile: _imageFile,
          imageBytes: _imageBytes,
          imageFileName: _imageName,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resep berhasil diupdate.')),
        );
        Navigator.pop(context, true);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, Routes.login, (r) => false);
        return;
      }

      final msg = (e.response?.data is Map)
          ? ((e.response?.data['message'] ?? 'Gagal menyimpan resep')
              .toString())
          : 'Gagal menyimpan resep';

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdd = widget.mode == FormMode.add;

    final hasImage = _imageFile != null || _imageBytes != null;
    final imageLabel = hasImage
        ? (_imageName ?? 'Gambar dipilih')
        : 'Format: JPG, PNG, Max: 2MB';

    return Scaffold(
      appBar: AppBar(
        title: Text(isAdd ? 'Tambah Resep Baru' : 'Edit Resep'),
        actions: [
          if (!isAdd)
            IconButton(onPressed: () {}, icon: const Icon(Icons.star_border)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Jago Masak',
                      style: TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  Text(
                    isAdd
                        ? 'Halo, Admin\nYuk tambahin resep baru biar koleksi kita makin banyak!'
                        : 'Halo, Admin\nYuk update deskripsi resep biar makin keren!',
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isAdd ? 'Tambah Resep Baru' : 'Edit Resep',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 12),

                  const Text('Masukkan Nama Resep',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _nameCtrl,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Nama resep wajib diisi'
                        : null,
                    decoration: const InputDecoration(
                      hintText: 'Masukkan nama resep disini',
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ===== KATEGORI dari API =====
                  const Text('Kategori',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _catCtrl,
                    readOnly: true,
                    onTap: _loading ? null : _openCategoryPicker,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Kategori wajib dipilih'
                        : null,
                    decoration: InputDecoration(
                      hintText: _loadingCats
                          ? 'Memuat kategori...'
                          : (_catError != null
                              ? 'Gagal memuat kategori (tap untuk coba lagi)'
                              : 'Pilih kategori'),
                      suffixIcon: _loadingCats
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : const Icon(Icons.keyboard_arrow_down),
                    ),
                  ),
                  const SizedBox(height: 10),

                  const Text('Deskripsi Resep',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _descCtrl,
                    minLines: 6,
                    maxLines: 12,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Deskripsi wajib diisi'
                        : null,
                    decoration: const InputDecoration(
                      hintText: 'Masukkan deskripsi resep disini',
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Upload (tetap gaya kamu)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F3F8),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE3E6EF)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.camera_alt_outlined),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Unggah Gambar',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w800)),
                              const SizedBox(height: 3),
                              Text(
                                imageLabel,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: hasImage
                                      ? Colors.black87
                                      : Colors.black54,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _loading ? null : _pickImage,
                          child: const Text('Unggah'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Simpan'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
