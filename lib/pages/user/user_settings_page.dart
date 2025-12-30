import 'package:flutter/material.dart';

class UserSettingsPage extends StatefulWidget {
  const UserSettingsPage({super.key});

  @override
  State<UserSettingsPage> createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> {
  bool showChangePassword = false;

  final oldCtrl = TextEditingController();
  final newCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  @override
  void dispose() {
    oldCtrl.dispose();
    newCtrl.dispose();
    confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.lock_outline),
                title: const Text('Ganti Password'),
                trailing: Icon(
                    showChangePassword ? Icons.expand_less : Icons.expand_more),
                onTap: () =>
                    setState(() => showChangePassword = !showChangePassword),
              ),
            ),
            if (showChangePassword) ...[
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      TextField(
                        controller: oldCtrl,
                        obscureText: true,
                        decoration:
                            const InputDecoration(labelText: 'Password Lama'),
                      ),
                      TextField(
                        controller: newCtrl,
                        obscureText: true,
                        decoration:
                            const InputDecoration(labelText: 'Password Baru'),
                      ),
                      TextField(
                        controller: confirmCtrl,
                        obscureText: true,
                        decoration: const InputDecoration(
                            labelText: 'Ketik Ulang Password'),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Password diubah (dummy).')),
                            );
                          },
                          child: const Text('Ubah Password'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Hapus Akun'),
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Hapus akun (dummy).')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
