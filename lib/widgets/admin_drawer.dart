import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../core/app_theme.dart';
import '../core/routes.dart';
import '../core/network/api_client.dart';
import '../core/storage/token_storage.dart';

class AdminDrawer extends StatefulWidget {
  const AdminDrawer({super.key});

  @override
  State<AdminDrawer> createState() => _AdminDrawerState();
}

class _AdminDrawerState extends State<AdminDrawer> {
  String _adminName = 'Admin';
  bool _loadingMe = true;

  @override
  void initState() {
    super.initState();
    _fetchMe();
  }

  Future<void> _fetchMe() async {
    setState(() => _loadingMe = true);

    try {
      final dio = ApiClient.instance.dio;
      final res = await dio.get('/me'); // baseUrl sudah .../api
      final data = res.data;

      if (!mounted) return;

      if (data is Map) {
        final name = (data['name'] ?? '').toString().trim();
        setState(() {
          _adminName = name.isNotEmpty ? name : 'Admin';
          _loadingMe = false;
        });
      } else {
        setState(() {
          _adminName = 'Admin';
          _loadingMe = false;
        });
      }
    } on DioException catch (e) {
      if (!mounted) return;

      // kalau token invalid / expired
      if (e.response?.statusCode == 401) {
        await TokenStorage.instance.clearToken();
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.login,
          (route) => false,
        );
        return;
      }

      setState(() {
        _adminName = 'Admin';
        _loadingMe = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _adminName = 'Admin';
        _loadingMe = false;
      });
    }
  }

  Future<void> _logout(BuildContext context) async {
    final dio = ApiClient.instance.dio;

    // tutup drawer dulu biar UX enak
    Navigator.pop(context);

    try {
      await dio.post('/logout'); // baseUrl sudah .../api
    } on DioException {
      // kalau error, tetap lanjut clear token
    } catch (_) {
      // ignore
    } finally {
      await TokenStorage.instance.clearToken();
    }

    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      Routes.login,
      (route) => false,
    );
  }

  void _go(BuildContext context, String routeName) {
    Navigator.pop(context); // tutup drawer
    Navigator.pushNamed(context, routeName);
  }

  @override
  Widget build(BuildContext context) {
    final nameText = _loadingMe ? 'Memuat...' : _adminName;

    return Drawer(
      child: Container(
        color: const Color(0xFF3B74C7), // biru sidebar (biar mirip screenshot)
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 14),
              const CircleAvatar(
                radius: 34,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: AppTheme.navy),
              ),
              const SizedBox(height: 10),

              // ✅ sekarang dinamis dari /me
              Text(
                nameText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 14),
              Divider(color: Colors.white.withOpacity(0.25), height: 1),

              // ===== MENU =====
              _item(
                icon: Icons.home_outlined,
                text: 'Dashboard',
                onTap: () => _go(context, Routes.dashboard),
              ),
              _item(
                icon: Icons.add_box_outlined,
                text: 'Tambah resep baru',
                onTap: () => _go(context, Routes.tambahResep),
              ),
              _item(
                icon: Icons.restaurant_menu_outlined,
                text: 'Kelola resep',
                onTap: () => _go(context, Routes.kelolaResep),
              ),
              _item(
                icon: Icons.mail_outline,
                text: 'Masukan pengguna',
                onTap: () => _go(context, Routes.masukanPengguna),
              ),
              _item(
                icon: Icons.people_alt_outlined,
                text: 'Kelola pengguna',
                onTap: () => _go(context, Routes.kelolaPengguna),
              ),
              _item(
                icon: Icons.lock_outline,
                text: 'Kelola akun admin',
                onTap: () => _go(context, Routes.kelolaAkunAdmin),
              ),
              _item(
                icon: Icons.notifications_none,
                text: 'Kelola notifikasi',
                onTap: () => _go(context, Routes.kelolaNotifikasi),
              ),

              const Spacer(),
              Divider(color: Colors.white.withOpacity(0.25), height: 1),

              // ===== LOGOUT =====
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onTap: () => _logout(context),
              ),

              const SizedBox(height: 10),
              const Text(
                'Jago Masak',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _item({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: onTap,
    );
  }
}
