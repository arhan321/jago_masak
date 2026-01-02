import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/routes.dart';
import '../../widgets/admin_drawer.dart';

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  final ScrollController _hCtrl = ScrollController();

  bool _loading = true;
  String? _error;

  List<_ApiUserRow> _users = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  @override
  void dispose() {
    _hCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final dio = ApiClient.instance.dio;

      // ✅ pastikan backend punya GET /api/users (admin only biasanya)
      final res = await dio.get('/users');

      final data = res.data;

      // 1) Kalau backend return List langsung: [ {...}, {...} ]
      if (data is List) {
        final parsed = data
            .map((e) => e is Map
                ? _ApiUserRow.fromJson(Map<String, dynamic>.from(e))
                : null)
            .whereType<_ApiUserRow>()
            .toList();

        if (!mounted) return;
        setState(() {
          _users = parsed;
          _loading = false;
        });
        return;
      }

      // 2) Kalau backend return Laravel paginate: { data: [ ... ], ... }
      if (data is Map && data['data'] is List) {
        final list = List.from(data['data'] as List);
        final parsed = list
            .map((e) => e is Map
                ? _ApiUserRow.fromJson(Map<String, dynamic>.from(e))
                : null)
            .whereType<_ApiUserRow>()
            .toList();

        if (!mounted) return;
        setState(() {
          _users = parsed;
          _loading = false;
        });
        return;
      }

      // 3) Kadang paginate nested: { data: { data: [...] } }
      if (data is Map &&
          data['data'] is Map &&
          (data['data'] as Map)['data'] is List) {
        final nested = data['data'] as Map;
        final list = List.from(nested['data'] as List);

        final parsed = list
            .map((e) => e is Map
                ? _ApiUserRow.fromJson(Map<String, dynamic>.from(e))
                : null)
            .whereType<_ApiUserRow>()
            .toList();

        if (!mounted) return;
        setState(() {
          _users = parsed;
          _loading = false;
        });
        return;
      }

      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Format response tidak sesuai';
      });
    } on DioException catch (e) {
      if (!mounted) return;

      // token invalid/expired
      if (e.response?.statusCode == 401) {
        Navigator.pushNamedAndRemoveUntil(context, Routes.login, (r) => false);
        return;
      }

      setState(() {
        _loading = false;
        _error = (e.response?.data is Map)
            ? ((e.response?.data['message'] ?? 'Gagal memuat users').toString())
            : 'Gagal memuat users';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Gagal memuat users';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jago Masak')),
      drawer: const AdminDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Kelola Pengguna',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : (_error != null)
                            ? _ErrorBox(message: _error!, onRetry: _fetchUsers)
                            : Scrollbar(
                                controller: _hCtrl,
                                thumbVisibility: true,
                                trackVisibility: true,
                                scrollbarOrientation:
                                    ScrollbarOrientation.bottom,
                                child: SingleChildScrollView(
                                  controller: _hCtrl,
                                  scrollDirection: Axis.horizontal,
                                  child: ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(minWidth: 980),
                                    child: DataTable(
                                      headingRowHeight: 48,
                                      dataRowHeight: 56,
                                      columnSpacing: 28,
                                      horizontalMargin: 16,
                                      dividerThickness: 0.8,
                                      headingRowColor: MaterialStatePropertyAll(
                                        Colors.blueGrey.shade300,
                                      ),
                                      headingTextStyle: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        color: Colors.black87,
                                      ),
                                      columns: const [
                                        DataColumn(
                                          label: SizedBox(
                                            width: 60,
                                            child: Text('No.'),
                                          ),
                                        ),
                                        DataColumn(
                                          label: SizedBox(
                                            width: 160,
                                            child: Text('Nama'),
                                          ),
                                        ),
                                        DataColumn(
                                          label: SizedBox(
                                            width: 220,
                                            child: Text('Email'),
                                          ),
                                        ),
                                        DataColumn(
                                          label: SizedBox(
                                            width: 140,
                                            child: Text('No. HP'),
                                          ),
                                        ),
                                        DataColumn(
                                          label: SizedBox(
                                            width: 140,
                                            child: Text('Roles'),
                                          ),
                                        ),
                                        DataColumn(
                                          label: SizedBox(
                                            width: 200,
                                            child: Text('Tgl Dibuat'),
                                          ),
                                        ),
                                      ],
                                      rows: List.generate(_users.length, (i) {
                                        final u = _users[i];

                                        // ✅ jumlah cells harus sama dengan jumlah columns (6)
                                        return DataRow(
                                          cells: [
                                            DataCell(
                                              SizedBox(
                                                width: 60,
                                                child: Text('${i + 1}.'),
                                              ),
                                            ),
                                            DataCell(
                                              SizedBox(
                                                width: 160,
                                                child: Text(
                                                  u.name,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              SizedBox(
                                                width: 220,
                                                child: Text(
                                                  u.email,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              SizedBox(
                                                width: 140,
                                                child: Text(u.phone),
                                              ),
                                            ),
                                            DataCell(
                                              SizedBox(
                                                width: 140,
                                                child: Text(u.role),
                                              ),
                                            ),
                                            DataCell(
                                              SizedBox(
                                                width: 200,
                                                child: Text(u.createdAtText),
                                              ),
                                            ),
                                          ],
                                        );
                                      }),
                                    ),
                                  ),
                                ),
                              ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Belum ada aksi simpan (API read-only).'),
                  ),
                ),
                child: const Text('Simpan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ApiUserRow {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String createdAtText;

  _ApiUserRow({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.createdAtText,
  });

  factory _ApiUserRow.fromJson(Map<String, dynamic> json) {
    // created_at dari laravel biasanya ISO string
    final createdAt = (json['created_at'] ?? '').toString();

    // role bisa "role" atau "roles" (tergantung backend kamu)
    final roleVal = (json['role'] ?? json['roles'] ?? '-').toString();

    // nomor telepon kamu pakai "nomor_telfon" (sesuai yg kamu sebut)
    final phoneVal =
        (json['nomor_telfon'] ?? json['phone'] ?? json['no_hp'] ?? '-')
            .toString();

    return _ApiUserRow(
      id: (json['id'] ?? 0) is int
          ? (json['id'] as int)
          : int.tryParse('${json['id']}') ?? 0,
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: phoneVal,
      role: roleVal,
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
