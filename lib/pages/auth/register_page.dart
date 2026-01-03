import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../core/app_theme.dart';
import '../../core/config/app_config.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController(); // ✅ nomor telfon
  final _passwordCtrl = TextEditingController();

  bool _obscure = true;
  bool _loading = false;

  final _client = http.Client();

  @override
  void dispose() {
    _client.close();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Map<String, String> _headersJson() => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

  Map<String, dynamic> _decode(http.Response res) {
    try {
      final body = res.body.isEmpty ? '{}' : res.body;
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {};
    } catch (_) {
      return {};
    }
  }

  String? _extractMessage(Map<String, dynamic> data) {
    if (data['message'] is String) return data['message'] as String;

    final errors = data['errors'];
    if (errors is Map) {
      final keys = errors.keys.toList();
      if (keys.isNotEmpty) {
        final v = errors[keys.first];
        if (v is List && v.isNotEmpty) return v.first.toString();
      }
    }
    return null;
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final res = await _client.post(
        AppConfig.apiUri('/register'),
        headers: _headersJson(),
        body: jsonEncode({
          'name': _nameCtrl.text.trim(),
          'email': _emailCtrl.text.trim(),
          'nomor_telfon': _phoneCtrl.text.trim(),
          'password': _passwordCtrl.text,
        }),
      );

      final data = _decode(res);

      if (res.statusCode == 201 || res.statusCode == 200) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pendaftaran berhasil. Silakan login.')),
        );

        Navigator.pop(context);
        return;
      }

      throw Exception(
        _extractMessage(data) ?? 'Register gagal (${res.statusCode})',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String? _validatePhone(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return 'Nomor telfon wajib diisi';

    final normalized = value.replaceAll(' ', '').replaceAll('-', '');
    final ok = RegExp(r'^\+?\d{8,15}$').hasMatch(normalized);
    if (!ok) return 'Nomor telfon tidak valid';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.navy,
      appBar: AppBar(
        backgroundColor: AppTheme.navy,
        foregroundColor: Colors.white,
        title: const Text('Daftar'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // ✅ LOGO di atas (seperti login)
              Image.asset(
                'assets/logo_jagomasak2.png',
                height: 180,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const SizedBox(
                  height: 120,
                  child: Center(
                    child: Icon(Icons.image_not_supported,
                        color: Colors.white70, size: 40),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.15)),
                  ),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameCtrl,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Nama wajib diisi'
                                : null,
                            decoration: const InputDecoration(hintText: 'Nama'),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              final value = (v ?? '').trim();
                              if (value.isEmpty) return 'Email wajib diisi';
                              if (!value.contains('@'))
                                return 'Email tidak valid';
                              return null;
                            },
                            decoration:
                                const InputDecoration(hintText: 'Email'),
                          ),
                          const SizedBox(height: 12),

                          // ✅ Nomor Telfon
                          TextFormField(
                            controller: _phoneCtrl,
                            keyboardType: TextInputType.phone,
                            validator: _validatePhone,
                            decoration:
                                const InputDecoration(hintText: 'Nomor Telfon'),
                          ),

                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _passwordCtrl,
                            obscureText: _obscure,
                            validator: (v) {
                              final value = v ?? '';
                              if (value.isEmpty) return 'Password wajib diisi';
                              if (value.length < 8) {
                                return 'Password minimal 8 karakter';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'Password',
                              suffixIcon: IconButton(
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _handleRegister,
                              child: _loading
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : const Text('Daftar'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
