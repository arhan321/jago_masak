import 'package:flutter/material.dart';
import '../../../core/routes.dart';

class UserAccountPage extends StatelessWidget {
  const UserAccountPage({super.key});

  Future<void> _logout(BuildContext context) async {
    final rootNav = Navigator.of(context, rootNavigator: true);

    final ok = await showDialog<bool>(
      context: rootNav.context,
      builder: (c) => AlertDialog(
        title: const Text('Keluar Akun'),
        content: const Text('Yakin ingin keluar?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (ok == true) {
      rootNav.pushNamedAndRemoveUntil(Routes.login, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: const [
              CircleAvatar(child: Icon(Icons.person)),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Halo Sarminah',
                        style: TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 14)),
                    Text('sarminah@gmail.com', style: TextStyle(fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          leading: const SizedBox(),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Akun', style: TextStyle(color: Colors.black54)),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Informasi Akun'),
              onTap: () => Navigator.pushNamed(context, Routes.userAccountInfo),
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Pengaturan'),
              onTap: () => Navigator.pushNamed(context, Routes.userSettings),
            ),
            const Divider(),
            const Text('Pusat Bantuan',
                style: TextStyle(color: Colors.black54)),
            ListTile(
              leading: const Icon(Icons.support_agent_outlined),
              title: const Text('Bantuan Jago Masak'),
              onTap: () => Navigator.pushNamed(context, Routes.userHelp),
            ),
            const Divider(),
            const Text('Panduan Layanan',
                style: TextStyle(color: Colors.black54)),
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: const Text('Syarat dan Ketentuan'),
              onTap: () => Navigator.pushNamed(context, Routes.userTerms),
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text('Kebijakan Privasi'),
              onTap: () => Navigator.pushNamed(context, Routes.userPrivacy),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Keluar Akun'),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
    );
  }
}
