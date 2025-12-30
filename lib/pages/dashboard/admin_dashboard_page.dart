import 'package:flutter/material.dart';
import '../../core/mock_db.dart';
import '../../widgets/dashboard_card.dart';
import '../../widgets/admin_drawer.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final db = MockDb.instance;

    return Scaffold(
      appBar: AppBar(title: const Text('Jago Masak')),
      drawer: const AdminDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selamat Datang di\nHalaman Admin!',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            const Text(
              'Dashboard',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  DashboardCard(
                    icon: Icons.people_alt_outlined,
                    title: 'Total Pengguna',
                    value: '${db.totalUsers}',
                  ),
                  DashboardCard(
                    icon: Icons.menu_book_outlined,
                    title: 'Total Resep',
                    value: '${db.totalRecipes}',
                  ),
                  DashboardCard(
                    icon: Icons.chat_bubble_outline,
                    title: 'Total\nMasukan\nPengguna',
                    value: '${db.totalFeedback}',
                  ),
                  DashboardCard(
                    icon: Icons.star_outline,
                    title: 'Rekomendasi\nResep',
                    value: '${db.totalRecommendations}',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
