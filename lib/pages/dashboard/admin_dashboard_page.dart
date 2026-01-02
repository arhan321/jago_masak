import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../core/routes.dart';
import '../../core/mock_db.dart';
import '../../core/network/api_client.dart';
import '../../widgets/dashboard_card.dart';
import '../../widgets/admin_drawer.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final db = MockDb.instance;

  String _adminName = '';
  bool _loadingMe = true;

  int? _totalPengguna;
  bool _loadingTotalPengguna = true;

  @override
  void initState() {
    super.initState();
    _fetchMe();
    _fetchTotalPengguna();
  }

  Future<void> _fetchMe() async {
    setState(() => _loadingMe = true);

    try {
      final dio = ApiClient.instance.dio;
      final res = await dio.get('/me');

      final data = res.data;
      if (data is Map) {
        final name = (data['name'] ?? '').toString();
        if (!mounted) return;
        setState(() => _adminName = name);
      }

      if (!mounted) return;
      setState(() => _loadingMe = false);
    } on DioException catch (e) {
      if (!mounted) return;

      if (e.response?.statusCode == 401) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.login,
          (route) => false,
        );
        return;
      }

      setState(() => _loadingMe = false);
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingMe = false);
    }
  }

  Future<void> _fetchTotalPengguna() async {
    if (!mounted) return;
    setState(() => _loadingTotalPengguna = true);

    try {
      final dio = ApiClient.instance.dio;
      final res = await dio.get('/total_pengguna');

      final data = res.data;
      if (data is Map) {
        final raw = data['total_pengguna'];

        int? total;
        if (raw is int) total = raw;
        if (raw is String) total = int.tryParse(raw);
        if (raw is num) total = raw.toInt();

        if (!mounted) return;
        setState(() => _totalPengguna = total);
      }

      if (!mounted) return;
      setState(() => _loadingTotalPengguna = false);
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingTotalPengguna = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleText = _loadingMe
        ? 'Selamat Datang di\nHalaman Admin!'
        : (_adminName.isNotEmpty
            ? 'Selamat Datang, $_adminName!\nHalaman Admin!'
            : 'Selamat Datang di\nHalaman Admin!');

    final totalPenggunaText = _loadingTotalPengguna
        ? '...'
        : (_totalPengguna?.toString() ?? '${db.totalUsers}');

    // ✅ kunci fix overflow: bikin item grid lebih tinggi di layar kecil
    final w = MediaQuery.of(context).size.width;
    final ratio = w < 380 ? 0.82 : 0.92;

    return Scaffold(
      appBar: AppBar(title: const Text('Jago Masak')),
      drawer: const AdminDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titleText,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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
                childAspectRatio: ratio, // ✅ FIX OVERFLOW
                children: [
                  DashboardCard(
                    icon: Icons.people_alt_outlined,
                    title: 'Total Pengguna',
                    value: totalPenggunaText,
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
