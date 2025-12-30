import 'package:flutter/material.dart';

class UserAccountInfoPage extends StatelessWidget {
  const UserAccountInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Informasi Akun')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Edit Foto'),
            ),
            const SizedBox(height: 14),
            const _LineField(label: 'Nama Akun', value: 'Sarminah'),
            const _LineField(label: 'No Telepon', value: '087800131888'),
            const _LineField(
                label: 'Alamat Email', value: 'sarminah@gmail.com'),
          ],
        ),
      ),
    );
  }
}

class _LineField extends StatelessWidget {
  final String label;
  final String value;
  const _LineField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
          const Divider(height: 18),
        ],
      ),
    );
  }
}
