import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/network/api_client.dart';
import '../../core/routes.dart';

class UserNotificationsPage extends StatefulWidget {
  const UserNotificationsPage({super.key});

  @override
  State<UserNotificationsPage> createState() => _UserNotificationsPageState();
}

class _UserNotificationsPageState extends State<UserNotificationsPage> {
  Dio get _dio => ApiClient.instance.dio;

  static const String _kLastSeenKey = 'last_seen_notification_created_at';

  bool _loading = true;
  String? _error;
  List<_ApiNotification> _items = [];

  DateTime? _latestCreatedAt; // untuk dikirim balik ke Home

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await _dio.get('/notifications');
      final data = res.data;

      List<_ApiNotification> parsed = [];

      if (data is List) {
        parsed = data
            .map((e) => e is Map
                ? _ApiNotification.fromJson(Map<String, dynamic>.from(e))
                : null)
            .whereType<_ApiNotification>()
            .toList();
      } else if (data is Map && data['data'] is List) {
        // kalau suatu saat backend ubah jadi {data:[]}
        final list = List.from(data['data'] as List);
        parsed = list
            .map((e) => e is Map
                ? _ApiNotification.fromJson(Map<String, dynamic>.from(e))
                : null)
            .whereType<_ApiNotification>()
            .toList();
      } else {
        throw Exception('Format response /notifications tidak sesuai');
      }

      // urutkan terbaru di atas (jaga-jaga)
      parsed.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // set latest
      _latestCreatedAt = parsed.isNotEmpty ? parsed.first.createdAt : null;

      // anggap "dibaca" saat halaman ini dibuka -> simpan lastSeen = latest
      if (_latestCreatedAt != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            _kLastSeenKey, _latestCreatedAt!.toIso8601String());
      }

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
            ? ((e.response?.data['message'] ?? 'Gagal memuat notifikasi')
                .toString())
            : 'Gagal memuat notifikasi';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _onRefresh() async => _fetch();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // kirim latest back ke Home
        Navigator.pop(context, _latestCreatedAt?.toIso8601String());
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notifikasi'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () =>
                Navigator.pop(context, _latestCreatedAt?.toIso8601String()),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _onRefresh,
          child: _loading
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 140),
                    Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ],
                )
              : (_error != null)
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: Colors.red.withOpacity(0.15)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: Colors.redAccent),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                              TextButton(
                                onPressed: _fetch,
                                child: const Text('Coba lagi'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : (_items.isEmpty)
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 140),
                            Center(child: Text('Belum ada notifikasi.')),
                          ],
                        )
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          itemCount: _items.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (_, i) {
                            final n = _items[i];
                            return Card(
                              child: ListTile(
                                leading: const Icon(Icons.notifications),
                                title: Text(
                                  n.judul.isEmpty ? '-' : n.judul,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  n.deskripsi.isEmpty ? '-' : n.deskripsi,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            );
                          },
                        ),
        ),
      ),
    );
  }
}

class _ApiNotification {
  final int id;
  final String judul;
  final String deskripsi;
  final DateTime createdAt;

  _ApiNotification({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.createdAt,
  });

  factory _ApiNotification.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is int ? rawId : int.tryParse('$rawId') ?? 0;

    final createdAtIso = (json['created_at'] ?? '').toString();
    final createdAt = DateTime.tryParse(createdAtIso) ?? DateTime.now();

    return _ApiNotification(
      id: id,
      judul: (json['judul'] ?? '').toString(),
      deskripsi: (json['deskripsi_notifikasi'] ?? '').toString(),
      createdAt: createdAt,
    );
  }
}
