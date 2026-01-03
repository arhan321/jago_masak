import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../../core/routes.dart';
import '../../widgets/admin_drawer.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  Dio get _dio => ApiClient.instance.dio;

  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  bool _sending = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendNotification() async {
    final title = _titleCtrl.text.trim();
    final desc = _descCtrl.text.trim();

    // validasi ringan
    if (title.isEmpty && desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul atau deskripsi harus diisi.')),
      );
      return;
    }

    if (!mounted) return;
    setState(() => _sending = true);

    try {
      await _dio.post(
        '/notifications',
        data: {
          'judul': title.isEmpty ? null : title,
          'deskripsi_notifikasi': desc.isEmpty ? null : desc,
        },
      );

      if (!mounted) return;

      _titleCtrl.clear();
      _descCtrl.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notifikasi berhasil dikirim.')),
      );
    } on DioException catch (e) {
      if (!mounted) return;

      if (e.response?.statusCode == 401) {
        Navigator.pushNamedAndRemoveUntil(context, Routes.login, (r) => false);
        return;
      }

      final msg = (e.response?.data is Map)
          ? ((e.response?.data['message'] ?? 'Gagal mengirim notifikasi')
              .toString())
          : 'Gagal mengirim notifikasi';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengirim notifikasi')),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jago Masak')),
      drawer: const AdminDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Kelola Notifikasi',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                const Text('Judul Notifikasi',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                TextField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Tutorial Memasak dengan Baik',
                    prefixIcon: Icon(Icons.notifications_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Deskripsi Notifikasi',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                TextField(
                  controller: _descCtrl,
                  minLines: 5,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    hintText: 'Pastikan kompor dinyalakan.',
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: _sending ? null : _sendNotification,
                    icon: _sending
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                    label: Text(_sending ? 'Mengirim...' : 'Kirim'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
