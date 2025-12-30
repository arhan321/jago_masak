import 'package:flutter/material.dart';
import '../../../models/recipe.dart';
import '../../../core/mock_db.dart';

class UserRecipeDetailPage extends StatefulWidget {
  final Recipe recipe;
  const UserRecipeDetailPage({super.key, required this.recipe});

  @override
  State<UserRecipeDetailPage> createState() => _UserRecipeDetailPageState();
}

class _UserRecipeDetailPageState extends State<UserRecipeDetailPage> {
  final db = MockDb.instance;

  @override
  Widget build(BuildContext context) {
    final isFav = db.isFavorite(widget.recipe.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Resep'),
        actions: [
          IconButton(
            tooltip: 'Favorit',
            onPressed: () {
              db.toggleFavorite(widget.recipe.id);

              // biar icon langsung berubah
              setState(() {});

              // snack rapih (tidak numpuk)
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    db.isFavorite(widget.recipe.id)
                        ? 'Ditambahkan ke favorit'
                        : 'Dihapus dari favorit',
                  ),
                ),
              );
            },
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? Colors.red : Colors.white,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                widget.recipe.imageUrl,
                fit: BoxFit.cover,

                // ✅ biar web tidak muncul [object ProgressEvent]
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: Colors.black12,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  );
                },

                // ✅ kalau URL error / 404
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.black12,
                  alignment: Alignment.center,
                  child: const Icon(Icons.broken_image, size: 44),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.recipe.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.category_outlined, size: 18),
              const SizedBox(width: 6),
              Text(
                widget.recipe.category,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Deskripsi Resep',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black12),
            ),
            child: Text(
              widget.recipe.description,
              style: const TextStyle(height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}
