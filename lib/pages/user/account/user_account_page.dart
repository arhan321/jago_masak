import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../core/routes.dart';

class UserAccountPage extends StatefulWidget {
  const UserAccountPage({super.key});

  @override
  State<UserAccountPage> createState() => _UserAccountPageState();
}

class _UserAccountPageState extends State<UserAccountPage> {
  Dio get _dio => ApiClient.instance.dio;

  bool _loadingMe = true;
  String _name = '...';
  String _email = '...';

  @override
  void initState() {
    super.initState();
    _fetchMe();
  }

  Future<void> _fetchMe() async {
    if (!mounted) return;
    setState(() => _loadingMe = true);

    try {
      final res = await _dio.get('/me'); // auth:sanctum
      final data = res.data;

      if (data is Map) {
        final name = (data['name'] ?? '').toString().trim();
        final email = (data['email'] ?? '').toString().trim();

        if (!mounted) return;
        setState(() {
          _name = name.isEmpty ? 'User' : name;
          _email = email.isEmpty ? '-' : email;
          _loadingMe = false;
        });
        return;
      }

      if (!mounted) return;
      setState(() {
        _name = 'User';
        _email = '-';
        _loadingMe = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;

      if (e.response?.statusCode == 401) {
        Navigator.pushNamedAndRemoveUntil(context, Routes.login, (r) => false);
        return;
      }

      setState(() {
        _name = 'User';
        _email = '-';
        _loadingMe = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _name = 'User';
        _email = '-';
        _loadingMe = false;
      });
    }
  }

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
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (ok == true) {
      // OPTIONAL (lebih benar): call backend logout dulu kalau ada endpoint /logout
      // try { await _dio.post('/logout'); } catch (_) {}

      rootNav.pushNamedAndRemoveUntil(Routes.login, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hello = _loadingMe ? 'Halo ...' : 'Halo $_name';

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              const CircleAvatar(child: Icon(Icons.person)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hello,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _loadingMe ? '...' : _email,
                      style: const TextStyle(fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          leading: const SizedBox(),
          actions: [
            IconButton(
              tooltip: 'Refresh',
              onPressed: _fetchMe,
              icon: const Icon(Icons.refresh),
            ),
          ],
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
