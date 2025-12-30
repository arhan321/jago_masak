import 'package:flutter/material.dart';
import '../../../core/mock_db.dart';

class UserHistoryPage extends StatefulWidget {
  const UserHistoryPage({super.key});

  @override
  State<UserHistoryPage> createState() => _UserHistoryPageState();
}

class _UserHistoryPageState extends State<UserHistoryPage> {
  final db = MockDb.instance;

  @override
  Widget build(BuildContext context) {
    final items = db.historyRecipes;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Riwayat'),
          leading: const SizedBox(),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: items.isEmpty
              ? const Center(child: Text('Belum ada riwayat.'))
              : ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final r = items[i];
                    final fav = db.isFavorite(r.id);
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
                          icon: Icon(
                              fav ? Icons.favorite : Icons.favorite_border,
                              color: fav ? Colors.red : Colors.black54),
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
