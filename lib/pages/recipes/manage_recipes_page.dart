import 'package:flutter/material.dart';
import '../../core/mock_db.dart';
import '../../widgets/admin_drawer.dart';
import '../../core/app_theme.dart';
import '../../models/recipe.dart';
import 'add_edit_recipe_page.dart';

class ManageRecipesPage extends StatefulWidget {
  const ManageRecipesPage({super.key});

  @override
  State<ManageRecipesPage> createState() => _ManageRecipesPageState();
}

class _ManageRecipesPageState extends State<ManageRecipesPage> {
  final db = MockDb.instance;
  final _searchCtrl = TextEditingController();
  final ScrollController _hCtrl = ScrollController(); // ✅
  String query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
    _hCtrl.dispose(); // ✅
  }

  @override
  Widget build(BuildContext context) {
    final filtered = db.recipes.where((r) {
      if (query.isEmpty) return true;
      final q = query.toLowerCase();
      return r.title.toLowerCase().contains(q) ||
          r.category.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Jago Masak')),
      drawer: const AdminDrawer(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.navy,
        onPressed: () async {
          final created = await Navigator.push<Recipe?>(
            context,
            MaterialPageRoute(
                builder: (_) => const AddEditRecipePage(mode: FormMode.add)),
          );
          if (created != null) {
            setState(() {});
            _snack(context, 'Resep berhasil ditambahkan!');
          }
        },
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
              onChanged: (v) => setState(() => query = v.trim()),
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
                    child: Scrollbar(
                      controller: _hCtrl,
                      thumbVisibility: true, // ✅ biar keliatan terus (web enak)
                      trackVisibility: true, // ✅ ada track
                      scrollbarOrientation: ScrollbarOrientation.bottom,
                      child: SingleChildScrollView(
                        controller: _hCtrl,
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          // ✅ kasih minWidth besar biar pasti butuh geser
                          constraints: const BoxConstraints(minWidth: 900),
                          child: DataTable(
                            headingRowHeight: 48,
                            dataRowHeight: 56,
                            columnSpacing: 28,
                            horizontalMargin: 16,
                            dividerThickness: 0.8,
                            headingRowColor: MaterialStatePropertyAll(
                              AppTheme.navy.withOpacity(0.92),
                            ),
                            headingTextStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                            columns: const [
                              DataColumn(
                                  label:
                                      SizedBox(width: 50, child: Text('No'))),
                              DataColumn(
                                  label: SizedBox(
                                      width: 260, child: Text('Nama Resep'))),
                              DataColumn(
                                  label: SizedBox(
                                      width: 160, child: Text('Kategori'))),
                              DataColumn(
                                  label: SizedBox(
                                      width: 180,
                                      child: Text('Terakhir dibuat'))),
                              DataColumn(
                                  label: SizedBox(
                                      width: 120, child: Text('Aksi'))),
                            ],
                            rows: List.generate(filtered.length, (i) {
                              final r = filtered[i];
                              return DataRow(
                                cells: [
                                  DataCell(SizedBox(
                                      width: 50, child: Text('${i + 1}.'))),
                                  DataCell(
                                    SizedBox(
                                      width: 260,
                                      child: InkWell(
                                        onTap: () async {
                                          final updated =
                                              await Navigator.push<Recipe?>(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => AddEditRecipePage(
                                                mode: FormMode.edit,
                                                recipe: r,
                                              ),
                                            ),
                                          );
                                          if (updated != null) {
                                            setState(() {});
                                            _snack(context,
                                                'Deskripsi resep berhasil diperbarui!');
                                          }
                                        },
                                        child: Text(
                                          r.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: AppTheme.navy,
                                            decoration:
                                                TextDecoration.underline,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(SizedBox(
                                      width: 160, child: Text(r.category))),
                                  DataCell(SizedBox(
                                      width: 180,
                                      child: Text(_formatDate(r.createdAt)))),
                                  DataCell(
                                    SizedBox(
                                      width: 120,
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: IconButton(
                                          tooltip: 'Hapus',
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () =>
                                              _confirmDelete(context, r),
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Recipe r) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Resep'),
        content: Text('Yakin mau hapus "${r.title}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (ok == true) {
      setState(() => db.deleteRecipe(r.id));
      if (context.mounted) _snack(context, 'Resep dihapus.');
    }
  }

  String _formatDate(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(dt.day)}/${two(dt.month)}/${dt.year}';
  }

  void _snack(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}
