import 'package:flutter/material.dart';

class UserTermsPage extends StatelessWidget {
  const UserTermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Syarat dan Ketentuan')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Expanded(
              child: SingleChildScrollView(
                child: Text(
                  'Ini adalah halaman Syarat dan Ketentuan (dummy).\n\n'
                  '1. Aplikasi hanya untuk kebutuhan pribadi.\n'
                  '2. Resep hanya informasi.\n'
                  '3. Data pengguna dijaga.\n\n'
                  'Dan seterusnya...',
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Setuju'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class UserPrivacyPage extends StatelessWidget {
  const UserPrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kebijakan Privasi')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Expanded(
              child: SingleChildScrollView(
                child: Text(
                  'Ini adalah halaman Kebijakan Privasi (dummy).\n\n'
                  'Kami menjaga privasi Anda...\n\n'
                  'Dan seterusnya...',
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Saya Mengerti'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
