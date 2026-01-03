import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../core/routes.dart';

class UserSettingsPage extends StatefulWidget {
  const UserSettingsPage({super.key});

  @override
  State<UserSettingsPage> createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> {
  Dio get _dio => ApiClient.instance.dio;

  bool showChangePassword = false;

  final _formKey = GlobalKey<FormState>();
  final oldCtrl = TextEditingController();
  final newCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  bool _loadingMe = true;
  bool _submitting = false;
  int? _myId;

  @override
  void initState() {
    super.initState();
    _fetchMe();
  }

  @override
  void dispose() {
    oldCtrl.dispose();
    newCtrl.dispose();
    confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchMe() async {
    if (!mounted) return;
    setState(() => _loadingMe = true);

    try {
      final res = await _dio.get('/me'); // auth:sanctum
      final data = res.data;

      if (data is Map) {
        final rawId = data['id'];
        int? id;
        if (rawId is int) id = rawId;
        if (rawId is String) id = int.tryParse(rawId);
        if (rawId is num) id = rawId.toInt();

        if (!mounted) return;
        setState(() {
          _myId = id;
          _loadingMe = false;
        });
        return;
      }

      if (!mounted) return;
      setState(() {
        _myId = null;
        _loadingMe = false;
      });
      _snack('Gagal mengambil data akun (me).');
    } on DioException catch (e) {
      if (!mounted) return;

      if (e.response?.statusCode == 401) {
        Navigator.pushNamedAndRemoveUntil(context, Routes.login, (r) => false);
        return;
      }

      setState(() => _loadingMe = false);
      _snack('Gagal mengambil data akun (me).');
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingMe = false);
      _snack('Gagal mengambil data akun (me).');
    }
  }

  Future<void> _submitChangePassword() async {
    if (_myId == null) {
      _snack('User ID tidak ditemukan. Coba login ulang.');
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    try {
      // Backend updateById tidak cek password lama, jadi oldCtrl tidak dikirim.
      await _dio.put(
        '/users/$_myId',
        data: {
          'password': newCtrl.text,
        },
      );

      if (!mounted) return;
      _snack('Password berhasil diubah.');

      oldCtrl.clear();
      newCtrl.clear();
      confirmCtrl.clear();

      setState(() => showChangePassword = false);
    } on DioException catch (e) {
      if (!mounted) return;

      if (e.response?.statusCode == 401) {
        Navigator.pushNamedAndRemoveUntil(context, Routes.login, (r) => false);
        return;
      }

      final msg = (e.response?.data is Map)
          ? ((e.response?.data['message'] ?? 'Gagal ubah password').toString())
          : 'Gagal ubah password';
      _snack(msg);
    } catch (e) {
      if (!mounted) return;
      _snack(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _confirmDeleteAccount() async {
    // NOTE: kamu belum kasih endpoint delete user di backend.
    // Jadi sementara tetap dummy tapi sudah ada dialog.
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Hapus Akun'),
        content: const Text(
            'Fitur ini belum tersambung ke backend. Lanjutkan (dummy)?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (ok == true) {
      _snack('Hapus akun (dummy).');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _loadingMe
            ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
            : Column(
                children: [
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.lock_outline),
                      title: const Text('Ganti Password'),
                      trailing: Icon(showChangePassword
                          ? Icons.expand_less
                          : Icons.expand_more),
                      onTap: () => setState(
                          () => showChangePassword = !showChangePassword),
                    ),
                  ),
                  if (showChangePassword) ...[
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // Password lama tidak dipakai backend, tapi boleh tampilkan
                              // TextFormField(
                              //   controller: oldCtrl,
                              //   obscureText: true,
                              //   decoration: const InputDecoration(
                              //     labelText: 'Password Lama',
                              //     helperText:
                              //         'Catatan: backend belum memvalidasi password lama.',
                              //   ),
                              // ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: newCtrl,
                                obscureText: true,
                                validator: (v) => (v == null || v.length < 8)
                                    ? 'Minimal 8 karakter'
                                    : null,
                                decoration: const InputDecoration(
                                  labelText: 'Password Baru',
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: confirmCtrl,
                                obscureText: true,
                                validator: (v) => (v != newCtrl.text)
                                    ? 'Password tidak sama'
                                    : null,
                                decoration: const InputDecoration(
                                  labelText: 'Ketik Ulang Password',
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _submitting
                                      ? null
                                      : _submitChangePassword,
                                  child: _submitting
                                      ? const SizedBox(
                                          height: 18,
                                          width: 18,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        )
                                      : const Text('Ubah Password'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.delete_outline),
                      title: const Text('Hapus Akun'),
                      onTap: _confirmDeleteAccount,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
