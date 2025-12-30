import 'package:flutter/material.dart';
import '../../../core/mock_db.dart';

class UserFavoritePage extends StatefulWidget {
  const UserFavoritePage({super.key});

  @override
  State<UserFavoritePage> createState() => _UserFavoritePageState();
}

class _UserFavoritePageState extends State<UserFavoritePage> {
  final db = MockDb.instance;

  @override
  Widget build(BuildContext context) {
    final items = db.favoriteRecipes;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Favorit'),
          leading: const SizedBox(), // biar mirip prototype (tanpa back)
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: items.isEmpty
              ? const Center(child: Text('Belum ada favorit.'))
              : ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final r = items[i];
                    return Card(
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(r.imageUrl,
                              width: 56, height: 56, fit: BoxFit.cover),
                        ),
                        title: Text(r.title,
                            style:
                                const TextStyle(fontWeight: FontWeight.w800)),
                        trailing: IconButton(
                          icon: const Icon(Icons.favorite, color: Colors.red),
                          onPressed: () {
                            db.toggleFavorite(r.id);
                            setState(() {});
                          },
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
