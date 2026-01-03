import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../core/routes.dart';
import '../../core/app_theme.dart';
import '../../core/network/api_client.dart';
import '../../widgets/admin_drawer.dart';
import '../../features/sarans/saran_api.dart';

class FeedbackInboxPage extends StatefulWidget {
  const FeedbackInboxPage({super.key});

  @override
  State<FeedbackInboxPage> createState() => _FeedbackInboxPageState();
}

class _FeedbackInboxPageState extends State<FeedbackInboxPage> {
  bool _loading = true;
  String? _error;

  List<_ApiSaranRow> _items = [];

  @override
  void initState() {
    super.initState();
    _fetchSarans();
  }

  Future<void> _fetchSarans() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final raw = await SaranApi.instance.fetchSarans();
      final parsed = raw.map((e) => _ApiSaranRow.fromJson(e)).toList();

      if (!mounted) return;
      setState(() {
        _items = parsed;
        _loading = false;
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
            ? ((e.response?.data['message'] ?? 'Gagal memuat masukan')
                .toString())
            : 'Gagal memuat masukan';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jago Masak'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading ? null : _fetchSarans,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      drawer: const AdminDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Masukan Pengguna',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : (_error != null)
                      ? _ErrorBox(message: _error!, onRetry: _fetchSarans)
                      : (_items.isEmpty)
                          ? const Center(
                              child: Text(
                                'Belum ada masukan.',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _fetchSarans,
                              child: ListView.separated(
                                itemCount: _items.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (_, i) {
                                  final m = _items[i];
                                  return _SaranCard(item: m, index: i + 1);
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SaranCard extends StatelessWidget {
  final _ApiSaranRow item;
  final int index;

  const _SaranCard({required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    final name = item.name.trim().isEmpty ? 'Anonim' : item.name.trim();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.softBlue.withOpacity(0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.navy.withOpacity(0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // badge nomor
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppTheme.navy,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                '$index',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // header: name + date
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: AppTheme.navy,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        item.createdAtText,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // pesan
                  Text(
                    item.pesan,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ApiSaranRow {
  final int id;
  final String name;
  final String pesan;
  final String createdAtText;
  final String? createdAtIso;

  _ApiSaranRow({
    required this.id,
    required this.name,
    required this.pesan,
    required this.createdAtText,
    this.createdAtIso,
  });

  factory _ApiSaranRow.fromJson(Map<String, dynamic> json) {
    final createdAt = (json['created_at'] ?? '').toString();

    return _ApiSaranRow(
      id: (json['id'] ?? 0) is int
          ? (json['id'] as int)
          : int.tryParse('${json['id']}') ?? 0,
      name: (json['name'] ?? '').toString(),
      pesan: (json['pesan'] ?? '').toString(),
      createdAtIso: createdAt,
      createdAtText: _formatCreatedAt(createdAt),
    );
  }

  static String _formatCreatedAt(String iso) {
    if (iso.isEmpty) return '-';
    final s = iso.replaceAll('T', ' ');
    final noMs = s.split('.').first;
    final noZ = noMs.replaceAll('Z', '');
    return noZ.length >= 16 ? noZ.substring(0, 16) : noZ;
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBox({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
