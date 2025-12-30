import '../models/recipe.dart';
import '../models/feedback_message.dart';
import '../models/app_user.dart';

class MockDb {
  MockDb._();
  static final instance = MockDb._();

  int _recipeId = 5;

  // Dashboard numbers (dummy)
  int get totalUsers => 98;
  int get totalRecipes => 40;
  int get totalFeedback => 12;
  int get totalRecommendations => 10;

  // Recipes
  final List<Recipe> recipes = [
    // Recipe(
    //   id: 1,
    //   title: 'Ayam Goreng Kuning',
    //   category: 'Ayam',
    //   createdAt: DateTime(2025, 12, 8),
    //   imageUrl:
    //       'https://images.unsplash.com/photo-1604908177522-4291233fe63c?q=80&w=1200&auto=format&fit=crop',
    //   description: _demoLongRecipe,
    // ),
    // Recipe(
    //   id: 2,
    //   title: 'Semur Daging Sapi',
    //   category: 'Sapi',
    //   createdAt: DateTime(2025, 12, 8),
    //   imageUrl:
    //       'https://images.unsplash.com/photo-1604908177522-4291233fe63c?q=80&w=1200&auto=format&fit=crop',
    //   description: _demoLongRecipe,
    // ),
    Recipe(
      id: 3,
      title: 'Ikan Bakar Bumbu Kecap',
      category: 'Ikan',
      createdAt: DateTime(2025, 12, 8),
      imageUrl:
          'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?q=80&w=1200&auto=format&fit=crop',
      description: _demoLongRecipe,
    ),
    Recipe(
      id: 4,
      title: 'Tumis Kangkung Belacan',
      category: 'Sayur',
      createdAt: DateTime(2025, 12, 8),
      imageUrl:
          'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?q=80&w=1200&auto=format&fit=crop',
      description: _demoLongRecipe,
    ),
  ];

  Recipe addRecipe({
    required String title,
    required String category,
    required String description,
  }) {
    _recipeId += 1;
    final r = Recipe(
      id: _recipeId,
      title: title,
      category: category,
      createdAt: DateTime.now(),
      imageUrl:
          'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?q=80&w=1200&auto=format&fit=crop',
      description: description,
    );
    recipes.insert(0, r);
    return r;
  }

  void updateRecipe(Recipe updated) {
    final idx = recipes.indexWhere((e) => e.id == updated.id);
    if (idx >= 0) recipes[idx] = updated;
  }

  void deleteRecipe(int id) {
    recipes.removeWhere((e) => e.id == id);

    // optional: bersihin juga favorit/riwayat supaya tidak ada id "nyangkut"
    favoriteRecipeIds.remove(id);
    historyRecipeIds.removeWhere((x) => x == id);
  }

  // Feedback inbox
  final List<FeedbackMessage> feedback = [
    FeedbackMessage(
      name: 'Ria Wijaya',
      dateText: '10 Des 2025',
      message:
          'Resep ayam betutu enak, tapi bumbu kurang pedas sedikit. Mohon diperhatikan.',
    ),
    FeedbackMessage(
      name: 'Ria Wijaya',
      dateText: '10 Des 2025',
      message:
          'Resepnya mantap, cuma langkah-langkahnya bisa dibuat lebih jelas.',
    ),
    FeedbackMessage(
      name: 'Ria Wijaya',
      dateText: '10 Des 2025',
      message:
          'Mungkin bisa tambah fitur favorit dan pencarian bahan ya admin 🙂',
    ),
  ];

  // Users
  final List<AppUser> users = [
    AppUser(
      name: 'Sarminah',
      email: 'sar@gmail.com',
      phone: '0812345',
      createdAtText: 'Minggu, 10/10/2025\n13:29',
    ),
    AppUser(
      name: 'Hanimmras',
      email: 'han@gmail.com',
      phone: '0812345',
      createdAtText: 'Minggu, 10/10/2025\n13:29',
    ),
  ];

  // =========================
  // ✅ USER FAVORITE & HISTORY
  // =========================
  final Set<int> favoriteRecipeIds = {};
  final List<int> historyRecipeIds = [];

  bool isFavorite(int recipeId) => favoriteRecipeIds.contains(recipeId);

  void toggleFavorite(int recipeId) {
    if (favoriteRecipeIds.contains(recipeId)) {
      favoriteRecipeIds.remove(recipeId);
    } else {
      favoriteRecipeIds.add(recipeId);
    }
  }

  void addToHistory(int recipeId) {
    historyRecipeIds.remove(recipeId);
    historyRecipeIds.insert(0, recipeId);
  }

  List<Recipe> get favoriteRecipes =>
      recipes.where((r) => favoriteRecipeIds.contains(r.id)).toList();

  List<Recipe> get historyRecipes {
    final map = {for (final r in recipes) r.id: r};
    return historyRecipeIds.map((id) => map[id]).whereType<Recipe>().toList();
  }
}

const _demoLongRecipe = '''
Bahan-bahan (4 porsi):
- 500 gr dada ayam (potong sedang)
- 3 sdm kecap manis
- 2 lembar daun salam
- 2 batang serai (memarkan)
- 3 butir kemiri
- 2 sdm minyak goreng
- 600 ml air

Bumbu halus:
- 6 siung bawang merah
- 3 siung bawang putih
- 3 buah cabai merah
- 1 sdt ketumbar bubuk
- Garam secukupnya

Langkah-langkah:
1. Panaskan minyak, tumis bumbu halus hingga harum.
2. Masukkan daun salam, serai, dan kemiri, aduk rata.
3. Tambahkan ayam, aduk hingga berubah warna.
4. Tuang air, masak hingga ayam empuk.
5. Tambahkan kecap manis, aduk rata.
6. Koreksi rasa, angkat, dan sajikan hangat.
''';
