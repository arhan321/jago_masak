import 'package:flutter/material.dart';
import '../../widgets/admin_drawer.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _oldCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _oldCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jago Masak')),
      drawer: const AdminDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Kelola Akun Admin',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 12),
                    const Text('Ganti Kata Sandi',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 10),
                    const Text('Kata Sandi Lama',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _oldCtrl,
                      obscureText: true,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                      decoration: const InputDecoration(
                          hintText: 'Masukkan Password Lama'),
                    ),
                    const SizedBox(height: 10),
                    const Text('Kata Sandi Baru',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _newCtrl,
                      obscureText: true,
                      validator: (v) => (v == null || v.length < 6)
                          ? 'Minimal 6 karakter'
                          : null,
                      decoration: const InputDecoration(
                          hintText: 'Masukkan Password Baru'),
                    ),
                    const SizedBox(height: 10),
                    const Text('Ketik Ulang Kata Sandi Baru',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _confirmCtrl,
                      obscureText: true,
                      validator: (v) =>
                          (v != _newCtrl.text) ? 'Password tidak sama' : null,
                      decoration: const InputDecoration(
                          hintText: 'Ketik Ulang Password Baru'),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton(
                      onPressed: () {
                        if (!_formKey.currentState!.validate()) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Password berhasil diubah (dummy).')),
                        );
                        _oldCtrl.clear();
                        _newCtrl.clear();
                        _confirmCtrl.clear();
                      },
                      child: const Text('Ubah Password'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
