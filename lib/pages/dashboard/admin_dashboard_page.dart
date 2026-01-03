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

  int? _totalResep;
  bool _loadingTotalResep = true;

  int? _totalSaran;
  bool _loadingTotalSaran = true;

  Dio get _dio => ApiClient.instance.dio;

  @override
  void initState() {
    super.initState();
    _fetchMe();
    _fetchTotalPengguna();
    _fetchTotalResep();
    _fetchTotalSaran(); // ✅ baru
  }

  Future<void> _fetchMe() async {
    setState(() => _loadingMe = true);

    try {
      final res = await _dio.get('/me');

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
        Navigator.pushNamedAndRemoveUntil(context, Routes.login, (r) => false);
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
      final res = await _dio.get('/total_pengguna');

      final data = res.data;
      if (data is Map) {
        final raw =
            data['total_pengguna'] ?? data['totalUsers'] ?? data['total'];

        int? total;
        if (raw is int) total = raw;
        if (raw is String) total = int.tryParse(raw);
        if (raw is num) total = raw.toInt();

        if (!mounted) return;
        setState(() => _totalPengguna = total);
      }

      if (!mounted) return;
      setState(() => _loadingTotalPengguna = false);
    } on DioException catch (e) {
      if (!mounted) return;

      if (e.response?.statusCode == 401) {
        Navigator.pushNamedAndRemoveUntil(context, Routes.login, (r) => false);
        return;
      }

      setState(() => _loadingTotalPengguna = false);
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingTotalPengguna = false);
    }
  }

  /// Total Resep:
  /// 1) GET /total_resep (kalau ada)
  /// 2) fallback ambil paginate /admin/recipes dan baca total
  Future<void> _fetchTotalResep() async {
    if (!mounted) return;
    setState(() => _loadingTotalResep = true);

    try {
      final res = await _dio.get('/total_resep');

      final data = res.data;
      if (data is Map) {
        final raw =
            data['total_resep'] ?? data['totalRecipes'] ?? data['total'];

        int? total;
        if (raw is int) total = raw;
        if (raw is String) total = int.tryParse(raw);
        if (raw is num) total = raw.toInt();

        if (!mounted) return;
        setState(() => _totalResep = total);
      }

      if (!mounted) return;
      setState(() => _loadingTotalResep = false);
      return;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, Routes.login, (r) => false);
        return;
      }

      // kalau bukan 404, stop aja
      if (!mounted) return;
      if (e.response?.statusCode != 404) {
        setState(() => _loadingTotalResep = false);
        return;
      }
    } catch (_) {
      // ignore, lanjut fallback
    }

    // fallback: /admin/recipes => { total: ... }
    try {
      final res = await _dio.get(
        '/admin/recipes',
        queryParameters: const {'page': 1, 'per_page': 1},
      );

      final data = res.data;
      if (data is Map) {
        final rawTotal = data['total'] ??
            (data['meta'] is Map ? (data['meta']['total']) : null);

        int? total;
        if (rawTotal is int) total = rawTotal;
        if (rawTotal is String) total = int.tryParse(rawTotal);
        if (rawTotal is num) total = rawTotal.toInt();

        if (!mounted) return;
        setState(() => _totalResep = total);
      }

      if (!mounted) return;
      setState(() => _loadingTotalResep = false);
    } on DioException catch (e) {
      if (!mounted) return;

      if (e.response?.statusCode == 401) {
        Navigator.pushNamedAndRemoveUntil(context, Routes.login, (r) => false);
        return;
      }

      setState(() => _loadingTotalResep = false);
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingTotalResep = false);
    }
  }

  /// ✅ Total Saran (Masukan Pengguna)
  /// 1) GET /total_saran -> { total_saran: 12 }
  /// 2) fallback GET /sarans -> { success, data:[...] } => data.length
  Future<void> _fetchTotalSaran() async {
    if (!mounted) return;
    setState(() => _loadingTotalSaran = true);

    // 1) coba endpoint count dulu
    try {
      final res = await _dio.get('/total_saran');
      final data = res.data;

      if (data is Map) {
        final raw = data['total_saran'] ?? data['total'] ?? data['count'];

        int? total;
        if (raw is int) total = raw;
        if (raw is String) total = int.tryParse(raw);
        if (raw is num) total = raw.toInt();

        if (!mounted) return;
        setState(() => _totalSaran = total);
      }

      if (!mounted) return;
      setState(() => _loadingTotalSaran = false);
      return;
    } on DioException catch (e) {
      if (!mounted) return;

      if (e.response?.statusCode == 401) {
        Navigator.pushNamedAndRemoveUntil(context, Routes.login, (r) => false);
        return;
      }

      // kalau bukan 404, stop saja
      if (e.response?.statusCode != 404) {
        setState(() => _loadingTotalSaran = false);
        return;
      }
      // kalau 404 -> fallback ke /sarans
    } catch (_) {
      // ignore, fallback
    }

    // 2) fallback: /sarans
    try {
      final res = await _dio.get('/sarans');
      final data = res.data;

      // bentuk dari controller kamu:
      // { success: true, message: "...", data: [ ... ] }
      if (data is Map && data['data'] is List) {
        final list = List.from(data['data'] as List);
        if (!mounted) return;
        setState(() => _totalSaran = list.length);
      } else if (data is List) {
        if (!mounted) return;
        setState(() => _totalSaran = data.length);
      }

      if (!mounted) return;
      setState(() => _loadingTotalSaran = false);
    } on DioException catch (e) {
      if (!mounted) return;

      if (e.response?.statusCode == 401) {
        Navigator.pushNamedAndRemoveUntil(context, Routes.login, (r) => false);
        return;
      }

      setState(() => _loadingTotalSaran = false);
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingTotalSaran = false);
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

    final totalResepText = _loadingTotalResep
        ? '...'
        : (_totalResep?.toString() ?? '${db.totalRecipes}');

    final totalSaranText = _loadingTotalSaran
        ? '...'
        : (_totalSaran?.toString() ?? '${db.totalFeedback}');

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
                childAspectRatio: ratio,
                children: [
                  DashboardCard(
                    icon: Icons.people_alt_outlined,
                    title: 'Total Pengguna',
                    value: totalPenggunaText,
                  ),
                  DashboardCard(
                    icon: Icons.menu_book_outlined,
                    title: 'Total Resep',
                    value: totalResepText,
                  ),
                  DashboardCard(
                    icon: Icons.chat_bubble_outline,
                    title: 'Total\nMasukan\nPengguna',
                    value: totalSaranText, // ✅ sekarang dari API
                  ),
                  DashboardCard(
                    icon: Icons.star_outline,
                    title: 'Rekomendasi\nResep',
                    value:
                        '${db.totalRecommendations}', // nanti bisa nyusul API
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
