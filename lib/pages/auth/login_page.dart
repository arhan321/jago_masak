import 'package:flutter/material.dart';
import '../../core/routes.dart';
import '../../core/app_theme.dart';
import '../../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final auth = await AuthService.instance.login(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );

      if (!mounted) return;

      // redirect by role
      final role = auth.user.role.toLowerCase();
      if (role == 'admin') {
        Navigator.pushReplacementNamed(context, Routes.dashboard);
      } else {
        // ✅ pakai userShell (karena routes.dart kamu tidak punya userHome)
        Navigator.pushReplacementNamed(context, Routes.userShell);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.navy,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              const SizedBox(height: 36),
              const Text(
                'JAGO\nMASAK',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Masuk',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.15)),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
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
                          decoration: const InputDecoration(
                            hintText: 'Email',
                          ),
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
                            hintText: 'Masukkan Kata sandi',
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
                            onPressed: _loading ? null : _handleLogin,
                            child: _loading
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Login'),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, Routes.register),
                          child: const Text(
                            'Belum punya akun? Daftar Sekarang!',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const Spacer(),
                        // TextButton(
                        //   // ✅ skip diarahkan ke userShell
                        //   onPressed: () => Navigator.pushReplacementNamed(
                        //     context,
                        //     Routes.userShell,
                        //   ),
                        //   child: const Text(
                        //     'Later (skip)',
                        //     style: TextStyle(color: Colors.white70),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
