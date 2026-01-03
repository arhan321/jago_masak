import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../core/routes.dart';

class UserAccountInfoPage extends StatefulWidget {
  const UserAccountInfoPage({super.key});

  @override
  State<UserAccountInfoPage> createState() => _UserAccountInfoPageState();
}

class _UserAccountInfoPageState extends State<UserAccountInfoPage> {
  Dio get _dio => ApiClient.instance.dio;

  bool _loading = true;
  String? _error;

  String _name = '-';
  String _email = '-';
  String _phone = '-';

  @override
  void initState() {
    super.initState();
    _fetchMe();
  }

  Future<void> _fetchMe() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await _dio.get('/me'); // auth:sanctum
      final data = res.data;

      if (data is Map) {
        final name = (data['name'] ?? '').toString().trim();
        final email = (data['email'] ?? '').toString().trim();

        // beberapa backend pakai 'phone' / 'no_telp' / 'telp'
        final phoneRaw =
            data['phone'] ?? data['nomor_telfon'] ?? data['telp'] ?? '';

        final phone = phoneRaw.toString().trim();

        if (!mounted) return;
        setState(() {
          _name = name.isEmpty ? '-' : name;
          _email = email.isEmpty ? '-' : email;
          _phone = phone.isEmpty ? '-' : phone;
          _loading = false;
        });
        return;
      }

      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Format response /me tidak sesuai.';
      });
    } on DioException catch (e) {
      if (!mounted) return;

      if (e.response?.statusCode == 401) {
        Navigator.pushNamedAndRemoveUntil(context, Routes.login, (r) => false);
        return;
      }

      setState(() {
        _loading = false;
        _error = (e.response?.data is Map)
            ? ((e.response?.data['message'] ?? 'Gagal memuat akun').toString())
            : 'Gagal memuat akun';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Gagal memuat akun';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informasi Akun'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _fetchMe,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _loading
            ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
            : (_error != null)
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.redAccent, size: 34),
                        const SizedBox(height: 10),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _fetchMe,
                          child: const Text('Coba lagi'),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        child: Icon(Icons.person, size: 40),
                      ),
                      const SizedBox(height: 10),
                      TextButton.icon(
                        onPressed: () {
                          // nanti kalau mau upload foto: implement di sini
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Fitur edit foto belum dibuat.')),
                          );
                        },
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Edit Foto'),
                      ),
                      const SizedBox(height: 14),
                      _LineField(label: 'Nama Akun', value: _name),
                      _LineField(label: 'No Telepon', value: _phone),
                      _LineField(label: 'Alamat Email', value: _email),
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
