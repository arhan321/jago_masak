import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../core/routes.dart';

class UserHelpPage extends StatefulWidget {
  const UserHelpPage({super.key});

  @override
  State<UserHelpPage> createState() => _UserHelpPageState();
}

class _UserHelpPageState extends State<UserHelpPage> {
  Dio get _dio => ApiClient.instance.dio;

  final _formKey = GlobalKey<FormState>();

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController(); // UI saja (backend belum pakai)
  final msgCtrl = TextEditingController();

  bool _submitting = false;

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    msgCtrl.dispose();
    super.dispose();
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    try {
      final payload = {
        // name nullable: kalau kosong jangan kirim (lebih rapi)
        if (nameCtrl.text.trim().isNotEmpty) 'name': nameCtrl.text.trim(),
        'pesan': msgCtrl.text.trim(),
      };

      await _dio.post('/sarans', data: payload);

      if (!mounted) return;

      _snack('Saran berhasil dikirim ✅');

      nameCtrl.clear();
      emailCtrl.clear();
      msgCtrl.clear();
    } on DioException catch (e) {
      if (!mounted) return;

      // kalau ternyata endpoint ini nanti dibuat auth, handle 401
      if (e.response?.statusCode == 401) {
        Navigator.pushNamedAndRemoveUntil(context, Routes.login, (r) => false);
        return;
      }

      final msg = (e.response?.data is Map)
          ? ((e.response?.data['message'] ?? 'Gagal mengirim saran').toString())
          : 'Gagal mengirim saran';
      _snack(msg);
    } catch (e) {
      if (!mounted) return;
      _snack(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pusat Bantuan')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Butuh Bantuan?\nKirim Pertanyaan atau Kendala di sini!',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Masukkan Nama'),
              ),

              const SizedBox(height: 10),

              // UI saja - backend belum menerima email
              // TextFormField(
              //   controller: emailCtrl,
              //   keyboardType: TextInputType.emailAddress,
              //   decoration: const InputDecoration(
              //     labelText: 'Email (opsional)',
              //     helperText:
              //         'Catatan: saat ini email tidak dikirim ke server.',
              //   ),
              // ),

              const SizedBox(height: 10),

              TextFormField(
                controller: msgCtrl,
                minLines: 4,
                maxLines: 6,
                validator: (v) {
                  final value = (v ?? '').trim();
                  if (value.isEmpty) return 'Pesan wajib diisi';
                  if (value.length > 1000) return 'Maksimal 1000 karakter';
                  return null;
                },
                decoration: const InputDecoration(labelText: 'Pesan'),
              ),

              const SizedBox(height: 14),

              ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Kirim'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
