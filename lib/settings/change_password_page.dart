import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../core/routes.dart';
import '../../features/admin/admin_account_api.dart';
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
    _oldCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchMe() async {
    setState(() => _loadingMe = true);

    try {
      final me = await AdminAccountApi.instance.me();
      final rawId = me['id'];

      int? id;
      if (rawId is int) id = rawId;
      if (rawId is String) id = int.tryParse(rawId);
      if (rawId is num) id = rawId.toInt();

      if (!mounted) return;
      setState(() {
        _myId = id;
        _loadingMe = false;
      });
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

  Future<void> _submit() async {
    if (_myId == null) {
      _snack('User ID tidak ditemukan. Coba login ulang.');
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    try {
      // NOTE:
      // Backend updateById kamu tidak memvalidasi password lama,
      // jadi _oldCtrl tidak dipakai untuk request.
      await AdminAccountApi.instance.updateById(
        id: _myId!,
        password: _newCtrl.text,
      );

      if (!mounted) return;
      _snack('Password berhasil diubah.');

      _oldCtrl.clear();
      _newCtrl.clear();
      _confirmCtrl.clear();
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
              child: _loadingMe
                  ? const SizedBox(
                      height: 220,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Kelola Akun Admin',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Ganti Kata Sandi',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 10),
                          // const Text(
                          //   'Kata Sandi Lama',
                          //   style: TextStyle(fontWeight: FontWeight.w700),
                          // ),
                          // const SizedBox(height: 6),
                          // TextFormField(
                          //   controller: _oldCtrl,
                          //   obscureText: true,
                          //   validator: (v) =>
                          //       (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                          //   decoration: const InputDecoration(
                          //     hintText: 'Masukkan Password Lama',
                          //     helperText:
                          //         'Catatan: backend belum memvalidasi password lama.',
                          //   ),
                          // ),
                          const SizedBox(height: 10),
                          const Text(
                            'Kata Sandi Baru',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _newCtrl,
                            obscureText: true,
                            validator: (v) => (v == null || v.length < 8)
                                ? 'Minimal 8 karakter'
                                : null,
                            decoration: const InputDecoration(
                              hintText: 'Masukkan Password Baru',
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Ketik Ulang Kata Sandi Baru',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _confirmCtrl,
                            obscureText: true,
                            validator: (v) => (v != _newCtrl.text)
                                ? 'Password tidak sama'
                                : null,
                            decoration: const InputDecoration(
                              hintText: 'Ketik Ulang Password Baru',
                            ),
                          ),
                          const SizedBox(height: 14),
                          ElevatedButton(
                            onPressed: _submitting ? null : _submit,
                            child: _submitting
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Text('Ubah Password'),
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
