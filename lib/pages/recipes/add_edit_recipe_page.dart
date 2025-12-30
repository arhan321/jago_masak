import 'package:flutter/material.dart';
import '../../core/mock_db.dart';
import '../../models/recipe.dart';

enum FormMode { add, edit }

class AddEditRecipePage extends StatefulWidget {
  final FormMode mode;
  final Recipe? recipe;

  const AddEditRecipePage({super.key, required this.mode, this.recipe});

  @override
  State<AddEditRecipePage> createState() => _AddEditRecipePageState();
}

class _AddEditRecipePageState extends State<AddEditRecipePage> {
  final db = MockDb.instance;
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _catCtrl;
  late final TextEditingController _descCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.recipe?.title ?? '');
    _catCtrl = TextEditingController(text: widget.recipe?.category ?? '');
    _descCtrl = TextEditingController(text: widget.recipe?.description ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _catCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAdd = widget.mode == FormMode.add;

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
                  Text(isAdd ? 'Tambah Resep Baru' : 'Edit Resep',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w900)),
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
                        hintText: 'Masukkan nama resep disini'),
                  ),
                  const SizedBox(height: 10),

                  const Text('Kategori',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _catCtrl,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Kategori wajib diisi'
                        : null,
                    decoration: const InputDecoration(
                        hintText: 'Masukkan kategori resep disini'),
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
                        hintText: 'Masukkan deskripsi resep disini'),
                  ),
                  const SizedBox(height: 12),

                  // Upload placeholder (static)
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
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Unggah Gambar',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w800)),
                              SizedBox(height: 3),
                              Text('Format: JPG, PNG, Max: 2MB',
                                  style: TextStyle(fontSize: 11)),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: null,
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
                          backgroundColor: Colors.green),
                      onPressed: () {
                        if (!_formKey.currentState!.validate()) return;

                        if (isAdd) {
                          final created = db.addRecipe(
                            title: _nameCtrl.text.trim(),
                            category: _catCtrl.text.trim(),
                            description: _descCtrl.text.trim(),
                          );
                          Navigator.pop(context, created);
                        } else {
                          final updated = widget.recipe!.copyWith(
                            title: _nameCtrl.text.trim(),
                            category: _catCtrl.text.trim(),
                            description: _descCtrl.text.trim(),
                          );
                          db.updateRecipe(updated);
                          Navigator.pop(context, updated);
                        }
                      },
                      child: const Text('Simpan'),
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
