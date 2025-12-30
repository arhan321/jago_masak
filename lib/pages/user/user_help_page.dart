import 'package:flutter/material.dart';

class UserHelpPage extends StatefulWidget {
  const UserHelpPage({super.key});

  @override
  State<UserHelpPage> createState() => _UserHelpPageState();
}

class _UserHelpPageState extends State<UserHelpPage> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final msgCtrl = TextEditingController();

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    msgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pusat Bantuan')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text('Butuh Bantuan?\nKirim Pertanyaan atau Kendala di sini!',
                style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Masukkan Nama')),
            const SizedBox(height: 10),
            TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 10),
            TextField(
              controller: msgCtrl,
              minLines: 4,
              maxLines: 6,
              decoration: const InputDecoration(labelText: 'Pesan'),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pesan terkirim! (dummy)')));
              },
              child: const Text('Kirim'),
            ),
          ],
        ),
      ),
    );
  }
}
