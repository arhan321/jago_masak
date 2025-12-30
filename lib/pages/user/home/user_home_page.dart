import 'package:flutter/material.dart';
import '../../../core/mock_db.dart';
import '../../../core/routes.dart';
import '../../../core/app_theme.dart';
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

  @override
  Widget build(BuildContext context) {
    // ambil data, tapi skip yang sudah error
    final recipes = db.recipes
        .where((r) => !_hiddenRecipeIds.contains(r.id))
        .take(6)
        .toList();

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
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              const Text(
                'Halo, Sarminah',
                style: TextStyle(fontWeight: FontWeight.w800),
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
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
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
              GridView.builder(
                itemCount: recipes.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UserRecipeDetailPage(recipe: r),
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

                              // ✅ loading aman
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Container(
                                  color: Colors.black12,
                                  alignment: Alignment.center,
                                  child: const CircularProgressIndicator(
                                      strokeWidth: 2),
                                );
                              },

                              // ✅ kalau error -> langsung hide card ini
                              errorBuilder: (_, __, ___) {
                                // schedule setState biar aman (tidak setState saat build)
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  if (mounted &&
                                      !_hiddenRecipeIds.contains(r.id)) {
                                    setState(() => _hiddenRecipeIds.add(r.id));
                                  }
                                });

                                // sementara return kosong
                                return const SizedBox.shrink();
                              },
                            ),
                          ),

                          // tombol favorite (tidak ikut buka detail)
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
                                  fav ? Icons.favorite : Icons.favorite_border,
                                  color: fav ? Colors.red : Colors.black54,
                                  size: 22,
                                ),
                              ),
                            ),
                          ),

                          // judul
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
    );
  }
}
