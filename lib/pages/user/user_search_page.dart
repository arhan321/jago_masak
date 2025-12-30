import 'package:flutter/material.dart';
import '../../../core/mock_db.dart';
import '../../../users/recipe/user_recipe_detail_page.dart';

class UserSearchPage extends StatefulWidget {
  const UserSearchPage({super.key});

  @override
  State<UserSearchPage> createState() => _UserSearchPageState();
}

class _UserSearchPageState extends State<UserSearchPage> {
  final db = MockDb.instance;
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() => _query = _searchCtrl.text.trim());
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List _filtered() {
    final q = _query.toLowerCase();

    // ✅ kalau kosong tampilkan semua
    if (q.isEmpty) return db.recipes;

    // ✅ filter berdasarkan title atau category
    return db.recipes.where((r) {
      final title = r.title.toLowerCase();
      final cat = r.category.toLowerCase();
      return title.contains(q) || cat.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final results = _filtered();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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
            const SizedBox(height: 12),
            Expanded(
              child: results.isEmpty
                  ? const Center(
                      child: Text(
                        'Resep tidak ditemukan.',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    )
                  : ListView.separated(
                      itemCount: results.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final r = results[i];

                        return ListTile(
                          leading: const Icon(Icons.circle, size: 10),
                          title: Text(
                            r.title,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(r.category),
                          onTap: () {
                            db.addToHistory(r.id);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UserRecipeDetailPage(recipe: r),
                              ),
                            );
                          },
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
