import 'package:flutter/material.dart';
import '../core/routes.dart';
import '../core/app_theme.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  void _goToDashboard(BuildContext context) {
    Navigator.pop(context);
    Navigator.pushNamedAndRemoveUntil(
      context,
      Routes.dashboard,
      (route) => false,
    );
  }

  Future<void> _logout(BuildContext context) async {
    // ambil root navigator (context yang aman / masih hidup)
    final rootNav = Navigator.of(context, rootNavigator: true);

    // tutup drawer
    Navigator.pop(context);

    // tampilkan dialog pakai rootNav.context (bukan context drawer)
    final ok = await showDialog<bool>(
      context: rootNav.context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (ok == true) {
      rootNav.pushNamedAndRemoveUntil(
        Routes.login,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF366EBF),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            const CircleAvatar(
              radius: 34,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 42, color: AppTheme.navy),
            ),
            const SizedBox(height: 8),
            const Text(
              'Admin',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            const Divider(color: Colors.white24),

            _DrawerItem(
              icon: Icons.home_outlined,
              label: 'Dashboard',
              onTap: () => _goToDashboard(context),
            ),
            _DrawerItem(
              icon: Icons.add_box_outlined,
              label: 'Tambah resep baru',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, Routes.tambahResep);
              },
            ),
            _DrawerItem(
              icon: Icons.restaurant_menu,
              label: 'Kelola resep',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, Routes.kelolaResep);
              },
            ),
            _DrawerItem(
              icon: Icons.mail_outline,
              label: 'Masukan pengguna',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, Routes.masukanPengguna);
              },
            ),
            _DrawerItem(
              icon: Icons.group_outlined,
              label: 'Kelola pengguna',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, Routes.kelolaPengguna);
              },
            ),
            _DrawerItem(
              icon: Icons.lock_outline,
              label: 'Kelola akun admin',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, Routes.kelolaAkunAdmin);
              },
            ),
            _DrawerItem(
              icon: Icons.notifications_none,
              label: 'Kelola notifikasi',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, Routes.kelolaNotifikasi);
              },
            ),

            const Spacer(),

            // ✅ Logout di bagian bawah
            const Divider(color: Colors.white24),
            _DrawerItem(
              icon: Icons.logout,
              label: 'Logout',
              onTap: () => _logout(context),
              color: Colors.redAccent,
            ),

            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Jago Masak',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? Colors.white;

    return ListTile(
      leading: Icon(icon, color: c),
      title: Text(label, style: TextStyle(color: c)),
      onTap: onTap,
    );
  }
}
